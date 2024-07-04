#include "PLSA660b.ch"	
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"
#include "hat-Actions.ch"

#define CRLF				Chr(13)+Chr(10)
#define  K_NovaVersao  6
#define  K_SubCon      6
/*                                                                             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS660Var ºAutor  ³Geraldo Felix Juniorº Data ³  03/15/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Declaracao das variaveis private... solucao para o erro de  º±±
±±º          ³compilacao "memory overflow".                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Function PLS660Var(cAlias,nReg,nOpc)
PRIVATE lUsaBHF    := .F.
PRIVATE lUsaQtd    := .F.
PRIVATE lUsaBZC	   := .F.
PRIVATE lUsaBZD	   := .F.
PRIVATE oEncBQC
PRIVATE nOpcx      := nOpc
PRIVATE nOpca      := 0
PRIVATE lAltFor    := .F.
PRIVATE lAtivConFin:= .F.
PRIVATE cChave     := BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da enchoice...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE n       := 1
PRIVATE aCols   := {}
PRIVATE aHeader := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Detalhamento da Forma de Cobranca ...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabDet  := {}
PRIVATE aDadDet  := {}

PRIVATE lNewVer  := .F.
PRIVATE aVetsFor := {}
PRIVATE aVetsTxF := {}
PRIVATE aVetsOpc := {}
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forma de Cobranca do Plano ...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabFor  := {}
PRIVATE aDadFor  := {}
PRIVATE aTrbFor  := {}
PRIVATE oBrwFor
PRIVATE oBotPro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forma de Cobranca dos Opcionais...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabFrOpc  := {}
PRIVATE aDadFrOpc  := {}
PRIVATE aTrbFrOpc  := {}
PRIVATE oBrwFrOpc
PRIVATE oBotFrOpc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuarios Permitidos do Plano...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

PRIVATE aCabUsp  := {}
PRIVATE aDadUsp  := {}
PRIVATE aTrbUsp  := {}
PRIVATE oBrwUsp
PRIVATE oBrwUso

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis para controle de Forma de Cobranca ...             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aSTela  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define folders...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oFolder
PRIVATE oDlgFolder
PRIVATE oFolPro
PRIVATE cCadastro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis do contrato selecionado...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oSay01
PRIVATE oPla
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cobranca de Idetnificacao de Usuario                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBJC  := {}
PRIVATE aDadBJC  := {}
PRIVATE aTrbBJC  := {}
PRIVATE oBrwBJC

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cobranca de Idetnificacao de Usuario                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBCO  := {}
PRIVATE aDadBCO  := {}
PRIVATE aTrbBCO  := {}
PRIVATE oBrwBCO
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Financeiro por contrato...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabFin  := {}
PRIVATE aDadFin  := {}
PRIVATE aTrbFin  := {}
PRIVATE oBrwFin
PRIVATE lFinanc   := ( nOpc <> K_Incluir .And. BG9->BG9_TIPO == "2" )
PRIVATE cInd
PRIVATE cFor
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de Debitos...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabDeb := {}
PRIVATE aDadDeb := {}
PRIVATE aTrbDeb := {}
PRIVATE oBrwDeb
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratamento de Valores de Adesao...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabAde := {}
PRIVATE aDadAde := {}
PRIVATE aTrbAde := {}
PRIVATE oBrwAde
PRIVATE oBotAde
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produtos relacionados aos contratos...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPro  := {}
PRIVATE aDadPro  := {}
PRIVATE aTrbPro  := {}
PRIVATE oBrwPro
PRIVATE oChkPro
PRIVATE cCodNumCon := ""
PRIVATE cCodVerCon := ""
PRIVATE cCodNumSubCon := ""
PRIVATE cCodVerSubCon := ""
PRIVATE cCodProSel := ""
PRIVATE cVersaoSel := ""
PRIVATE cDesProSel := ""
PRIVATE cCodOpcSel := ""
PRIVATE cVerOpcSel := ""
PRIVATE cCodForSel := ""
PRIVATE cCodAliSel := ""


PRIVATE cAllUsr    := ""
PRIVATE cOPCCID    := ""
PRIVATE cOPCESP    := ""
PRIVATE aButtons   := { {"POSCLI",{|| PLS600ALC() },STR0001,STR0002}  } //"Alterar Cliente do Subcontrato"###"Cliente"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Co-Participacao                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCPro := {}
PRIVATE aDadCPro := {}
PRIVATE aTrbCPro := {}
PRIVATE oBrwCPro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Situacoes Adversas...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabSAD := {}
PRIVATE aDadSAD := {}
PRIVATE aTrbSAD := {}
PRIVATE oBrwSAD
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Regras novos dependentes...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBEY := {}
PRIVATE aDadBEY := {}
PRIVATE aTrbBEY := {}
PRIVATE oBrwBEY
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Classe de Carencia                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBA6 := {}
PRIVATE aDadBA6 := {}
PRIVATE aTrbBA6 := {}
PRIVATE oBrwBA6
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Tipo Prestador                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cTipPre := ""
PRIVATE cDesPre := ""
PRIVATE aCabBGP := {}
PRIVATE aDadBGP := {}
PRIVATE aTrbBGP := {}
PRIVATE oBrwBGP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Municipio Atendimento                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCodMun := ""
PRIVATE aCabBGG := {}
PRIVATE aDadBGG := {}
PRIVATE aTrbBGG := {}
PRIVATE oBrwBGG
PRIVATE oBotBGL
PRIVATE oBrwBGL
PRIVATE aCabBGL := {}
PRIVATE aDadBGL := {}
PRIVATE aTrbBGL := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SUB X PROD X FAT. MULT. REEMB                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCodCla := ""
PRIVATE aCabB33 := {}
PRIVATE aDadB33 := {}
PRIVATE aTrbB33 := {}
PRIVATE aVetB33 := {}
PRIVATE oBrwB33
PRIVATE cCodSeqB33:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VIG SUB XPROD X FAT MULT REEMB                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBotB34
PRIVATE oBrwB34
PRIVATE aCabB34 := {}
PRIVATE aDadB34 := {}
PRIVATE aTrbB34 := {}
PRIVATE aVetB34 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Tipo Prestador x CO-Participacao                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwBGS
PRIVATE aCabBGS := {}
PRIVATE aDadBGS := {}
PRIVATE aTrbBGS := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Cobranca x Co-Participacao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCobCP := {}
PRIVATE aDadCobCP := {}
PRIVATE aTrbCobCP := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Produto x Opcionais                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabOpc := {}
PRIVATE aDadOpc := {}
PRIVATE aTrbOpc := {}
PRIVATE oBrwOpc
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Coberturas...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabGru := {}
PRIVATE aDadGru := {}
PRIVATE aTrbGru := {}
PRIVATE oBrwGru

PRIVATE cCodGru  := ""
PRIVATE cCodGQuan:= ""
PRIVATE cCodGruCob := ""
PRIVATE cDesGruCob := ""
PRIVATE oBotGru

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Quantidades... Geraldo Felix Junior 15/03/03               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabQtd := {}
PRIVATE aDadQtd := {}
PRIVATE aTrbQtd := {}

PRIVATE cCodGruQtd := ""
PRIVATE cDesGruQtd := ""
PRIVATE cCodProQtd := ""

PRIVATE oBrwQtd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Co-Participacao do Grupo de Quantidades... Geraldo Felix Junior 15/03/03       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCQtd := {}
PRIVATE aDadCQtd := {}
PRIVATE aTrbCQtd := {}
PRIVATE oBrwCQtd
PRIVATE oBotQtd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo de Coberturas...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCla := {}
PRIVATE aDadCla := {}
PRIVATE aTrbCla := {}
PRIVATE oBrwCla
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo Coberturas x Co-Participacao                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCGru := {}
PRIVATE aDadCGru := {}
PRIVATE aTrbCGru := {}
PRIVATE oBrwCGru
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupo Coberturas x Classe de Carencia                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabClaCar := {}
PRIVATE aDadClaCar := {}
PRIVATE aTrbClaCar := {}
PRIVATE oBrwClaCar

PRIVATE oBotCar
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPPg := {}
PRIVATE aDadPPg := {}
PRIVATE aTrbPPg := {}
PRIVATE oBrwPPg
PRIVATE cTipPreSel := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBML := {}
PRIVATE aDadBML := {}
PRIVATE aTrbBML := {}
PRIVATE oBrwBML
PRIVATE cCodEspSel := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados da diferenciacao do filme...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBG6 := {}
PRIVATE aDadBG6 := {}
PRIVATE aTrbBG6 := {}
PRIVATE oBrwBG6
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados Informacoes ANS...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBYU := {}
PRIVATE aDadBYU := {}
PRIVATE aTrbBYU := {}
PRIVATE oBrwBYU

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados Informacoes ANS...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBDV := {}
PRIVATE aDadBDV := {}
PRIVATE aTrbBDV := {}
PRIVATE oBrwBDV
PRIVATE nPosFldBDV := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBKA := {}
PRIVATE aDadBKA := {}
PRIVATE aTrbBKA := {}
PRIVATE oBrwBKA
PRIVATE cCodOpeSel := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento x Procedimentos...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBKB := {}
PRIVATE aDadBKB := {}
PRIVATE aTrbBKB := {}
PRIVATE oBrwBKB
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento x Procedimentos...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPPP := {}
PRIVATE aDadPPP := {}
PRIVATE aTrbPPP := {}
PRIVATE oBrwPPP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento x Procedimentos...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabBMM := {}
PRIVATE aDadBMM := {}
PRIVATE aTrbBMM := {}
PRIVATE oBrwBMM
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento Especifoco Prestador...           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPPgPre := {}
PRIVATE aDadPPgPre := {}
PRIVATE aTrbPPgPre := {}
PRIVATE oBrwPPgPre
PRIVATE cTipRDASel := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados dos Parametros Pagamento x Procedimentos X Especifico Pres ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabPPPPre := {}
PRIVATE aDadPPPPre := {}
PRIVATE aTrbPPPPre := {}
PRIVATE oBrwPPPPre
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coberturas...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabCob := {}
PRIVATE aDadCob := {}
PRIVATE aTrbCob := {}
PRIVATE oBrwCob
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Co Participacao..		.                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwCCo    := {}
PRIVATE aDadCCo    := {}
PRIVATE aCabCCo    := {}
PRIVATE aTrbCCo    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SubContrato X Procec X CID...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwBLU    := {}
PRIVATE aDadBLU    := {}
PRIVATE aCabBLU    := {}
PRIVATE aTrbBLU    := {}
PRIVATE cCID       := ""
PRIVATE cSeqSel    := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Subcontrato X Proc X CID X Co-Part...								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwBLW    := {}
PRIVATE aDadBLW    := {}
PRIVATE aCabBLW    := {}
PRIVATE aTrbBLW    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CoPart.xSubcontratoxProcxEspec...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwBLT    := {}
PRIVATE aDadBLT    := {}
PRIVATE aCabBLT    := {}
PRIVATE aTrbBLT    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SubcontratoXProcXEspecXCo-Part...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwBLX    := {}
PRIVATE aDadBLX    := {}
PRIVATE aCabBLX    := {}
PRIVATE aTrbBLX    := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo Acomodacao Sub-Contrato...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwPc    := {}
PRIVATE aDadPc    := {}
PRIVATE aCabPc    := {}
PRIVATE aTrbPc    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados da regra de reajuste...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabB77 := {}
PRIVATE aDadB77 := {}
PRIVATE aTrbB77 := {}
PRIVATE oBrwB77
PRIVATE nPosFldB77 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ GetDados da regra de parcelamento...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabB81 := {}
PRIVATE aDadB81 := {}
PRIVATE aTrbB81 := {}
PRIVATE oBrwB81
PRIVATE nPosFldB81 := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dados do browse...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oBrwBWV    := {}
PRIVATE aDadBWV    := {}
PRIVATE aCabBWV    := {}
PRIVATE aTrbBWV    := {}

PRIVATE oBotCob
PRIVATE oBotCobOpc
PRIVATE cCodPadOpc:= ""
PRIVATE cCodPsaOpc:= ""
PRIVATE cNivelOpc := ""
PRIVATE cCodPad   := ""
PRIVATE cCodPsa   := ""
PRIVATE cDesPsa   := ""
PRIVATE cNivelPro := ""
PRIVATE cCodNiv01 := ""
PRIVATE cCodNiv02 := ""
PRIVATE cCodNiv03 := ""
PRIVATE cCodNiv04 := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coberturas x Co-Participacao                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabEsp  := {}
PRIVATE aDadEsp  := {}
PRIVATE aTrbEsp  := {}
PRIVATE oBrwEsp
PRIVATE cSeqPart := ""          
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Versoes Contratos ...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabVer  := {}
PRIVATE aDadVer  := {}
PRIVATE aTrbVer  := {}
PRIVATE oBrwVer
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Contratos dos grupos...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cSubCon    := BQC->BQC_SUBCON
PRIVATE cChavSub
PRIVATE cCodSeqBEY := ""

PRIVATE cPlsVersao := "001"
PRIVATE nRecBQD
PRIVATE cVerEsc    := ""
PRIVATE lSalv      := .T.

PRIVATE oBrwBTN
PRIVATE nOrdBQC
PRIVATE nRecBQC
PRIVATE nRegOld := nReg
PRIVATE nScan
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de lock de registro...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lLock   := .F.
PRIVATE aCabBZC := {}
PRIVATE aDadBZC := {}
PRIVATE aVetBZC := {}
PRIVATE aCabBZD := {}
PRIVATE aDadBZD := {}
PRIVATE aVetBZD := {}
PRIVATE aCabBZE := {}
PRIVATE aDadBZE := {}
PRIVATE aVetBZE := {}
PRIVATE aCabBZF := {}
PRIVATE aDadBZF := {}
PRIVATE aVetBZF := {}
PRIVATE aCabBZG := {}
PRIVATE aDadBZG := {}
PRIVATE aVetBZG := {}
PRIVATE aCabBZL := {}
PRIVATE aDadBZL := {}
PRIVATE aVetBZL := {}
PRIVATE aCabBZM := {}
PRIVATE aDadBZM := {}
PRIVATE aVetBZM := {}
PRIVATE aCabBZH := {}
PRIVATE aDadBZH := {}
PRIVATE aVetBZH := {}
PRIVATE aCabBZJ := {}
PRIVATE aDadBZJ := {}
PRIVATE aVetBZJ := {}
PRIVATE aCabBZK := {}
PRIVATE aDadBZK := {}
PRIVATE aVetBZK := {}
PRIVATE aCabBZI := {}
PRIVATE aDadBZI := {}
PRIVATE aVetBZI := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rede Referenciada...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabRDF := {}
PRIVATE aDadRDF := {}
PRIVATE aTrbRDF := {}
PRIVATE oBrwRDF
PRIVATE oChkRDF
PRIVATE lChkRDF := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Operadora de atendimento...											³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCabOPE := {}
PRIVATE aDadOPE := {}
PRIVATE aTrbOPE := {}

PRIVATE oGetBZL
PRIVATE oGetBZM
PRIVATE oSubFol01
PRIVATE oSubFol02
PRIVATE oSubFol03     


PRIVATE _l660Err := .T.
                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define se Passou pela Atualizacao de Faixas e Descontos.				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lOkFxDes := .F.
PRIVATE aCodProA := {}
Private nHS	:= 0


If ExistBlock("PL660VAR")
	If !ExecBlock("PL660VAR",.F.,.F.,{nOpc})
		Return
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¨¿
//³Tratamento para que nos casos em que a BG9/BT5/BQC estão exclusivas e na BQC não há nenhum subcontrato incluso o sistema esta se perdendo no ponteiro da BG9³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¨Ù
If BG9->(EOF())
	BG9->(DbSeek(BT5->(BT5_FILIAL+BT5_CODINT+BT5_CODIGO)))
Endif

Return(PLS660ConS(cAlias,nReg,nOpc))
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS660ConS ³ Autor ³ Michele Tatagiba   ³ Data ³ 03.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de Manutencao dos Contratos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLS660ConS(cAlias,nReg,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA660                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³16/03/03  |      |Geraldo Jr.  | Desmembramento da funcao para        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁ solucionar o problema "memory overflow"±
±±³ ocorrido na compilacao. A cconstrucao das "GetDados" paasam a ser    ³±±
±±³ feitas em uma outra funcao.                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660ConS(cAlias,nReg,nOpc)
Local I__f := 0
Local nI,nCont
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da EnchoiceBar...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL bOK     	:= {|| nOpca := 1,If( PLS660SOOK(nOpc,BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO),M->BQC_SUBCON), ;
oDlgFolder:End(),nOpca:=2),If(nOpca==1,oDlgFolder:End(),.F.) }
LOCAL bCancel	:= {|| If(MsgYesNo(__cMsgAban),(nOpca := 0, oDlgFolder:End()),.F.) }
LOCAL nCnt 	    := 0
Local aAreaBXR	:= BXR->(GetArea())
LOCAL aSize 	:= {}
LOCAL aInfo 	:= {}
LOCAL aObjects 	:= {}   
LOCAL aPosObj 	:= {}
LOCAL aInfo2 	:= {}
LOCAL aObjects2 := {}     
LOCAL aPosObj2 	:= {}
LOCAL aInfo3 	:= {}
LOCAL aObjects3 := {}     
LOCAL aPosObj3 	:= {}
LOCAL aInfo4 	:= {}
LOCAL aObjects4 := {}     
LOCAL aPosObj4 	:= {}
LOCAL aInfo6 	:= {}
LOCAL aObjects6 := {}         
LOCAL aPosObj6 	:= {}
Local aTitles 	:= {}
Local aPages 	:= {}
Local  lAtuSubC  := GetNewPar("MV_PATUSUB",.F.) //Define se o sistema ira exibir a perguntar se deseja replicar para o sub-contrato as alteracoes das faixas ou descontos.
Local cTitulo	:= ""



If ExistBlock("PLS660MN")
   If !(Execblock("PLS660MN",.F.,.F.,{nOpc, If(Empty(BQC->BQC_CODBLO),"0","1")}))
       Return(.F.)
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera filtros do mBrowse...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BQC->(DbClearFilter())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de versao dos Contratos ...                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdBQC := BQC->(IndexOrd())
nRecBQC := BQC->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o contrato estiver bloqueado nao sera possivel alterar nenhum dado do mesmo... |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # K_Incluir .And. !Empty(BQC->BQC_DATBLO)
	If Aviso(STR0003,STR0004,; //"Bloqueado!"###"Este sub-contrato encontra-se bloqueado, o registro somente podera ser visualizado."
		{STR0005,STR0006}) == 1 //"Continuar"###"Sair"
		
		nOpc := K_Visualizar
		altera := .F.
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Refaz filtro para mBrowse...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("BQC")
		SET FILTER TO &cFiltro
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Contrato Selecionado ...                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> K_Incluir
			BQC->(DbGoTo(nRegOld))
		Endif
		
		Return()
	Endif
Endif

If     nOpc == K_Incluir
	cPLSVersao := "001"
	cCadastro  := cTitulo + STR0007 //" - Novo Sub-Contrato"
ElseIf nOpc == K_NovaVersao
	lNewVer := .T.
	BQC->(DbSetOrder(1))
	BQC->(MsSeek(xFilial("BQC")+cChave+cSubCon+"999",.T.))
	BQC->(DbSkip(-1))
	cPLSVersao := StrZero(Val(BQC->BQC_VERSUB)+1,3)
	BQC->(DbSetOrder(nOrdBQC))
	BQC->(DbGoTo(nRecBQC))
	cCadastro  :=  cTitulo + STR0008 //" - Novo Versao do Sub-Contrato"
ElseIf nOpc == K_Visualizar .Or. nOpc == K_Alterar .Or. nOpc == K_Excluir
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle de versao do plano. Exibir as versoes existentes...        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCadastro  :=  cTitulo + OemtoAnsi(STR0196)
	cVerEsc := ""
	BQC->(DBGoTop())
	BQC->(DbSetOrder(1))
	BQC->(MsSeek(xFilial("BQC")+cChave+cSubCon+"001"))
	BQC->(DbSkip())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VERSOES...                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Store Header "BQD" TO aCabVer For .T.
	BQD->(DbSetOrder(1))
	If BQD->(MsSeek(xFilial("BQD")+cChave+cSubCon+"001"))
		Store COLS "BQD" TO aDadVer FROM aCabVer VETTRAB aTrbVer While cChave+cSubCon == BQD->(BQD_CODIGO+BQD_NUMCON+BQD_VERCON+BQD_SUBCON)
	Else
		If lLock
			BQD->(MsUnLock())
		Endif
		
		Help("",1,"PLS660VE2")
		
		DbSelectArea("BQC")
		SET FILTER TO &cFiltro
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Contrato Selecionado ...                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> K_Incluir
			BQC->(DbGoTo(nRegOld))
		Endif

		Return
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define dialogo...                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aDadVer) > 1
		DEFINE MSDIALOG oDlgFolder TITLE STR0009 FROM 008.2,010.3 TO 22,56 OF GetWndDefault() //"Versao do Sub-contrato" 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TPLSBRW -> VERSOES                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		oBrwVer := TPLSBrw():New(038,006,175,95,nil  ,oDlgFolder,nil    , {|| nOpca := 1,cVerEsc := oBrwVer:FieldGet("BQD_VERSUB"), oDlgFolder:End() }  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabVer,aDadVer,.T.,"BQD",K_Visualizar,STR0010 ,{{"BQD_DATFIN","=",ctod("")}}) //"Versoes do Sub-contrato"
		oBrwVer:AVETTRAB := Aclone(aTrbVer)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ativa o dialogo...                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,{|| nOpca := 1,cVerEsc := oBrwVer:FieldGet("BQD_VERSUB"), oDlgFolder:End()},{|| nOpca := 2,oDlgFolder:End()})
	Else
		nOpca   := K_OK
		cVerEsc := aDadVer[1,PLRETPOS("BQD_VERSUB",aCabVer)]
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ testa se confirmou alguma versao...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca <> K_OK
		If lLock
			BQC->(MsUnLock())
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Refaz filtro para mBrowse...                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("BQC")
		SET FILTER TO &cFiltro
		Return
	Endif
	
	BQD->(DbSetOrder(1))
	BQD->(MsSeek(xFilial("BQD")+cChave+cSubCon+cVerEsc))
	
	BQC->(DbSetOrder(1))
	BQC->(MsSeek(xFilial("BQC")+cChave+cSubCon+cVerEsc))
	nRecBQD := BQD->(Recno())
Endif

If nOpcx == K_Alterar
	cCadastro  := cTitulo + STR0011 //" - Alteracao do Sub-contrato "
Elseif nOpcx == K_Excluir
	cCadastro  := cTitulo + STR0012 //" - Exclusao do Sub-contrato"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se registro esta disponivel...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Alterar .Or. nOpcx == K_Excluir
	If ! BQC->(RecLock("BQC",.F.))
		DbSelectArea("BQC")
		SET FILTER TO &cFiltro
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no Contrato Selecionado ...                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOpc <> K_Incluir
			BQC->(DbGoTo(nRegOld))
		Endif
		Return
	Else
		lLock := .T.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta M->??? para enchoice...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_Incluir
	Copy cAlias To Memory Blank
Else
	Copy cAlias TO MEMORY
	cChavSub := cChave+BQC->(BQC_SUBCON+BQC_VERSUB)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetEnch("")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aObjects := {}   
AAdd( aObjects, { 100, 20, .t., .f. } )    
AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
aPosObj := MsObjSize( aInfo, aObjects )     

aInfo2 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects2 := {}     
AAdd( aObjects2, { 100, 1, .t., .f. } )        
AAdd( aObjects2, { 100, 50, .t., .t.,.t. } )
AAdd( aObjects2, { 100, 50, .t., .t.,.t. } )
aPosObj2 := MsObjSize( aInfo2, aObjects2 )     

aInfo3 := { 0, 0, aPosObj2[3,3], aPosObj2[3,4], 3, 3 }
aObjects3 := {}     
AAdd( aObjects3, { 100, 80, .t., .t. } )  
AAdd( aObjects3, { 100, 80, .t., .t. } )
aPosObj3 := MsObjSize( aInfo3, aObjects3 )     

aInfo4 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects4 := {}     
AAdd( aObjects4, { 100, 1, .t., .f. } )    
AAdd( aObjects4, { 100, 100, .t., .t.,.f. } )
aPosObj4 := MsObjSize( aInfo4, aObjects4 )     

aInfo6 := { 0, 0, aPosObj2[3,3], aPosObj2[3,4], 3, 3 }
aObjects6 := {}         
AAdd( aObjects6, { 100, 100, .t., .t.,.t. } )
aPosObj6 := MsObjSize( aInfo6, aObjects6 )     
                                                                  	
DEFINE MSDIALOG oDlgFolder TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel

aTitles := {}
aPages  := {}
If ! lFinanc
	aTitles := {STR0013,; //"Sub-contratos "
				STR0014,; //"Versoes"
				STR0015,; //"Produtos"
				STR0017,; //"Cobranca de Identificacao do Usuario"
				STR0018,; //"Doc. Obrigat. Usuarios"
				STR0019,; //"Parametro Pagamento Tipo Prestador"
				STR0020,; //"Parametro Pagamento Prestador"
				STR0021,; //"Parametro Pagamento Especialidade"
				STR0022,; //"Historico Financeiro"
				STR0023,; //"Parametro Pagamento Operadora"
				STR0024,; //"Diferenciacao do Valor do Filme"
				STR0124} //"Informacoes ANS"
Else
	aTitles := {STR0013,; //"Sub-contratos "
				STR0014,; //"Versoes"
				STR0015,; //"Produtos"
				STR0017,; //"Cobranca de Identificacao do Usuario"
				STR0018,; //"Doc. Obrigat. Usuarios"
				STR0019,; //"Parametro Pagamento Tipo Prestador"
				STR0020,; //"Parametro Pagamento Prestador"
				STR0021,; //"Parametro Pagamento Especialidade"
				STR0022,; //"Historico Financeiro"
			    STR0023,; //"Parametro Pagamento Operadora"
			  	STR0024,; //"Diferenciacao do Valor do Filme"
			  	STR0124} //"Informacoes ANS"
Endif
              
// Adiciona folder de regra de reajuste.
If PLSALIASEX("B77")
	Aadd(aTitles, "Regra de reajuste")
	nPosFldB77 := Len(aTitles)
Endif

// Adiciona folder de regra de parcelamento.
If PLSALIASEX("B81")
	Aadd(aTitles, "Regra de parcelamento")
	nPosFldB81 := Len(aTitles)
Endif

// Adiciona folder Proteção Financeira.
If PLSALIASEX("BDV")
	Aadd(aTitles, "Proteção Financeira")
	nPosFldBDV := Len(aTitles)
Endif

// Alinha aPages com o aTitles.      
For nI := 1 to Len(aTitles)
	Aadd(aPages,"")
Next

// Cria folder da familia.
oFolder := TFolder():New(aPosObj[2][1],aPosObj[2][2],aTitles,aPages,oDlgFolder,,,,.T.,.F.,aPosObj[2][3],aPosObj[2][4])

oFolder:bChange := { |nFolder| A660Chg(nFolder) } 

@ aPosObj2[3][1],aPosObj2[3][2] FOLDER oFolPro SIZE aPosObj2[3][3],aPosObj2[3][4] OF oFolder:aDialogs[3] PIXEL PROMPTS  STR0025,; //"Coberturas"
STR0026,; //"Forma de Cobranca"
STR0027,; //"Taxas de Adesao"
STR0028,; //"Co-participacao"
STR0030,; //"Situacao Adversa"
STR0031,; //"Usuarios Permitidos"
STR0032,; //"Opcionais"
STR0033,; //"Opcionais - Forma Cobranca"
STR0034,; //"Tipo Prestador"
STR0035,; //"Municipio de Atendimento"
STR0036,; //"Rede Referenciada"
"Fatores de Reembolso"                                

oFolPro:bChange := { |nFolder| A660ProChg(nFolder) }

@ aPosObj6[1][1],aPosObj6[1][2] FOLDER FOLDER oFldCob SIZE aPosObj6[1][3],(aPosObj6[1][4] * 0.81) OF oFolPro:aDialogs[1] PIXEL PROMPTS  STR0038,; //"Grupos Determinados"
STR0039,; //"Procedimentos"
STR0040,; //"Grupos de Quantidades"
STR0041,; //"Carencias p/ Novos Usuarios"
STR0043 //"Classe de Carencia"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Mensagem Informativa...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 005, 003 GROUP oGrupoCon TO 022, 155 PIXEL OF oDlgFolder LABEL STR0044  COLOR CLR_HBLUE, CLR_HRED //" Contrato / Versao "
@ 012, 006 Say oSayCon PROMPT BT5->BT5_NUMCON+ " / "+BT5->BT5_VERSAO SIZE 152, 006 OF oDlgFolder PIXEL COLOR CLR_HBLUE
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Zero();oEncBQC := MsMGet():New(cAlias,nReg,nOpc,,,,,{005,005,(aPosObj[2][4]-15),aPosObj[2][3]},,,,,,oFolder:aDialogs[1],,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VERSOES...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Incluir .Or. nOpcx == K_NovaVersao
	Copy "BQD" To Memory BLANK
	M->BQD_VERSAO := cPLSVersao
	M->BQC_VERSUB := cPLSVersao
ElseIf nOpcx <> K_NovaVersao
	Copy "BQD" To Memory
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de versao...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == K_NovaVersao
	M->BQC_VERSAO  := cPLSVersao
	lRefresh       := .T.
	nOpc           := K_Alterar
	nOpcx          := K_Alterar
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TPLSBRW -> VERSOES SUBCONTRATOS                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aTela := {}
aGets := {}
cVar  := "aSTela["+AllTrim(Str(Len(aSTela)+1))+"]"
aadd(aSTela,{})
oEncVer := BQD->(MsMGet():New("BQD",nRecBQD,nOpc,,,,,{005,005,aPosObj[2][4],aPosObj[2][3]},,,,,,oFolder:aDialogs[2],,,.F.,cVar))
aSTela[len(aSTela)] = aClone(aTela)

PLS660C(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle da Forma de Cobranca                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	cOldAlias := cAlias
	n         := 1
	BT9->(DbSetOrder(1))
	If BT9->(MsSeek(xFilial("BT9")+cChavSub))
		While ! BT9->(Eof()) .And. BT9->(BT9_FILIAL+BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB) == xFilial("BT9")+cChavSub
			
			cCodFor  := BT9->(BT9_CODFOR)
			aOpcoes  := A660MOpc(BT9->BT9_CODFOR)
			aDados   := {}
			aCabec   := {}
			
			For nI := 1 To Len(aOpcoes)
				aRecTrab := {}
				cAlias  := aOpcoes[nI,2]
				cTipo   := aOpcoes[nI,3]
				cTit    := aOpcoes[nI,1]
				                        
				
				// Testa se o alias realmente existe no dicionario de dados... se nao existir, ignora.
				If !PLSALIASEX(cAlias)
					MsgAlert("A tabela "+cAlias+" deve ser retirada do cadastro de forma de cobranca porque nao existe no dicionario de dados.")
					Loop
				Endif
				
				DbSelectArea(cAlias)  
				If cAlias =="BTN"
					DbselectArea("SIX")
					If DbSeek("BTN"+"4") 
						DbSelectArea(cAlias)  
						DbSetOrder(4)
					Else                      
						DbSelectArea(cAlias)  
						DbSetOrder(1)
					Endif						
				Else  
					DbSelectArea(cAlias)  					
					DbSetOrder(1)
				Endif					
			
				If cTipo = "1" .Or. "_CODFOR" $ IndexKey()
					MsSeek(xFilial(cAlias)+BT9->(BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO)+cCodFor)
				Else
					MsSeek(xFilial(cAlias)+BT9->(BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO))
				Endif
				
				If Found() .And. cTipo == "0" // Enchoice
					Copy cAlias To Memory
					aCpos   := {}
					aFields := DBSTRUCT()
					For nCont := 1 To Len(aFields)
						cTrab := "M->"+aFields[nCont,1]
						cDado := &cTrab
						aadd(aCpos,{cTrab,cDado})
					Next
					aadd(aVetsFor,{cCodFor,cAlias,cTipo,aCpos,Recno(),;
					BT9->BT9_NUMCON,BT9->BT9_VERCON,BT9->BT9_SUBCON,BT9->BT9_VERSUB,;
					BT9->BT9_CODPRO,BT9->BT9_VERSAO,BT9->(BT9_CODFOR+BT9_CODPRO+BT9_VERSAO)})
				ElseIf cTipo == "1" // GetDados
					_cChave := cAlias+"_CODIGO+"+;
					cAlias+"_NUMCON+"+;
					cAlias+"_VERCON+"+;
					cAlias+"_SUBCON+"+;
					cAlias+"_VERSUB+"+;
					cAlias+"_CODPRO+"+;
					cAlias+"_VERPRO"
					
					STORE HEADER cAlias TO aCabec For .T.
					If Found()
						If "_CODFOR" $ IndexKey()
							_cChave += "+"+cAlias+"_CODFOR"
							Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == BT9->(BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO+BT9_CODFOR)
						Else
							Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == BT9->(BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO)
						Endif
					Else
						aDados := {}
					Endif                                            					
					// Trata a matriz, para alimentar o codigo do produto corretamente.
					If Len(aDados) > 0
						For nCnt := 1 To Len(aDados)
							aDados[n][PLRETPOS(cAlias+"_CODPRO",aCabec)] := BT9->BT9_CODPRO
							aDados[n][PLRETPOS(cAlias+"_VERPRO",aCabec)] := BT9->BT9_VERSAO
						Next
					Endif
					aadd(aVetsFor,{cCodFor,cAlias,cTipo,aDados,aRecTrab,;
					BT9->BT9_NUMCON,BT9->BT9_VERCON,BT9->BT9_SUBCON,BT9->BT9_VERSUB,;
					BT9->BT9_CODPRO,BT9->BT9_VERSAO,BT9->(BT9_CODFOR+BT9_CODPRO+BT9_VERSAO)})
				Endif
			Next
			BT9->(DbSkip())
		Enddo
	Endif
	cAlias := cOldAlias
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle da Forma de Cobranca da Taxa de Adesao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	cOldAlias := cAlias
	n         := 1
	BTK->(DbSetOrder(1))
	If BTK->(MsSeek(xFilial("BTK")+cChavSub))
		While ! BTK->(Eof()) .And. BTK->(BTK_FILIAL+BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB) == xFilial("BTK")+cChavSub
			
			cCodFor  := BTK->(BTK_CODFOR)
			aOpcoes  := A660MOpc(BTK->BTK_CODFOR)
			aDados   := {}
			aCabec   := {}
			
			For nI := 1 To Len(aOpcoes)
				aRecTrab := {}
				cAlias  := aOpcoes[nI,2]
				cTipo   := aOpcoes[nI,3]
				cTit    := aOpcoes[nI,1]
				                 
				// Testa se o alias realmente existe no dicionario de dados... se nao existir, ignora.
				If !PLSALIASEX(cAlias)
					MsgAlert("A tabela "+cAlias+" deve ser retirada do cadastro de forma de cobranca porque nao existe no dicionario de dados.")
					Loop
				Endif
				
				DbSelectArea(cAlias)
				DbSetOrder(1)
				If cTipo = "1" .Or. "_CODFOR" $ IndexKey()
					MsSeek(xFilial(cAlias)+BTK->(BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB+BTK_CODPRO+BTK_VERSAO)+cCodFor)
				Else
					MsSeek(xFilial(cAlias)+BTK->(BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB+BTK_CODPRO+BTK_VERSAO))
				Endif
				If Found() .And. cTipo == "0" // Enchoice
					Copy cAlias To Memory
					aCpos   := {}
					aFields := DBSTRUCT()
					For nCont := 1 To Len(aFields)
						cTrab := "M->"+aFields[nCont,1]
						cDado := &cTrab
						aadd(aCpos,{cTrab,cDado})
					Next
					aadd(aVetsTxF,{cCodFor,cAlias,cTipo,aCpos,Recno(),;
					BTK->BTK_NUMCON,BTK->BTK_VERCON,BTK->BTK_SUBCON,BTK->BTK_VERSUB,;
					BTK->BTK_CODPRO,BTK->BTK_VERSAO,BTK->(BTK_CODFOR+BTK_CODPRO+BTK_VERSAO)})
				ElseIf cTipo == "1" // GetDados
					_cChave := cAlias+"_CODIGO+"+;
					cAlias+"_NUMCON+"+;
					cAlias+"_VERCON+"+;
					cAlias+"_SUBCON+"+;
					cAlias+"_VERSUB+"+;
					cAlias+"_CODPRO+"+;
					cAlias+"_VERPRO+"+;
					cAlias+"_CODFOR"
					
					STORE HEADER cAlias TO aCabec For .T.
					If Found()
						Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == BTK->(BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB+BTK_CODPRO+BTK_VERSAO+BTK_CODFOR)
					Else
						aDados := {}
					Endif
					// Trata a matriz, para alimentar o codigo do opcional corretamente.
					If Len(aDados) > 0
						For nCnt := 1 To Len(aDados)
							aDados[n][PLRETPOS(cAlias+"_CODPRO",aCabec)] := BTK->BTK_CODPRO
							aDados[n][PLRETPOS(cAlias+"_VERPRO",aCabec)] := BTK->BTK_VERSAO
						Next
					Endif
					aadd(aVetsTxF,{cCodFor,cAlias,cTipo,aDados,aRecTrab,;
					BTK->BTK_NUMCON,BTK->BTK_VERCON,BTK->BTK_SUBCON,BTK->BTK_VERSUB,;
					BTK->BTK_CODPRO,BTK->BTK_VERSAO,BTK->(BTK_CODFOR+BTK_CODPRO+BTK_VERSAO)})
				Endif
			Next
			BTK->(DbSkip())
		Enddo
	Endif
	cAlias := cOldAlias
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle da Forma de Cobranca do Opcional                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	cOldAlias 	:= cAlias
	n         	:= 1
	BJW->(DbSetOrder(1))
	If BJW->(MsSeek(xFilial("BJW")+cChavSub))
		While ! BJW->(Eof()) .And. BJW->(BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB) == xFilial("BJW")+cChavSub
			
			cCodFor  := BJW->(BJW_CODFOR)
			aOpcoes  := A660MOpc(BJW->BJW_CODFOR)
			aDados   := {}
			aCabec   := {}
			
			For nI := 1 To Len(aOpcoes)
				aRecTrab := {}
				cAlias   := aOpcoes[nI,2]
				cTipo    := aOpcoes[nI,3]
				cTit     := aOpcoes[nI,1]
				
				// Testa se o alias realmente existe no dicionario de dados... se nao existir, ignora.
				If !PLSALIASEX(cAlias)
					MsgAlert("A tabela "+cAlias+" deve ser retirada do cadastro de forma de cobranca porque nao existe no dicionario de dados.")
					Loop
				Endif
								
				DbSelectArea(cAlias)
				DbSetOrder(1)
				If cTipo = "1" .Or. "_CODFOR" $ IndexKey()
					MsSeek(xFilial(cAlias)+BJW->(BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC)+cCodFor)
				Else
					MsSeek(xFilial(cAlias)+BJW->(BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC))
				Endif
				
				If Found() .And. cTipo == "0" // Enchoice
					Copy cAlias To Memory
					aCpos   := {}
					aFields := DBSTRUCT()
					For nCont := 1 To Len(aFields)
						cTrab := "M->"+aFields[nCont,1]
						cDado := &cTrab
						aadd(aCpos,{cTrab,cDado})
					Next
					aadd(aVetsOpc,{cCodFor,cAlias,cTipo,aCpos,Recno(),;
					BJW->BJW_NUMCON,BJW->BJW_VERCON,BJW->BJW_SUBCON,BJW->BJW_VERSUB,;
					BJW->BJW_CODPRO,BJW->BJW_VERSAO,BJW->(BJW_CODFOR+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC)})
				ElseIf cTipo == "1" // GetDados      
					_cChave := cAlias+"_CODIGO+"+;
					cAlias+"_NUMCON+"+;
					cAlias+"_VERCON+"+;
					cAlias+"_SUBCON+"+;
					cAlias+"_VERSUB+"+;
					cAlias+"_CODPRO+"+;
					cAlias+"_VERPRO+"+;
					cAlias+"_CODOPC+"+;
					cAlias+"_VEROPC+"+;
					cAlias+"_CODFOR"
					STORE HEADER cAlias TO aCabec For .T.
					
					If Found()
						Store COLS cAlias TO aDados FROM aCabec VETTRAB aRecTrab While &_cChave == BJW->(BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC)+cCodFor
					Else
						aDados := {}
					Endif
					
					// Trata a matriz, para alimentar o codigo do opcional corretamente.
					If Len(aDados) > 0
						For nCnt := 1 To Len(aDados)
							aDados[n][PLRETPOS(cAlias+"_CODOPC",aCabec)] := BJW->BJW_CODOPC
							aDados[n][PLRETPOS(cAlias+"_VEROPC",aCabec)] := BJW->BJW_VEROPC
						Next
					Endif
						
					aadd(aVetsOpc,{cCodFor,cAlias,cTipo,aDados,aRecTrab,;
					BJW->BJW_NUMCON,BJW->BJW_VERCON,BJW->BJW_SUBCON,BJW->BJW_VERSUB,;
					BJW->BJW_CODPRO,BJW->BJW_VERSAO,BJW->(BJW_CODFOR+BJW_CODPRO+BJW_VERSAO+BJW_CODOPC+BJW_VEROPC)})
				Endif
			Next
			BJW->(DbSkip())
		Enddo
	Endif
	cAlias := cOldAlias
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada PL660SBUT inclui novos botoes na rotina            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If ExistBlock( "PL660SBUT" ) 
	If ValType( aUsButtons := ExecBlock( "PL660SBUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButtons, x ) } ) 	 	
	EndIf 	
EndIf 	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgFolder ON INIT EnchoiceBar(oDlgFolder,bOK,bCancel,.F.,aButtons)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata atualizacao dos dados...                                      |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK .and. nOpc <> K_Visualizar
	GravaSub(nOpc,lLock)
	If (!Empty(M->(BQC_CODINT+BQC_CODEMP+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)) .Or. !Empty(aCodProA)) .And. lOkFxDes .And. lAtuSubC
		PLSA660CHK(M->BQC_CODINT,M->BQC_CODEMP,M->BQC_NUMCON,M->BQC_VERCON,M->BQC_SUBCON,M->BQC_VERSUB)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refaz filtro para mBrowse...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("BQC")
SET FILTER TO &cFiltro
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Contrato Selecionado ...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc <> K_Incluir
	BQC->(DbGoTo(nRegOld))
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaBXR)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS660SOOK ³ Autor ³ Michele Tatagiba    ³ Data ³ 12.07.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica processo de atualizacao...                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Altera‡„o                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Tulio Cesar ³18.01.03³V 7.10³  Nao pertimir mais de 1 contrato de      ³±±
±±³            ³        ³      ³  intercambio eventual seja incluido...   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660SOOK(nOpc,cChave,cSubCon)
Local lRet    := Eval( { || Obrigatorio(oEncBQC:aGets,oEncBQC:aTela) .And. PLS660SVer() .And. PLSA660Pro() })
Local nOrdBQC := BQC->(IndexOrd())
Local cSQL	:= ""
Local lFam	:= .T.	
Local nInd	:= 0

If lRet
	If nOpc == K_Incluir
		lRet := MsgYesNo(STR0045) //"Confirma a inclusao do Sub-contrato?"
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Dia de Vencimento e Codcli de acordo com Nivel...        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
			if M->BQC_COBNIV == "1"
				if ! Empty(M->BQC_CODCLI) .or. ! Empty(M->BQC_CODFOR)
					if M->BQC_VENCTO == 0
						lRet := .F.
						Help("",1,"PL660DVEN")
					Endif
				Else
					lRet := .F.
					Help("",1,"PL660CLOBR")
				Endif                            
			Endif
		Endif
		
		If lRet
			BQC->(DbSetOrder(1))
			If BQC->(MsSeek(xFilial("BQC")+cChave+cSubCon))
				Help("",1,"JAGRAVADO")
				lRet := .F.
			Else
				nHS := PLSAbreSem("PLSA660S.SMF")
			Endif
		Endif
		BQC->(DbSetOrder(nOrdBQC))
		
	Elseif nOpc == K_Alterar
		if M->BQC_COBNIV == "1"
			if ! Empty(M->BQC_CODCLI) .or. ! Empty(M->BQC_CODFOR)
				if M->BQC_VENCTO == 0
					lRet := .F.
					Help("",1,"PL660DVEN")
				Endif
			Else
				lRet := .F.
				Help("",1,"PL660CLOBR")
			Endif                            
		Else   
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifico se existe o indice (tratamento durante a versao)		    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SIX->(DbSetOrder(1)) 
			If SIX->(MsSeek("BA39"))
				BA3->(DbSetOrder(9))                                             
				lFam := ( BA3->(MsSeek(xFilial("BA3")+M->BQC_CODIGO+M->BQC_NUMCON+M->BQC_VERCON+M->BQC_SUBCON+M->BQC_VERSUB+" ")) .And. Empty(BA3->BA3_MOTBLO) ) ;
				        .OR. ( BA3->(MsSeek(xFilial("BA3")+M->BQC_CODIGO+M->BQC_NUMCON+M->BQC_VERCON+M->BQC_SUBCON+M->BQC_VERSUB+"0")) .And. Empty(BA3->BA3_MOTBLO) )
			Endif 			                                                       
			If BT5->BT5_COBNIV <> '1' .and. Empty(BG9->BG9_CODCLI) .and. lFam
				MsgAlert(STR0046+; //"Nao existe nivel de cobranca valido para este sub contrato. "
				STR0047) //"Primeiro parametrize um nivel de cobranca ou no contrato ou no grupo empresa, ou informe nivel de cobranca para todas as familias deste subcontrato."
				lRet := .F.                                       
			Endif	
		Endif
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a cobranca da Co-Participacao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
/*If lRet .And. Empty(M->BQC_CODVEN) .And. ! Empty(M->BQC_EQUIPE)
	ApMsgAlert(STR0048, STR0049) //"Preencher o vendedor é obrigatório pois a equipe de vendas foi informada !"###"Atencao"
	lRet := .F.
Endif
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ BOPS 114534 - Permite confirmar ou nao a operacao executada pelo usuario. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. ExistBlock("PL660OPE")
	lRet := ExecBlock("PL660OPE",.F.,.F.,{nOpc})
EndIf

If !lRet .And. nOpcx == K_Incluir
   PLSFechaSem(nHS,"PLSA660S.SMF")
EndIf             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza a familia com base no grupo de cobranca definido no subcontrato³
//³ Somente familias que estao no mesmo grupo								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

BA3->(DbSetorder(7))
If lRet .And. M->BQC_GRPCOB <> BQC->BQC_GRPCOB ;
.and. BA3->(MsSeek(xFilial("BA3")+BQC->BQC_CODIGO+BQC->BQC_NUMCON +BQC->BQC_VERCON+BQC->BQC_SUBCON+BQC->BQC_VERSUB))

	If MsgYesNo(OemtoAnsi(STR0143)+chr(10)+OemtoAnsi(STR0144) )//"Deseja atualizar o grupo de cobrança das famílias deste subcontrato?     "##"(Somente famílias pertencentes ao grupo de cobrança alterado!)"
		cSql := "UPDATE "+RETSQLNAME("BA3")+" SET BA3_GRPCOB = '"+M->BQC_GRPCOB+"'"
		cSQL += " WHERE BA3_FILIAL = '"+BQC->BQC_FILIAL+"'"
		cSQL += "   AND BA3_CODINT+BA3_CODEMP = '"+BQC->BQC_CODIGO+"'"
		cSQL += "   AND BA3_CONEMP = '"+BQC->BQC_NUMCON+"'"         
		cSQL += "   AND BA3_VERCON = '"+BQC->BQC_VERCON+"'"         
		cSQL += "   AND BA3_SUBCON = '"+BQC->BQC_SUBCON+"'"         
		cSQL += "   AND BA3_VERSUB = '"+BQC->BQC_VERSUB+"'"         
		cSQL += "   AND BA3_GRPCOB = '"+BQC->BQC_GRPCOB+"'"             
		
		If ExistBlock("PL660BCQ")
			cSQL := ExecBlock("PL660BCQ",.F.,.F.,{cSQL})
		EndIf

		TCSQLExec(cSQL) 
    EndIf
    
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS660SVER ³ Autor ³ Tulio Cesar         ³ Data ³ 16.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica processo de atualizacao...                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660SVer()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lRet    := .T.

If Empty(dtos(M->BQD_DATINI))
	Help("",1,"PLSA660EX7")
	lRet := .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da funcao...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS660SCAB ³ Autor ³ Tulio Cesar         ³ Data ³ 18.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualiza o cabecalho da tela no dialogo do SubContrato     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660SCab(lRefresh)   //Static
DEFAULT lRefresh := .T.

cSubCon         := M->BQC_SUBCON

If lRefresh
	oSay01:Refresh()
Endif

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A660CHG    ³ Autor ³ Tulio Cesar         ³ Data ³ 18.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Change do Folder...
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A660Chg(nFolder)  //Static

If nFolder >= 2 .And. ! Obrigatorio(oEncBQC:aGets,oEncBQC:aTela)
	oFolder:SetOption(1)
	Return(.F.)
Endif

If nFolder == 3
	oBrwPro:oBrowse:oBrowse:SetFocus()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A660CHG    ³ Autor ³ Tulio Cesar         ³ Data ³ 18.09.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Change do Folder...
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A660ProChg(nFolder) 

If nFolder == 7
	oBrwOpc:oBrowse:oBrowse:SetFocus()
Elseif nFolder == 8
	oBrwFrOpc:ForceRefresh(oBrwOpc)

	If oBrwOpc:FieldGet("BHS_TIPVIN",oBrwOpc:Linha()) == "0"
		If !oBrwOpc:IsDeleted(oBrwOpc:Linha())
			oBrwFrOpc:OBROWSE:OBROWSE:LREADONLY := .F.
			oBotFrOpc:Enable()
		Else
			oBrwFrOpc:OBROWSE:OBROWSE:LREADONLY := .T.
			oBotFrOpc:Disable()
		EndIf
	Else
		If !oBrwOpc:IsDeleted(oBrwOpc:Linha())
			oBrwFrOpc:OBROWSE:OBROWSE:LREADONLY := .T.
			oBotFrOpc:Enable()
		Else
			oBrwFrOpc:OBROWSE:OBROWSE:LREADONLY := .T.
			oBotFrOpc:Enable()			
		EndIf
	EndIf
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao    ³ PLSA660For ³ Autor ³ Tulio Cesar           ³ Data ³ 03.05.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Edita uma Forma de Cobranca                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ Edicao do browse Forma de Cobranca                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
nTipo == 1  -> Forma de Cobranca do Produto
nTipo == 2  -> Forma de Cobranca da Taxa de Adesao
nTipo == 3  -> Forma de Cobranca do Opcional
/*/
Function PLSA660For(nOpcx,nTipo,lTabAnt,oObjeto,lFRefres)
Local I__f := 0
Local nI,nInd,nCont,nTr,nFields
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Codigo e Descricao da Forma atual...                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave
LOCAL cDescri

LOCAL oDlgFor
LOCAL aCampos  	:= {}
LOCAL oEnc
LOCAL cAlias
LOCAL oFld
LOCAL aOpcoes  	:= {}
LOCAL aTitles  	:= {}
LOCAL aVetTemp 	:= {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cOldCad  	:= cCadastro
LOCAL aOldTela 	:= aTela
LOCAL aOldGets 	:= aGets

LOCAL nOldOpc  	:= nOpca
LOCAL nOpca    	:= 0
LOCAL cOldAlias	:= Alias()
LOCAL aTiles   	:= {}
LOCAL aPages   	:= {}
LOCAL nControl 	:= 0
LOCAL cMala    	:= Space(01)
LOCAL cVar
LOCAL bFilter
LOCAL aVetsTmp 	:= {}
LOCAL _aVetTrb 	:= {}
LOCAL nPosObj	:= 0
LOCAL lDelLin	:= .F.
LOCAL aCpoObri	:= {}, lDigitou := .F.
LOCAL nObrig 	:= nOk := 0
LOCAL lOlInclui := INCLUI
LOCAL bErro 	:= ErrorBlock({ |e| PL660ERR(e)})      
LOCAL bRefrBGW 	:= {|| IIf(Empty(aOpcoes[2,6]) .And. aOpcoes[2,2]== "BGW", aOpcoes[2,6] := "{|| OBRWBGW:FORCEREFRESH(OBRWBBX)}", "") }
Local aSize 	:= MsAdvSize()
Local aObjects 	:= {}       
Local aInfo 	:= {}
Local aPosObj 	
Local aColsAnt := {}

DEFAULT oObjeto := NIL
DEFAULT nTipo 	:= 1
DEFAULT lTabAnt := .F.
DEFAULT lFRefres := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCols   := {}
PRIVATE aHeader := {}
PRIVATE n       := 1     
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aSvaTela := {}
PRIVATE oPriBro
PRIVATE lFiltro
If Valtype(oObjeto) == 'O'
	nPosObj := oObjeto:oBrowse:nAt 
Endif

if nTipo == 1
	cCodFor := oBrwFor:FieldGet("BT9_CODFOR")
	cChave  := oBrwFor:FieldGet("BT9_CODFOR")+cCodProSel+cVersaoSel
	cDescri := oBrwFor:FieldGet("BT9_DESFOR")
	aVetsTmp := AClone(aVetsFor)
Elseif nTipo == 2
	cCodFor := oBrwAde:FieldGet("BTK_CODFOR")
	cChave  := oBrwAde:FieldGet("BTK_CODFOR")+cCodProSel+cVersaoSel
	cDescri := oBrwAde:FieldGet("BTK_DESFOR")
	aVetsTmp := AClone(aVetsTxF)
Else
	If lFRefres
		oBrwFrOpc:ForceRefresh(oBrwOpc)
	EndIf
	cCodFor := oBrwFrOpc:FieldGet("BJW_CODFOR")
	cChave  := oBrwFrOpc:FieldGet("BJW_CODFOR")+cCodProSel+cVersaoSel+cCodOpcSel+cVerOpcSel
	cDescri := oBrwFrOpc:FieldGet("BJW_DESFOR")
	aVetsTmp := AClone(aVetsOpc)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa preenchimento da linha...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nTipo == 1 .And. ! oBrwFor:LinhaOK()
	Return
Elseif nTipo == 2 .And. ! oBrwAde:LinhaOK()
	Return
ElseIf nTipo = 3 .And. ! oBrwFrOpc:LinhaOK()
	Return
Endif

BJ1->(MsSeek(xFilial("BJ1") + cCodFor))
                
// Incrementa vetor de objetos disponiveis na tela.                                                         
AAdd( aObjects, { 100, 200, .T., .T. } )
AAdd( aObjects, { 200, 100, .T., .T.,.T. } )
                
// Define tamanhos de acordo com a resolucao da tela do client
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgFor TITLE STR0050+cCodFor+" - "+AllTrim(cDescri)+STR0051 FROM aSize[7],0 To aSize[6],aSize[5] OF oDlgFolder PIXEL  //"Forma de Cobranca "###" - Propriedades"
cMala := Space(01) // nao retirar. Consultar Tulio ou Eduardo
@ 10000,2000 GET cMala PICTURE "@!" PIXEL OF oDlgFor // nao retirar. Consultar Tulio ou Eduardo
//essas linhas foram incluidas a classe tplsbrw nunca podera ser o 1 objeto do dialogo...
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o folder de acordo com a quantidade de objetos...              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aOpcoes := a660MOpc(cCodFor)

SetEnch("")
For nI := 1 to Len(aOpcoes)
	Aadd(aTitles,OemtoAnsi(aOpcoes[nI,1]))
	Aadd(aPages,"HEADER "+Trim(Str(nI,2)))
	nControl++
Next
                                                 
//oFld := TFolder():New(20,0,aTitles,aPages,oDlgFor,,,,.T.,.F.,x,aSize[4]-15,)
oFld := TFolder():New(40,0,aTitles,aPages,oDlgFor,,,,.T.,.F.,aPosObj[2][3],aPosObj[2][4]+15)
oFld:bChange := {|nFolder| Eval(bRefrBGW), PL260FORREFR(nFolder,,aOpcoes)} 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Objetos...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len(aOpcoes)
	cAlias  := aOpcoes[nI,2]
	cTipo   := aOpcoes[nI,3]
	cTit    := aOpcoes[nI,1]
	lFiltro := IF(aOpcoes[nI,4]=="1",.T.,.F.)
	bFilter := AllTrim(aOpcoes[nI,5])
	            
					// Testa se o alias realmente existe no dicionario de dados... se nao existir, ignora.
	If !PLSALIASEX(cAlias)
		MsgAlert("A tabela "+cAlias+" deve ser retirada do cadastro de forma de cobranca porque nao existe no dicionario de dados.")
		Loop
	Endif
	
	aHeader := {}
	aCols   := {}
	_aVetTrb:= {}
	DbSelectArea(cAlias)                   
	
	cBrw := "oBrw"+cAlias
	
	STORE HEADER cAlias TO aHeader For .T.
	
	lFlag    := .F.
	For nInd := 1 To Len(aVetsTmp)
		If 	cTipo == "0" .And. aVetsTmp[nInd,1] == cCodFor .And. aVetsTmp[nInd,2] == cAlias .And.;
			aVetsTmp[nInd,12] == cChave
			lFlag := .T.
			aVetTrab := aVetsTmp[nInd,4]
			For nCont  := 1 To Len(aVetTrab)
				cDado  := aVetTrab[nCont,1]
				&cDado := aVetTrab[nCont,2]
			Next
			Exit
		ElseIf cTipo == "1"
			if nTipo < 3
				if 	aVetsTmp[nInd,2] == cAlias  .And. aVetsTmp[nInd,1] == cCodFor .And.;
					aVetsTmp[nInd,12] == cChave
					aTrab   := aVetsTmp[nInd,4]
					_aVetTrb := aVetsTmp[nInd,5]
					If Len(aTrab) == 0
						Store COLS Blank cAlias TO aDados FROM aHeader
					Endif
					For nTr := 1 To Len(aTrab)
						nPos := PLRETPOS(cAlias+"_VERPRO",aHeader,.F.)
						if aTrab[nTr,1] == cCodProSel .And. aTrab[nTr,nPos] == cVersaoSel
							aadd(aCols,AClone(aTrab[nTr]))
							lFlag := .T.
						Endif
					Next
					Exit
				Endif
			Else
				if 	aVetsTmp[nInd,1] == cCodFor .And. aVetsTmp[nInd,2] == cAlias .And.;
					aVetsTmp[nInd,12] == cChave
					aTrab   := aVetsTmp[nInd,4]
					_aVetTrb := aVetsTmp[nInd,5]
					If Len(aTrab) == 0
						Store COLS Blank cAlias TO aDados FROM aHeader
					Endif
					For nTr := 1 To Len(aTrab)
						if cCodProSel == aTrab[nTr,1] .And. aTrab[nTr,3] == cCodOpcSel .And. aTrab[nTr,4] == cVerOpcSel
							aadd(aCols,aTrab[nTr])
							lFlag := .T.
						Endif
					Next
					Exit
				Endif
			Endif
		Endif
		If lFlag
			Exit
		Endif
	Next
	
	If ! lFlag
		INCLUI := .T.
		If cTipo == "0" // Enchoice
			cAlias := aOpcoes[nI,2]
			COPY cAlias To Memory Blank
		ElseIf cTipo == "1" // GetDados
			STORE COLS Blank cAlias TO aCols FROM aHeader
		Endif
		INCLUI := lOlInclui
	Endif
	
	If cTipo == "0" // Enchoice
		aTela := {}
		aGets := {}
		cVar  := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
		aadd(aSvaTela,{})
		&cBrw := MsMGet():New(cAlias,0,nOpcx,,,,,aPosObj[1],,,,,,oFld:aDialogs[nI],,,.F.,cVar)
		aSvaTela[len(aSvaTela)] = aClone(aTela)
	ElseIf cTipo == "1" // GetDados
		lDelLin := aCols[1][Len(aCols[1])]
		aCols[1][Len(aCols[1])] := .F.
		
		// o último folder não deve permitir edição para o usuário mesmo que seja selecionado a opcao alterar
		If cBrw == "oBrwBBW"
			&cBrw := TPLSBrw():New(005,005,aPosObj[2][3]-15,aPosObj[2][4],nil  ,oFld:aDialogs[nI],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,cAlias,2,cTit,nil,nil,nil,_aVetTrb,"PL660VldLn('BTN','"+ccodfor+"')",,IF(lFiltro,&bFilter,nil))
		Else		
			&cBrw := TPLSBrw():New(005,005,aPosObj[2][3]-15,aPosObj[2][4],nil  ,oFld:aDialogs[nI],nil    , nil ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aHeader,aCols,.F.,cAlias,nOpcx,cTit,nil,nil,nil,_aVetTrb,"PL660VldLn('BTN','"+ccodfor+"')",,IF(lFiltro,&bFilter,nil))
		EndIf

		If oPriBro = Nil .And. lDelLin .And. N = 1
			oPriBro := &cBrw
		Endif
		&cBrw:aCols[1][Len(aCols[1])] := lDelLin
		&cBrw:Cargo := lTabAnt
	Endif                                                                     
Next

//Guarda aCols padrão
aColsAnt := aClone(aCols)

If ExistBlock("PLS660FG")
   ExecBlock("PLS660FG",.F.,.F.)
Endif   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgFor ON INIT (	If( oPriBro <> Nil , ( oPriBro:oBrowse:oBrowse:SetFocus() , oPriBro:ForceRefresh(oPriBro) ) , .T. ) , ;
												EnchoiceBar( oDlgFor , {|| nOpca := 1 , lOkFxDes := .T. , PLSA660PRD(cCodFor,cCodProSel,cVersaoSel) , oDlgFor:End() } , {|| nOpca := 2 , oDlgFor:End() } ) )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza dados dos vetores...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
	If ! lAltFor
		lAltFor := .T.
	Endif
	
	For nI := 1 To Len(aOpcoes)
		cAlias   := aOpcoes[nI,2]
		DbSelectArea(cAlias)
		cTipo    := aOpcoes[nI,3]
		cTit     := aOpcoes[nI,1]
		
		nPos  := Ascan(aVetsTmp,{|x| x[1]+x[2]+x[12] == cCodFor+cAlias+cChave})
		nTemp := 0		
		if nPos > 0
			if aVetsTmp[nPos,2] == cAlias  .And. aVetsTmp[nPos,12] <> cChave
				While nPos <= Len(aVetsTmp) .And. nPos <> 0
					nPos := Ascan(aVetsTmp,{|x| x[1]+x[2] == cCodFor+cAlias},nPos+1)
					if nPos > 0
						nTemp := nPos
					Endif
				Enddo
				if nTemp > 0
					nPos := nTemp
				Else
					nPos := 0
				Endif
			Endif
		Endif
		
		If cTipo == "0" // Enchoice
		ElseIf cTipo == "1" // GetDados
			cBrw     := "oBrw"+cAlias
			&(cBrw):EndFilter(.F.)
			aCols    := aClone((&(cBrw):aCols))
			aHeader  := aClone((&(cBrw):aHeader))
			_aVetTrb := aClone((&(cBrw):aVetTrab))

			lDigitou := .F.

            If Len(aCols) = 1
				aCpoObri := {}
				For nCont := 1 To Len(aCols)
				    nObrig := nOk := 0
				    For nFields := 1 To Len(aHeader)
			    		If Ascan(aCpoObri, AllTrim(aHeader[nFields][2])) > 0
				    		nObrig ++
			   				If ! Empty(aCols[nCont,nFields])
		    					nOk ++
			    			Endif
			    		Endif
			    	Next
			    	lDigitou := nObrig = nOk
				Next    
			Else
				lDigitou := .T.
			Endif
		Endif
		
		If cTipo == "0" // Enchoice
			aCpos   := {}
			aFields := DBSTRUCT()
			For nCont := 1 To Len(aFields)
				cTrab := "M->"+aFields[nCont,1]
				cDado := &cTrab
				aadd(aCpos,{cTrab,cDado})
			Next
			If nPos == 0
				aadd(aVetsTmp,{cCodFor,cAlias,cTipo,aCpos,0,M->BQC_NUMCON,cPLSVersao,;
				M->BQC_SUBCON,M->BQC_VERSUB,cCodProSel,cVersaoSel,cCodFor+cCodProSel+cVersaoSel})
			Else
				aVetsTmp[nPos] := {cCodFor,cAlias,cTipo,aCpos,aVetsTmp[nPos,5],M->BQC_NUMCON,cPLSVersao,;
				M->BQC_SUBCON,M->BQC_VERSUB,cCodProSel,cVersaoSel,cCodFor+cCodProSel+cVersaoSel}
			Endif
		ElseIf cTipo == "1" // GetDados
			if nTipo == 3
				If nPos == 0
					aadd(aVetsTmp,{cCodFor,cAlias,cTipo,aCols,{},M->BQC_NUMCON,cPLSVersao,;
					M->BQC_SUBCON,M->BQC_VERSUB,cCodProSel,cVersaoSel,cCodFor+cCodProSel+cVersaoSel+cCodOpcSel+cVerOpcSel,lDigitou})
				Else
					aVetsTmp[nPos] := {cCodFor,cAlias,cTipo,aCols,_aVetTrb,M->BQC_NUMCON,;
					cPLSVersao,M->BQC_SUBCON,M->BQC_VERSUB,cCodProSel,cVersaoSel,cCodFor+cCodProSel+cVersaoSel+cCodOpcSel+cVerOpcSel,lDigitou}
				Endif
			Else
				If nPos == 0
					aadd(aVetsTmp,{cCodFor,cAlias,cTipo,aCols,{},M->BQC_NUMCON,cPLSVersao,;
					M->BQC_SUBCON,M->BQC_VERSUB,cCodProSel,cVersaoSel,cCodFor+cCodProSel+cVersaoSel,lDigitou})
				Else
					aVetsTmp[nPos] := {cCodFor,cAlias,cTipo,aCols,_aVetTrb,M->BQC_NUMCON,;
					cPLSVersao,M->BQC_SUBCON,M->BQC_VERSUB,cCodProSel,cVersaoSel,cCodFor+cCodProSel+cVersaoSel,lDigitou}
				Endif
			Endif
		Endif
	Next
	if nTipo == 1
		aVetsFor := aClone(aVetsTmp)
	Elseif nTipo == 2
		aVetsTxF := aClone(aVetsTmp)
	Elseif nTipo == 3
		aVetsOpc := aClone(aVetsTmp)
	Endif

    lOkFxDes := .T.
Else
    lOkFxDes := .F.

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados gravados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := cOldCad
aTela     := aOldTela
aGets     := aOldGets
nOpca     := nOldOpc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa de erro...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ErrorBlock(bErro)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza objeto...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ValType(oObjeto) == 'O' .and. nPosObj <> 0
	oObjeto:Atualiza()
	oObjeto:SetPos(nPosObj)
Endif
               
If !Empty(cOldAlias)
	DbSelectArea(cOldAlias)
EndIf

_l660Err := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A660MOPC ³ Autor ³ Tulio Cesar           ³ Data ³ 03.10.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta as opcoes (alias) para uma Forma de Cobranca...      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A660MOpc(cCodFor)
aOpcoes := {}
BJ2->(DbSetOrder(1))
If BJ2->(MsSeek(xFilial("BJ2")+cCodFor+"2"))
	While ! BJ2->(Eof()) .And. BJ2->(BJ2_FILIAL+BJ2_CODIGO+BJ2_USO) == xFilial("BJ2")+cCodFor+"2"
		SX2->(DbSetOrder(1))
		SX2->(MsSeek(BJ2->BJ2_ALIAS))
		If BJ2->(FieldPos("BJ2_EXPREF")) > 0		
			aadd(aOpcoes,{ AllTrim(SX2->(X2NOME())) , BJ2->BJ2_ALIAS, BJ2->BJ2_TIPO, BJ2->BJ2_BFILT, BJ2->BJ2_EXPF, BJ2->BJ2_EXPREF})
		Else
			aadd(aOpcoes,{ AllTrim(SX2->(X2NOME())) , BJ2->BJ2_ALIAS, BJ2->BJ2_TIPO, BJ2->BJ2_BFILT, BJ2->BJ2_EXPF, ''})
		Endif			
		BJ2->(DbSkip())
	Enddo
Endif
Return(aOpcoes)



Function PLSA660Exc(cTipo,cCodInt,cCodEmp,lHelp,cConEmp,cVerCon,cSubCon,cVerSub)
LOCAL lRet


If cTipo == "1"
	BA3->(DbSetOrder(1))
	lRet := !BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodEmp))
Endif

If cTipo == "2"
	BA3->(DbSetOrder(7))
	lRet := !BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodEmp+cConEmp+cVerCon))
Endif

If cTipo == "3"
	BA3->(DbSetOrder(7))
	lRet := !BA3->(MsSeek(xFilial("BA3")+cCodInt+cCodEmp+cConEmp+cVerCon+cSubCon+cVerSub))
Endif

If ! lRet .And. lHelp
	Help("",1,"PLSA660EXC")
Endif

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS660SDAT³ Autor ³ Michele Tatagiba      ³ Data ³ 22.05.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata a data da versao do Grupo/Empresa - Subcontrato      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660SDat(cChave,dData)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva dados...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOrdBQD := BQD->(IndexOrd())
LOCAL nRecBQD := BQD->(Recno())
LOCAL dUltDat := dData
LOCAL lRet    := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a data informada e maior que a da ultima versao...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BQD->(DbSetOrder(1))
BQD->(MsSeek(xFilial("BQD")+cChave+"999",.T.))
BQD->(DbSkip(-1))

If BQD->(BQD_FILIAL+BQD_CODIGO+BQD_NUMCON+BQD_VERCON+BQD_SUBCON) == xFilial("BQD")+cChave
	dUltDat := BQD->BQD_DATINI
	If dtos(dData) > dtos(dUltDat)
		lRet := .T.
	Endif
Else
	lRet := .T.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura dados salvos...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BQD->(DbSetOrder(nOrdBQD))
BQD->(DbGoTo(nRecBQD))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe help caso data seja errada...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lRet
	Help("",1,"PLS660SDat")
Else
	If dtos(dData) < dtos(BT5->BT5_DATCON)
		MsgInfo(STR0052) //"Data da versao deve ser maior que a data do contrato"
		lRet := .F.
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lRet)



Function PLS660SSeq(cSubCon)
LOCAL nRet    := 0
LOCAL nOrdBQD := BQD->(IndexOrd())
LOCAL nTam    := Len(BQD->BQD_VERSUB)

BQD->(DbSetOrder(1))

BQD->(MsSeek(xFilial("BQD")+BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)+cSubCon+Replicate("9",nTam),.T.))
BQD->(DbSkip(-1))

If BQD->(BQD_FILIAL+BQD_CODIGO+BQD_NUMCON+BQD_VERCON+BQD_SUBCON) <> xFilial("BQD")+BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)+cSubCon
	nRet := StrZero(1,nTam)
Else
	nRet := StrZero(Val(BQD->BQD_VERSUB)+1,nTam)
Endif

BQD->(DbSetOrder(nOrdBQD))

Return(nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLS660ADDC ³ Autor ³ Tulio Cesar      ³ Data ³ 13.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Co Participacao                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660ADDC(oBrwCob)
LOCAL oDlg

LOCAL nOpca      := 0
LOCAL nOldN      := oBrwCob:oBrowse:nAt
LOCAL aButtBHE	 := {}
                                                                     
cDesPsa	  		 := oBrwCob:FieldGet("BT8_DESCRI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta rotina so sera usada na alteracao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Incluir
	MsgInfo(STR0053) //"Este botao nao esta disponivel na opcao incluir"
	Return
Endif                    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0054+cCodPsa+" - "+cDesPsa FROM 009,000 TO 039,0110 OF GetWndDefault() //"Co-participacao - "
oDlg:lEscClose := .F.

PlsBut(oDlg)          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBHE, {"BUDGET",{||PL660HTFRA('1',"BHE",	cChavSub,;
													oBrwCCo:FieldGet("BHE_CODPRO"),;
													Iif((BHE->( FieldPos("BHE_VERPRO") ) > 0), oBrwCCo:FieldGet("BHE_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BHE->( FieldPos("BHE_VERPRO") ) > 0 .And. BT8->( FieldPos("BT8_VERPRO") ) > 0
	bFilter  		   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHE_CODPRO",aHeader)] == cCodProSel .And.;
									   				aCols[nLine,GdFieldPos("BHE_VERPRO",aHeader)] == cVersaoSel .And.;
									   				aCols[nLine,GdFieldPos("BHE_CODPAD",aHeader)] == cCodPad 	 .And.;
									   				aCols[nLine,GdFieldPos("BHE_CODPSA",aHeader)] == cCodPsa}
	oBrwCCo  		   := TPLSBrw():New(0031,001,435,226,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCCo ,aDadCCo ,.F. ,"BHE" ,nOpcx,STR0028,nil,nil,nil,aTrbCCo,'PlsVldBHE',,bFilter,,aButtBHE) //"Co-participacao"
	oBrwCCo:oPai       := oBrwCob
	oBrwCCo:aOrigem    := {"BT8_CODPRO","BT8_VERPRO","BT8_CODPAD","BT8_CODPSA"}
	oBrwCCo:aRelac     := {"BHE_CODPRO","BHE_VERPRO","BHE_CODPAD","BHE_CODPSA"}
Else	
	bFilter  		   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHE_CODPRO",aHeader)]== cCodProSel .And.;
									   				aCols[nLine,GdFieldPos("BHE_CODPAD",aHeader)]== cCodPad 	.And.;
									   				aCols[nLine,GdFieldPos("BHE_CODPSA",aHeader)]== cCodPsa}
	oBrwCCo  		   := TPLSBrw():New(0030,001,435,226,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCCo ,aDadCCo ,.F. ,"BHE" ,nOpcx,STR0028,nil,nil,nil,aTrbCCo,'PlsVldBHE',,bFilter,,aButtBHE) //"Co-participacao"
	oBrwCCo:oPai       := oBrwCob
	oBrwCCo:aOrigem    := {"BT8_CODPRO","BT8_CODPAD","BT8_CODPSA"}
	oBrwCCo:aRelac     := {"BHE_CODPRO","BHE_CODPAD","BHE_CODPSA"}
EndIf	

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
   aDadCCo := aClone(oBrwCCo:aCols)
Endif

oBrwCob:Atualiza()
oBrwCob:SetPos(nOldN)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLS660ADPC ³ Autor ³ Geraldo Felix Jr.³ Data ³ 05.04.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Tipo de Acomodacao                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660ADPC(oBrwCob)
LOCAL oDlg

LOCAL nOpca      := 0
LOCAL nOldN      := oBrwCob:oBrowse:nAt           

cDesPsa	  		 := oBrwCob:FieldGet("BT8_DESCRI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta rotina so sera usada na alteracao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Incluir
	MsgInfo(STR0053) //"Este botao nao esta disponivel na opcao incluir"
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0055+cCodPsa+" - "+cDesPsa FROM 009,000 TO 029,060 OF GetWndDefault() //"Tipo de Acomodacao - "
oDlg:lEscClose := .F.

PlsBut(oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
   aDadPc := aClone(oBrwPc:aCols)
Endif

oBrwCob:Atualiza()
oBrwCob:SetPos(nOldN)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ A940PAR ³ Autor ³ Michele Tatagiba     ³ Data ³ 18.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Co Participacao para Grupo de Cobertura³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660ADDG(oBrwGru)
LOCAL oDlg

LOCAL nOpca      := 0
LOCAL nOldN      := oBrwGru:oBrowse:nAt
LOCAL aButtBHF	 := {}

                                                                           
cDesGruCob 		 := oBrwGru:FieldGet("BT7_DESGRU")

DEFINE MSDIALOG oDlg TITLE STR0057+cCodGruCob+" - "+cDesGruCob FROM 009,000 TO 029,060 OF GetWndDefault() //"Co-participacao:  "
oDlg:lEscClose := .F.

PlsBut(oDlg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBHF, {"BUDGET",{||PL660HTFRA('1',"BHF",	cChavSub,;
													oBrwCGru:FieldGet("BHF_CODPRO"),;
													Iif((BHF->( FieldPos("BHF_VERPRO") ) > 0), oBrwCGru:FieldGet("BHF_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If BT7->( FieldPos("BT7_VERPRO") ) > 0 .and. BHF->( FieldPos("BHF_VERPRO") ) > 0 
	bFilter   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHF_CODPRO",aHeader)] == cCodProSel .And.;
										aCols[nLine,GdFieldPos("BHF_VERPRO",aHeader)] == cVersaoSel .And.;
										aCols[nLine,GdFieldPos("BHF_CODGRU",aHeader)] == cCodGruCob}
	oBrwCGru  := TPLSBrw():New(0033,001,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCGru ,aDadCGru ,.F. ,"BHF" ,nOpcX,STR0028,nil,nil,nil,aTrbCGru,'PlsVldBHF',,bFilter,,aButtBHF) //"Co-participacao"
	oBrwCGru:oPai       := oBrwGru
	oBrwCGru:aOrigem    := {"BT7_CODPRO","BT7_VERPRO","BT7_CODGRU"}
	oBrwCGru:aRelac     := {"BHF_CODPRO","BHF_VERPRO","BHF_CODGRU"}

Else 
	bFilter   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHF_CODPRO",aHeader)]==cCodProSel .And.;
										aCols[nLine,GdFieldPos("BHF_CODGRU",aHeader)]==cCodGruCob}
	oBrwCGru  := TPLSBrw():New(0013,001,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCGru ,aDadCGru ,.F. ,"BHF" ,nOpcX,STR0028,nil,nil,nil,aTrbCGru,'PlsVldBHF',,bFilter,,aButtBHF) //"Co-participacao"
	oBrwCGru:oPai       := oBrwGru
	oBrwCGru:aOrigem    := {"BT7_CODPRO","BT7_CODGRU"}
	oBrwCGru:aRelac     := {"BHF_CODPRO","BHF_CODGRU"}
EndIf	                                

lUsaBHF := .T.

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
	aCabCGru := aClone(oBrwCGru:aHeader)
	aDadCGru := aClone(oBrwCGru:aCols)
Endif

oBrwGru:Atualiza()
oBrwGru:SetPos(nOldN)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSNADA   ºAutor  ³Microsiga           º Data ³  09/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSNADA()

BI3->(DbGoTop())
While ! BI3->(Eof())
	
	BJ9->(DbSetOrder(1))
	If ! BJ9->(MsSeek(xFilial("BJ9")+BI3->(BI3_CODINT+BI3_CODIGO)+"103"))
		BJ9->(RecLock("BJ9",.T.))
		BJ9->BJ9_FILIAL := xFilial("BJ9")
		BJ9->BJ9_CODIGO := BI3->(BI3_CODINT+BI3_CODIGO)
		BJ9->BJ9_VERSAO := "001"
		BJ9->BJ9_CODFOR := "103"
		BJ9->(MsUnLock())
	Endif
	
	BI3->(DbSkip())
Enddo

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA660PRO ³ Autor ³ Tulio Cesar       ³ Data ³ 18.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe pelo menos um produto relacionado...    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA660PRO()
LOCAL nInd
LOCAL lFlag := .F.
LOCAL nPos  := oBrwPro:Coluna("BT6_TIPOPR")

For nInd := 1 To Len(oBrwPro:aCols)
	
	If ( ! oBrwPro:aCols[nInd,Len(oBrwPro:aHeader)+1] ) .And. ( oBrwPro:aCols[nInd,nPos] == "1" )
		lFlag := .T.
		Exit
	Endif
	
Next

If ! lFlag
	Help("",1,"PLSA660PRO")
Endif

Return(lFlag)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PL660CF    ³ Autor ³ Antonio de Padua  ³ Data ³ 10.10.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When dos campos Cliente/Fornecedor...                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
cTipo := F - Fornecedor
C - Cliente

nNum  := 1 - Grupo Empresa
2 - Contrato
3 - Sub-Contrato

/*/
Function PL660CF(nNum,cTipo)

if nNum == 1
	if M->BG9_TIPO == "2"
		if cTipo == "F"
			lFlag := Empty(M->BG9_CODCLI)
		Else
			lFlag := Empty(M->BG9_CODFOR)
		Endif
	Else
		lFlag := .F.
	Endif
Elseif nNum == 2
	if M->BT5_COBNIV == "1"
		if cTipo == "F"
			lFlag := Empty(M->BT5_CODCLI)
		Else
			lFlag := Empty(M->BT5_CODFOR)
		Endif
	Else
		lFlag := .F.
	Endif
Else
	if M->BQC_COBNIV == "1"
		if cTipo == "F"
			lFlag := Empty(M->BQC_CODCLI)
		Else
			lFlag := Empty(M->BQC_CODFOR)
		Endif
	Else
		lFlag := .F.
	Endif
Endif

Return(lFlag)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA660BT5³ Autor ³ Tulio Cesar           ³ Data ³ 23.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o proximo numero de um contrato.                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA660BT5()
LOCAL nRegBT5 := BT5->(Recno())
LOCAL nOrdBT5 := BT5->(IndexOrd())
LOCAL cNewCod

cNewCod := PLSA625Cd("BT5_NUMCON","BT5",1,"BT5->(BT5_CODINT+BT5_CODIGO)",BG9->(BG9_CODINT+BG9_CODIGO),.T.)

BT5->(DbSetOrder(nOrdBT5))
BT5->(DbGoTo(nRegBT5))

Return(cNewCod)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA660BQC³ Autor ³ Tulio Cesar           ³ Data ³ 23.12.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna o proximo numero de um sub-contrato.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA660BQC()
LOCAL nRegBQC := BQC->(Recno())
LOCAL nOrdBQC := BQC->(IndexOrd())
LOCAL cNewCod

cNewCod := PLSA625Cd("BQC_SUBCON","BQC",1,"BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON)",BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO),.T.)

BQC->(DbSetOrder(nOrdBQC))
BQC->(DbGoTo(nRegBQC))

Return(cNewCod)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSA660WHE³ Autor ³ Tulio Cesar          ³ Data ³ 18.01.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ When de diversos campo do siga...                           ³±±
±±³          ³ nao cabe no X3_WHEN ai coloca em uma funcao                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA660Whe(cTipo)
LOCAL lPode := .F.

//Tabela BHG
If     cTipo == "01" //BHG_PERCOP
	lPode := ( M->BHG_VLRCOP == 0 )
ElseIf cTipo == "02" //BHG_VLRCOP
	lPode := ( M->BHG_PERCOP == 0 .And. M->BHG_VALUS == 0 )
ElseIf cTipo == "03" //BHC_VALUS
	lPode := .T.
Endif

//Tabela BHE
If     cTipo == "04" //BHE_PERCOP
	lPode := ( M->BHE_VLRCOP == 0 )
ElseIf cTipo == "05" //BHE_VLRCOP
	lPode := ( M->BHE_PERCOP == 0 )
ElseIf cTipo == "06" //BHE_VALUS
	lPode := .T.
Endif

If    cTipo == "07"
	lPode := M->BTN_GRAUPA<>GETMV("MV_PLCDTGP") .And. M->BTN_FAIFAM == "0"
Endif

//Tabela BLX
If     cTipo == "08" //BLX_PERCOP
	lPode := ( M->BLX_VLRCOP == 0 )
ElseIf cTipo == "09" //BLX_VLRCOP
	lPode := ( M->BLX_PERCOP == 0 )
ElseIf cTipo == "10" //BLX_VALUS
	lPode := .T.
Endif

//Tabela BLW
If     cTipo == "11" //BLW_PERCOP
	lPode := ( M->BLW_VLRCOP == 0 )
ElseIf cTipo == "12" //BLW_VLRCOP
	lPode := ( M->BLW_PERCOP == 0 )
ElseIf cTipo == "13" //BLW_VALUS
	lPode := .T.
Endif

//Tabela BGS
If     cTipo == "14" //BGS_PERCOP
	lPode := ( M->BGS_VLRCOP == 0 )
ElseIf cTipo == "15" //BGS_VLRCOP
	lPode := ( M->BGS_PERCOP == 0 )
ElseIf cTipo == "16" //BGS_VALUS
	lPode := .T.
Endif
     
//Tabela BHF
If     cTipo == "17" //BGS_PERCOP
	lPode := ( M->BHF_VALCOP == 0 )
ElseIf cTipo == "18" //BGS_VLRCOP
	lPode := ( M->BHF_PERCOP == 0 )
ElseIf cTipo == "16" //BGS_VALUS
	lPode := .T.
Endif

Return(lPode)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLS660ADES ³ Autor ³ Tulio Cesar      ³ Data ³ 13.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Especialidade..                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660ADES(oBrwCob)
LOCAL oDlg

LOCAL nOpca      := 0
LOCAL nOldN      := oBrwCob:oBrowse:nAt           
LOCAL aButtBLX	 := {}

cDesPsa	  		 := oBrwCob:FieldGet("BT8_DESCRI")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta rotina so sera usada na alteracao...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpcx == K_Incluir
	MsgInfo(STR0053) //"Este botao nao esta disponivel na opcao incluir"
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0059+cCodPsa+" - "+cDesPsa FROM 009,000 TO 039,0110 OF GetWndDefault() //"Especialidade - "
oDlg:lEscClose := .F.

PlsBut(oDlg)          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para visualizacao do historico de reajuste da franquia  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBLX, {"BUDGET",{||PL660HTFRA('1',"BLX",	cChavSub,;
													oBrwBLX:FieldGet("BLX_CODPRO"),;
													Iif((BLX->( FieldPos("BLX_VERPRO") ) > 0), oBrwBLX:FieldGet("BLX_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BLT->( FieldPos("BLT_VERPRO") ) > 0 .And. BLX->( FieldPos("BLX_VERPRO") ) > 0
	bFilter  		:= {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLX_CODPRO",aHeader)] == cCodProSel .And.;
								   				aCols[nLine,GdFieldPos("BLX_VERPRO",aHeader)] == cVersaoSel .And.;
								   				aCols[nLine,GdFieldPos("BLX_CODPAD",aHeader)] == cCodPad 	 .And.;
								   				aCols[nLine,GdFieldPos("BLX_CODPSA",aHeader)] == cCodPsa	 .And.;
												aCols[nLine,GdFieldPos("BLX_CODESP",aHeader)] == cCodEspSel .And.;
									 			aCols[nLine,GdFieldPos("BLX_SEQUEN",aHeader)] == cSeqSel }

	oBrwBLX   		:= TPLSBrw():New(130,003,435,222,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLX ,aDadBLX ,.F. ,"BLX" ,nOpcx,STR0060,nil,nil,nil,aTrbBLX,'PlsVldBLX',,bFilter,,aButtBLX) //"Especialidade/Co-Participacao" 
	oBrwBLX:oPai    := oBrwBLT
	oBrwBLX:aOrigem := {"BLT_CODPRO","BLT_VERPRO","BLT_CODPAD","BLT_CODPSA","BLT_CODESP","BLT_SEQUEN"}
	oBrwBLX:aRelac  := {"BLX_CODPRO","BLX_VERPRO","BLX_CODPAD","BLX_CODPSA","BLX_CODESP","BLX_SEQUEN"}

Else 
	bFilter  		:= {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLX_CODPRO",aHeader)] == cCodProSel .And.;
								   				aCols[nLine,GdFieldPos("BLX_CODPAD",aHeader)] == cCodPad 	 .And.;
								   				aCols[nLine,GdFieldPos("BLX_CODPSA",aHeader)] == cCodPsa	 .And.;
												aCols[nLine,GdFieldPos("BLX_CODESP",aHeader)] == cCodEspSel .And.;
									 			aCols[nLine,GdFieldPos("BLX_SEQUEN",aHeader)] == cSeqSel }
	oBrwBLX   		:= TPLSBrw():New(120,001,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLX ,aDadBLX ,.F. ,"BLX" ,nOpcx,STR0060,nil,nil,nil,aTrbBLX,'PlsVldBLX',,bFilter,,aButtBLX) //"Especialidade/Co-Participacao"
	oBrwBLX:oPai    := oBrwBLT
	oBrwBLX:aOrigem := {"BLT_CODPRO","BLT_CODPAD","BLT_CODPSA","BLT_CODESP","BLT_SEQUEN"}
	oBrwBLX:aRelac  := {"BLX_CODPRO","BLX_CODPAD","BLX_CODPSA","BLX_CODESP","BLX_SEQUEN"}

EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BLT->( FieldPos("BLT_VERPRO") ) > 0 .And. BT8->( FieldPos("BT8_VERPRO") ) > 0
	bFilter  		   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLT_CODPRO",aHeader)] == cCodProSel .And.;
									   				aCols[nLine,GdFieldPos("BLT_VERPRO",aHeader)] == cVersaoSel .And.;
									   				aCols[nLine,GdFieldPos("BLT_CODPAD",aHeader)] == cCodPad 	 .And.;
									   				aCols[nLine,GdFieldPos("BLT_CODPSA",aHeader)] == cCodPsa}

	oBrwBLT   := TPLSBrw():New(034,003,435,120,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLT ,aDadBLT ,.F. ,"BLT" ,nOpcx,STR0061,nil,nil,nil,aTrbBLT,,,bFilter) //"Especialidade"  
	oBrwBLT:oPai       := oBrwCob
	oBrwBLT:aOrigem    := {"BT8_CODPRO","BT8_VERPRO","BT8_CODPAD","BT8_CODPSA"}
	oBrwBLT:aRelac     := {"BLT_CODPRO","BLT_VERPRO","BLT_CODPAD","BLT_CODPSA"}
Else
	bFilter  		   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLT_CODPRO",aHeader)] == cCodProSel .And.;
									   				aCols[nLine,GdFieldPos("BLT_CODPAD",aHeader)] == cCodPad 	 .And.;
									   				aCols[nLine,GdFieldPos("BLT_CODPSA",aHeader)] == cCodPsa}
	oBrwBLT   			:= TPLSBrw():New(0013,001,237,100,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLT ,aDadBLT ,.F. ,"BLT" ,nOpcx,STR0061,nil,nil,nil,aTrbBLT,,,bFilter) //"Especialidade" 
	oBrwBLT:oPai       	:= oBrwCob
	oBrwBLT:aOrigem    	:= {"BT8_CODPRO","BT8_CODPAD","BT8_CODPSA"}
	oBrwBLT:aRelac     	:= {"BLT_CODPRO","BLT_CODPAD","BLT_CODPSA"}
EndIf                    
oBrwBLT:bGotFocus 	   	:= {|| 	oBrwBLT:SetPos(oBrwBLT:Linha()) }
oBrwBLT:bLostFocus 		:= {||	cCodEspSel	:= oBrwBLT:FieldGet("BLT_CODESP"),;
						 		cSeqSel 	:= oBrwBLT:FieldGet("BLT_SEQUEN")  }
oBrwBLT:bChange    		:= {||	Eval(oBrwBLT:bLostFocus),;
								oBrwBLX:ForceRefresh(oBrwBLT) }
                         
Eval(oBrwBLT:bChange)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
   aDadBLT := aClone(oBrwBLT:aCols)
   aDadBLX := aClone(oBrwBLX:aCols)
Endif

oBrwCob:Atualiza()
oBrwCob:SetPos(nOldN)

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLS660ADCD ³ Autor ³ Tulio Cesar      ³ Data ³ 13.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados do CID                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS660ADCD(oBrwCob)
LOCAL oDlg

LOCAL nOldN 	 := oBrwCob:oBrowse:nAt
LOCAL nOpca      := 0      
LOCAL aButtBLW	 := {}

cDesPsa	  		 := oBrwCob:FieldGet("BT8_DESCRI")

If nOpcx == K_Incluir
	MsgInfo(STR0053) //"Este botao nao esta disponivel na opcao incluir"
	Return
Endif

DEFINE MSDIALOG oDlg TITLE STR0062+cCodPsa+" - "+cDesPsa FROM 009,000 TO 029,060 OF GetWndDefault() //"CID - "
oDlg:lEscClose := .F.

PlsBut(oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de Co-Participacao para o Produto      			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBLW, {"BUDGET",{||PL660HTFRA('1',"BLW",	cChavSub,;
													oBrwBLW:FieldGet("BLW_CODPRO"),;
													Iif((BLW->( FieldPos("BLW_VERPRO") ) > 0), oBrwBLW:FieldGet("BLW_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BLU->( FieldPos("BLU_VERPRO") ) > 0 .And. BLW->( FieldPos("BLW_VERPRO") ) > 0
	bFilter  	    := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLW_CODPRO",aHeader)] == cCodProSel .And.;
									   			aCols[nLine,GdFieldPos("BLW_VERPRO",aHeader)] == cVersaoSel .And.;
									   			aCols[nLine,GdFieldPos("BLW_CODPAD",aHeader)] == cCodPad 	 .And.;
									 			aCols[nLine,GdFieldPos("BLW_CODPSA",aHeader)] == cCodPsa	 .And.;
												aCols[nLine,GdFieldPos("BLW_CID",aHeader)]	   == cCid 		 .And.;
											 	aCols[nLine,GdFieldPos("BLW_SEQUEN",aHeader)] == cSeqSel }
	oBrwBLW   		:= TPLSBrw():New(105,001,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLW ,aDadBLW ,.F. ,"BLW" ,nOpcx,STR0063,nil,nil,nil,aTrbBLW,'PlsVldBLW',,bFilter,,aButtBLW) //"CID/Co-Participacao"
	oBrwBLW:oPai    := oBrwBLU
	oBrwBLW:aOrigem := {"BLU_CODPRO","BLU_VERPRO","BLU_CODPAD","BLU_CODPSA","BLU_CID","BLU_SEQUEN"}
	oBrwBLW:aRelac  := {"BLW_CODPRO","BLW_VERPRO","BLW_CODPAD","BLW_CODPSA","BLW_CID","BLW_SEQUEN"}

Else 
	bFilter  	    := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLW_CODPRO",aHeader)] == cCodProSel .And.;
									   			aCols[nLine,GdFieldPos("BLW_CODPAD",aHeader)] == cCodPad 	 .And.;
									 			aCols[nLine,GdFieldPos("BLW_CODPSA",aHeader)] == cCodPsa	 .And.;
												aCols[nLine,GdFieldPos("BLW_CID",aHeader)]	   == cCid 		 .And.;
											 	aCols[nLine,GdFieldPos("BLW_SEQUEN",aHeader)] == cSeqSel }
	oBrwBLW   		:= TPLSBrw():New(105,001,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLW ,aDadBLW ,.F. ,"BLW" ,nOpcx,STR0063,nil,nil,nil,aTrbBLW,'PlsVldBLW',,bFilter,,aButtBLW) //"CID/Co-Participacao"
	oBrwBLW:oPai    := oBrwBLU
	oBrwBLW:aOrigem := {"BLU_CODPRO","BLU_CODPAD","BLU_CODPSA","BLU_CID","BLU_SEQUEN"}
	oBrwBLW:aRelac  := {"BLW_CODPRO","BLW_CODPAD","BLW_CODPSA","BLW_CID","BLW_SEQUEN"}

EndIf	                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BLU->( FieldPos("BLU_VERPRO") ) > 0 .And. BT8->( FieldPos("BT8_VERPRO") ) > 0
	bFilter  		   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLU_CODPRO",aHeader)] == cCodProSel .And.;
									   				aCols[nLine,GdFieldPos("BLU_VERPRO",aHeader)] == cVersaoSel .And.;
									   				aCols[nLine,GdFieldPos("BLU_CODPAD",aHeader)] == cCodPad 	 .And.;
									   				aCols[nLine,GdFieldPos("BLU_CODPSA",aHeader)] == cCodPsa}
	oBrwBLU   		   := TPLSBrw():New(0029,004,237,100,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLU ,aDadBLU ,.F. ,"BLU" ,nOpcx,"CID",nil,nil,nil,aTrbBLU,,,bFilter) 
	oBrwBLU:oPai       := oBrwCob
	oBrwBLU:aOrigem    := {"BT8_CODPRO","BT8_VERPRO","BT8_CODPAD","BT8_CODPSA"}
	oBrwBLU:aRelac     := {"BLU_CODPRO","BLU_VERPRO","BLU_CODPAD","BLU_CODPSA"}
Else
	bFilter  		   := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BLU_CODPRO",aHeader)] == cCodProSel .And.;
									   				aCols[nLine,GdFieldPos("BLU_CODPAD",aHeader)] == cCodPad 	 .And.;
									   				aCols[nLine,GdFieldPos("BLU_CODPSA",aHeader)] == cCodPsa}
	oBrwBLU   		   := TPLSBrw():New(0013,001,237,100,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBLU ,aDadBLU ,.F. ,"BLU" ,nOpcx,"CID",nil,nil,nil,aTrbBLU,,,bFilter)
	oBrwBLU:aOrigem    := {"BT8_CODPRO","BT8_CODPAD","BT8_CODPSA"}
	oBrwBLU:aRelac     := {"BLU_CODPRO","BLU_CODPAD","BLU_CODPSA"}
EndIf	
oBrwBLU:bGotFocus 	   := {|| 	oBrwBLU:SetPos(oBrwBLU:Linha()) }
oBrwBLU:bLostFocus 	   := {|| 	cCid 	:= oBrwBLU:FieldGet("BLU_CID"),;
								cSeqSel := oBrwBLU:FieldGet("BLU_SEQUEN")}
oBrwBLU:bChange    	   := {|| 	Eval(oBrwBLU:bLostFocus),;
						   		oBrwBLW:ForceRefresh(oBrwBLU) }
						   
Eval(oBrwBLU:bChange)						   

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| PlsEndBrw(),nOpca:=1,oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
   aDadBLU := aClone(oBrwBLU:aCols)
   aDadBLW := aClone(oBrwBLW:aCols)
Endif

oBrwCob:Atualiza()
oBrwCob:SetPos(nOldN)


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS660C   ºAutor  ³Geraldo Felix Juniorº Data ³  03/15/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para contrucao das GetDados do Sub-Contrato.        º±±
±±º          ³ Desmembrado da funcao PLS660CONS() devio ao "memory overflow"±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS660C(cAlias,nReg,nOpc)
Local aHeadTemp := {}
Local aColsTemp := {}
Local aVetTemp  := {}
LOCAL aButtBHG	:= {}

LOCAL cPrefix	:= ''
LOCAL cNumTit	:= ''
LOCAL cParcela  := ''
LOCAL cTipTit	:= ''
LOCAL cNumCob	:= ''
LOCAL oBotCon
LOCAL oBotAd01  
LOCAL aSize 	:= {}
LOCAL aInfo 	:= {}
LOCAL aObjects 	:= {}   
LOCAL aPosObj 	:= {}
LOCAL aInfo2 	:= {}
LOCAL aObjects2 := {}     
LOCAL aPosObj2 	:= {}
LOCAL aInfo3 	:= {}
LOCAL aObjects3 := {}     
LOCAL aPosObj3 	:= {}
LOCAL aInfo4 	:= {}
LOCAL aObjects4 := {}     
LOCAL aPosObj4 	:= {}
LOCAL aInfo5 	:= {}
LOCAL aObjects5 := {}     
LOCAL aPosObj5 	:= {}
LOCAL aInfo6 	:= {}
LOCAL aObjects6 := {}     
LOCAL aPosObj6 	:= {}
LOCAL aInfo7 	:= {}
LOCAL aObjects7 := {}         
LOCAL aPosObj7 	:= {}
LOCAL nTam		:=10	
LOCAL oTempBBT
LOCAL aStructBBT := {}
LOCAL aFieldsBBT := {}
LOCAL cWhere
LOCAL cOrderBy   := "" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aObjects := {}   
AAdd( aObjects, { 100, 20, .t., .f. } )    
AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
aPosObj := MsObjSize( aInfo, aObjects )     

aInfo2 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects2 := {}     
AAdd( aObjects2, { 100, 1, .t., .f. } )        
AAdd( aObjects2, { 100, 50, .t., .t.,.t. } )
AAdd( aObjects2, { 100, 50, .t., .t.,.t. } )
aPosObj2 := MsObjSize( aInfo2, aObjects2 )     

aInfo5 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects5 := {}     
AAdd( aObjects5, { 100, 1, .t., .f. } )        
AAdd( aObjects5, { 100, 100, .t., .t.,.t. } )
aPosObj5 := MsObjSize( aInfo5, aObjects5 )     

aInfo3 := { 0, 0, aPosObj5[2,3], aPosObj5[2,4], 3, 3 }
aObjects3 := {}     
AAdd( aObjects3, { 100, 80, .t., .t. } )  
AAdd( aObjects3, { 100, 80, .t., .t. } )
aPosObj3 := MsObjSize( aInfo3, aObjects3 )     

aInfo4 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects4 := {}     
AAdd( aObjects4, { 100, 1, .t., .f. } )    
AAdd( aObjects4, { 100, 100, .t., .t.,.f. } )
aPosObj4 := MsObjSize( aInfo4, aObjects4 )     

aInfo6 := { 0, 0, aPosObj2[3,3], aPosObj2[3,4], 3, 3 }
aObjects6 := {}         
AAdd( aObjects6, { 100, 100, .t., .t.,.t. } )
aPosObj6 := MsObjSize( aInfo6, aObjects6 )     

aInfo7 := { 0, 0, aPosObj6[1,3], aPosObj6[1,4], 3, 3 }
aObjects7 := {}         
AAdd( aObjects7, { 100, 100, .t., .t.,.t. } )
aPosObj7 := MsObjSize( aInfo7, aObjects7 )     

Store Header "BMF" TO aCabPPg For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BMF" TO aDadPPg FROM aCabPPg
Else
	BMF->(DbSetOrder(1))
	If ! BMF->(MsSeek(xFilial("BMF")+cChavSub))
		Store COLS Blank "BMF" TO aDadPPg FROM aCabPPg
	Else
		cTipPreSel := BMF->BMF_TIPPRE
		Store COLS "BMF" TO aDadPPg FROM aCabPPg VETTRAB aTrbPPg While BMF->(BMF_FILIAL+BMF_CODINT+BMF_CODEMP+BMF_NUMCON+BMF_VERCON+BMF_SUBCON+BMF_VERSUB) == xFilial("BMF")+cChavSub
	Endif
Endif

oBrwPPg  			:= TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3]-nTam,nil  ,oFolder:aDialogs[6], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPg,aDadPPg,.F.,"BMF",nOpcx,STR0064,nil,nil,nil,aTrbPPg) //"Parametros Pagamento Tipo Prestador"
oBrwPPg:bLostFocus 	:= { ||	cTipPreSel	:= oBrwPPg:FieldGet("BMF_TIPPRE") }
oBrwPPg:bChange    	:= { ||	Eval(oBrwPPg:bLostFocus),;
							oBrwPPP:ForceRefresh(oBrwPPg) }
oBrwPPg:cVldLine   	:= 'PL660VLDAT( {"BMF_TIPPRE","BMF_DATDE"},"BMF_DATDE" ) '
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento x Procedimentos...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BMG" TO aCabPPP For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BMG" TO aDadPPP FROM aCabPPP
Else
	BMG->(DbSetOrder(1))
	If ! BMG->(MsSeek(xFilial("BMG")+cChavSub))
		Store COLS Blank "BMG" TO aDadPPP FROM aCabPPP
	Else
		Store COLS "BMG" TO aDadPPP FROM aCabPPP VETTRAB aTrbPPP While BMG->(BMG_FILIAL+BMG_CODINT+BMG_CODEMP+BMG_NUMCON+BMG_VERCON+BMG_SUBCON+BMG_VERSUB) == xFilial("BMG")+cChavSub
	Endif
Endif

bFilter  			:= {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BMG_TIPPRE",aHeader)]	== cTipPreSel }
oBrwPPP  			:= TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3]-nTam,nil  ,oFolder:aDialogs[6], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPP,aDadPPP,.F.,"BMG",nOpcx,STR0065,nil,nil,nil,aTrbPPP,'PLSCHKBMG(oBrwPPP)',,bFilter) //"Parametros Pagamento Tipo Prestador X Procedimentos"
oBrwPPP:oPai       	:= oBrwPPg
oBrwPPP:aOrigem    	:= {"BMF_TIPPRE"}
oBrwPPP:aRelac     	:= {"BMG_TIPPRE"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento por especialidade                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BML" TO aCabBML For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BML" TO aDadBML FROM aCabBML
Else
	BML->(DbSetOrder(1))
	If ! BML->(MsSeek(xFilial("BML")+cChavSub))
		Store COLS Blank "BML" TO aDadBML FROM aCabBML
	Else
		cCodEspSel := BML->BML_CODESP
		Store COLS "BML" TO aDadBML FROM aCabBML VETTRAB aTrbBML While BML->(BML_FILIAL+BML_CODINT+BML_CODEMP+BML_NUMCON+BML_VERCON+BML_SUBCON+BML_VERSUB) == xFilial("BML")+cChavSub
	Endif
Endif

oBrwBML  := TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3]-nTam,nil  ,oFolder:aDialogs[8], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBML,aDadBML,.F.,"BML",nOpcx,STR0066,nil,nil,nil,aTrbBML) //"Parametros Pagamento Especialidade"
oBrwBML:bLostFocus := { ||	cCodEspSel 	:= oBrwBML:FieldGet("BML_CODESP") }
oBrwBML:bChange    := { ||	Eval(oBrwBML:bLostFocus),;
							oBrwBMM:ForceRefresh(oBrwBML) }
oBrwBML:cVldLine   := 'PL660VLDAT( {"BML_CODESP","BML_DATDE"},"BML_DATDE" ) '
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento x Procedimentos...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BMM" TO aCabBMM For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BMM" TO aDadBMM FROM aCabBMM
Else
	BMM->(DbSetOrder(1))
	If ! BMM->(MsSeek(xFilial("BMM")+cChavSub))
		Store COLS Blank "BMM" TO aDadBMM FROM aCabBMM
	Else
		Store COLS "BMM" TO aDadBMM FROM aCabBMM VETTRAB aTrbBMM While BMM->(BMM_FILIAL+BMM_CODINT+BMM_CODEMP+BMM_NUMCON+BMM_VERCON+BMM_SUBCON+BMM_VERSUB) == xFilial("BMM")+cChavSub
	Endif
Endif

bFilter  := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BMM_CODESP",aHeader)]	== cCodEspSel }
oBrwBMM  := TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3]-nTam,nil  ,oFolder:aDialogs[08], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBMM,aDadBMM,.F.,"BMM",nOpcx,STR0067,nil,nil,nil,aTrbBMM,,,bFilter) //"Parametros Pagamento Especialidade X Procedimentos"
oBrwBMM:oPai       := oBrwBML
oBrwBMM:aOrigem    := {"BML_CODESP"}
oBrwBMM:aRelac     := {"BMM_CODESP"}
oBrwBMM:cVldLine   := 'PLSCHKBMM(oBrwBMM) .and. PL660VLDAT( {"BMM_CODPSA","BMM_CODPAD","BMM_DATDE"},"BMM_DATDE" ) '
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Diferenciacao do filme por subcontrato...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If PLSALIASEX("BG6")
   Store Header "BG6" TO aCabBG6 For .T.
   If nOpcx == K_Incluir
   	  Store COLS Blank "BG6" TO aDadBG6 FROM aCabBG6
   Else
  	  BG6->(DbSetOrder(1))
	  If ! BG6->(MsSeek(xFilial("BG6")+cChavSub))
		  Store COLS Blank "BG6" TO aDadBG6 FROM aCabBG6
	  Else
	  	  Store COLS "BG6" TO aDadBG6 FROM aCabBG6 VETTRAB aTrbBG6 While BG6->(BG6_FILIAL+BG6_CODINT+BG6_CODEMP+BG6_NUMCON+BG6_VERCON+BG6_SUBCON+BG6_VERSUB) == xFilial("BG6")+cChavSub
	  Endif
   Endif

   oBrwBG6  		:= TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[11], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBG6,aDadBG6,.F.,"BG6",nOpcx,STR0068,nil,nil,nil,aTrbBG6) //"Diferenciacao do Filme"
   oBrwBG6:cVldLine := 'PLSVLDVIG("BG6",nOpcx,oBrwBG6,"BG6_DATINI","BG6_DATFIN")'
Endif

If PLSALIASEX("BYU")
   Store Header "BYU" TO aCabBYU For .T.
   If nOpcx == K_Incluir
   	  Store COLS Blank "BYU" TO aDadBYU FROM aCabBYU
   Else
  	  BYU->(DbSetOrder(1))
	  If ! BYU->(MsSeek(xFilial("BYU")+cChavSub))
		  Store COLS Blank "BYU" TO aDadBYU FROM aCabBYU
	  Else
	  	  Store COLS "BYU" TO aDadBYU FROM aCabBYU VETTRAB aTrbBYU While BYU->(BYU_FILIAL+BYU_CODINT+BYU_CODEMP+BYU_NUMCON+BYU_VERCON+BYU_SUBCON+BYU_VERSUB) == xFilial("BYU")+cChavSub
	  Endif
   Endif

   oBrwBYU  		:= TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[12], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBYU,aDadBYU,.F.,"BYU",nOpcx,STR0124,nil,nil,nil,aTrbBYU) //"Informacoes ANS"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Protecao financeira                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("BDV")
   Store Header "BDV" TO aCabBDV For .T.
   If nOpcx == K_Incluir
   	  Store COLS Blank "BDV" TO aDadBDV FROM aCabBDV
   Else
  	  BDV->(DbSetOrder(1))
	  If ! BDV->(MsSeek(xFilial("BDV")+cChavSub))
		  Store COLS Blank "BDV" TO aDadBDV FROM aCabBDV
	  Else
	  	  Store COLS "BDV" TO aDadBDV FROM aCabBDV VETTRAB aTrbBDV While BDV->(BDV_FILIAL+BDV_CODINT+BDV_CODEMP+BDV_NUMCON+BDV_VERCON+BDV_SUBCON+BDV_VERSUB) == xFilial("BDV")+cChavSub
	  Endif
   Endif
   oBrwBDV  		:= TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[nPosFldBDV], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBDV,aDadBDV,.F.,"BDV",nOpcx,"Proteção Financeira",nil,nil,nil,aTrbBDV) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento por OPERADORA                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If PLSALIASEX("BKA")
   Store Header "BKA" TO aCabBKA For .T.
   If nOpcx == K_Incluir
   	  Store COLS Blank "BKA" TO aDadBKA FROM aCabBKA
   Else
  	  BKA->(DbSetOrder(1))
	  If ! BKA->(MsSeek(xFilial("BKA")+cChavSub))
		  Store COLS Blank "BKA" TO aDadBKA FROM aCabBKA
	  Else
	      cCodOpeSel := BKA->BKA_CODOPE
	  	  Store COLS "BKA" TO aDadBKA FROM aCabBKA VETTRAB aTrbBKA While BKA->(BKA_FILIAL+BKA_CODINT+BKA_CODEMP+BKA_NUMCON+BKA_VERCON+BKA_SUBCON+BKA_VERSUB) == xFilial("BKA")+cChavSub
	  Endif
   Endif

   oBrwBKA  := TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3]-nTam,nil  ,oFolder:aDialogs[10], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBKA,aDadBKA,.F.,"BKA",nOpcx,STR0069,nil,nil,nil,aTrbBKA) //"Parametros Pagamento Operadora"
   oBrwBKA:bLostFocus := { ||	cCodOpeSel	:= oBrwBKA:FieldGet("BKA_CODOPE") }
   oBrwBKA:bChange    := { ||	Eval(oBrwBKA:bLostFocus),;
   								oBrwBKB:ForceRefresh(oBrwBKA) }
   oBrwBKA:cVldLine   := 'PL660VLDAT( {"BKA_CODOPE","BKA_DATDE"},"BKA_DATDE" ) '
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento x Procedimentos...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Store Header "BKB" TO aCabBKB For .T.
   If nOpcx == K_Incluir
      Store COLS Blank "BKB" TO aDadBKB FROM aCabBKB
   Else
      BKB->(DbSetOrder(1))
	  If ! BKB->(MsSeek(xFilial("BKB")+cChavSub))
	     Store COLS Blank "BKB" TO aDadBKB FROM aCabBKB
  	  Else
	 	 Store COLS "BKB" TO aDadBKB FROM aCabBKB VETTRAB aTrbBKB While BKB->(BKB_FILIAL+BKB_CODINT+BKB_CODEMP+BKB_NUMCON+BKB_VERCON+BKB_SUBCON+BKB_VERSUB) == xFilial("BKB")+cChavSub
	 Endif
   Endif

   bFilter  := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BKB_CODOPE",aHeader)]	== cCodOpeSel }
   oBrwBKB  := TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3]-nTam,nil  ,oFolder:aDialogs[10], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBKB,aDadBKB,.F.,"BKB",nOpcx,STR0070,nil,nil,nil,aTrbBKB,,,bFilter) //"Parametros Pagamento Operadora X Procedimentos"
   oBrwBKB:oPai       := oBrwBKA
   oBrwBKB:aOrigem    := {"BKA_CODOPE"}
   oBrwBKB:aRelac     := {"BKB_CODOPE"}
   oBrwBKB:cVldLine   := 'PLSCHKBKB(oBrwBKB) .AND. PL660VLDAT( {"BKB_CODPSA","BKB_CODPAD","BKB_DATDE"},"BKB_DATDE" ) '
EndIf 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento Especifico Prestador...                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BMH" TO aCabPPgPRE For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BMH" TO aDadPPgPRE FROM aCabPPgPRE
Else
	BMH->(DbSetOrder(1))
	If ! BMH->(MsSeek(xFilial("BMH")+cChavSub))
		Store COLS Blank "BMH" TO aDadPPgPRE FROM aCabPPgPRE
	Else
		cTipRDASel := BMH->BMH_CODRDA
		Store COLS "BMH" TO aDadPPgPRE FROM aCabPPgPRE VETTRAB aTrbPPgPRE While BMH->(BMH_FILIAL+BMH_CODINT+BMH_CODEMP+BMH_NUMCON+BMH_VERCON+BMH_SUBCON+BMH_VERSUB) == xFilial("BMH")+cChavSub
	Endif
Endif

oBrwPPgPRE  := TPLSBrw():New(aPosObj3[1][1],aPosObj3[1][2],aPosObj3[1][4],aPosObj3[1][3]-nTam,nil  ,oFolder:aDialogs[7], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPgPRE,aDadPPgPRE,.F.,"BMH",nOpcx,STR0071,nil,nil,nil,aTrbPPgPRE) //"Parametros Pagamento Prestador"
oBrwPPgPRE:bLostFocus := { ||	cTipRDASel	:= oBrwPPgPRE:FieldGet("BMH_CODRDA") }
oBrwPPgPRE:bChange    := { ||	Eval(oBrwPPgPRE:bLostFocus),;
								oBrwPPPPRE:ForceRefresh(oBrwPPgPRE) }
oBrwPPgPRE:cVldLine   := 'PL660VLDAT( {"BMH_CODRDA","BMH_DATDE"},"BMH_DATDE" ) '
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento x Procedimentos Prestador...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BMI" TO aCabPPPPRE For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BMI" TO aDadPPPPRE FROM aCabPPPPRE
Else
	BMI->(DbSetOrder(1))
	If ! BMI->(MsSeek(xFilial("BMI")+cChavSub))
		Store COLS Blank "BMI" TO aDadPPPPRE FROM aCabPPPPRE
	Else
		Store COLS "BMI" TO aDadPPPPRE FROM aCabPPPPRE VETTRAB aTrbPPPPRE While BMI->(BMI_FILIAL+BMI_CODINT+BMI_CODEMP+BMI_NUMCON+BMI_VERCON+BMI_SUBCON+BMI_VERSUB) == xFilial("BMI")+cChavSub
	Endif
Endif

bFilter  := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BMI_CODRDA",aHeader)]	== cTipRDASel }
oBrwPPPPRE  := TPLSBrw():New(aPosObj3[2][1],aPosObj3[2][2],aPosObj3[2][4],aPosObj3[2][3]-nTam,nil  ,oFolder:aDialogs[7], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabPPPPRE,aDadPPPPRE,.F.,"BMI",nOpcx,STR0072,nil,nil,nil,aTrbPPPPRE,,,bFilter) //"Parametros Pagamento Prestador X Procedimentos "
oBrwPPPPRE:oPai       := oBrwPPgPRE
oBrwPPPPRE:aOrigem    := {"BMH_CODRDA"}
oBrwPPPPRE:aRelac     := {"BMI_CODRDA"}
oBrwPPPPRE:cVldLine   := 'PLSCHKBMI(oBrwPPPPRE) .and.  PL660VLDAT( {"BMI_CODPSA","BMI_CODPAD","BMI_DATDE"},"BMI_DATDE" ) '

If nOpc <> K_Incluir
	PLS660SCab(.F.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ COBRANCA DE IDENTIFICACAO DE USUARIO                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJC" TO aCabBJC For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BJC" TO aDadBJC FROM aCabBJC
Else
	BJC->(DbSetOrder(1))
	If ! BJC->(MsSeek(xFilial("BJC")+cChavSub))
		Store COLS Blank "BJC" TO aDadBJC FROM aCabBJC
	Else
		Store COLS "BJC" TO aDadBJC FROM aCabBJC VETTRAB aTrbBJC While xFilial("BJC")+cChavSub == BJC->(BJC_FILIAL+BJC_CODINT+BJC_CODEMP+BJC_NUMCON+BJC_VERCON+BJC_SUBCON+BJC_VERSUB)
	Endif
Endif

oBrwBJC := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[4],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBJC   ,aDadBJC ,.F.      ,"BJC" ,nOpcx,STR0074,nil,nil,nil,aTrbBJC,,,) //"Cobranca de Identificacao de Usuario"
oBrwBJC:cVldLine := 'PLSXANAFAI( { "BJC_MOTIVO","BJC_TIPUSR","BJC_GRAUPA" },"BJC_EMIDE","BJC_EMIATE",n)'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Docs Obrigatorios dos Usuarios                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BCO" TO aCabBCO For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BCO" TO aDadBCO FROM aCabBCO
Else
	BCO->(DbSetOrder(1))
	If ! BCO->(MsSeek(xFilial("BCO")+cChavSub))
		Store COLS Blank "BCO" TO aDadBCO FROM aCabBCO
	Else
		Store COLS "BCO" TO aDadBCO FROM aCabBCO VETTRAB aTrbBCO While xFilial("BCO")+cChavSub == BCO->(BCO_FILIAL+BCO_CODOPE+BCO_CODEMP+BCO_NUMCON+BCO_VERCON+BCO_SUBCON+BCO_VERSUB)
	Endif
Endif
oBrwBCO 		 := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[5],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBCO   ,aDadBCO ,.F.      ,"BCO" ,nOpcx,STR0075,nil,nil,nil,aTrbBCO,,,) //"Docs. Obrigat. Usuarios"
oBrwBCO:cVldLine := 'PLSXANAFAI( { "BCO_CODDOC","BCO_TIPUSR","BCO_GRAUPA" },"BCO_IDAINI","BCO_IDAFIN",n)'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FINANCEIRO...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFinanc
	Store Header "BBT" TO aCabFin For AllTrim(SX3->X3_CAMPO) $ "BBT_MESTIT,BBT_ANOTIT,BBT_CLIFOR,BBT_PREFIX,BBT_NUMTIT,BBT_PARCEL,BBT_TIPTIT,BBT_NUMCOB,BBT_RECPAG,BBT_VALOR"
	
	If nOpcx == K_Incluir
		Store COLS Blank "BBT" TO aDadFin FROM aCabFin
	Else
		cWhere := " WHERE BBT_FILIAL = '"+xFilial("BBT")+"' and BBT_CODOPE = '"+BG9->BG9_CODINT+"' and  "
		cWhere += "BBT_CODEMP = '"+BG9->BG9_CODIGO+"' and BBT_CONEMP = '"+BQC->BQC_NUMCON+"' and "
		cWhere += "BBT_VERCON = '"+BQC->BQC_VERCON+"' and BBT_SUBCON = '"+BQC->BQC_SUBCON+"' and "
		cWhere += "BBT_VERSUB = '"+BQC->BQC_VERSUB+"' and BBT_NIVEL  = '3' and D_E_L_E_T_ = ' ' "

		cOrderBy := " ORDER BY "  
		cOrderBy += "BBT_FILIAL, " 
		cOrderBy += "BBT_NIVEL, " 
		cOrderBy += "BBT_CODOPE, " 
		cOrderBy += "BBT_CODEMP, " 
		cOrderBy += "BBT_CONEMP, " 
		cOrderBy += "BBT_VERCON, " 
		cOrderBy += "BBT_SUBCON, " 
		cOrderBy += "BBT_VERSUB, " 
		cOrderBy += "BBT_ANOTIT, " 
		cOrderBy += "BBT_MESTIT" 

		MPSysOpenQuery( "select * from " + RetSqlName( "BBT" ) + cWhere + cOrderBy,'QRYBBT' ) 
		
		Store COLS "QRYBBT" TO aDadFin FROM aCabFin VETTRAB aTrbFin While .T.
		
		if( select( "QRYBBT" ) > 0 )
			QRYBBT->( dbCloseArea() )
		endIf		
		
		if( select( "TEMPBBT" ) > 0 )
			oTempBBT:delete()
		endIf
	
		If Len(aDadFin) == 0
			Store COLS Blank "BBT" TO aDadFin FROM aCabFin
			@ 005, 006 Say oSayFin PROMPT STR0076 SIZE 150, 006 OF oFolder:aDialogs[9] PIXEL COLOR CLR_HBLUE //"Nao ha titulos no financeiro para este Sub-contrato"
		Else
			oBrwFin := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.71,nil  ,oFolder:aDialogs[9],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabFin   ,aDadFin ,.F.      ,"BBT" ,K_Visualizar,STR0022,nil,nil,nil,aTrbFin,,,) //"Historico Financeiro"
			oBrwFin:bGotFocus  := {||	cPrefix  	:= oBrwFin:FieldGet("BBT_PREFIX"),;
								      	cNumTit  	:= oBrwFin:FieldGet("BBT_NUMTIT"),;
								      	cParcela 	:= oBrwFin:FieldGet("BBT_PARCEL"),;
								      	cTipTit  	:= oBrwFin:FieldGet("BBT_TIPTIT"),;
								      	cNumCob  	:= oBrwFin:FieldGet("BBT_NUMCOB"),;
							  		  	lAtivConFin := .T.}
			oBrwFin:bLostFocus := {|| lAtivConFin := .F.}
			oBrwFin:bChange    := {||Eval(oBrwFin:bGotFocus)}

			oBotCon := SButton():New(aPosObj4[2][3]*0.81, 005, 09, {|| PLSCOMPFIN(cPrefix,cNumTit,cParcela,;
			                                                      cTipTit,cNumCob,.F.,.F.) },;
			                                                      oFolder:aDialogs[9], .T.)   
			oBotCon:cCaption := STR0151 //"Comp. tit."
			oBotCon:cTOOLTIP := STR0077 //"Composicao do titulo"
		Endif
	Endif
Else
	@ 005, 006 Say oSayFin PROMPT STR0076 SIZE 150, 006 OF oFolder:aDialogs[9] PIXEL COLOR CLR_HBLUE	 //"Nao ha titulos no financeiro para este Sub-contrato"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PRODUTOS RELACIONADOS AOS CONTRATOS                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT6" TO aCabPro For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT6" TO aDadPro FROM aCabPro
Else
	BT6->(DbSetOrder(1))
	If ! BT6->(MsSeek(xFilial("BT6")+cChavSub))
		Store COLS Blank "BT6" TO aDadPro FROM aCabPro
	Else                          
		If BT6->( FieldPos("BT6_ALLCRE") ) > 0
		   lChkRDF := IF( BT6->BT6_ALLCRE == "1",.T.,.F. )
		EndIf	
//		cAllusr    := BT6->BT6_ALLUSR
       cCodNumCon := BT6->BT6_NUMCON
       cCodVerCon := BT6->BT6_VERCON
		cCodNumSubCon := BT6->BT6_SUBCON
       cCodVerSubCon := BT6->BT6_VERSUB
		cCodProSel := BT6->BT6_CODPRO
		cVersaoSel := BT6->BT6_VERSAO
		cDesProSel := BI3->(Posicione("BI3",1,xFilial("BI3")+BG9->BG9_CODINT+cCodProSel+cVersaoSel,"BI3_DESCRI"))
		Store COLS "BT6" TO aDadPro FROM aCabPro VETTRAB aTrbPro While xFilial("BT6")+cChavSub == BT6->(BT6_FILIAL+BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB)
	Endif
Endif

oBrwPro := TPLSBrw():New(aPosObj2[2,1],aPosObj2[2,2],aPosObj2[2,3]-nTam,aPosObj2[2,4],nil  ,oFolder:aDialogs[3],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabPro   ,aDadPro ,.F.      ,"BT6" ,nOpcx,STR0133,nil,nil,nil,aTrbPro,,"PL660Del( BT5->(BT5_CODINT+BT5_CODIGO+BT5_NUMCON+BT5_VERSAO)+ M->(BQC_SUBCON+BQC_VERSUB))",,{|| PL660FORMA() }) //"Produtos"

//cAllUsr := oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:FieldPos("BT6_ALLUSR",aCabPro)],;
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa se o campo existe, atualiza a variavel de controle do checkbox³ 
//³	e da um refresh no browse onde esta dando o fieldpos				³
//³ Todo o Browse que tem o pai como browse produto e tem um botao      ³
//³ posibilita ir direto no botao sem clicar no browse filho 			³
//³ fazendo com isso que o valor de nAt se perca por isso foi feito a 	³
//³ implementacao de valor 1 no blostfocus do browse produto			³
//³ Alexander 14/07/2005												³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwPro:bLostFocus := {||	cCodProSel := oBrwPro:FieldGet("BT6_CODPRO"),;
							cVersaoSel := oBrwPro:FieldGet("BT6_VERSAO"),;
							cDesProSel := BI3->(Posicione("BI3",1,xFilial("BI3")+BG9->BG9_CODINT+cCodProSel,"BI3_DESCRI")),;
							Iif( BT6->( FieldPos("BT6_ALLCRE") ) > 0, ( lChkRDF := oBrwPro:FieldGet("BT6_ALLCRE") == "1" , oChkRDF:Refresh() ),.T. ),;
							oBrwCob:oBrowse:nAt := 1,oBrwBGG:oBrowse:nAt := 1,;
							oBrwBGP:oBrowse:nAt := 1,oBrwFor:oBrowse:nAt := 1,;
							oBrwCob:oBrowse:nAt := 1,oBrwQtd:oBrowse:nAt := 1,;
							oBrwGru:oBrowse:nAt := 1,oBrwBEY:oBrowse:nAt := 1,;
							oBrwOpc:oBrowse:nAt := 1,oBrwB33:oBrowse:nAt := 1 }
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse relacionados como o produto							 ³
//³ Obs:O obj oBrwFrOpc e PLSCHKPF NA BJW nao e relacionado com o produto³
//³  e sim com o opcional esta no change para efeito visual				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If BT7->( FieldPos('BT7_VERPRO') ) > 0 .And. BT8->( FieldPos('BT8_VERPRO') ) > 0 .And.;
   BHS->( FieldPos('BHS_VERPRO') ) > 0 
	oBrwPro:bChange    := {||  PLSCHKPF( "BT6_CODPRO+BT6_VERSAO",{'BTK_CODPRO+BTK_VERSAO','BT9_CODPRO+BT9_VERSAO','BT7_CODPRO+BT7_VERPRO','BT8_CODPRO+BT8_VERPRO','BHS_CODPRO+BHS_VERPRO'} ),;
								PLSCHKPF( "BHS_CODPLA+BHS_VERPLA",{'BJW_CODOPC+BJW_VEROPC'} ),;
								Eval(oBrwPro:bLostFocus),;
								oBrwBGG:ForceRefresh(oBrwPro),oBrwBGP:ForceRefresh(oBrwPro)		,;
								oBrwFor:ForceRefresh(oBrwPro),oBrwCob:ForceRefresh(oBrwPro)		,;
								oBrwQtd:ForceRefresh(oBrwPro),oBrwUsp:ForceRefresh(oBrwPro)		,;
								oBrwGru:ForceRefresh(oBrwPro),oBrwBA6:ForceRefresh(oBrwPro)		,;
								oBrwBEY:ForceRefresh(oBrwPro),;
								oBrwSAD:ForceRefresh(oBrwPro),oBrwCPro:ForceRefresh(oBrwPro)	,;
								oBrwAde:ForceRefresh(oBrwPro)	,;
								oBrwOpc:ForceRefresh(oBrwPro),Iif(oFolPro:nOption == 7, oBrwOpc:oBrowse:oBrowse:setFocus(),), Eval(oBrwOpc:bLostFocus)			,;								
								oBrwFrOpc:ForceRefresh(oBrwOpc),oBrwRDF:ForceRefresh(oBrwPro),;
								oBrwB33:ForceRefresh(oBrwPro)}
Else
	oBrwPro:bChange    := {||	PLSCHKPF( "BT6_CODPRO",{'BT7_CODPRO','BT8_CODPRO','BHS_CODPRO'} ),; 
								PLSCHKPF( "BT6_CODPRO+BT6_VERSAO",{'BTK_CODPRO+BTK_VERSAO','BT9_CODPRO+BT9_VERSAO'} ),;
								PLSCHKPF( "BHS_CODPLA+BHS_VERPLA",{'BJW_CODOPC+BJW_VEROPC'} ),;
								Eval(oBrwPro:bLostFocus),;
								Iif(Type('oBrwBGG')=='O',oBrwBGG:ForceRefresh(oBrwPro),''),;
								oBrwBGP:ForceRefresh(oBrwPro),;
								oBrwFor:ForceRefresh(oBrwPro),oBrwCob:ForceRefresh(oBrwPro)		,;
								oBrwQtd:ForceRefresh(oBrwPro),oBrwUsp:ForceRefresh(oBrwPro)		,;
								oBrwGru:ForceRefresh(oBrwPro),oBrwBA6:ForceRefresh(oBrwPro)		,;
								oBrwBEY:ForceRefresh(oBrwPro)		,;
								oBrwSAD:ForceRefresh(oBrwPro),oBrwCPro:ForceRefresh(oBrwPro)	,;
								oBrwAde:ForceRefresh(oBrwPro)	,;
								oBrwOpc:ForceRefresh(oBrwPro),Iif(oFolPro:nOption == 7, oBrwOpc:oBrowse:oBrowse:setFocus(),), Eval(oBrwOpc:bLostFocus)			,;
								oBrwFrOpc:ForceRefresh(oBrwOpc),Iif(Type('oBrwRDF')=='O',oBrwRDF:ForceRefresh(oBrwPro),''),;
								oBrwB33:ForceRefresh(oBrwPro)}
EndIf								
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Taxas de Adesao...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BTK" TO aCabAde For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BTK" TO aDadAde FROM aCabAde
Else
	BTK->(DbSetOrder(1))
	If ! BTK->(MsSeek(xFilial("BTK")+cChavSub))
		Store COLS Blank "BTK" TO aDadAde FROM aCabAde
	Else
		Store COLS "BTK" TO aDadAde FROM aCabAde VETTRAB aTrbAde While xFilial("BTK")+cChavSub == BTK->(BTK_FILIAL+BTK_CODIGO+BTK_NUMCON+BTK_VERCON+BTK_SUBCON+BTK_VERSUB)
	Endif
Endif

bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BTK_CODPRO",aHeader)]== cCodProSel .And.;
								 	aCols[nLine,GdFieldPos("BTK_VERSAO",aHeader)]== cVersaoSel }
oBrwAde := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil  ,oFolPro:aDialogs[3],nil    , nil,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabAde   ,aDadAde ,.F.      ,"BTK" ,nOpcx,STR0078,nil,nil,nil,aTrbAde,,"PLSM660Del(" + Str(nOpcx, 1) + ",2)",bFilter) //"Valores de Adesao"
oBrwAde:oPai    := oBrwPro
oBrwAde:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
oBrwAde:aRelac  := {"BTK_CODPRO","BTK_VERSAO"}


@ aPosObj6[1][4]*0.60, 005 BUTTON oBotAde PROMPT STR0079 ACTION {|| PLSA660For(nOpcx,2) } SIZE 45, 11 OF oFolPro:aDialogs[3] PIXEL //"Propriedades"
oBotAde:cTOOLTIP := STR0080 //"Propriedades da Forma de Cobranca da Taxa de Adesao"

@ aPosObj6[1][4]*0.60, 055 BUTTON oBotAd01 PROMPT STR0081 ACTION {|| PLSHISFAI("BYE",	BQC->( BQC_CODINT+BQC_CODEMP+BQC_NUMCON+; //"&Historicos"
															       BQC_VERCON+BQC_SUBCON+BQC_VERSUB+;
															       BQC_CODINT),;
																	"BYE->( BYE_FILIAL+BYE_CODOPE+BYE_CODEMP+"+;
																   "BYE_CONEMP+BYE_VERCON+BYE_SUBCON+"+;
																   "BYE_VERSUB+BYE_OPEREA)",1)} SIZE 45, 11 OF oFolPro:aDialogs[3] PIXEL

																   
oBotAd01:cTOOLTIP := "Historicos"
																   
oBrwAde:bChange  := { || 	If(oBrwAde:IsDeleted(oBrwAde:Linha()),;
							oBotAde:Disable(), oBotAde:Enable()) }												
oBrwAde:bLostFocus  := { || Eval(oBrwAde:bChange) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados dos Opcionais do Produto                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHS" TO aCabOpc For .T.

If nOpcx == K_Incluir
	Store COLS Blank "BHS" TO aDadOpc FROM aCabOpc
Else
	BHS->(DbSetOrder(1))
	If ! BHS->(MsSeek(xFilial("BHS")+cChavSub))
		Store COLS Blank "BHS" TO aDadOpc FROM aCabOpc
	Else
		cCodOpcSel := BHS->BHS_CODPLA
		cVerOpcSel := BHS->BHS_VERPLA
		Store COLS "BHS" TO aDadOpc FROM aCabOpc VETTRAB aTrbOpc While xFilial("BHS")+cChavSub == BHS->(BHS_FILIAL+BHS_CODINT+BHS_CODIGO+BHS_NUMCON+BHS_VERCON+BHS_SUBCON+BHS_VERSUB)
	Endif
Endif

bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHS_CODPRO",aHeader)]== cCodProSel .And.;
								 	aCols[nLine,GdFieldPos("BHS_VERPRO",aHeader)]== cVersaoSel }
oBrwOpc := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.8 ,nil  ,oFolPro:aDialogs[7],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabOpc   ,aDadOpc ,.F.      ,"BHS" ,nOpcx,STR0082,nil,nil,nil,aTrbOpc,nil,IIf(ExistBlock("PL660OUS"),'PL660DOP()' ,"PLSM660Del(" + Str(nOpcx, 1) + ",3,.T.)"),bFilter  ) //"Opcional" "Pls660DRel"
oBrwOpc:oPai    := oBrwPro
oBrwOpc:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
oBrwOpc:aRelac  := {"BHS_CODPRO","BHS_VERPRO"}

oBrwOpc:bLostFocus := {||	cCodOpcSel := oBrwOpc:FieldGet("BHS_CODPLA"),;
						    cVerOpcSel := oBrwOpc:FieldGet("BHS_VERPLA") }
oBrwOpc:bChange    := {||	PLSCHKPF( "BHS_CODPLA+BHS_VERPLA",{'BJW_CODOPC+BJW_VEROPC'} ),;	//Opcionais forma de cobranca
							Eval(oBrwOpc:bLostFocus) }

// folder CO-PARTICIPACAO DENTRO DE ESPECIALIDADE DENTRO DE PROCEDIMENTOS DENTRO DE OPCIONAIS
Store Header "BZM" TO aHeadTemp For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BZM" TO aColsTemp FROM aHeadTemp
Else
	BZM->(DbSetOrder(1))
	If ! BZM->(MsSeek(xFilial("BZM")+cChavSub))
		Store COLS Blank "BZM" TO aColsTemp FROM aHeadTemp
	Else
		Store COLS "BZM" TO aColsTemp FROM aHeadTemp VETTRAB aVetTemp While xFilial("BZM")+cChavSub == BZM->(BZM_FILIAL+BZM_CODIGO+BZM_NUMCON+BZM_VERCON+BZM_SUBCON+BZM_VERSUB)
	Endif
Endif
aCabBZM := aClone(aHeadTemp)
aDadBZM := aClone(aColsTemp)
aVetBZM := aClone(aVetTemp)
aHeadTemp := {}
aColsTemp := {}
aVetTemp  := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de Co-Participacao para o Produto      			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHG" TO aCabCPro For .T.

If nOpcx == K_Incluir
	Store COLS Blank "BHG" TO aDadCPro FROM aCabCPro
Else
	BHG->(DbSetOrder(1))
	If ! BHG->(MsSeek(xFilial("BHG")+cChavSub))
		Store COLS Blank "BHG" TO aDadCPro FROM aCabCPro
	Else
		Store COLS "BHG" TO aDadCPro FROM aCabCPro VETTRAB aTrbCPro While xFilial("BHG")+cChavSub == BHG->(BHG_FILIAL+BHG_CODINT+BHG_CODIGO+BHG_NUMCON+BHG_VERCON+BHG_SUBCON+BHG_VERSUB)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de Co-Participacao para o Produto      			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBHG, {"BUDGET",{||PL660HTFRA('1',"BHG",	cChavSub,;
													oBrwCPro:FieldGet("BHG_CODPRO"),;
													Iif((BHG->( FieldPos("BHG_VERPRO") ) > 0), oBrwCPro:FieldGet("BHG_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif

If BHG->( FieldPos("BHG_VERPRO") ) > 0
	bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHG_CODPRO",aHeader)]== cCodProSel .And.;
									 	aCols[nLine,GdFieldPos("BHG_VERPRO",aHeader)]== cVersaoSel}
	oBrwCPro := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.71 ,nil  ,oFolPro:aDialogs[4],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCPro   ,aDadCPro ,.F.      ,"BHG" ,nOpcx,STR0028,nil,nil,nil,aTrbCPro,'PlsVldBHG',,bFilter,,aButtBHG) //"Co-participacao"
	oBrwCPro:oPai    := oBrwPro
	oBrwCPro:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwCPro:aRelac  := {"BHG_CODPRO","BHG_VERPRO"}
Else
	bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BHG_CODPRO",aHeader)]== cCodProSel}
	oBrwCPro := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][1],aPosObj6[1][3],aPosObj6[1][4]*0.71 ,nil  ,oFolPro:aDialogs[4],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCPro   ,aDadCPro ,.F.      ,"BHG" ,nOpcx,STR0028,nil,nil,nil,aTrbCPro,'PlsVldBHG',,bFilter,,aButtBHG) //"Co-participacao"
	oBrwCPro:oPai    := oBrwPro
	oBrwCPro:aOrigem := {"BT6_CODPRO"}
	oBrwCPro:aRelac  := {"BHG_CODPRO"}
EndIf	               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de Sit Adversas  para   o Produto                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHN" TO aCabSAD  For .T.

If nOpcx == K_Incluir
	Store COLS Blank "BHN" TO aDadSAD  FROM aCabSAD
Else
	BHN->(DbSetOrder(1))
	If ! BHN->(MsSeek(xFilial("BHN")+cChavSub))
		Store COLS Blank "BHN" TO aDadSAD  FROM aCabSAD
	Else
		Store COLS "BHN" TO aDadSAD  FROM aCabSAD  VETTRAB aTrbSAD  While xFilial("BHN")+cChavSub == BHN->(BHN_FILIAL+BHN_CODINT+BHN_CODIGO+BHN_NUMCON+BHN_VERCON+BHN_SUBCON+BHN_VERSUB)
	Endif
Endif
If BHN->( FieldPos("BHN_VERPRO") ) > 0
	bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BHN_CODPRO",aHeader)]== cCodProSel .And.;
									 	aCols[nLine,GdFieldPos("BHN_VERPRO",aHeader)]== cVersaoSel}
	oBrwSAD := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.71 ,nil  ,oFolPro:aDialogs[5],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabSAD   ,aDadSAD ,.F.      ,"BHN" ,nOpcx,STR0030,nil,nil,nil,aTrbSAD,,,bFilter) //"Situacao Adversa"
	oBrwSAD:oPai    := oBrwPro
	oBrwSAD:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwSAD:aRelac  := {"BHN_CODPRO","BHN_VERPRO"}
Else
	bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BHN_CODPRO",aHeader)]== cCodProSel}
	oBrwSAD := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.71,nil  ,oFolPro:aDialogs[5],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabSAD   ,aDadSAD ,.F.      ,"BHN" ,nOpcx,STR0030,nil,nil,nil,aTrbSAD,,,bFilter) //"Situacao Adversa"
	oBrwSAD:oPai    := oBrwPro
	oBrwSAD:aOrigem := {"BT6_CODPRO"}
	oBrwSAD:aRelac  := {"BHN_CODPRO"}
EndIf	                                   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de Regras Nov Dep p/    o Produto                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BEY" TO aCabBEY  For .T.

If nOpcx == K_Incluir
	Store COLS Blank "BEY" TO aDadBEY  FROM aCabBEY
Else
	BEY->(DbSetOrder(1))
	If ! BEY->(MsSeek(xFilial("BEY")+cChavSub))
		Store COLS Blank "BEY" TO aDadBEY  FROM aCabBEY
	Else
		cCodSeqBEY := BEY->BEY_SEQUEN
		Store COLS "BEY" TO aDadBEY  FROM aCabBEY VETTRAB aTrbBEY While xFilial("BEY")+cChavSub == BEY->(BEY_FILIAL+BEY_CODINT+BEY_CODIGO+BEY_NUMCON+BEY_VERCON+BEY_SUBCON+BEY_VERSUB)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Clas.Caren. novos Dep. SubCont										³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BWV" TO aCabBWV For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BWV" TO aDadBWV FROM aCabBWV
Else
	BWV->(DbSetOrder(1))
	If BWV->(MsSeek(xFilial("BWV")+cChavSub))
		Store COLS "BWV" TO aDadBWV FROM aCabBWV VETTRAB aTrbBWV While BWV->(BWV_FILIAL+BWV_CODINT+BWV_CODIGO+BWV_NUMCON+BWV_VERCON+BWV_SUBCON+BWV_VERSUB) == xFilial("BWV")+cChavSub
	Else
		Store COLS Blank "BWV" TO aDadBWV FROM aCabBWV
	Endif
Endif

If BEY->( FieldPos("BEY_VERPRO") ) > 0
	bFilter 			:= {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BEY_CODPRO",aHeader)]== cCodProSel .And.;
													aCols[nLine,GdFieldPos("BEY_VERPRO",aHeader)]== cVersaoSel}
	oBrwBEY 			:= TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[4],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBEY   ,aDadBEY ,.F.      ,"BEY" ,nOpcx,STR0041,nil,nil,nil,aTrbBEY,,,bFilter) //"Carencias p/ Novos Usuarios"
	oBrwBEY:oPai    	:= oBrwPro
	oBrwBEY:aOrigem 	:= {"BT6_CODPRO","BT6_VERSAO"}
	oBrwBEY:aRelac  	:= {"BEY_CODPRO","BEY_VERPRO"}
Else
	bFilter 			:= {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BEY_CODPRO",aHeader)]== cCodProSel}
	oBrwBEY 			:= TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[4],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBEY   ,aDadBEY ,.F.      ,"BEY" ,nOpcx,STR0041,nil,nil,nil,aTrbBEY,,,bFilter) //"Carencias p/ Novos Usuarios"
	oBrwBEY:oPai    	:= oBrwPro
	oBrwBEY:aOrigem 	:= {"BT6_CODPRO"}
	oBrwBEY:aRelac  	:= {"BEY_CODPRO"}
EndIf
oBrwBEY:bLostFocus	:= {|| cCodSeqBEY := oBrwBEY:FieldGet("BEY_SEQUEN")}
oBrwBEY:bChange     := {|| Eval(oBrwBEY:bLostFocus)}


@ (aPosObj7[1,4]*0.81) - 38, 005 BUTTON oBotBEY PROMPT STR0043 ACTION {|| Eval(oBrwBEY:bLostFocus),PLS660ADCM(oBrwBEY) } SIZE 65, 11 OF oFldCob:aDialogs[4] PIXEL 
oBotAde:cTOOLTIP := STR0043 //"Classe de Carencia"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados de Classe de Carencia                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BA6" TO aCabBA6  For .T.

If nOpcx == K_Incluir
	Store COLS Blank "BA6" TO aDadBA6  FROM aCabBA6
Else
	BA6->(DbSetOrder(1))
	If ! BA6->(MsSeek(xFilial("BA6")+cChavSub))
		Store COLS Blank "BA6" TO aDadBA6  FROM aCabBA6
	Else
		Store COLS "BA6" TO aDadBA6  FROM aCabBA6 VETTRAB aTrbBA6 While xFilial("BA6")+cChavSub == BA6->(BA6_FILIAL+BA6_CODINT+BA6_CODIGO+BA6_NUMCON+BA6_VERCON+BA6_SUBCON+BA6_VERSUB)
	Endif
Endif

If BA6->( FieldPos("BA6_VERPRO") ) > 0
	bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BA6_CODPRO",aHeader)]== cCodProSel .And.;
										aCols[nLine,GdFieldPos("BA6_VERPRO",aHeader)]== cVersaoSel}
	oBrwBA6 := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[5],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBA6   ,aDadBA6 ,.F.      ,"BA6" ,nOpcx,STR0085,nil,nil,nil,aTrbBA6,,,bFilter) //"Carencia p/ Tipo de Internacao"
	oBrwBA6:oPai    := oBrwPro
	oBrwBA6:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwBA6:aRelac  := {"BA6_CODPRO","BA6_VERPRO"}
Else 
	bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BA6_CODPRO",aHeader)]== cCodProSel}
	oBrwBA6 := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[5],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBA6   ,aDadBA6 ,.F.      ,"BA6" ,nOpcx,STR0085,nil,nil,nil,aTrbBA6,,,bFilter) //"Carencia p/ Tipo de Internacao"
	oBrwBA6:oPai    := oBrwPro
	oBrwBA6:aOrigem := {"BT6_CODPRO"}
	oBrwBA6:aRelac  := {"BA6_CODPRO"}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Regras de reajuste    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B77")
   Store Header "B77" TO aCabB77 For .T.
   If nOpcx == K_Incluir
   	  Store COLS Blank "B77" TO aDadB77 FROM aCabB77
   Else
  	  B77->(DbSetOrder(1))
	  If ! B77->(MsSeek(xFilial("B77")+cChavSub))
		  Store COLS Blank "B77" TO aDadB77 FROM aCabB77
	  Else
	  	  Store COLS "B77" TO aDadB77 FROM aCabB77 VETTRAB aTrbB77 While B77->(B77_FILIAL+B77_CODINT+B77_CODEMP+B77_CONEMP+B77_VERCON+B77_SUBCON+B77_VERSUB) == xFilial("B77")+cChavSub
	  Endif
   Endif

   oBrwB77  := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[nPosFldB77], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB77,aDadB77,.F.,"B77",nOpcx,STR0195,nil,nil,nil,aTrbB77) //"Regras de reajuste"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Regras de parcelamento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B81")
   Store Header "B81" TO aCabB81 For .T.
   If nOpcx == K_Incluir
   	  Store COLS Blank "B81" TO aDadB81 FROM aCabB81
   Else
  	  B81->(DbSetOrder(1))
	  If ! B81->(MsSeek(xFilial("B81")+cChavSub))
		  Store COLS Blank "B81" TO aDadB81 FROM aCabB81
	  Else
	  	  Store COLS "B81" TO aDadB81 FROM aCabB81 VETTRAB aTrbB81 While B81->(B81_FILIAL+B81_CODINT+B81_CODEMP+B81_CONEMP+B81_VERCON+B81_SUBCON+B81_VERSUB) == xFilial("B81")+cChavSub
	  Endif
   Endif

   oBrwB81  := TPLSBrw():New(aPosObj4[2][1],aPosObj4[2][1],aPosObj4[2][4],aPosObj4[2][3]*0.86,nil  ,oFolder:aDialogs[nPosFldB81], nil , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabB81,aDadB81,.F.,"B81",nOpcx,STR0150,nil,nil,nil,aTrbB81) //"Regra de parcelamento"
Endif


PLS660D(cAlias,nReg,nOpc)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS660D   ºAutor  ³Geraldo Felix Juniorº Data ³  03/15/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para contrucao dos aCols, aHeaders e objetos da Rot.º±±
±±º          ³ Desmembrado da funcao PLS660CONS() devio ao "memory overflow"±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLS660D(cAlias,nReg,nOpc)
Local oBotBGS
LOCAL oBotFr01
LOCAL aButtBHF	:= {}
LOCAL I			
LOCAL aSize 	:= {}
LOCAL aInfo 	:= {}
LOCAL aObjects 	:= {}   
LOCAL aPosObj 	:= {}
LOCAL aInfo2 	:= {}
LOCAL aObjects2 := {}     
LOCAL aPosObj2 	:= {}
LOCAL aInfo3 	:= {}
LOCAL aObjects3 := {}     
LOCAL aPosObj3 	:= {}
LOCAL aInfo4 	:= {}
LOCAL aObjects4 := {}     
LOCAL aPosObj4 	:= {}
LOCAL aInfo6 	:= {}
LOCAL aObjects6 := {}     
LOCAL aPosObj6 	:= {}
LOCAL aInfo7 	:= {}
LOCAL aObjects7 := {}     
LOCAL aPosObj7 	:= {}
LOCAL bBrwDel

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros Pagamento...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aObjects := {}   
AAdd( aObjects, { 100, 20, .t., .f. } )    
AAdd( aObjects, { 100, 100, .t., .t.,.t. } )
aPosObj := MsObjSize( aInfo, aObjects )     

aInfo2 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects2 := {}     
AAdd( aObjects2, { 100, 1, .t., .f. } )        
AAdd( aObjects2, { 100, 50, .t., .t.,.t. } )
AAdd( aObjects2, { 100, 50, .t., .t.,.t. } )
aPosObj2 := MsObjSize( aInfo2, aObjects2 )     

aInfo3 := { 0, 0, aPosObj2[3,3], aPosObj2[3,4], 3, 3 }
aObjects3 := {}     
AAdd( aObjects3, { 100, 80, .t., .t. } )  
AAdd( aObjects3, { 100, 80, .t., .t. } )
aPosObj3 := MsObjSize( aInfo3, aObjects3 )     

aInfo4 := { 0, 0, aPosObj[2,3], aPosObj[2,4], 3, 3 }
aObjects4 := {}     
AAdd( aObjects4, { 100, 1, .t., .f. } )    
AAdd( aObjects4, { 100, 100, .t., .t.,.f. } )
aPosObj4 := MsObjSize( aInfo4, aObjects4 )     

aInfo6 := { 0, 0, aPosObj2[3,3], aPosObj2[3,4], 3, 3 }
aObjects6 := {}         
AAdd( aObjects6, { 100, 100, .t., .t.,.t. } )
aPosObj6 := MsObjSize( aInfo6, aObjects6 )     

aInfo7 := { 0, 0, aPosObj6[1,3], aPosObj6[1,4], 3, 3 }
aObjects7 := {}         
AAdd( aObjects7, { 100, 100, .t., .t.,.t. } )
aPosObj7 := MsObjSize( aInfo7, aObjects7 )     
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupos de Coberturas...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT7" TO aCabGru For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT7" TO aDadGru FROM aCabGru
Else
	BT7->(DbSetOrder(1))
	If ! BT7->(MsSeek(xFilial("BT7")+cChavSub))
		Store COLS Blank "BT7" TO aDadGru FROM aCabGru
	Else
		cCodGruCob := BT7->BT7_CODGRU
		Store COLS "BT7" TO aDadGru FROM aCabGru VETTRAB aTrbGru While xFilial("BT7")+cChavSub == BT7->(BT7_FILIAL+BT7_CODINT+BT7_CODIGO+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a GetDados da Co-Participacao para Grupo de Cobertura         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHF" TO aCabCGru For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BHF" TO aDadCGru FROM aCabCGru
Else
	BHF->(DbSetOrder(1))
	If ! BHF->(MsSeek(xFilial("BHF")+cChavSub))
		Store COLS Blank "BHF" TO aDadCGru FROM aCabCGru
	Else
		Store COLS "BHF" TO aDadCGru FROM aCabCGru VETTRAB aTrbCGru While xFilial("BHF")+cChavSub == BHF->(BHF_FILIAL+BHF_CODINT+BHF_CODIGO+BHF_NUMCON+BHF_VERCON+BHF_SUBCON+BHF_VERSUB)
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botoes para consulta do historico de reajuste da franquia...  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBHF, {"BUDGET",{||PL660HTFRA('1',"BHF",	cChavSub,;
													oBrwGru:FieldGet("BHF_CODPRO"),;
													Iif((BHF->( FieldPos("BHF_VERPRO") ) > 0), oBrwGru:FieldGet("BHF_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
If BT7->( FieldPos("BT7_VERPRO") ) > 0
	bFilter            := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BT7_CODPRO",aHeader)]== cCodProSel .And.;
										 			aCols[nLine,GdFieldPos("BT7_VERPRO",aHeader)]== cVersaoSel}
	oBrwGru            := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabGru   ,aDadGru ,.F.      ,"BT7" ,nOpcx,STR0086,nil,nil,nil,aTrbGru,,,bFilter,,aButtBHF) //"Grupo de Cobertura"
	oBrwGru:oPai       := oBrwPro
	oBrwGru:aOrigem    := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwGru:aRelac     := {"BT7_CODPRO","BT7_VERPRO"}
Else 
	bFilter            := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BT7_CODPRO",aHeader)]== cCodProSel}
	oBrwGru            := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[1],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabGru   ,aDadGru ,.F.      ,"BT7" ,nOpcx,STR0086,nil,nil,nil,aTrbGru,,,bFilter,,aButtBHF) //"Grupo de Cobertura"
	oBrwGru:oPai       := oBrwPro
	oBrwGru:aOrigem    := {"BT6_CODPRO"}
	oBrwGru:aRelac     := {"BT7_CODPRO"}
EndIf
oBrwGru:bLostFocus := {||	cCodGruCob := oBrwGru:FieldGet("BT7_CODGRU"),;
							cDesGruCob := oBrwGru:FieldGet("BT7_DESGRU"),;
							oBrwPro:FieldPut("BT6_INFGRC",If(oBrwGru:VerExiData(),"1","0"))  }
oBrwGru:bChange    := {|| Eval(oBrwGru:bLostFocus) }


@ (aPosObj7[1,4]*0.81) - 38, 005 BUTTON oBotGru PROMPT STR0028 ACTION {|| Eval(oBrwGru:bLostFocus), PLS660ADDG(oBrwGru) } SIZE 45, 11 OF oFldCob:aDialogs[1] PIXEL 
oBotAde:cTOOLTIP := STR0028 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Usuarios Permitidos...                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT0" TO aCabUsp For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT0" TO aDadUsp FROM aCabUsp
Else
	BT0->(DbSetOrder(1))
	If ! BT0->(MsSeek(xFilial("BT0")+cChavSub))
		Store COLS Blank "BT0" TO aDadUsp FROM aCabUsp
	Else
		Store COLS "BT0" TO aDadUsp FROM aCabUsp VETTRAB aTrbUsp While xFilial("BT0")+cChavSub == BT0->(BT0_FILIAL+BT0_CODIGO+BT0_NUMCON+BT0_VERCON+BT0_SUBCON+BT0_VERSUB)
	Endif
Endif

bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BT0_CODPRO",aHeader)]== cCodProSel .And.;
									aCols[nLine,GdFieldPos("BT0_VERSAO",aHeader)]== cVersaoSel}
oBrwUsp := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.71,nil  ,oFolPro:aDialogs[6],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabUsp   ,aDadUsp ,.F.      ,"BT0" ,nOpcx,STR0031,nil,nil,nil,aTrbUsp,,,bFilter) //"Usuarios Permitidos"
oBrwUsp:oPai    := oBrwPro
oBrwUsp:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
oBrwUsp:aRelac  := {"BT0_CODPRO","BT0_VERSAO"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grupos de Quantidades... - Geraldo Felix - 15/03/03 - Botucatu      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BW5" TO aCabQtd For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BW5" TO aDadQtd FROM aCabQtd
Else
	BW5->(DbSetOrder(1))
	If ! BW5->(MsSeek(xFilial("BW5")+cChavSub))
		Store COLS Blank "BW5" TO aDadQtd FROM aCabQtd
	Else
		cCodGruQtd := BW5->BW5_CODGRU
		cCodProQtd := BW5->BW5_CODPRO
		Store COLS "BW5" TO aDadQtd FROM aCabQtd VETTRAB aTrbQtd While xFilial("BW5")+cChavSub == BW5->(BW5_FILIAL+BW5_CODINT+BW5_CODIGO+BW5_NUMCON+BW5_VERCON+BW5_SUBCON+BW5_VERSUB)
	Endif
Endif

If BW5->( FieldPos("BW5_VERPRO") ) > 0
	bFilter            := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BW5_CODPRO",aHeader)]== cCodProSel .And.;
												 aCols[nLine,GdFieldPos("BW5_VERPRO",aHeader)]== cVersaoSel}
	oBrwQtd            := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[3],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabQtd   ,aDadQtd ,.F.      ,"BW5" ,nOpcx,STR0087,nil,nil,nil,aTrbQtd,,,bFilter) //"Grupo de Quantidades"
	oBrwQtd:oPai       := oBrwPro
	oBrwQtd:aOrigem    := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwQtd:aRelac     := {"BW5_CODPRO","BW5_VERPRO"}
Else 
	bFilter            := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BW5_CODPRO",aHeader)]== cCodProSel}
	oBrwQtd            := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41,nil  ,oFldCob:aDialogs[3],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabQtd   ,aDadQtd ,.F.      ,"BW5" ,nOpcx,STR0087,nil,nil,nil,aTrbQtd,,,bFilter) //"Grupo de Quantidades"
	oBrwQtd:oPai       := oBrwPro
	oBrwQtd:aOrigem    := {"BT6_CODPRO"}
	oBrwQtd:aRelac     := {"BW5_CODPRO"}
EndIf	                         
oBrwQtd:bLostFocus := {||	cCodGruQtd := oBrwQtd:FieldGet("BW5_CODGRU"),;
							cDesGruQtd := oBrwQtd:FieldGet("BW5_DESGRU"),;
							cCodProQtd := oBrwQtd:FieldGet("BW5_CODPRO") }
oBrwQtd:bChange    := {|| Eval(oBrwQtd:bLostFocus) }

bFilter := {|nLine,aCols,aHeader|aCols[nLine,PLRETPOS("BTB_CODGRU",aCabCla,.T.)]== cCodGruCob .And. aCols[nLine,PLRETPOS("BTB_CODPRO",aCabCla,.T.)]== cCodProSel }
oBrwCla := TPLSBrw():New(005,005,290,040 ,nil  ,oFldCob:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCla   ,aDadCla ,.F.      ,"BTB" ,nOpcx,STR0135,nil,nil,nil,aTrbCla,,,bFilter) //"Classe de Carencia"
oBrwCla:oPai    := oBrwGru
oBrwCla:aOrigem := {"BT7_CODGRU","BT7_CODPRO"}
oBrwCla:aRelac  := {"BTB_CODGRU","BTB_CODPRO"}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coberturas...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT8" TO aCabCob For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT8" TO aDadCob FROM aCabCob
Else
	BT8->(DbSetOrder(1))
	If ! BT8->(MsSeek(xFilial("BT8")+cChavSub))
		Store COLS Blank "BT8" TO aDadCob FROM aCabCob
	Else
		cCodPad	  := BT8->BT8_CODPAD
		cCodPsa	  := BT8->BT8_CODPSA
		cNivelPro := BT8->BT8_NIVEL
		cCodNiv01 := BT8->BT8_CDNV01
		cCodNiv02 := BT8->BT8_CDNV02
		cCodNiv03 := BT8->BT8_CDNV03
		cCodNiv04 := BT8->BT8_CDNV04
		Store COLS "BT8" TO aDadCob FROM aCabCob VETTRAB aTrbCob While xFilial("BT8")+cChavSub == BT8->(BT8_FILIAL+BT8_CODINT+BT8_CODIGO+BT8_NUMCON+BT8_VERCON+BT8_SUBCON+BT8_VERSUB)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SubContrato X Procec X CID...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BLU" TO aCabBLU For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BLU" TO aDadBLU FROM aCabBLU
Else
	BLU->(DbSetOrder(1))
	If BLU->(MsSeek(xFilial("BLU")+cChavSub))

		cCID     := BLU->BLU_CID
		cSeqSel  := BLU->BLU_SEQUEN
		Store COLS "BLU" TO aDadBLU FROM aCabBLU VETTRAB aTrbBLU While BLU->(BLU_FILIAL+BLU_CODINT+BLU_CODIGO+BLU_NUMCON+BLU_VERCON+BLU_SUBCON+BLU_VERSUB) == xFilial("BLU")+cChavSub
	Else
		Store COLS Blank "BLU" TO aDadBLU FROM aCabBLU
	Endif
Endif            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Subcontrato X Proc X CID X Co-Part...								³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BLW" TO aCabBLW For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BLW" TO aDadBLW FROM aCabBLW
Else
	BLW->(DbSetOrder(1))
	If BLW->(MsSeek(xFilial("BLW")+cChavSub))
		Store COLS "BLW" TO aDadBLW FROM aCabBLW VETTRAB aTrbBLW While BLW->(BLW_FILIAL+BLW_CODINT+BLW_CODIGO+BLW_NUMCON+BLW_VERCON+BLW_SUBCON+BLW_VERSUB) == xFilial("BLW")+cChavSub
	Else
		Store COLS Blank "BLW" TO aDadBLW FROM aCabBLW
	Endif
Endif                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SubcontratoXProcXEspecXCo-Part...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BLX" TO aCabBLX For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BLX" TO aDadBLX FROM aCabBLX
Else
	BLX->(DbSetOrder(1))
	If BLX->(MsSeek(xFilial("BLX")+cChavSub))
		Store COLS "BLX" TO aDadBLX FROM aCabBLX VETTRAB aTrbBLX While BLX->(BLX_FILIAL+BLX_CODINT+BLX_CODIGO+BLX_NUMCON+BLX_VERCON+BLX_SUBCON+BLX_VERSUB) == xFilial("BLX")+cChavSub
	Else
		Store COLS Blank "BLX" TO aDadBLX FROM aCabBLX
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CoPart.xSubcontratoxProcxEspec...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BLT" TO aCabBLT For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BLT" TO aDadBLT FROM aCabBLT
Else
	BLT->(DbSetOrder(1))
	If BLT->(MsSeek(xFilial("BLT")+cChavSub))
		
		cCodEspSel := BLT->BLT_CODESP
		cSeqSel    := BLT->BLT_SEQUEN
		
		Store COLS "BLT" TO aDadBLT FROM aCabBLT VETTRAB aTrbBLT While BLT->(BLT_FILIAL+BLT_CODINT+BLT_CODIGO+BLT_NUMCON+BLT_VERCON+BLT_SUBCON+BLT_VERSUB) == xFilial("BLT")+cChavSub
	Else
		Store COLS Blank "BLT" TO aDadBLT FROM aCabBLT
	Endif
Endif        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grp/Empresa X Co-participacao...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BHE" TO aCabCCo For .T.
If nOpcX == K_Incluir
	Store COLS Blank "BHE" TO aDadCCo FROM aCabCCo
Else
	BHE->(DbSetOrder(1))
	If BHE->( MsSeek(xFilial("BHE")+cChavSub+cCodProSel+cVersaoSel ) )
		Store COLS "BHE" TO aDadCCo FROM aCabCCo VETTRAB aTrbCCo While BHE->(BHE_FILIAL+BHE_CODINT+BHE_CODIGO+BHE_NUMCON+BHE_VERCON+BHE_SUBCON+BHE_VERSUB) == xFilial("BHE")+cChavSub
	Else
		Store COLS Blank "BHE" TO aDadCCo FROM aCabCCo
	Endif
Endif 

aButEsp := {{OemtoAnsi(STR0181),{||PlVigDifId("BT8",'M->(BQC_FILIAL+BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB+BT8_CODPRO+BT8_VERPRO+BT8_CODPAD+BT8_CODPSA+BT8_NIVEL)',M->BT8_DIFIDA)},OemtoAnsi(STR0181),OemtoAnsi(STR0181)}} //"Period. Dif. Idade"
If BT8->( FieldPos("BT8_VERPRO") ) > 0
	bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BT8_CODPRO",aHeader)]==cCodProSel .And.;
									 	aCols[nLine,GdFieldPos("BT8_VERPRO",aHeader)]== cVersaoSel}
	oBrwCob := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41 ,nil  ,oFldCob:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCob   ,aDadCob ,.F.      ,"BT8" ,nOpcx,STR0083,nil,nil,nil,aTrbCob,,,bFilter,,aButEsp) //"Cobertura"
	oBrwCob:oPai       := oBrwPro
	oBrwCob:aOrigem    := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwCob:aRelac     := {"BT8_CODPRO","BT8_VERPRO"}
	oBrwCob:cVldLine   	:= 'PLSCHKBT8(oBrwCob,M->BT8_CODPSA)'
Else 
	bFilter := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BT8_CODPRO",aHeader)]==cCodProSel}
	oBrwCob := TPLSBrw():New(aPosObj7[1,1],aPosObj7[1,2],aPosObj7[1,3],(aPosObj7[1,4]*0.81) - 41 ,nil  ,oFldCob:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabCob   ,aDadCob ,.F.      ,"BT8" ,nOpcx,STR0083,nil,nil,nil,aTrbCob,,,bFilter,,aButEsp) //"Cobertura"
	oBrwCob:oPai       := oBrwPro
	oBrwCob:aOrigem    := {"BT6_CODPRO"}
	oBrwCob:aRelac     := {"BT8_CODPRO"}
	oBrwCob:cVldLine   	:= 'PLSCHKBT8(oBrwCob,M->BT8_CODPSA)'
EndIf							                                                               
oBrwCob:bLostFocus := {|| cCodPad	 := oBrwCob:FieldGet("BT8_CODPAD"),;
						   cCodPsa	 := oBrwCob:FieldGet("BT8_CODPSA"),;
						   cDesPsa	 := oBrwCob:FieldGet("BT8_DESCRI"),;
						   cNivelPro := oBrwCob:FieldGet("BT8_NIVEL") ,;
						   cCodNiv01 := oBrwCob:FieldGet("BT8_CDNV01"),;
						   cCodNiv02 := oBrwCob:FieldGet("BT8_CDNV02"),;
						   cCodNiv03 := oBrwCob:FieldGet("BT8_CDNV03"),;
						   cCodNiv04 := oBrwCob:FieldGet("BT8_CDNV04"),;
						   oBrwPro:FieldPut("BT6_INFCOB",If(oBrwCob:VerExiData(),"1","0")) }
oBrwCob:bChange := {|| Eval(oBrwCob:bLostFocus)}

@ (aPosObj7[1,4]*0.81) - 38 , 005 BUTTON oBotCob PROMPT STR0088 ACTION {|| Eval(oBrwCob:bLostFocus) ,PLS660ADCD(oBrwCob) } SIZE 55, 11 OF oFldCob:aDialogs[2] PIXEL 
oBotCob:cTOOLTIP := STR0088 //"CID"

@ (aPosObj7[1,4]*0.81) - 38 , 065 BUTTON oBotCob2 PROMPT STR0061 ACTION {|| Eval(oBrwCob:bLostFocus) ,PLS660ADES(oBrwCob) } SIZE 55, 11 OF oFldCob:aDialogs[2] PIXEL 
oBotCob2:cTOOLTIP := STR0061 //"Especialidade"

@ (aPosObj7[1,4]*0.81) - 38 , 125 BUTTON oBotCob3 PROMPT STR0028 ACTION {|| Eval(oBrwCob:bLostFocus) ,PLS660ADDC(oBrwCob) } SIZE 55, 11 OF oFldCob:aDialogs[2] PIXEL 
oBotCob3:cTOOLTIP := STR0028 //"Co-Participacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forma de Cobranca ...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BT9" TO aCabFor For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BT9" TO aDadFor FROM aCabFor
Else
	BT9->(DbSetOrder(1))
	If ! BT9->(MsSeek(xFilial("BT9")+cChavSub))
		Store COLS Blank "BT9" TO aDadFor FROM aCabFor
	Else
		Store COLS "BT9" TO aDadFor FROM aCabFor VETTRAB aTrbFor While xFilial("BT9")+cChavSub == BT9->(BT9_FILIAL+BT9_CODIGO+BT9_NUMCON+BT9_VERCON+BT9_SUBCON+BT9_VERSUB)
	Endif
Endif

bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BT9_CODPRO",aHeader)] == cCodProSel .and.;
								 	aCols[nLine,GdFieldPos("BT9_VERSAO",aHeader)] == cVersaoSel}
oBrwFor := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil  ,oFolPro:aDialogs[2],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabFor   ,aDadFor ,.F.      ,"BT9" ,nOpcx,STR0026,nil,nil,nil,aTrbFor,, "PLSM660Del(" + Str(nOpcx, 1) + ",1)",bFilter) //"Forma de Cobranca"
oBrwFor:oPai    	:= oBrwPro
oBrwFor:aOrigem 	:= {"BT6_CODPRO","BT6_VERSAO"}
oBrwFor:aRelac  	:= {"BT9_CODPRO","BT9_VERSAO"}

@ aPosObj6[1][4]*0.6,005 BUTTON oBotPro PROMPT STR0089 ACTION {|| PLSA660For(nOpcx,1,,oBrwFor) } SIZE 45, 11 OF oFolPro:aDialogs[2] PIXEL //"&Propriedades"
oBotPro:cTOOLTIP := STR0090 //"Propriedades da Forma de Cobranca"


@ aPosObj6[1][4]*0.6,055 BUTTON oBotPro PROMPT STR0091 ACTION {||PL660HSal() } SIZE 45, 11 OF oFolPro:aDialogs[2] PIXEL
oBotPro:cTOOLTIP := STR0081 //"Historicos"

oBrwFor:bChange  := { || 	If(oBrwFor:IsDeleted(oBrwFor:Linha()),;
							oBotPro:Disable(), oBotPro:Enable()) }
oBrwFor:bLostFocus  := { || Eval(oBrwFor:bChange) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Forma de Cobranca  dos Opcionais...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BJW" TO aCabFrOpc For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BJW" TO aDadFrOpc FROM aCabFrOpc
Else
	BJW->(DbSetOrder(1))
	If ! BJW->(MsSeek(xFilial("BJW")+cChavSub))
		Store COLS Blank "BJW" TO aDadFrOpc FROM aCabFrOpc
	Else
		Store COLS "BJW" TO aDadFrOpc FROM aCabFrOpc VETTRAB aTrbFrOpc While xFilial("BJW")+cChavSub == BJW->(BJW_FILIAL+BJW_CODIGO+BJW_NUMCON+BJW_VERCON+BJW_SUBCON+BJW_VERSUB)
	Endif
Endif
bFilter   := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BJW_CODPRO",aHeader)]== cCodProSel .And.;
									aCols[nLine,GdFieldPos("BJW_VERSAO",aHeader)]== cVersaoSel .And.;
									aCols[nLine,GdFieldPos("BJW_CODOPC",aHeader)]== cCodOpcSel .And.;
									aCols[nLine,GdFieldPos("BJW_VEROPC",aHeader)]== cVerOpcSel}
oBrwFrOpc := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil  ,oFolPro:aDialogs[8],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabFrOpc   ,aDadFrOpc ,.F.      ,"BJW" ,nOpcx,STR0026,nil,nil,nil,aTrbFrOpc,,"PLSM660Del(" + Str(nOpcx, 1) + ",3)",bFilter) //"Forma de Cobranca"
oBrwFrOpc:oPai    := oBrwOpc 
oBrwFrOpc:aOrigem := {"BHS_CODPRO","BHS_VERPRO","BHS_CODPLA","BHS_VERPLA"}
oBrwFrOpc:aRelac  := {"BJW_CODPRO","BJW_VERSAO","BJW_CODOPC","BJW_VEROPC"}


@ aPosObj6[1][4]*0.6 ,005 BUTTON oBotFrOpc PROMPT STR0089 ACTION {|| PLSA660For(nOpcx,3) } SIZE 45, 11 OF oFolPro:aDialogs[8] PIXEL //"&Propriedades"
oBotFrOpc:cTOOLTIP := STR0092 //"Propriedades da Forma de Cobranca (OPCIONAIS)"


@ aPosObj6[1][4]*0.6 ,055 BUTTON oBotFr01 PROMPT STR0091 ACTION {|| PLSHISFAI("BYF",BQC->( BQC_CODINT+BQC_CODEMP+BQC_NUMCON+; //"&Historicos"
															       BQC_VERCON+BQC_SUBCON+BQC_VERSUB+;
															       cCodProSel+cVersaoSel+cCodOpcSel+cVerOpcSel),;
															"BYF->( BYF_FILIAL+BYF_CODOPE+BYF_CODEMP+"+;
																   "BYF_CONEMP+BYF_VERCON+BYF_SUBCON+"+;
																   "BYF_VERSUB+BYF_CODPRO+BYF_VERPRO+"+;
																   "BYF_CODOPC+BYF_VEROPC)",3) } SIZE 45, 11 OF oFolPro:aDialogs[8] PIXEL
oBotFr01:cTOOLTIP := STR0081 //"Historicos"
																    
bBrwDel := oBrwFrOpc:oBrowse:oBrowse:bDelete
oBrwFrOpc:oBrowse:oBrowse:bDelete := {||If(ValType(bBrwDel)=="B",Eval(bBrwDel),),If(oBrwFrOpc:IsDeleted(oBrwFrOpc:Linha()) .OR. oBrwOpc:IsDeleted(oBrwOpc:Linha()),oBotFrOpc:Disable(), oBotFrOpc:Enable())}

oBrwFrOpc:bChange  := { || 	(	If(oBrwOpc:FieldGet("BHS_TIPVIN",oBrwOpc:Linha()) == "0" .And. ! oBrwOpc:IsDeleted(oBrwOpc:Linha()),oBrwFrOpc:OBROWSE:OBROWSE:LREADONLY := .F. ,oBrwFrOpc:OBROWSE:OBROWSE:LREADONLY := .T.),;
									If(oBrwFrOpc:IsDeleted(oBrwFrOpc:Linha()) .OR. oBrwOpc:IsDeleted(oBrwOpc:Linha()),oBotFrOpc:Disable(), oBotFrOpc:Enable())) }													
							
//oBrwFrOpc:bLostFocus  := { || Eval(oBrwFrOpc:bChange) }
//oBrwFrOpc:bGotFocus   := { || Eval(oBrwFrOpc:bChange) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Prestador   .                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BGP" TO aCabBGP For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BGP" TO aDadBGP FROM aCabBGP
Else
	BGP->(DbSetOrder(1))
	If ! BGP->(MsSeek(xFilial("BGP")+cChavSub))
		Store COLS Blank "BGP" TO aDadBGP FROM aCabBGP
	Else
		cTipPre := BGP->BGP_TIPPRE
		Store COLS "BGP" TO aDadBGP FROM aCabBGP VETTRAB aTrbBGP While xFilial("BGP")+cChavSub == BGP->(BGP_FILIAL+BGP_CODINT+BGP_CODIGO+BGP_NUMCON+BGP_VERCON+BGP_SUBCON+BGP_VERSUB)
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo de Prestador X Co-Participacao                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "BGS" TO aCabBGS For .T.
If nOpcx == K_Incluir
	Store COLS Blank "BGS" TO aDadBGS FROM aCabBGS
Else
	BGS->(DbSetOrder(1))
	If ! BGS->(MsSeek(xFilial("BGS")+cChavSub))
		Store COLS Blank "BGS" TO aDadBGS FROM aCabBGS
	Else
		Store COLS "BGS" TO aDadBGS FROM aCabBGS VETTRAB aTrbBGS While xFilial("BGS")+cChavSub == BGS->(BGS_FILIAL+BGS_CODINT+BGS_CODIGO+BGS_NUMCON+BGS_VERCON+BGS_SUBCON+BGS_VERSUB)
	Endif
Endif
bFilter 			:= {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BGP_CODPRO",aHeader)] == cCodProSel .And.;
											 	aCols[nLine,GdFieldPos("BGP_VERPRO",aHeader)] == cVersaoSel}
oBrwBGP 			:= TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil  ,oFolPro:aDialogs[9],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBGP   ,aDadBGP ,.F.      ,"BGP" ,nOpcx,STR0026,nil,nil,nil,aTrbBGP,,"PLSM660Del(" + Str(nOpcx, 1) + ",1)",bFilter) //"Forma de Cobranca"
oBrwBGP:oPai    	:= oBrwPro
oBrwBGP:aOrigem 	:= {"BT6_CODPRO","BT6_VERSAO"}
oBrwBGP:aRelac  	:= {"BGP_CODPRO","BGP_VERPRO"}
oBrwBGP:bLostFocus 	:= { ||	cTipPre := oBrwBGP:FieldGet("BGP_TIPPRE"),;
							cDesPre := oBrwBGP:FieldGet("BGP_DESPRE")} 
oBrwBGP:bChange    	:= { || Eval(oBrwBGP:bLostFocus) }
oBrwBGP:cVldLine   	:= 'PL660VLDAT( {"BGP_TIPPRE","BGP_DATDE"},"BGP_DATDE" ) '

@ aPosObj6[1][4]*0.6,005 BUTTON oBotBGS PROMPT STR0093 ACTION {|| Eval(oBrwBGP:bLostFocus), PLS660BGS(oBrwBGP) } SIZE 40, 11 OF oFolPro:aDialogs[9] PIXEL //"Co-Particip."
oBotBGS:cTOOLTIP   	:= STR0028 //"Co-Participacao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Municipio de Atendimento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("BGG")
   Store Header "BGG" TO aCabBGG For .T.
   If nOpcx == K_Incluir
      Store COLS Blank "BGG" TO aDadBGG FROM aCabBGG
   Else
   	  BGG->(DbSetOrder(1))
	  If ! BGG->(MsSeek(xFilial("BGG")+cChavSub))
		 Store COLS Blank "BGG" TO aDadBGG FROM aCabBGG
	  Else
		 cCodMun := BGG->BGG_CODMUN     
	 	 Store COLS "BGG" TO aDadBGG FROM aCabBGG VETTRAB aTrbBGG While xFilial("BGG")+cChavSub == BGG->(BGG_FILIAL+BGG_CODINT+BGG_CODIGO+BGG_NUMCON+BGG_VERCON+BGG_SUBCON+BGG_VERSUB)
	  Endif
   Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Municipio Atend. X Co-Participacao                            		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Store Header "BGL" TO aCabBGL For .T.
   If nOpcx == K_Incluir
	  Store COLS Blank "BGL" TO aDadBGL FROM aCabBGL
   Else
      BGL->(DbSetOrder(1))
	  If ! BGL->(MsSeek(xFilial("BGL")+cChavSub))
		 Store COLS Blank "BGL" TO aDadBGL FROM aCabBGL
	  Else
		 Store COLS "BGL" TO aDadBGL FROM aCabBGL VETTRAB aTrbBGL While xFilial("BGL")+cChavSub == BGL->(xFilial("BGL")+BGL_CODINT+BGL_CODIGO+BGL_NUMCON+BGL_VERCON+BGL_SUBCON+BGL_VERSUB)
	  Endif
   EndIf  

   bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BGG_CODPRO",aHeader)] == cCodProSel .And.;
   									 	aCols[nLine,GdFieldPos("BGG_VERPRO",aHeader)] == cVersaoSel}
   oBrwBGG := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil  ,oFolPro:aDialogs[10],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBGG   ,aDadBGG ,.F.      ,"BGG" ,nOpcx,STR0026,nil,nil,nil,aTrbBGG,, "PLSM660Del(" + Str(nOpcx, 1) + ",1)",bFilter) //"Forma de Cobranca"
   oBrwBGG:oPai    := oBrwPro
   oBrwBGG:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
   oBrwBGG:aRelac  := {"BGG_CODPRO","BGG_VERPRO"}
   oBrwBGG:bLostFocus := { || cCodMun := oBrwBGG:FieldGet("BGG_CODMUN")}
   oBrwBGG:bChange    := { || Eval(oBrwBGG:bLostFocus) }
   oBrwBGG:cVldLine   := 'PL660VLDAT( {"BGG_CODMUN","BGG_DATDE"},"BGG_DATDE" ) '


	@ aPosObj6[1][4]*0.6 ,005 BUTTON oBotBGL PROMPT STR0093 ACTION {|| Eval(oBrwBGG:bLostFocus) ,PLS660BGL(oBrwBGG) } SIZE 40, 11 OF oFolPro:aDialogs[10] PIXEL //"Co-Particip."
	oBotBGL:cTOOLTIP   := STR0028 //"Co-Participacao"
	
Endif                               
If PLSALIASEX("BOR")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ REDE REFERENCIADA... Alexander  11/07/2005                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Store Header "BOR" TO aCabRDF For .T.
	If nOpcx == K_Incluir
		Store COLS Blank "BOR" TO aDadRDF FROM aCabRDF
	Else
   		BOR->( DbSetOrder(1) )
  		If ! BOR->( MsSeek( xFilial("BOR")+cChavSub ) )
  			Store COLS Blank "BOR" TO aDadRDF FROM aCabRDF
  		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o CheckBox													³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Store COLS "BOR" TO aDadRDF FROM aCabRDF VETTRAB aTrbRDF While BOR->(BOR_FILIAL+BOR_CODINT+BOR_CODEMP+BOR_NUMCON+BOR_VERCON+BOR_SUBCON+BOR_VERSUB) == xFilial("BOR")+cChavSub 
		EndIf	
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Browse REDE REFERENCIADA...                                     	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    bFilter 		 := {|nLine ,aCols ,aHeader|	aCols[nLine ,GdFieldPos("BOR_CODPRO",aHeader)] == cCodProSel .And.;
    											 	aCols[nLine ,GdFieldPos("BOR_VERPRO" ,aHeader)] == cVersaoSel }
	oBrwRDF 		 := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil ,oFolPro:aDialogs[11] ,nil ,nil ,nil ,nil ,nil ,.T. ,nil ,.T. ,nil ,aCabRDF ,aDadRDF ,.F. ,"BOR" ,nOpcx ,STR0036 ,nil ,nil ,nil ,aTrbRDF,'PlsVldBOR',,bFilter) //"Rede Referenciada"
	oBrwRDF:oPai     := oBrwPro
	oBrwRDF:aOrigem  := {"BT6_CODPRO","BT6_VERSAO"}
	oBrwRDF:aRelac   := {"BOR_CODPRO","BOR_VERPRO"}          
	If BT6->( FieldPos("BT6_ALLCRE") ) > 0	
	   @ aPosObj6[1][4]*0.6,005 CHECKBOX oChkRDF VAR lChkRDF PROMPT STR0094 PIXEL SIZE 80,09 OF oFolPro:aDialogs[11]  //"Toda a Rede Credenciada"
	   oChkRDF:bChange := {|| oBrwPro:FieldGet("BT6_ALLCRE") := Iif( lChkRDF,"1","0" ),oBrwPro:lAltered := .T. }
    EndIf		
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SUB X PROD X FAT. MULT. REEMB...                                  	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B33" TO aCabB33 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B33" TO aDadB33 FROM aCabB33
	cCodSeqB33 := aDadB33[AScan(aCabB33,{|x|x[2]=="B33_SEQUEN"}),1]
Else
	B33->(DbSetOrder(1))
	If ! B33->(MsSeek(xFilial("B33")+cChavSub))
		Store COLS Blank "B33" TO aDadB33 FROM aCabB33
		cCodSeqB33 := aDadB33[AScan(aCabB33,{|x|x[2]=="B33_SEQUEN"}),1]
	Else
		Store COLS "B33" TO aDadB33 FROM aCabB33 VETTRAB aTrbB33 While xFilial("B33")+cChavSub == B33->(B33_FILIAL+B33_CODINT+B33_CODIGO+B33_NUMCON+B33_VERCON+B33_SUBCON+B33_VERSUB)
		cCodCla := B33->B33_CLASSE     
		cCodSeqB33 := aDadB33[AScan(aCabB33,{|x|x[2]=="B33_SEQUEN"}),1]	 	
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VIG SUB XPROD X FAT MULT REEMB			                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B34" TO aCabB34 For .T.
If nOpcx == K_Incluir
	Store COLS Blank "B34" TO aDadB34 FROM aCabB34
Else
    B34->(DbSetOrder(1))
	If ! B34->(MsSeek(xFilial("B34")+cChavSub))
		Store COLS Blank "B34" TO aDadB34 FROM aCabB34
		aDadB34[AScan(aCabB34,{|x|x[2]=="B34_SEQUEN"}),1] := cCodSeqB33
	Else
		Store COLS "B34" TO aDadB34 FROM aCabB34 VETTRAB aTrbB34 While xFilial("B34")+cChavSub == B34->(xFilial("B34")+B34_CODINT+B34_CODIGO+B34_NUMCON+B34_VERCON+B34_SUBCON+B34_VERSUB)
	Endif
EndIf  
If Len(aDadB34) > 0
	For  I:=1 To Len(aDadB34)
		If !Empty(Alltrim(aDadB34[I,AScan(aCabB34,{|x|x[2]=="B34_CLASSE"})]))
				aadd(aVetB34,{	aDadB34[I,AScan(aCabB34,{|x|x[2]=="B34_CLASSE"})],; //1
									"B34",;	//2
									NIL,;		//3
									NIL,;		//4
									0,;		//5
									NIL,; 	//6
									NIL,; 	//7
									NIL,; 	//8
									NIL,; 	//9
									NIL,; 	//10
									NIL,; 	//11
									NIL,; 	//12
									!aDadb34[I,LEN(aDadB34[I])]})		//13
		EndIf
	Next
EndIf	
bFilter := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("B33_CODPRO",aHeader)] == cCodProSel .And.;
									aCols[nLine,GdFieldPos("B33_VERSAO",aHeader)] == cVersaoSel}
oBrwB33 := TPLSBrw():New(aPosObj6[1][1],aPosObj6[1][2],aPosObj6[1][3],aPosObj6[1][4]*0.571 ,nil  ,oFolPro:aDialogs[12],nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabB33   ,aDadB33 ,.F.      ,"B33" ,nOpcx,STR0125,nil,nil,nil,aTrbB33,"Pls660DB34",,bFilter) //"FAtor de Reembolso"
oBrwB33:oPai    := oBrwPro
oBrwB33:aOrigem := {"BT6_CODPRO","BT6_VERSAO"}
oBrwB33:aRelac  := {"B33_CODPRO","B33_VERSAO"}
oBrwB33:bLostFocus := { || cCodCla := oBrwB33:FieldGet("B33_CLASSE"),cCodSeqB33 := oBrwB33:FieldGet("B33_SEQUEN")}
oBrwB33:bChange    := { || Eval(oBrwB33:bLostFocus) }
oBrwB33:cVldLine   := 'PLSVLDGD( {"B33_CLASSE","B33_INTEXT","B33_TIPATE"} )'


@ aPosObj6[1][4]*0.6 ,005 BUTTON oBotB34 PROMPT STR0126 ACTION {|| Eval(oBrwB33:bLostFocus) ,PLS660B34(oBrwB33) } SIZE 40, 11 OF oFolPro:aDialogs[12] PIXEL //"Vigencia"
oBotB34:cTOOLTIP   := STR0126 //"Vigencia"
  
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Plsa660V1 ºAutor  ³Microsiga           º Data ³  09/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Plsa660V1()
Return PLSGATNIV(M->BZF_CODPAD,M->BZF_CODPSA,"BZF")


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS600ALC ºAutor  ³Microsiga           º Data ³  09/01/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS600ALC()
Local _aRots := aClone(aRotina)

aRotina := {{STRPL01,"AxPesqui",0,1},;
                  {STRPL02,"AxVisual",0,2},;
                  {STRPL03       ,"AxInclui"  ,0,3},;
                  {STRPL04      ,"AxAltera",0,4}}


If Empty(M->BQC_CODCLI) .Or. Empty(M->BQC_LOJA)
	Help("",1,"PLS600ALC")
	Return
Endif

SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+M->BQC_CODCLI+M->BQC_LOJA))
	SA1->(AxAltera("SA1",SA1->(Recno()),K_Alterar))
Endif

aRotina := aClone(_aRots)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS660BLQ ºAutor  ³Geraldo Felix Juniorº Data ³  20/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Bloqueio ou desBloqueio de sub-contrato                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS660BLQ(cAlias,nReg,nOpc)
Local oDlg
Local oSay
Local oGet
Local oFont, oFontAutor
Local nOpca := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso na enchoiceBar...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aButtons   := {}
LOCAL bOK        := {|| nOpca := 1,Iif(BlqConf(cMotBlo,dDatBlq,BQC->BQC_CODBLO,STR0098, "BQU",'3',BQC->BQC_DATCON,'1',dDatPed,cBloqFut),; //" deste Sub-Contrato ? "
						oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel    := {|| oDlg:End() }

Local cTipBlq 	:= Space(LEN(BQC->BQC_TIPBLO))
Local dDatBlq 	:= CTOD("")
Local dDatPed 	:= CTOD("")
Local cDesBlq 	:= Space(30)
Local cObsBlq 	:= Space(LEN(BC3->BC3_OBS))
Local aBloqFut  := {"Não","Sim"}
Local cBloqFut	:= aBloqFut[1]
Local lBloqFut	:= .F.
                                      
PRIVATE cMotBlo := Space(LEN(BQC->BQC_CODBLO))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-017

If ExistBlock("PLS660MN")
   If !(Execblock("PLS660MN",.F.,.F.,{nOpc, If(Empty(BQC->BQC_CODBLO),"0","1")}))
       Return(.F.)
   Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 036.7,100.3 OF GetWndDefault()

@ 030, 003 GROUP oGrupo TO 91, 350 PIXEL OF oDlg LABEL " "+STR0099 +" "  COLOR CLR_BLACK, CLR_HRED //"Dados do Sub-Contrato"
@ 040, 008  Say oSay PROMPT STR0100 SIZE 250,010 OF oDlgFolder PIXEL FONT oFont COLOR CLR_BLACK //"Operadora           "
@ 040, 070  Say oSay PROMPT ": "+LEFT(BQC->BQC_CODIGO,4)+"-"+Posicione("BA0",1,xFilial("BA0")+LEFT(BQC->BQC_CODIGO,4),"BA0_NOMINT") SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 050, 008  Say oSay PROMPT STR0101 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Grupo/Empresa       "
@ 050, 070  Say oSay PROMPT ": "+SUBS(BQC->BQC_CODIGO,5)+"-"+Posicione("BG9",1,xFilial("BG9")+BQC->BQC_CODIGO,"BG9_DESCRI") SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 060, 008  Say oSay PROMPT STR0102 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Contrato/Versao     "
@ 060, 070  Say oSay PROMPT ": "+BQC->BQC_NUMCON+"/"+BQC->BQC_VERCON SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 070, 008  Say oSay PROMPT STR0103 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Sub-Contrato/Versao "
@ 070, 070  Say oSay PROMPT ": "+BQC->BQC_SUBCON+"/"+BQC->BQC_VERSUB SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 080, 008  Say oSay PROMPT STR0104 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Id.Sub-Contrato"
@ 080, 070  Say oSay PROMPT ": "+BQC->BQC_DESCRI SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK

@ 100, 003 GROUP oGrupo TO 129, 350 PIXEL OF oDlg LABEL " "+STR0105 +" "  COLOR CLR_BLACK, CLR_HRED //"Motivo do Bloqueio"
If Empty(BQC->BQC_CODBLO)
	@ 108,008 Say oSay PROMPT STR0106 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"SUB-CONTRATO NAO BLOQUEADO"
Else
	@ 108, 008  Say oSay PROMPT STR0107 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Bloqueio"
	@ 108, 070  Say oSay PROMPT ": "+BQC->BQC_CODBLO+ " - " + Posicione("BQU",1,xFilial("BQU")+BQC->BQC_CODBLO,"BQU_DESBLO") SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
	@ 118, 008  Say oSay PROMPT STR0108 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Data Bloqueio "
	@ 118, 070  Say oSay PROMPT ": "+DTOC(BQC->BQC_DATBLO) SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
EndIf

@ 135, 003 GROUP oGrupo TO 220, 350 PIXEL OF oDlg LABEL " "+If(Empty(BQC->BQC_CODBLO),"B","Desb")+"loquear Sub-Contrato" +" "  COLOR CLR_BLACK, CLR_HRED

@ 141.5, 060   Say oSay PROMPT STR0109 SIZE 250,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_BLACK //"Tipo"
@ 141.5, 124.5 Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_BLACK
@ 141.5, 130   Say oSay PROMPT If(Empty(BQC->BQC_CODBLO),STR0107,STR0110) SIZE 250,010 OF oDlg PIXEL FONT oFontAutorAutor COLOR If(Empty(BQC->BQC_CODBLO),CLR_HRED,CLR_BLACK) //"Bloqueio"###"DesBloqueio"

@ 155, 060  Say oSay PROMPT STR0111 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Data"
@ 155, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 155, 130  MSGET oGet VAR dDatBlq SIZE 0,0 OF oDlg FONT oFont PICTURE "@D" PIXEL VALID BlqConf("",dDatBlq,"","","BQU",'1',,'1')

If Empty(BQC->BQC_CODBLO)
	@ 155, 200  Say oSay PROMPT STR0122 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Dt Ped Bloq"
	@ 155, 250  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
	@ 155, 255  MSGET oGet VAR dDatPed SIZE 0,0 OF oDlg FONT oFont PICTURE "@D" PIXEL VALID BlqConf("","","","","BQU",'4',,'1',dDatPed)
EndIf

@ 170, 060  Say oSay PROMPT STR0112+If(Empty(BQC->BQC_CODBLO),"B","Desb")+"loqueio" SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Motivo do "
@ 170, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 170, 130  MSGET oGet VAR cMotBlo SIZE 0,0 OF oDlg FONT oFont PICTURE "@!" F3 Iif(PlsGetVersao() >= 8, 'BQXPLS', 'BQX') VALID If(BlqConf(cMotBlo,cTod(""),"","","BQU",'2',,''),;
																							   cDesBlq := Posicione("BQU",1,xFilial("BQU")+cMotBlo,"BQU_DESBLO"),.F.) PIXEL

@ 170, 160  MSGET oGet VAR cDesBlq SIZE 0,0 OF oDlg FONT oFont PICTURE "@!" WHEN .F. PIXEL

@ 185, 060  Say oSay PROMPT STR0113 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Observação"
@ 185, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 185, 130  MSGET oGet VAR cObsBlq SIZE 0,0 OF oDlg FONT oFont PICTURE "@S35!" PIXEL

If Empty(BQC->BQC_CODBLO)
	@ 200, 020  Say oSay PROMPT STR0197 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK // "Bloquear Famílias com Bloqueio Futuro?"
	@ 200, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
	@ 200, 130  MSCOMBOBOX oCbx VAR cBloqFut ITEMS aBloqFut SIZE 35, 10 OF oDlg PIXEL
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOK, bCancel, .F., aButtons)

//Arquivo BQC deve estar posicionado
If nOpca == K_OK
	lBloqFut := IIF(cBloqFut == "Não", .F., .T.)
	BLQSubCont(If(Empty(BQC->BQC_CODBLO),"0","1"), dDatBlq, cMotBlo, cObsBlq, BQU->BQU_BLOFAT,dDatPed,lBloqFut)
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BlqConf   ºAutor  ³Paulo Carnelossi    º Data ³  20/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirma se Bloqueia ou Desbloqueia Sub-Contrato            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BlqConf(cMotBlq,dDatBlq,cBloqueio,cOpcao,cTcAlias,cTipo,dDatInc,cOrigem,dDatPed,cBloqFut) 
/* cTipo
1 = Validacao da data de bloqueio.
2 = Validacao do motivo de bloqueio.
3 = Validacao no botao de OK.
4 = Validacao da Data de Pedido do Bloqueio

** cOrigem 
1 - Subcontrato
2 - Familia
3 - Usuario

*/
LOCAL cOperacao := "0"
LOCAL lRet 			:= .T.
LOCAL cTitulo   	:= STR0114+If(Empty(cBloqueio) ,STR0107,STR0110)+cOpcao //"Confirma o "###"Bloqueio"###"DesBloqueio"

DEFAULT cTipo 		:= '1,2,3,4'
DEFAULT dDatInc     := dDataBase
DEFAULT cOrigem		:= ''
DEFAULT cBloqFut	:= ""

//verificando o valor de BQC->BQC_CODBLO, se "" nOperacao = 0 (bloqueio), senão nOperacao = 1 (desbloqueio)
If Empty (BQC->BQC_CODBLO)
	cOperacao := "0"
	//Alert("Bloqueio")
Else
	cOperacao := "1"
	//Alert("Desbloqueio")
EndIf

If  Empty(dDatBlq) .And. cTipo $ '1'
	MsgStop(STR0115) //"Campo Data do Bloqueio é obrigatório!"
	lRet := .F.
	
ElseIf !Empty(BQC->BQC_DATBLO) .And. cTipo $ '1'
	If dDatBlq < BQC->BQC_DATBLO
	   MsgStop(STR0116)			 //"Data de (des)bloqueio invalida."
	   lRet := .F.
	Endif
	
ElseIf Empty(cMotBlq) .And. cTipo $ '2'
	MsgStop(STR0117) //"Campo Motivo do Bloqueio é obrigatório!"
	lRet := .F.
	
ElseIf !Empty(cMotBlq) .And. cTipo $ '2'                                
	&(cTcAlias)->( dbSetorder(01) )
	&(cTcAlias)->( MsSeek(xFilial(cTcAlias)+cMotBlq))
	If (cTcAlias)->BQU_TIPBLO != cOperacao .Or. ! &(cTcAlias)->( MsSeek(xFilial(cTcAlias)+cMotBlq)) //motivo digitado é diferente da operação a ser realizada
		MsgStop(STR0118)			 //"Motivo de bloqueio nao cadastrado na base de dados."
		lRet := .F.
	EndIf
	     
Elseif Empty(cBloqueio) .And. cTipo $ '3'
	If dDatBlq < dDatInc
		MsgStop(STR0136)   //"Data de bloqueio nao pode ser menor que a data de inclusao."
		lRet := .F.
	EndIf		
	
ElseIf !Empty(cMotBlq) .And. cTipo $ '3'                                
	If Aviso( If(Empty(cBloqueio) ,STR0107,STR0110), cTitulo, { STR0119, STR0120}, 2 ) 	== 1 //"Bloqueio"###"DesBloqueio"###"Sim"###"Nao"
  	   lRet := .T.
    Else
       lRet := .F.                                  
    Endif
ElseIf Empty(dDatPed) .And. cTipo $ '4'                                
	   MsgStop(STR0123)			 //"Campo Dt Ped Bloq é obrigatório!"
       lRet := .F.                                  
EndIf

If lRet // So se estiver tudo ok.	
	If cTipo == '3' .and. cOrigem == '1' // Bloqueio do subcontrato.
		If ExistBlock("PLBLQSUB")
			lRet := ExecBlock('PLBLQSUB',.F.,.F.,{cBloqueio,cMotBlq,dDatBlq,cTcAlias,dDatInc,dDatPed,cBloqFut})
		Endif
		
	Elseif cTipo == '3' .and. cOrigem == '2'  // Bloqueio da familia.
		If ExistBlock("PLBLQFAM")
			lRet := ExecBlock('PLBLQFAM',.F.,.F.,{cBloqueio,cMotBlq,dDatBlq,cTcAlias,dDatInc,dDatPed})
		Endif	
			
	Elseif cTipo == '3' .and. cOrigem == '3' // Bloqueio do usuario.
		If ExistBlock("PLBLQUSR")
			lRet := ExecBlock('PLBLQUSR',.F.,.F.,{cBloqueio,cMotBlq,dDatBlq,cTcAlias,dDatInc,dDatPed})
		Endif	
	
	Endif
Endif
		
Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BLQSubContºAutor  ³Paulo Carnelossi    º Data ³  20/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava Bloqueio e desbloqueio de Subcontrato                 º±±
±±º          ³BQC deve estar posicionado                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BLQSubCont(cTipo, dDatBlq, cMotivo, cObserv, cBloFat,dDatPed,lBloqFut)

Local dDatBlqAnt 	:= BQC->BQC_DATBLO
Local cMotBlqAnt 	:= BQC->BQC_CODBLO
Local aAreaBQC   	:= BQC->(GetArea())
Local aAreaBA1   	:= BA1->(GetArea())
Local aAreaBA3   	:= BA3->(GetArea())
Local cNivel     	:= "S"
Local lGrvHist 		:= .F.  
Local lPL660BQ1 	:= ExistBlock("PL660BQ1")  
Local lPL660BQ2 	:= ExistBlock("PL660BQ2")
Local lAtuNio 		:= .T.
Local cBlqAns 		:= ""
Local cDesBloAns 	:= ""                     
LOCAL lCentralObr 	:= GetNewPar("MV_PLSEXCO",.F.)//Indica se o sistema utilizara a atualizacao automatica da central de obrigacoes sempre que um cadastro relevante for alterado no Protheus
Local lUsaSIP 		:= "1" $ GetNewPar("MV_PLSTIPO","")
Local lUsaSIB 		:= "2" $ GetNewPar("MV_PLSTIPO","")
LOCAL aCritSib 		:= {}
LOCAL aRecBa1 		:= {}
LOCAL nInd			:= 0
Local lSIPSincrono 	:= "1" $ GetNewPar("MV_PLOBRSI","1,2")
Local lSIBSincrono 	:= "2" $ GetNewPar("MV_PLOBRSI","1,2")
Local cB3KMat 		:= ""
Local cNomBen 		:= ""
Local aOpcSip 		:= {}
Local aDadCob 		:= {}
Local aDadNioAux 	:= {}
Local aDadCobJob 	:= {}
Local aDadUsr		:= {}
local cChaveHAT 	:= ""
Local lBloqBenef
Local lBloqFam
Local cChvBA3, cChvBA1

Default lBloqFut := .F.

dbSelectArea("BQC")

//Bloqueia o Sub-Contrato
RecLock("BQC", .F.)
If cTipo == "0"
	BQC->BQC_TIPBLO := cTipo
	BQC->BQC_CODBLO := cMotivo
	BQC->BQC_DATBLO := dDatBlq
Else
	BQC->BQC_TIPBLO := cTipo
	BQC->BQC_CODBLO := ""
	BQC->BQC_DATBLO := Ctod("")
EndIf
MsUnLock()

//historico do sub-contrato
BCC->(RecLock("BCC", .T.))
BCC->BCC_FILIAL	:= xFilial("BCC")
BCC->BCC_CODIGO	:=	BQC->BQC_CODIGO
BCC->BCC_NUMCON	:=	BQC->BQC_NUMCON
BCC->BCC_VERCON	:=	BQC->BQC_VERCON
BCC->BCC_SUBCON	:=	BQC->BQC_SUBCON
BCC->BCC_VERSUB	:=	BQC->BQC_VERSUB
BCC->BCC_TIPO	:=	cTipo
BCC->BCC_DATA	:=	dDatBlq
BCC->BCC_MOTBLO	:=	cMotivo
BCC->BCC_OBS	:=	cObserv
BCC->BCC_USUOPE	:=	cUserName
BCC->BCC_NIVBLQ	:=	"S"
BCC->BCC_DATPED	:=	dDatPed
BCC->BCC_DATLAN	:=	Date()
BCC->BCC_HORLAN	:=	Time()
BCC->(MsUnlock())

cChvBA3 := xFilial("BA3")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)

dbSelectArea("BA3")
dbSetOrder(7)
MsSeek(cChvBA3)

While BA3->(! EOF() .And. BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_CONEMP+;
	BA3_VERCON+BA3_SUBCON+BA3_VERSUB == cChvBA3)
	
	lGrvHist := .F.
	
	// Bloqueia Familia
	If cTipo == "0"

		lBloqFam := IIF(lBloqFut, !Empty(BA3->BA3_DATBLO) .AND. BA3->BA3_DATBLO > dDatBlq, .F.)

		If Empty(BA3->BA3_MOTBLO) .OR. lBloqFam 
			RecLock("BA3", .F.)
			lGrvHist := .T.
			BA3->BA3_MOTBLO := cMotivo
			BA3->BA3_DATBLO := dDatBlq
			If BA3->(FieldPos("BA3_CONSID")) > 0
				BA3->BA3_CONSID := 'S'
			Endif			
			If BA3->(FieldPos("BA3_BLOFAT")) > 0
				BA3->BA3_BLOFAT := cBloFat
			Endif
			MsUnlock()
		EndIf
	Else
		If ! Empty(BA3->BA3_MOTBLO) .And. BA3->BA3_MOTBLO == cMotBlqAnt;
			.And. BA3->BA3_DATBLO == dDatBlqAnt

			If BA3->(FieldPos("BA3_CONSID")) > 0 .AND. !(Substr(BA3->BA3_CONSID,1,1) $ 'S, ')
				lGrvHist := .F.
				
			Else
				RecLock("BA3", .F.)
					lGrvHist := .T.
					BA3->BA3_MOTBLO := ""
					BA3->BA3_DATBLO := CTOD("")
					If BA3->(FieldPos("BA3_CONSID")) > 0		
						BA3->BA3_CONSID := ""	
					Endif
					If BA3->(FieldPos("BA3_BLOFAT")) > 0
						BA3->BA3_BLOFAT := ""
					Endif
					MsUnlock()
			Endif
		EndIf
	EndIf
	
	If lGrvHist
		//gravar no historico bloqueio da familia
		RecLock("BC3", .T.)
		BC3_FILIAL 	:= xFilial("BC3")
		BC3_MATRIC 	:= BA3->(BA3_CODINT + BA3_CODEMP + BA3_MATRIC)
		BC3_TIPO	:= cTipo
		BC3_DATA	:= dDatBlq
		BC3_MOTBLO	:= cMotivo
		BC3_OBS		:= cObserv
		BC3_USUOPE	:= cUserName
		BC3_NIVBLQ 	:= "S"
		BC3_DATPED	:= dDatPed
		BC3_DATLAN  := Date()
		BC3_HORLAN  := Time()
		If BC3->(FieldPos("BC3_BLOFAT")) > 0
			BC3_BLOFAT	:= cBloFat
		Endif
		MsUnlock()
	EndIf
	
	//Bloqueia usuarios da familia
	cChvBA1 := xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
	
	dbSelectArea("BA1")
	dbSetOrder(2)
	MsSeek(cChvBA1)
	BQU->(DbSetOrder(1)) //BQU_FILIAL+BQU_CODBLO
	If BQU->(DbSeek(xFilial("BQU")+cMotivo))
			cBlqAns := Alltrim(BQU->BQU_BLQANS)
		If BQU->(Fieldpos("BQU_ENVANS")) > 0
			cDesBloAns := Alltrim(BQU->BQU_ENVANS)
		EndIf
	EndIf
	
	While BA1->(! EOF() .And. BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_MATRIC == ;
		cChvBA1)
		
		lGrvHist:= .F.	
		
		// Bloqueia Usuarios
		If cTipo == "0"
			lBloqBenef := IIF(lBloqFut, !Empty(BA1->BA1_DATBLO) .AND. BA1->BA1_DATBLO > dDatBlq, .F.)

			If Empty(BA1->BA1_MOTBLO) .OR. lBloqBenef
				RecLock("BA1", .F.)
				lGrvHist := .T.				
				BA1->BA1_MOTBLO := cMotivo
				BA1->BA1_DATBLO := dDatBlq
				BA1->BA1_IMAGE  := "DISABLE"
				BA1->BA1_CONSID := "S"
				If BA1->(FieldPos("BA1_BLOFAT")) > 0
					BA1->BA1_BLOFAT	:= cBloFat
				Endif			
				MsUnlock()

				Aadd(aRecBa1,{BA1->(RECNO()), .F.} ) /*Beneficiário não estava bloqueado*/ 
			Else

				Aadd(aRecBa1,{BA1->(RECNO()), .T.} ) /*Beneficiário já estava bloqueado*/
			EndIf 
		Else
			If ! Empty(BA1->BA1_MOTBLO).And. BA1->BA1_MOTBLO == cMotBlqAnt;
				.And. BA1->BA1_DATBLO == dDatBlqAnt .and. BA1->BA1_CONSID $ 'S, '

				RecLock("BA1", .F.)
				lGrvHist := .T.
				BA1->BA1_MOTBLO := ""
				BA1->BA1_DATBLO := CTOD("")
				BA1->BA1_IMAGE  := "ENABLE"
				BA1->BA1_CONSID := ""     
				If BA1->(FieldPos("BA1_BLOFAT")) > 0
					BA1->BA1_BLOFAT := ""
				Endif
				MsUnlock()

				Aadd(aRecBa1,{BA1->(RECNO()), .F.} ) /*Beneficiário não estava bloqueado*/ 
			Else
				Aadd(aRecBa1,{BA1->(RECNO()), .T.} ) /*Beneficiário já estava bloqueado*/
			EndIf 	
				
		EndIf					
		
		//gravar no historico bloqueio do usuario
		If lGrvHist
			RecLock("BCA", .T.)
			BCA_FILIAL 	:= xFilial("BCA")
			BCA_MATRIC 	:= BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC)
			BCA_TIPREG	:= BA1->BA1_TIPREG
			BCA_TIPO	:= cTipo
			BCA_DATA	:= dDatBlq
			BCA_MOTBLO	:= cMotivo
			BCA_OBS		:= cObserv
			BCA_USUOPE	:= cUserName
			BCA_NIVBLQ 	:= "S"
			BCA_DATPED	:= dDatPed
			BCA_DATLAN  := Date()
			BCA_HORLAN  := Time()
			If BCA->(FieldPos("BCA_BLOFAT")) > 0
				BCA_BLOFAT	:= cBloFat
			Endif
			MsUnlock()

			if GetNewPar("MV_PLSHAT","0") == "1"
				BNV->(DbSetOrder(2))//BNV_FILIAL+BNV_CODTRA+BNV_ALIAS+BNV_CHAVE
				//Bloqueio
				if cTipo == "0"
					//Verifico se ja tem desbloqueio nao enviado, se tiver, excluo
					if BNV->(MsSeek(xFilial("BNV")+_beneficiaryStatus_desblo+"BCA"+BCA->(BCA_MATRIC+BCA_TIPREG)+Dtos(BCA->BCA_DATA))) .And. BNV->BNV_STATUS == HAT_PENDENTE_ENVIO
						PLS274GRV( K_Excluir )
					else
						cChaveHAT := BCA->(BCA_MATRIC+BCA_TIPREG)+Dtos(BCA->BCA_DATA)+BCA->BCA_TIPO
						PLHATPedPD(K_Incluir,_beneficiaryStatus_blo,"BCA",cChaveHAT,NIL,1)	
					endIf	
				//Desbloqueio
				else 
					//Verifico se ja tem bloqueio nao enviado, se tiver, excluo
				    If BNV->(MsSeek(xFilial("BNV")+_beneficiaryStatus_blo+"BCA"+BCA->(BCA_MATRIC+BCA_TIPREG)+Dtos(BCA->BCA_DATA))) .And. BNV->BNV_STATUS == HAT_PENDENTE_ENVIO
						PLS274GRV( K_Excluir )
					Else
						cChaveHAT := BCA->(BCA_MATRIC+BCA_TIPREG)+Dtos(BCA->BCA_DATA)+BCA->BCA_TIPO
						PLHATPedPD(K_Incluir,_beneficiaryStatus_desblo,"BCA",cChaveHAT,NIL,1)	
				    EndIf		
				endIf	
			endIf

		EndIf
		
		// Sava Area
		nRegBA1 := BA1->( Recno() )
		nRegBA3 := BA3->( Recno() )
		
		If lPL660BQ1
			ExecBlock("PL660BQ1",.F.,.F.,{cTipo, dDatBlq, cMotivo, lGrvHist})
		Endif
		
		// Restaura area
		BA1->( dbGoto(nRegBA1) )
		BA3->( dbGoto(nRegBA3) )		
		BA1->(dbSkip())
		
	End

	// Sava Area
	nRegBA1 := BA1->( Recno() )
	nRegBA3 := BA3->( Recno() )

	If lPL660BQ2
		ExecBlock("PL660BQ2",.F.,.F.,{cTipo, dDatBlq, cMotivo, lGrvHist})
	Endif	
	
	// Restaura area
	BA1->( dbGoto(nRegBA1) )
	BA3->( dbGoto(nRegBA3) )			
	BA3->(dbSkip())
	
End
//Verifica o campo BQU_ENVANS, para fazer ou não a comunicação com a central.
If cTipo == "1" .And. cDesBloAns == "0"
	lAtuNio := .F.
//Verifica se o campo BLQANS está preenchido no momento do bloqueio
ElseIf cTipo == "0" .And. Empty(cBlqAns)
	lAtuNio := .F.
EndIf

//Rotina que trata e envia os dados dos beneficiários para a Central de Obrigações
If lCentralObr .AND. (lUsaSIP .OR.  lUsaSIB) .AND. lAtuNio
	aAreaBA1 := BA1->(GetArea())
	aAreaBA3 := BA3->(GetArea())
	aAreaBTS := BTS->(GetArea())
	
	//Percorro os beneficiários da familia			
	For nInd := 1 To Len(aRecBa1)

		BA1->( dbGoto(aRecBa1[nInd][1]) ) //Recno
		
		//Se não estava bloqueado antes de bloquear o subcontrato atualiza a central
		If !aRecBa1[nInd][2] 
			
			BA3->( dbSetOrder(1))
			BA3->(MsSeek( xFilial("BA3") + BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB) ))
			
			If PlSibEnvANS(BA3->BA3_TIPOUS,BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_CONEMP,BA3->BA3_VERCON,;
							BA3->BA3_SUBCON,BA3->BA3_VERSUB,BA1->BA1_INFANS)	

				
				//0-Bloqueio ; 1-Desbloqueio
				If cTipo == "0"
					oModel := Pl260DadNio('1',Nil,Nil,"",aDadUsr,.T.,.T., , lUsaSIP )						
					oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','4')//Envio um bloqueio						
					oModel:SetValue( "B3KMASTER", 'B3K_MOTBLO', PlMotBloANS(cNivel,cMotivo))//motivo de des/bloqueio -- Na central o campo tem tamanho 2
					oModel:SetValue( "B3KMASTER", 'B3K_DATBLO',dDatBlq)//Data de Bloqueio		
				Else
					oModel := Pl260DadNio('1',Nil,Nil,"",aDadUsr,.T.,.F., , lUsaSIP )
					oModel:SetValue( "B3KMASTER", 'B3K_OPESIB','5')//Envio um desbloqueio									
					oModel:SetValue( "B3KMASTER", 'B3K_MOTBLO', PlMotBloANS(cNivel,cMotivo))//motivo de des/bloqueio -- Na central o campo tem tamanho 2
					oModel:SetValue( "B3KMASTER", 'B3K_DATREA' ,dDatBlq)//Data de Reativação
				EndIf

				If FindFunction("PLGetHrCentral")
					oModel := PLGetHrCentral(oModel)
				EndIf

				//Chamo a rotina genérica que atualiza o Núcleo de Informações da Central de Obrigações
				If lSIPSincrono .OR. lSIBSincrono 
					cB3KMat	:= oModel:GetValue( "B3KMASTER", 'B3K_MATRIC')
					cNomBen	:= oModel:GetValue( "B3KMASTER", 'B3K_NOMBEN')
					aAdd(aCritSib,{cB3KMat,cNomBen,""})
					oModel:commitData()
					
				EndIf
			EndIf
		EndIf 

		BA1->( dbSkip())
	Next nInd
	
	If Len(aDadNioAux) > 0
		StartJob("PLJOBNIO",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
					"B3K",aDadNioAux,nOpcx,.T./*lMult*/,aOpcSip,;
					dDataBase,aDadCobJob)
	EndIf
				
	RestArea(aAreaBA3)
	RestArea(aAreaBA1)
	RestArea(aAreaBTS)
EndIf



BQC->(RestArea(aAreaBQC))
BA1->(RestArea(aAreaBA1))
BA3->(RestArea(aAreaBA3))

dbSelectArea("BQC")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A660DescBloqºAutor ³Microsiga          º Data ³  26/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para carregar a descricao do bloqueio de acordo com  º±±
±±º          ³nivel de bloqueio                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a660DescBloq(cAlias)
Local aArea := GetArea()
Local cDescBlq := ""
Local cTipBlq := (cAlias)->(FieldGet(FieldPos(cAlias+"_NIVBLQ")))
Local cMotBlq := (cAlias)->(FieldGet(FieldPos(cAlias+"_MOTBLO")))
Local cAliasPesq := "BG1"

If 	cTipBlq == "S"		//Bloqueio por SubContrato
	cAliasPesq := "BQU"
ElseIf cTipBlq == "F"	//Bloqueio por Familia
	cAliasPesq := "BG1"
ElseIf cTipBlq == "U"	//Bloqueio por Usuario
	cAliasPesq := "BG3"
EndIf

If (cAliasPesq)->(MsSeek(xFilial(cAliasPesq)+cMotBlq))
	cDescBlq := (cAliasPesq)->(FieldGet(FieldPos(cAliasPesq+"_DESBLO")))
EndIf

RestArea(aArea)
Return(cDescBlq)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS660HIS ºAutor  ³Paulo Carnelossi    º Data ³  01/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exibir o historico de Bloqueio de Sub-Contrato              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLS660HIS(cAlias,nReg,nOpc)
Local I__f := 0
Local oDlg
Local oEncBQC
Local oBrwBCC

Local aCabBCC := {}
Local aDadBCC := {}
Local aVetBCC := {}

PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aHeader
PRIVATE aCols

Copy cAlias TO MEMORY

BCC->(DbSetOrder(1))
Store Header "BCC" TO aCabBCC For .T.
If ! BCC->(MsSeek(xFilial("BCC")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)))
	Store COLS Blank "BCC" TO aDadBCC FROM aCabBCC
Else
	Store COLS "BCC" TO aDadBCC FROM aCabBCC VETTRAB aVetBCC While BCC->(BCC_FILIAL+BCC_CODIGO+BCC_NUMCON+BCC_VERCON+BCC_SUBCON+BCC_VERSUB) == xFilial("BCC")+BQC->(BQC_CODIGO+BQC_NUMCON+BQC_VERCON+BQC_SUBCON+BQC_VERSUB)
Endif

If Len(aDadBCC) == 0
	Store COLS Blank "BCC" TO aDadBCC FROM aCabBCC
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetEnch("")
DEFINE MSDIALOG oDlg TITLE cCadastro FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

Zero();oEncBQC := MsMGet():New(cAlias,nReg,K_Visualizar,,,,,{029,005,110,343},,,,,,oDlg,,,.F.)

oBrwBCC := BCC->(TPLSBrw():New(116,005,343,195,nil,oDlg,nil,{||.t.},nil,nil,nil,.T.,nil,.T.,nil,aCabBCC,aDadBCC,.F.,"BCC",K_Visualizar,STR0121,nil,nil,nil,aVetBCC,,,)) //"Histórico Bloqueio de Sub-Contrato"

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (PlsEndBrw(),oDlg:End())},{|| PlsEndBrw(), oDlg:End() },K_MsgDel)

Return

/*/ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS660ADCM  Autor³Geraldo Felix Junior  ³ Data ³ 04.06.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Classe de Carencia para novos dependent³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Function PLS660ADCM(oBrwBEY)

LOCAL oDlg
LOCAL nOpca      := 0
LOCAL nOldN      := oBrwBEY:oBrowse:nAt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Esta rotina sera usada na inclusao e na alteracao...                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF EMPTY(oBrwBEY:aCols[nOldN, 2])	//	o campo Tipo é Obrigatório
	MsgInfo(STR0180)	//	"Preencha o Registro antes de informar a Classe de Carência"
  RETURN
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0043 FROM 009,000 TO 029,060 OF GetWndDefault() //"Classe de Carencia"
oDlg:lEscClose := .F.
PlsBut(oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BWV->( FieldPos("BWV_VERPRO") ) > 0 .And. BT8->( FieldPos("BEY_VERPRO") ) > 0
	bFilter         := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BWV_CODPRO",aHeader)] == cCodProSel .And.;
		aCols[nLine,GdFieldPos("BWV_VERPRO",aHeader)] == cVersaoSel .And.;
		aCols[nLine,GdFieldPos("BWV_CODGRU",aHeader)] == cCodSeqBEY}
	oBrwBWV         := TPLSBrw():New(0037,001,240,150,,oDlg,,,,,,.T.,,.T.,,aCabBWV,aDadBWV,.F.,"BWV",nOpcx,STR0043,,,,aTrbBWV,,,bFilter) //"Classe de Carencia"
	oBrwBWV:oPai    := oBrwBEY
	oBrwBWV:aOrigem := {"BEY_CODPRO","BEY_VERPRO","BEY_SEQUEN"}
	oBrwBWV:aRelac  := {"BWV_CODPRO","BWV_VERPRO","BWV_CODGRU"}
Else
	bFilter         := {|nLine,aCols,aHeader|	aCols[nLine,GdFieldPos("BWV_CODPRO",aHeader)] == cCodProSel .And.;
		aCols[nLine,GdFieldPos("BWV_CODGRU",aHeader)] == cCodSeqBEY}
	oBrwBWV         := TPLSBrw():New(0030,001,240,150,,oDlg,,,,,,.T.,,.T.,,aCabBWV,aDadBWV,.F.,"BWV",nOpcx,STR0043,,,,aTrbBWV,,,bFilter) //"Classe de Carencia"
	oBrwBWV:oPai    := oBrwBEY
	oBrwBWV:aOrigem := {"BEY_CODPRO","BEY_SEQUEN"}
	oBrwBWV:aRelac  := {"BWV_CODPRO","BWV_CODGRU"}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o dialogo...                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
	aDadBWV := aClone(oBrwBWV:aCols)
Endif
oBrwBEY:Atualiza()
oBrwBEY:SetPos(nOldN)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSM660Del³ Autor ³Wagner Mobile Costa  ³ Data ³ 21.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca as propriedades da cobranca ao deletar a forma       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSM660DEL(nOpc, nTipo, lFRefres)
Local nI,nInd,nTr
Local cCodFor, cChave, aVetsTmp, aTrab, aOpcoes
Local aSavCols := AClone(aCols), aSavHead := AClone(aHeader)
DEFAULT lFRefres := .F.

if nTipo == 1
	cCodFor := oBrwFor:FieldGet("BT9_CODFOR")
	cChave  := oBrwFor:FieldGet("BT9_CODFOR")+cCodProSel+cVersaoSel
	aVetsTmp := AClone(aVetsFor)
Elseif nTipo == 2
	cCodFor := oBrwAde:FieldGet("BTK_CODFOR")
	cChave  := oBrwAde:FieldGet("BTK_CODFOR")+cCodProSel+cVersaoSel
	aVetsTmp := AClone(aVetsTxF)
Else
	cCodFor := oBrwFrOpc:FieldGet("BJW_CODFOR")
	cChave  := oBrwFrOpc:FieldGet("BJW_CODFOR")+cCodProSel+cVersaoSel+cCodOpcSel+cVerOpcSel
	aVetsTmp := AClone(aVetsOpc)
Endif

aOpcoes := a660MOpc(cCodFor)

For nI := 1 To Len(aOpcoes)
	cAlias  := aOpcoes[nI,2]
	cTipo   := aOpcoes[nI,3]
	aHeader := {}
	aCols   := {}
	DbSelectArea(cAlias)
	
	cBrw := "oBrw"+cAlias
	STORE HEADER cAlias TO aHeader For .T.
	
	lFlag    := .F.
	For nInd := 1 To Len(aVetsTmp)
		If cTipo == "1"
			if nTipo < 3
				if aVetsTmp[nInd,2] == cAlias  .And. aVetsTmp[nInd,12] == cChave
					aTrab   := aVetsTmp[nInd,4]
					_aVetTrb := aVetsTmp[nInd,5]
					For nTr := 1 To Len(aTrab)
						nPos := PLRETPOS(cAlias+"_VERPRO",aHeader,.F.)
						if aTrab[nTr,1] == cCodProSel .And. aTrab[nTr,nPos] == cVersaoSel
							If ! aTrab[nTr,Len(aHeader)+1]//SE ELE ESTA ATIVO EU DELETO
								aVetsTmp[nInd,4][nTr][Len(aVetsTmp[nInd,4][nTr])] := .T.
							Else//SE ELE ESTA DELETADO EU ATIVO
								aVetsTmp[nInd,4][nTr][Len(aVetsTmp[nInd,4][nTr])] := .F.
							Endif
						Endif
					Next
				Endif
			Else
				if aVetsTmp[nInd,12] == cChave .And. aVetsTmp[nInd,2] == cAlias
					aTrab   := aVetsTmp[nInd,4]
					_aVetTrb := aVetsTmp[nInd,5]
					For nTr := 1 To Len(aTrab)
						if cCodProSel == aTrab[nTr,1] .And. aTrab[nTr,3] == cCodOpcSel .And. aTrab[nTr,4] == cVerOpcSel 
							iF ! aTrab[nTr,Len(aHeader)+1]
								aVetsTmp[nInd,4][nTr][Len(aVetsTmp[nInd,4][nTr])] := .T.
							Else
								aVetsTmp[nInd,4][nTr][Len(aVetsTmp[nInd,4][nTr])] := .F.
							Endif
						Endif
					Next
				Endif
			Endif
		Endif
	Next
Next

if nTipo == 1
	aVetsFor := aClone(aVetsTmp)
Elseif nTipo == 2
	aVetsTxF := aClone(aVetsTmp)
Elseif nTipo == 3
	aVetsOpc := aClone(aVetsTmp)
Endif

aCols := AClone(aSavCols)
aHeader := AClone(aSavHead)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Pls660DRel³ Autor ³Wagner Mobile Costa  ³ Data ³ 29.07.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta o produto vinculado e as formas de cobranca rel.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Pls660DRel

Local nCols := 0

If 	oBrwOpc:IsDeleted(oBrwOpc:Linha()) .Or.;
	oBrwOpc:FieldGet("BHS_TIPVIN")=="1"
	For nCols := 1 To Len(oBrwFrOpc:aCols)
		oBrwFrOpc:oBrowse:oBrowse:nAt := nCols
		oBrwFrOpc:aCols[oBrwFrOpc:Linha(), Len(oBrwFrOpc:aCols[1])] := .T.
		PLSM660Del(nOpcx, 3)
	Next
	oBrwFrOpc:ForceRefresh(oBrwFrOpc)
	oBrwFrOpc:oBrowse:oBrowse:nAt := 1
	oBrwFrOpc:OBROWSE:OBROWSE:lReadOnly := .T.
Else
	oBrwFrOpc:OBROWSE:OBROWSE:lReadOnly := .F.
Endif	

Return .T.

Function PL660DOP()

	Local lRet := .T.

	lRet := ExecBlock("PL660OUS",.F.,.F.,{})
	
	If lRet
		PLSM660Del(nOpcx, 3, .T.)
	EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Pls660DB34³ Autor ³Otacilio A. Junior   ³ Data ³ 31.05.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta o itens da Classe de Procedimento.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Pls660DB34
Local nCols := 0

If oBrwB33:IsDeleted(oBrwB33:Linha()) 
	For nCols := 1 To Len(oBrwB34:aCols)
		oBrwB34:oBrowse:oBrowse:nAt := nCols
		oBrwB34:aCols[oBrwB34:Linha(), Len(oBrwB34:aCols[1])] := .T.
		PLSM660Del(nOpcx, 3)
	Next
	oBrwB34:ForceRefresh(oBrwB33)
	oBrwB34:oBrowse:oBrowse:nAt := 1
	oBrwB34:OBrowse:OBrowse:lReadOnly := .T.
Else
	oBrwB34:OBrowse:OBrowse:lReadOnly := .F.
Endif	

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLSM660NAl³ Autor ³Wagner Mobile Costa  ³ Data ³ 22.08.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Nao permite alteracao do codigo da cobranca caso  ja  tenha³±±
±±³          ³ propriedades                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSM660NAl(cAlias)

Local lEdita := .T., nFor
Local nRecTrab, aVetsTmp, cCodFor

if cAlias = "BT9"
	aVetsTmp := AClone(aVetsFor)
	cCodFor := M->BT9_CODFOR
Elseif cAlias = "BTK"
	aVetsTmp := AClone(aVetsTxF)
	cCodFor := M->BTK_CODFOR
Elseif cAlias = "BJW"
	aVetsTmp := AClone(aVetsOpc)
	cCodFor := M->BJW_CODFOR
Elseif cAlias = "B31"
	aVetsTmp := AClone(aVetB32)
	cCodFor := M->B31_CLASSE
Elseif cAlias = "B33"
	aVetsTmp := AClone(aVetB34)
	cCodFor := M->B33_CLASSE
Endif

For nFor := 1 To Len(aVetsTmp)
	If 	aVetsTmp[nFor][1] = cCodFor 
		If Len(aVetsTmp[nFor]) > 12 .And. aVetsTmp[nFor][13]
			lEdita := .F.
		Else
			If ValType(aVetsTmp[nFor][5]) = "A"
				For nRecTrab := 1 To Len(aVetsTmp[nFor][5])
					If aVetsTmp[nFor][5][nRecTrab] > 0
						lEdita := .F.
						Exit
					Endif
				Next
			Else
				lEdita := aVetsTmp[nFor][5] = 0
			Endif
		Endif
		If ! lEdita
			Exit
		Endif
	Endif
Next

Return lEdita


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS660BGS³ Autor ³ Michele Tatagiba     ³ Data ³ 04.10.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Co Participacao para Tipo Prestador    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS660BGS(oBrwBGP)

LOCAL oDlg 
LOCAL nOpca      := 0
LOCAL nOldN      := oBrwBGP:oBrowse:nAt
LOCAL aButtBGS	 := {}
LOCAL cDesPre	 := oBrwBGP:FieldGet("BGP_DESPRE")

DEFINE MSDIALOG oDlg TITLE STR0057+cTipPre+" - "+cDesPre FROM 009,000 TO 029,060 OF GetWndDefault() //"Co-participacao:  "
oDlg:lEscClose := .F.

PlsBut(oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para consulta do historico de reajuste da franquia...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBGS, {"BUDGET",{||PL660HTFRA('1',"BGS",	cChavSub,;
													oBrwBGS:FieldGet("BGS_CODPRO"),;
													Iif((BGS->( FieldPos("BGS_VERPRO") ) > 0), oBrwBGS:FieldGet("BGS_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BGS_CODPRO",aHeader)]== cCodProSel .And.;
									aCols[nLine,GdFieldPos("BGS_VERPRO",aHeader)]== cVersaoSel .And.;
									aCols[nLine,GdFieldPos("BGS_TIPPRE",aHeader)]== cTipPre}

oBrwBGS  := TPLSBrw():New(0031,003,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBGS ,aDadBGS ,.F. ,"BGS" ,nOpcX,STR0028,nil,nil,nil,aTrbBGS,'PlsVldBGS',,bFilter,,aButtBGS) //"Co-participacao" 
oBrwBGS:oPai       := oBrwBGP
oBrwBGS:aOrigem    := {"BGP_CODPRO","BGP_VERPRO","BGP_TIPPRE"}
oBrwBGS:aRelac     := {"BGS_CODPRO","BGS_VERPRO","BGS_TIPPRE"}
                               
ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| nOpca:= 0,oDlg:End()} ))

If nOpca == 1
	aCabBGS := aClone(oBrwBGS:aHeader)
	aDadBGS := aClone(oBrwBGS:aCols)
Endif
                       
oBrwBGP:Atualiza()
oBrwBGP:SetPos(nOldN)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS660BGL³ Autor ³ Eduardo Motta        ³ Data ³ 08.01.2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados da Co Participacao para Municipio Atend.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS660BGL(oBrwBGG)
LOCAL oDlg

LOCAL nOpca      := 0
LOCAL nOldN      := oBrwBGG:oBrowse:nAt
LOCAL aButtBGL	 := {}

PRIVATE cDesMun  := Posicione("BID",1,xFilial("BID")+cCodMun,"BID_DESCRI")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta botao para consulta do historico de reajuste da franquia...   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PLSALIASEX("B0B")
	Aadd(aButtBGL, {"BUDGET",{||PL660HTFRA('1',"BGL",	cChavSub,;
													oBrwBGL:FieldGet("BGL_CODPRO"),;
													Iif((BGL->( FieldPos("BGL_VERPRO") ) > 0), oBrwBGL:FieldGet("BGL_VERPRO"), NIL))},;
													STR0131,STR0132}) //"Historico de reajuste da franquia"###"Historico"
Endif
													
DEFINE MSDIALOG oDlg TITLE STR0057+cCodMun+" - "+cDesMun FROM 009,000 TO 029,060 OF GetWndDefault() //"Co-participacao:  "
oDlg:lEscClose := .F.

PlsBut(oDlg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("BGL_CODPRO",aHeader)]== cCodProSel .And.;
									aCols[nLine,GdFieldPos("BGL_VERPRO",aHeader)]== cVersaoSel .And.;
									aCols[nLine,GdFieldPos("BGL_CODMUN",aHeader)]== cCodMun}
oBrwBGL  := TPLSBrw():New(0031,004,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabBGL ,aDadBGL ,.F. ,"BGL" ,nOpcX,STR0028,nil,nil,nil,aTrbBGL,'PlsVldBGL',,bFilter,,aButtBGL) //"Co-participacao" 
oBrwBGL:oPai       := oBrwBGG
oBrwBGL:aOrigem    := {"BGG_CODPRO","BGG_VERPRO","BGG_CODMUN"}
oBrwBGL:aRelac     := {"BGL_CODPRO","BGL_VERPRO","BGL_CODMUN"}

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| PlsEndBrw(),nOpca:= 0,oDlg:End()} ))

If nOpca == 1
	aCabBGL := aClone(oBrwBGL:aHeader)
	aDadBGL := aClone(oBrwBGL:aCols)
Endif             

oBrwBGG:Atualiza()
oBrwBGG:SetPos(nOldN)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PLS660B34³ Autor ³ David de Oliviera    ³ Data ³ 08.01.2007 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta a getdados dos Fatores de Co-participação            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS660B34(oBrwB33)
LOCAL oDlg

LOCAL nOpca      := 0
LOCAL nOldN      := oBrwB33:oBrowse:nAt

DEFINE MSDIALOG oDlg TITLE STR0127+cCodCla FROM 009,000 TO 029,060 OF GetWndDefault() //"Classe  "
oDlg:lEscClose := .F.

PlsBut(oDlg)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Browse dos Procedimentos                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bFilter   := {|nLine,aCols,aHeader|aCols[nLine,GdFieldPos("B34_CODPRO",aHeader)]== cCodProSel .And.;
												aCols[nLine,GdFieldPos("B34_SEQUEN",aHeader)]== cCodSeqB33 .And.;
												aCols[nLine,GdFieldPos("B34_VERSAO",aHeader)]== cVersaoSel .And.;
												aCols[nLine,GdFieldPos("B34_CLASSE",aHeader)]== cCodCla}
oBrwB34  			:= TPLSBrw():New(0031,004,237,150,nil  ,oDlg,nil    , nil      ,nil    ,nil  , nil, .T.  ,nil   ,.T.   ,nil   ,aCabB34 ,aDadB34 ,.F. ,"B34" ,nOpcX,STR0128,nil,nil,nil,aTrbB34,,,bFilter) //"Fatores de Reembolso" 
oBrwB34:oPai       := oBrwB33
oBrwB34:aOrigem    := {"B33_SEQUEN","B33_CODPRO","B33_VERSAO","B33_CLASSE"}
oBrwB34:aRelac     := {"B34_SEQUEN","B34_CODPRO","B34_VERSAO","B34_CLASSE"}                                                                       
oBrwB34:cVldLine   := 'PLSXANAFAI( { "B34_CLASSE","B34_ADEINI","B34_ADEFIM" },"B34_VIGINI","B34_VIGFIM",n)'

ACTIVATE DIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg, {|| nOpca:=1,PlsEndBrw(),oDlg:End()},{|| PlsEndBrw(),nOpca:= 0,oDlg:End()} ))

If nOpca == 1
	aCabB34 := aClone(oBrwB34:aHeader)
	aDadB34 := aClone(oBrwB34:aCols)
Endif             

oBrwB33:Atualiza()
oBrwB33:SetPos(nOldN)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PL660OpcDES³ Autor ³ Wagner Mobile Costa³ Data ³ 14.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno filtro para desconto para cobranca de produto      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL660OpcDES(nLine, aCols, aHeader)

Local lRet := .F.

If Type("oBrwBBX") = "O"
	lRet :=	oBrwBBX:FieldGet("BBX_CODFAI",oBrwBBX:LINHA()) == aCols[nLine,GdFieldPos("BGW_CODFAI",aHeader)] .AND.;
			aCols[nLine,GdFieldPos("BGW_VALOR",aHeader)] > 0
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Pl660FilBNT ³ Autor ³ Geraldo Felix Junior³ Data ³ 29.12.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra a tabela de cobranca do Sub-Contrato.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Pl660FilBTN(aCols, aHeader, nLine)
Local cFilBtn := GetNewPar("MV_PLFLBTN","")

If Type("OBrwBTN") = "U"
	Return .T.
Endif

If !lFiltro	// Indica que esta visualizando tabelas anteriores
	Return aCols[nLine,GdFIELDPOS("BTN_TABVLD",AHEADER)] <> Ctod("")
Else      
    If cFilBtn == "2"
	    _l660Err:=.F.
	  	Return aCols[nLine,GdFIELDPOS("BTN_TABVLD",AHEADER)]
  	Else
  	    Return aCols[nLine,GdFIELDPOS("BTN_TABVLD",AHEADER)] >=  dDataBase  .or. Empty(aCols[nLine,GdFIELDPOS("BTN_TABVLD",AHEADER)])
  	Endif	
Endif

_l660Err:=.T.
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL660VLDAT  ³ Autor ³ Alexander			³ Data ³ 18.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a chave esta duplicada e se tem data com valor ³±±
±±³ 		 ³ Menor													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660VLDAT(aMat,cCamVld)
LOCAL nI    
LOCAL cCampos := ''                                         
LOCAL cCamAsc := ''
LOCAL cConAsc := ''
LOCAL lRet 	  := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta os campos para validação										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !Empty(aMat)
		For nI := 1 To Len(aMat)
		    cCampos += '"'+aMat[nI]+'",'
		    If cCamVld <> aMat[nI]
			   cCamAsc += 'x[PLRETPOS("'+aMat[nI]+'",aHeader,.T.)]+'
			   cConAsc += 'M->'+aMat[nI]+'+'
			EndIf    
		Next                            
		cCampos := Substring(cCampos,1,Len(cCampos)-1)
		cCamAsc := Substring(cCamAsc,1,Len(cCamAsc)-1)
		cConAsc := Substring(cConAsc,1,Len(cConAsc)-1)
    EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validação de chave duplicada										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    lRet := &('PLSVLDGD({'+cCampos+'})')               
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checa se e uma inclusao ou alteracao 								³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If lRet .And. !Empty( &('M->'+cCamVld) )                    
	   lRet := &('Ascan( aCols,{ |x| '+cCamAsc+'=='+cConAsc+' .And. x[PLRETPOS("'+cCamVld+'",aHeader,.T.)] > M->'+cCamVld+' .And. !Empty( x[PLRETPOS("'+cCamVld+'",aHeader,.T.)] ) } )') == 0
	   If !lRet 
		  MsgAlert(STR0137) //'Impossível incluir DATA menor que a existente!'
	   EndIf
    EndIf
    
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSCHKPF    ³ Autor ³ Alexander			³ Data ³ 20.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Checa no folder pai se o folder filho esta mostrando o	  ³±±
±±³ 		 ³ x3_relacao de um determinado campo nao visual 			  ³±±
±±³ 		 ³ (Gatinho) campo nao visual que tem o posicione			  ³±±
±±³ 		 ³ Obs:Apos carregar o primeiro registro no browse filho a    ³±±
±±³ 		 ³ tabela posiciona no ultimo registro fazendo com que as 	  ³±±
±±³ 		 ³ outras linhas do browse mostre o conteudo do ultimo        ³±±
±±³ 		 ³ registro. Obs2: Este problema nao acontece em todos os     ³±±
±±³			 | browse													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCHKPF( cCamVld1,aCamVld2 )
 	LOCAL cAlias1 := SubsTring(cCamVld1,1,3)+'->'
 	LOCAL cAlias2,nI
 	
 	For nI := 1 To Len(aCamVld2)
 		cAlias2	:= SubsTring(aCamVld2[nI],1,3)+'->'
		If &(cAlias1+'('+cCamVld1+')') <> &(cAlias2+'('+aCamVld2[nI]+')')
		   &(cAlias2+'( DbGoto(LastRec()+1) )')
		EndIf
	Next
	
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL660COSEQ  ³ Autor ³ Alexander			³ Data ³ 21.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche o campo XXX_SEQUEN conforme a linha do browse pai ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660COSEQ(oBrw)          
    LOCAL cRet := "001"     
    If Type(oBrw) == 'O'     
	   cRet := StrZero(&oBrw:oBrowse:nat,3) 
	EndIf    
Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL660VLDCF  ³ Autor ³ Alexander			³ Data ³ 21.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o codigo do cliente ou fornecedor nao foram 	  ³±±
±±³			 ³ preenchidos												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660VLDCF()
    LOCAL lRet := .T.
	If Empty(M->BHX_CODCLI) .And. Empty(M->BHX_CODFOR)
       Help(" ",1,"OBRIGAT")
       lRet := .F.
	EndIf
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PL660MTBLO  ³ Autor ³ Alexander			³ Data ³ 21.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro para tipo de bloqueio								  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660MTBLO()
Local lRet := .F.

If Empty(BQC->BQC_TIPBLO) .Or. BQC->BQC_TIPBLO == '1' .and. BQU->BQU_PERBLO == "1" 
	lRet := BQU->BQU_TIPBLO == '0'
Elseif BQU->BQU_PERBLO == "1"  
	lRet := BQU->BQU_TIPBLO == '1'
EndIf

   
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PlsVldVer() ³ Autor ³ Alexander			³ Data ³ 27.07.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida a versao do produto							   	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
 ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldVer()
LOCAL lRet := .F.

If PlsVldGd({"BT6_CODPRO","BT6_VERSAO"}) 
	If ExistCpo( "BI3",BG9->BG9_CODINT+M->BT6_CODPRO+M->BT6_VERSAO )
		If Empty( Posicione("BIL",1,xFilial("BIL")+BG9->BG9_CODINT+M->BT6_CODPRO+M->BT6_VERSAO,"BIL_DATFIN") )
			BI3->( dbSetorder(01) )
			If BI3->( dbSeek(xFilial("BI3")+BG9->BG9_CODINT+M->BT6_CODPRO+M->BT6_VERSAO) ) .and. BI3->BI3_STATUS <> '2' .and. !BI3->BI3_SITANS $ "2,3"
				lRet := .T.
			Else
				If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
					Help("",1,"PLSSITANS")
				Else
					Help("",1,"PLSA260002")
				Endif
			Endif
		Else     
			If BI3->( dbSeek(xFilial("BI3")+BG9->BG9_CODINT+M->BT6_CODPRO+M->BT6_VERSAO) ) .and. BI3->BI3_STATUS == '2' 
				If BI3->(FieldPos("BI3_SITANS")) > 0 .And. BI3->BI3_SITANS $ "2,3"
					Help("",1,"PLSSITANS")
				Else
					Help("",1,"PLSA260002")
				Endif
			Else
				Help("",1,"PLS26003")	
			Endif		
		Endif
	Endif
Endif           

If ExistBlock("PLS660NP")
   lRet := ExecBlock("PLS660NP",.F.,.F.,{lRet,M->BT6_CODPRO,M->BT6_VERSAO})
Endif   
	
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PL660Err   ³ Autor ³Geraldo Felix Junior ³ Data ³ 22/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento de Erro para formas de cobranca				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PL660Err()								 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Formas de cobrancas										  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL660ERR(e)
If e:gencode > 0  
	If _l660Err	
		msgStop(STR0138+chr(10)+chr(13)+; //"O cadastro de forma de cobranca esta inconsistente."
				STR0139+chr(10)+chr(13)+; //"As informacoes digitadas a partir deste ponto nao serao salvas no cadastro de formas de cobranca."
				STR0140+chr(10)+chr(13)+; //"Favor entrar em contato com suporte tecnico."
				STR0141+e:Description) //"Definicao da inconsistencia: "
		_l660Err := .F.
	Endif
EndIf


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL660HTFRAºAutor  ³Geraldo Felix Jr.   º Data ³  21/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apresenta historico do reajuste da franquia em diversos    º±±
±±º          ³niveis de acordo com o ALIAS informado como parametro...    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660HTFRA(cOrigem,cAlias,cChavSeek,cCodPla,cVersao)
LOCAL aCab 	:= {}
LOCAL aDad 	:= {}  
LOCAL aTrb	:= {}
LOCAL aArea	:= GetArea()
LOCAL oDlg
LOCAL oBrwHis

DEFAULT cVersao := ''

// Seleciona area
dbSelectArea("B0B")
                 
// Indexa area
If cOrigem == '1' 			// Subcontrato...
	cChavB0B := "B0B_FILIAL+B0B_ALIAS+B0B_CODINT+B0B_CODEMP+B0B_NUMCON+B0B_VERCON+B0B_SUBCON+B0B_VERSUB+B0B_CODPRO+B0B_VERPRO"
	dbSetorder(02)

	Store Header "B0B" TO aCab For !(SX3->X3_CAMPO $ 'B0B_MATRIC, B0B_TIPEG')
Elseif cOrigem == '2'		// Produto...
	cChavB0B := "B0B_FILIAL+B0B_ALIAS+B0B_CODINT+B0B_CODPRO+B0B_VERPRO"
	dbSetorder(03)
	
	Store Header "B0B" TO aCab For !(SX3->X3_CAMPO $ 'B0B_CODEMP,B0B_NUMCON,B0B_VERCON,B0B_SUBCON,B0B_VERSUB,B0B_INDREA,B0B_MATRIC,B0B_TIPREG')
	
Elseif cOrigem == '3'		// Familia...
	cChavB0B := "B0B_FILIAL+B0B_ALIAS+B0B_CODINT+B0B_CODEMP+B0B_MATRIC+B0B_CODPRO+B0B_VERPRO"
	dbSetorder(04)
	
	Store Header "B0B" TO aCab For !(SX3->X3_CAMPO $ 'B0B_CODEMP,B0B_NUMCON,B0B_VERCON,B0B_SUBCON,B0B_VERSUB,B0B_TIPREG')

Elseif cOrigem == '4'		// Usuario...
	cChavB0B := "B0B_FILIAL+B0B_ALIAS+B0B_CODINT+B0B_CODEMP+B0B_MATRIC+B0B_TIPREG+B0B_CODPRO+B0B_VERPRO"
	dbSetorder(05)
	
	Store Header "B0B" TO aCab For !(SX3->X3_CAMPO $ 'B0B_CODEMP,B0B_NUMCON,B0B_VERCON,B0B_SUBCON,B0B_VERSUB')
		
Endif
                 
// Busca informacao
If dbSeek(xFilial("B0B")+cAlias+cChavSeek+cCodPla+cVersao)
	// Se encontrar, carrega matriz com historico...
	Store COLS "B0B" TO aDad FROM aCab VETTRAB aTrb While xFilial("B0B")+cAlias+cChavSeek+cCodPla+cVersao == &(cChavB0B)
	
Else
	// Se nao encontrar, carrega matriz em branco...
	Store COLS BLANK "B0B" TO aDad FROM aCab

Endif
       
// Garante integridade da matriz de dados...
If Len(aDad) == 0
	Store COLS BLANK "B0B" TO aDad FROM aCab
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0142 FROM 009,000 TO 029,060 OF GetWndDefault()  //"Historico do reajuste da franquia"
oDlg:lEscClose := .F.

// Monta browse para visualizacao do conteudo do historico...
oBrwHis := 	TPLSBrw():New(013,001,237,145,nil,oDlg,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCab,aDad,.F.,"B0B",K_Visualizar,"Historico",nil,nil,nil,aTrb)
			
// Ativa o dialogo 
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()})
        
// Retorna
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL660DEL  ºAutor  ³Luciano Aparecido   º Data ³  06/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Trata Deleção do Produto no Sub-Contrato				      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Plano de Saúde                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660DEL(cChave)
Local lOk      := .T.
Local cSql     := ""
Local cCodPro  := ""
Local cCodVer  := "" 
Local cCodInt  := "" 
Local cCodEmp  := "" 
Local cNumCon  := "" 
Local cVerCon  := "" 
Local cSubCon  := "" 
Local cVerSub  := "" 
Local aArea    := GetArea()
DEFAULT cChave := Space(36)

cCodPro  := oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PLRETPOS("BT6_CODPRO")]  
cCodVer  := oBrwPro:aCols[oBrwPro:Linha(),oBrwPro:PLRETPOS("BT6_VERSAO")]  
cCodInt  := Substr(cChave,1,4)
cCodEmp  := Substr(cChave,5,4)
cNumCon  := Substr(cChave,9,12) 
cVerCon  := Substr(cChave,21,3) 
cSubCon  := Substr(cChave,24,9) 
cVerSub  := Substr(cChave,33,3) 


cSql :=	"SELECT COUNT(*)QTDREG "
cSql += "FROM "+RetSqlName("BA1")+" BA1, "+RetSqlName("BA3")+" BA3 "
cSql += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "  
cSql += "AND BA3_FILIAL = '" + xFilial("BA3") + "' "
cSql += "AND BA1_CODINT = '" +cCodInt+"' "
cSql += "AND BA1_CODEMP = '" +cCodEmp+"' "
cSQL +=	"AND BA1_CONEMP = '" + cNumCon + "' "
cSql += "AND BA1_VERCON = '" + cVerCon + "' "
cSQL += "AND BA1_SUBCON = '" + cSubCon + "' " 
cSql += "AND BA1_VERSUB = '" + cVerSub + "' "
cSql += "AND ((BA1_CODPLA = '" + cCodPro + "' "
cSql += "AND BA1_VERSAO = '" + cCodVer + "' )"
cSql += "OR (BA3_CODPLA = '" + cCodPro + "' "
cSql += "AND BA3_VERSAO = '" + cCodVer + "' ))"
cSQL +=	"AND BA1.D_E_L_E_T_ = ' ' "
cSQL += "AND BA3.D_E_L_E_T_ = ' ' " 
cSQL += "AND BA3.BA3_FILIAL = BA1.BA1_FILIAL " 
cSQL +=	"AND BA3.BA3_CODINT = BA1.BA1_CODINT " 
cSQL += "AND BA3.BA3_CODEMP = BA1.BA1_CODEMP " 
cSQL += "AND BA3.BA3_CONEMP = BA1.BA1_CONEMP " 
cSQL += "AND BA3.BA3_VERCON = BA1.BA1_VERCON " 
cSQL += "AND BA3.BA3_SUBCON = BA1.BA1_SUBCON " 
cSQL += "AND BA3.BA3_VERSUB = BA1.BA1_VERSUB "

PLSQuery(cSQL,"TrbPro")

If TrbPro->(QTDREG) > 0
	MsgStop(STR0129,STR0130) //"O Produto não pode ser Excluído, devido a ter Família / Usuário vinculados !"##"Exclusão Negada "
	lOK:= .F.	
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validação do produto no momento da deleçãos da linha³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lOK
	If ExistBlock("PL660EXBT6")
		lOK:=ExecBlock("PL660EXBT6",.F.,.F.,{cCodPro,cCodVer})
	Endif
Endif

TrbPro->(DbCloseArea())

RestArea(aArea)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA660B  ºAutor  ³Microsiga           º Data ³  06/27/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao de Procedimentos x coberturas x Produto no Subconº±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldBT8660b(cCodPad,cCodPsa,cCodpro,cVerpro)
Local bRet     := .F.
Local cChvBT8 := xFilial("BT8")+BQC->BQC_CODINT+BQC->BQC_CODEMP+BQC->BQC_NUMCON+BQC->BQC_VERCON+BQC->BQC_SUBCON+BQC->BQC_VERSUB+cCodpro+cVerpro+cCodPad+cCodPsa
Local nPosPsa  := aScan(oBrwCob:aHeader,{|x| AllTrim(x[2])=="BT8_CODPSA"})
Local nPosPad  := aScan(oBrwCob:aHeader,{|x| AllTrim(x[2])=="BT8_CODPAD"})
Local nX       := 0

//Verifica se o Procedimento existe Gravado na base ?
If Empty(cCodPad) .Or. Empty(cCodPsa)
	bRet := .T.
Else
	DbSelectArea("BT8")
	BT8->(DbSetOrder(1))
	If BT8->(MsSeek(cChvBT8,.T.)) .AND. Altera
		Help(" ",1,"JAGRAVADO")
		bRet := .F.
	Else    	
		bRet := .T.
	EndIf
EndIf    

//Verifica se o Procedimento existe no aCols ?
If nPosPsa>0 .And. nPosPad>0
	For nX:=1 to Len(oBrwCob:aCols)
		If oBrwCob:aCols[nX,nPosPsa] == cCodPsa .And. oBrwCob:aCols[nX,nPosPad]==cCodPad
			Help(" ",1,"JAGRAVADO")
			bRet := .F.
			Exit
		EndIf
	Next nX
EndIf

Return bRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL660WENR ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utilizada no when dos campos de regra de reajuste.          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660WENR(nTipo)

Local lRet	   	:= .F.
Local nCount	:= 0
Local nI		:= 0 
Local nUltDia	:= 0

Default nTipo := 0

For nI := 1 To Len(oBrwB77:aCols)		
	If !oBrwB77:IsDeleted(nI) .And. nI != n 
		If  oBrwB77:FieldGet("B77_MESBAS", nI) 	== M->B77_MESBAS .And.;
			oBrwB77:FieldGet("B77_ANOBAS", nI) 	== M->B77_ANOBAS .And.;
			oBrwB77:FieldGet("B77_PARDE",  nI) 	<= M->B77_PARATE .And.;
			( 	oBrwB77:FieldGet("B77_PARATE", nI) >= M->B77_PARDE .Or.;
			 	(	Empty(oBrwB77:FieldGet("B77_PARATE", nI)) .And.; 
			 		Empty (M->B77_PARDE);
			 	);
			 ) 		
	   	
	   		nCount ++
	   	
	   	EndIf
	EndIf
Next nI

Do case
    // Valida o mes
	case nTipo == 1
		lRet := M->B77_MESBAS $ '01,02,03,04,05,06,07,08,09,10,11,12' .And. nCount < 1
	// Valida o ano
	case nTipo == 2
	 	lRet := Len(AllTrim(M->B77_ANOBAS)) == 4 .And. nCount < 1
	// Atualizo o percentaul do dia
	case nTipo == 3 
		If M->B77_VLRREA > 0
			nUltDia	:= Last_Day(CtoD("01"+"/"+M->B77_MESBAS+"/"+M->B77_ANOBAS))
			M->B77_PERDIA := M->B77_VLRREA / nUltDia
		EndIf
		lRet := .T. 
EndCase



Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA660B  ºAutor  ³Microsiga           º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldBLW() // tratado
Local lRet     := .T.
Local cDatDe   := "BLW_VIGINI"
Local cDatAte  := "BLW_VIGFIN"
Local cTipo	   := "BLW_TIPO"
Local aChave   := {}
Local aArea	   := GetArea()                                          
        
If BLW->( FieldPos("BLW_VIGINI") ) > 0 .and. BLW->( FieldPos("BLW_VIGFIN") ) > 0
	If BLW->( FieldPos("BLW_FINATE") ) > 0 
		aChave := {'01',M->BLW_CODTAB+M->BLW_TIPUSR+M->BLW_GRAUPA+M->BLW_FINATE,;
						'BLW_CODTAB+BLW_TIPUSR+BLW_GRAUPA+BLW_FINATE'}
	Else
		aChave := {'01',M->BLW_CODTAB+M->BLW_TIPUSR+M->BLW_GRAUPA,;
						'BLW_CODTAB+BLW_TIPUSR+BLW_GRAUPA'}
	Endif

	lRet := PLSVLDVIG("BLW",0,oBrwBLW,cDatDe,cDatAte,aChave,,,,,,,cTipo)
	  
Endif

RestArea(aArea)

Return(lRet)     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL660WENT ºAutor  ³Diogo Ximenes       º Data ³  01/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utilizada no when dos campos de regra de parcelamento.      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL660WENT()
LOCAL lRet 	:= .T.
LOCAL nI	:= 0  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Data inicial maior que a final 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If  !Empty(M->B81_VIGPA) .And. !Empty(M->B81_VIGFIM) .And. M->B81_VIGPA >= M->B81_VIGFIM
	lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Data valida
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Data com todo o conteudo do browse
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	For nI := 1 To Len(oBrwB81:aCols)		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³Se nao esta deletado e esta em uma linha diferente
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If !oBrwB81:IsDeleted(nI) .And. nI != n      
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Data final menor que a inicial 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			If 	!Empty(M->B81_VIGFIM) .And. M->B81_VIGPA >= M->B81_VIGFIM
				lRet := .F.    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Data inicial esta no meio de uma data
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			ElseIf	M->B81_VIGPA >= oBrwB81:FieldGet("B81_VIGPA", nI) .And. ( M->B81_VIGPA <= oBrwB81:FieldGet("B81_VIGFIM", nI) .Or. Empty(oBrwB81:FieldGet("B81_VIGFIM", nI))	)
				lRet := .F.	 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Data final esta no meio de uma data
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			ElseIf M->B81_VIGFIM >= oBrwB81:FieldGet("B81_VIGPA", nI) .And. ( M->B81_VIGFIM <= oBrwB81:FieldGet("B81_VIGFIM", nI) .Or. Empty(oBrwB81:FieldGet("B81_VIGFIM", nI)) )
				lRet := .F.	 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			//³Comporta intervalo de datas
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
			ElseIf M->B81_VIGPA <= oBrwB81:FieldGet("B81_VIGPA", nI) .And. ( M->B81_VIGFIM >= oBrwB81:FieldGet("B81_VIGFIM", nI) )
				lRet := .F.	
			EndIf
		EndIf
	Next nI
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Fim da Rotina
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA660B  ºAutor  ³Microsiga           º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PlsVldBLX() 
Local lRet     := .T.
Local aChave   := {}
Local aArea	   := GetArea()                                          

aChave := {'01',M->BLX_CODTAB+M->BLX_TIPUSR+M->BLX_GRAUPA+M->BLX_FINATE,'BLX_CODTAB+BLX_TIPUSR+BLX_GRAUPA+BLX_FINATE'}

MsAguarde({||lRet := PLSVLDVIG("BLX",0,oBrwBLX,"BLX_VIGINI","BLX_VIGFIN",aChave,,,,,,,"BLX_TIPO","BLX_QTD") }, "Validação", "Aguarde...", .F.) 

RestArea(aArea)

Return(lRet)     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBHE ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Coberturas / Co-Participacao.        º±±
±±º          ³ Tabela - BHE - Grupo Empresas Co-Participacao.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBHE()  // Tratado
Local lRet     := .T.
Local cDatDe   := "BHE_VIGINI"
Local cDatAte  := "BHE_VIGFIN"
Local cTipo	   := "BHE_TIPO"
Local aChave   := {}
Local aArea	   := GetArea()                                          

If BHE->( FieldPos("BHE_VIGINI") ) > 0 .And. BHE->( FieldPos("BHE_VIGFIN") ) > 0
	If BHE->( FieldPos("BHE_FINATE") ) > 0 
		aChave := {'01',M->BHE_CODPAD+cValToChar(M->BHE_QTD)+M->BHE_CODPSA+M->BHE_SEQUEN+M->BHE_CODTAB+M->BHE_GRPINT+M->BHE_TIPUSR+M->BHE_GRAUPA+M->BHE_FINATE,;
		'BHE_CODPAD+BHE_CODPSA+BHE_SEQUEN+BHE_CODTAB+BHE_GRPINT+BHE_TIPUSR+BHE_GRAUPA+BHE_FINATE'}
	Else
		aChave := {'01',M->BHE_CODPAD+cValToChar(M->BHE_QTD)+M->BHE_CODPSA+M->BHE_SEQUEN+M->BHE_CODTAB+M->BHE_GRPINT+M->BHE_TIPUSR+M->BHE_GRAUPA,;
		'BHE_CODPAD+BHE_CODPSA+BHE_SEQUEN+BHE_CODTAB+BHE_GRPINT+BHE_TIPUSR+BHE_GRAUPA'}
	Endif
	
	cDatDe   := "BHE_VIGINI"
	cDatAte  := "BHE_VIGFIN" 
	cTipo	 := "BHE_TIPO"

	lRet := PLSVLDVIG("BHE",0,oBrwCCo,cDatDe,cDatAte,aChave,,,,,,,cTipo)

EndIf

RestArea(aArea)

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBGL ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Produtos / Municipio Atendimento.    º±±
±±º          ³ Tabela - BGL - GrEmpr x TpPres x Co-Part.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBGL() // Tratado
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := ""
Local cTipo	   := ""
Local aChave   := {}
Local aArea	   := GetArea() 

If BGL->( FieldPos("BGL_VIGINI") ) > 0 .And. BGL->( FieldPos("BGL_VIGFIN") ) > 0

	If BGL->( FieldPos("BGL_FINATE") ) > 0 
		aChave := {'01',M->BGL_CODMUN+M->BGL_CODTAB+M->BGL_CODPAD+M->BGL_CDPROC+M->BGL_TIPUSR+M->BGL_GRAUPA+M->BGL_FINATE,'BGL_CODMUN+BGL_CODTAB+BGL_CODPAD+BGL_CDPROC+BGL_TIPUSR+BGL_GRAUPA+BGL_FINATE'}   
	Else
		aChave := {'01',M->BGL_CODMUN+M->BGL_CODTAB+M->BGL_CODPAD+M->BGL_CDPROC+M->BGL_TIPUSR+M->BGL_GRAUPA,'BGL_CODMUN+BGL_CODTAB+BGL_CODPAD+BGL_CDPROC+BGL_TIPUSR+BGL_GRAUPA'}   
	Endif
	
	cDatDe   := "BGL_VIGINI"
	cDatAte  := "BGL_VIGFIN"
	cTipo	 := "BGL_TIPO"
    
	lRet := PLSVLDVIG("BGL",0,oBrwBGL,cDatDe,cDatAte,aChave,,,,,,,cTipo)   

EndIf	

RestArea(aArea)

Return(lRet)  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBHF ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Coberturas / Co-Participacao.        º±±
±±º          ³ Tabela - BHF - Grp/Emp x Grp Cob x Co-Part. 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBHF()  // tratado
Local lRet     := .f.

If BHF->( FieldPos("BHF_VIGINI") ) > 0 .And. BHF->( FieldPos("BHF_VIGFIN") ) > 0
	if ! Empty(M->BHF_VIGFIN) .And. M->BHF_VIGINI > M->BHF_VIGFIN
	MsgAlert("Vigência final menor que a inicial!")
   else
	lRet := .t.
   endif
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBHF ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Coberturas / Co-Participacao.        º±±
±±º          ³ Tabela - BHF - Grp/Emp x Grp Cob x Co-Part. 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBOR()  // tratado
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := "" 
Local aChave   := {}
Local aArea	   := GetArea()                                          

If BOR->( FieldPos("BOR_VIGDE") ) > 0 .And. BOR->( FieldPos("BOR_VIGATE") ) > 0

	If BOR->( FieldPos("BOR_FINATE") ) > 0 
		aChave := {'01',M->BOR_CODPRO+M->BOR_CODTAB+M->BOR_FINATE,'BOR_CODPRO+BOR_CODTAB+BOR_FINATE'}   
	Else
		aChave := {'01',M->BOR_CODTAB,'BOR_CODTAB'}   
	Endif
	
	cDatDe   := "BOR_VIGDE"
	cDatAte  := "BOR_VIGATE"   
	
	If !Empty(M->BOR_VIGDE)
		lRet := PLSVLDVIG("BOR",0,oBrwRDF,cDatDe,cDatAte,aChave)
	EndIf	
EndIf
             
RestArea(aArea)

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBHG ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Produtos / Co-Participacao.          º±±
±±º          ³ Tabela - BHG - Grp/Emp x Contrato x Co-Part.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBHG() // Tratado
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := "" 
Local cTipo	   := ""
Local aChave   := {}
Local aArea	   := GetArea()  
                                        
If  BHG->( FieldPos("BHG_VIGINI") ) > 0 .And. BHG->( FieldPos("BHG_VIGFIN") ) > 0

	If BHG->( FieldPos("BHG_FINATE") ) > 0 
		aChave := {'01',M->BHG_CODPRO+M->BHG_VERPRO+M->BHG_CODTAB+M->BHG_TIPUSR+M->BHG_GRAUPA+M->BHG_FINATE,'BHG_CODPRO+BHG_VERPRO+BHG_CODTAB+BHG_TIPUSR+BHG_GRAUPA+BHG_FINATE'}   
	Else
		aChave := {'01',M->BHG_CODPRO+M->BHG_VERPRO+M->BHG_CODTAB+M->BHG_TIPUSR+M->BHG_GRAUPA,'BHG_CODPRO+BHG_VERPRO+BHG_CODTAB+BHG_TIPUSR+BHG_GRAUPA'}   
	Endif
	
	lRet := PLSVLDVIG("BHG",0,oBrwCPro,"BHG_VIGINI","BHG_VIGFIN",aChave,,,,,,,"BHG_TIPO","BHG_QTD") 
EndIf

RestArea(aArea)

Return(lRet)   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PlsVldBGS ºAutor  ³Microsiga           º Data ³  17/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funca de validacao das datas de vigencia, chamada no       º±±
±±º          ³ botao de OK da Rotina Produtos / Tipo Prestador.           º±±
±±º          ³ Tabela - BGS - GrEmpr x TpPres x Co-Part.				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PlsVldBGS()
Local lRet     := .T.
Local cDatDe   := ""
Local cDatAte  := "" 
Local cTipo	   := ""
Local aChave   := {}
Local aArea	   := GetArea() 

If BGS->( FieldPos("BGS_VIGINI") ) > 0 .And. BGS->( FieldPos("BGS_VIGFIN") ) > 0

	If BGS->( FieldPos("BGS_FINATE") ) > 0 
		aChave := {'01',M->BGS_TIPPRE+M->BGS_CODTAB+M->BGS_TIPUSR+M->BGS_GRAUPA+M->BGS_FINATE,'BGS_TIPPRE+BGS_CODTAB+BGS_TIPUSR+BGS_GRAUPA+BGS_FINATE'}   
	Else
		aChave := {'01',M->BGS_TIPPRE+M->BGS_CODTAB+M->BGS_TIPUSR+M->BGS_GRAUPA,'BGS_TIPPRE+BGS_CODTAB+BGS_TIPUSR+BGS_GRAUPA'}
	Endif
	
	cDatDe   := "BGS_VIGINI"
	cDatAte  := "BGS_VIGFIN" 
	cTipo	 := "BGS_TIPO"

	lRet := PLSVLDVIG("BGS",0,oBrwBGS,cDatDe,cDatAte,aChave,,,,,,,cTipo)
			
EndIf

RestArea(aArea)

Return(lRet)   
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBHE ºAutor  ³Microsiga           º Data ³  05/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBHE()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwCCo:aHeader)

nQTD := Ascan(oBrwCCo:aHeader,{|x| Alltrim(x[2])=="BHE_QTD"})  

If BHE->( FieldPos("BHE_VIGINI") ) > 0 .And. BHE->( FieldPos("BHE_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwCCo:aHeader,{|x| Alltrim(x[2])=="BHE_VIGINI"})
	nPosFin := Ascan(oBrwCCo:aHeader,{|x| Alltrim(x[2])=="BHE_VIGFIN"})
	
	For nX := 1 To Len(oBrwCCo:aCols)
		If !oBrwCCo:aCols[nX][nUsado+1]
			If nX < n
				If M->BHE_VIGINI == CTOD(" / / ") .And. M->BHE_VIGFIN == CTOD(" / / ")
					If M->BHE_QTD == oBrwCCo:aCols[nX][nQTD] .And. Empty(oBrwCCo:aCols[nX][nPosIni]) .And. Empty(oBrwCCo:aCols[nX][nPosFin])
						If BHE->( FieldPos("BHE_VERPRO") ) > 0 .And. BT8->( FieldPos("BT8_VERPRO") ) > 0
							oBrwCCo:cVldLine := 'PLSVLDGD( {"BHE_SEQUEN","BHE_TIPO","BHE_QTD","BHE_CODPRO","BHE_VERPRO","BHE_CODPAD","BHE_CODPSA","BHE_GRPINT","BHE_VIGINI","BHE_VIGFIN"} )'
							Return lRet := .T.
						Else
							oBrwCCo:cVldLine := 'PLSVLDGD( {"BHE_SEQUEN","BHE_TIPO","BHE_QTD","BHE_CODPRO","BHE_CODPAD","BHE_CODPSA","BHE_GRPINT","BHE_VIGINI","BHE_VIGFIN"} )'
							Return lRet := .T.
						EndIf	
					Endif
				Endif
			Endif
		Endif
	Next nX 
Else
	If BHE->( FieldPos("BHE_VERPRO") ) > 0 .And. BT8->( FieldPos("BT8_VERPRO") ) > 0
		oBrwCCo:cVldLine   := 'PLSVLDGD( {"BHE_SEQUEN","BHE_TIPO","BHE_QTD","BHE_CODPRO","BHE_VERPRO","BHE_CODPAD","BHE_CODPSA","BHE_GRPINT"} )' 
		Return lRet := .T.
	Else	
		oBrwCCo:cVldLine   := 'PLSVLDGD( {"BHE_SEQUEN","BHE_TIPO","BHE_QTD","BHE_CODPRO","BHE_CODPAD","BHE_CODPSA","BHE_GRPINT"} )'     
		Return lRet := .T.
	EndIf		
EndIf

RestArea(aArea)

Return lRet               

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBHF ºAutor  ³Microsiga           º Data ³  05/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBHF()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwCGru:aHeader)

nQTD    := Ascan(oBrwCGru:aHeader,{|x| Alltrim(x[2])=="BHF_QTD"})

If BHF->( FieldPos("BHF_VIGINI") ) > 0 .And. BHF->( FieldPos("BHF_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwCGru:aHeader,{|x| Alltrim(x[2])=="BHF_VIGINI"})
	nPosFin := Ascan(oBrwCGru:aHeader,{|x| Alltrim(x[2])=="BHF_VIGFIN"})

	For nX := 1 To Len(oBrwCGru:aCols)
		If !oBrwCGru:aCols[nX][nUsado+1]
			If nX < n
				If M->BHF_VIGINI == CTOD(" / / ") .And. M->BHF_VIGFIN == CTOD(" / / ")
					If M->BHF_QTD == oBrwCGru:aCols[nX][nQTD] .And. Empty(oBrwCGru:aCols[nX][nPosIni]) .And. Empty(oBrwCGru:aCols[nX][nPosFin])
						oBrwCGru:cVldLine := 'PLSVLDCOL({"BHF_TIPO","BHF_QTD","BHF_CODPRO","BHF_CODGRU","BHF_TIPUSR","BHF_VIGINI","BHF_VIGFIN"}) .And. PLSXANAFAI( {"BHF_TIPO","BHF_QTD","BHF_TIPUSR","BHF_VIGINI","BHF_VIGFIN"},"BHF_IDAINI","BHF_IDAFIN",n)'
						Return lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Next nX
Else
	oBrwCGru:cVldLine   := 'PLSXANAFAI( {"BHF_TIPO","BHF_QTD","BHF_TIPUSR"},"BHF_IDAINI","BHF_IDAFIN",n)'
	Return lRet := .T.
EndIf

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBHG ºAutor  ³Microsiga           º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBHG()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwCPro:aHeader)

nQTD    := Ascan(oBrwCPro:aHeader,{|x| Alltrim(x[2])=="BHG_QTD"})  

If BHG->( FieldPos("BHG_VIGINI") ) > 0 .And. BHG->( FieldPos("BHG_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwCPro:aHeader,{|x| Alltrim(x[2])=="BHG_VIGINI"})
	nPosFin := Ascan(oBrwCPro:aHeader,{|x| Alltrim(x[2])=="BHG_VIGFIN"})
	
	For nX := 1 To Len(oBrwCPro:aCols)
		If !oBrwCPro:aCols[nX][nUsado+1]
			If nX < n
				If M->BHG_VIGINI == CTOD(" / / ") .And. M->BHG_VIGFIN == CTOD(" / / ")
					If M->BHG_QTD == oBrwCPro:aCols[nX][nQTD] .And. Empty(oBrwCPro:aCols[nX][nPosIni]) .And. Empty(oBrwCPro:aCols[nX][nPosFin])
						If BHG->( FieldPos("BHG_VERPRO") ) > 0
							oBrwCPro:cVldLine := 'PLSVLDGD( {"BHG_TIPO","BHG_QTD","BHG_CODPRO","BHG_VERPRO","BHG_VIGINI","BHG_VIGFIN"} ) .AND. PLSXANAFAI( {"BHG_TIPO","BHG_QTD","BHG_TIPUSR","BHG_VIGINI","BHG_VIGFIN"},"BHG_IDAINI","BHG_IDAFIN",n)'
							Return lRet := .T.
						Else
							oBrwCPro:cVldLine := 'PLSVLDGD( {"BHG_TIPO","BHG_QTD","BHG_CODPRO","BHG_VIGINI","BHG_VIGFIN"} )'
							Return lRet := .T.
						EndIf
					Endif
				Endif
			Endif
		Endif
	Next nX 
Else
	If BHG->( FieldPos("BHG_VERPRO") ) > 0
		oBrwCPro:cVldLine := 'PLSVLDGD( {"BHG_TIPO","BHG_QTD","BHG_CODPRO","BHG_VERPRO"} ) .AND. PLSXANAFAI( {"BHG_TIPO","BHG_QTD","BHG_TIPUSR"},"BHG_IDAINI","BHG_IDAFIN",n)'
		Return lRet := .T.		
	Else
		oBrwCPro:cVldLine := 'PLSVLDGD( {"BHG_TIPO","BHG_QTD","BHG_CODPRO"} )'
		Return lRet := .T.
	EndIf	               
EndIf

RestArea(aArea)

Return lRet    

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBGS ºAutor  ³Microsiga           º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBGS()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwBGS:aHeader)

nQTD    := Ascan(oBrwBGS:aHeader,{|x| Alltrim(x[2])=="BGS_QTD"})  

If BGS->( FieldPos("BGS_VIGINI") ) > 0 .And. BGS->( FieldPos("BGS_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwBGS:aHeader,{|x| Alltrim(x[2])=="BGS_VIGINI"})
	nPosFin := Ascan(oBrwBGS:aHeader,{|x| Alltrim(x[2])=="BGS_VIGFIN"})
	
	For nX := 1 To Len(oBrwBGS:aCols)
		If !oBrwBGS:aCols[nX][nUsado+1]
			If nX < n
				If M->BGS_VIGINI == CTOD(" / / ") .And. M->BGS_VIGFIN == CTOD(" / / ")
					If M->BGS_QTD == oBrwBGS:aCols[nX][nQTD] .And. Empty(oBrwBGS:aCols[nX][nPosIni]) .And. Empty(oBrwBGS:aCols[nX][nPosFin])
						oBrwBGS:cVldLine := 'PLSVLDGD( {"BGS_CODPRO","BGS_VERPRO","BGS_TIPPRE","BGS_TIPO","BGS_QTD","BGS_VIGINI","BGS_VIGFIN"} ) .AND. PLSXANAFAI( {"BGS_TIPO","BGS_QTD","BGS_TIPUSR","BGS_VIGINI","BGS_VIGFIN"},"BGS_IDAINI","BGS_IDAFIN",n)'
						Return lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Next nX 
Else
	oBrwBGS:cVldLine := 'PLSVLDGD( {"BGS_CODPRO","BGS_VERPRO","BGS_TIPPRE","BGS_TIPO","BGS_QTD"} ) .AND. PLSXANAFAI( {"BGS_TIPO","BGS_QTD","BGS_TIPUSR"},"BGS_IDAINI","BGS_IDAFIN",n)'
	Return lRet := .T.
EndIf

RestArea(aArea)

Return lRet     

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSQTDBGL ºAutor  ³Microsiga           º Data ³  08/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida a quantidade quando nao existe data de vigencia     º±±
±±º          ³ Informada e nao permite quantidade duplicada.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSQTDBGL()
Local lRet := .F. 
Local nX   := 0     
Local nPosIni := ""
Local nPosFin := ""
Local nQTD    := ""   
Local aArea	  := GetArea()  
Local nUsado  := Len(oBrwBGL:aHeader)

nQTD    := Ascan(oBrwBGL:aHeader,{|x| Alltrim(x[2])=="BGL_QTD"})  

If BGL->( FieldPos("BGL_VIGINI") ) > 0 .And. BGL->( FieldPos("BGL_VIGFIN") ) > 0
	nPosIni := Ascan(oBrwBGL:aHeader,{|x| Alltrim(x[2])=="BGL_VIGINI"})
	nPosFin := Ascan(oBrwBGL:aHeader,{|x| Alltrim(x[2])=="BGL_VIGFIN"})
	
	For nX := 1 To Len(oBrwBGL:aCols)
		If !oBrwBGL:aCols[nX][nUsado+1]
			If nX < n
				If M->BGL_VIGINI == CTOD(" / / ") .And. M->BGL_VIGFIN == CTOD(" / / ")
					If M->BGL_QTD == oBrwBGL:aCols[nX][nQTD] .And. Empty(oBrwBGL:aCols[nX][nPosIni]) .And. Empty(oBrwBGL:aCols[nX][nPosFin])
						oBrwBGL:cVldLine   := 'PLSVLDGD( {"BGL_CODPRO","BGL_VERPRO","BGL_CODMUN","BGL_TIPO","BGL_QTD","BGL_VIGINI","BGL_VIGFIN"} ) .AND. PLSXANAFAI( {"BGL_TIPO","BGL_QTD","BGL_TIPUSR","BGL_VIGINI","BGL_VIGFIN"},"BGL_IDAINI","BGL_IDAFIN",n)'
						Return lRet := .T.
					Endif
				Endif
			Endif
		Endif
	Next nX 
Else
	oBrwBGL:cVldLine   := 'PLSVLDGD( {"BGL_CODPRO","BGL_VERPRO","BGL_CODMUN","BGL_TIPO","BGL_QTD"} ) .AND. PLSXANAFAI( {"BGL_TIPO","BGL_QTD","BGL_TIPUSR"},"BGL_IDAINI","BGL_IDAFIN",n)'
	Return lRet := .T.
EndIf

RestArea(aArea)

Return lRet


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCHKBMG ºAutor  ³Robson Nayland      º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para checar os registros na tabela BMG               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSCHKBMG(oBrwPPP)
Local lret	:=.T.
Local nPosTip := PLRETPOS("BMG_TIPPRE",oBrwPPP:AHEADER)
Local I

IF nPosTip > 0 
	For i:=1 to Len(oBrwPPP:ACOLS)
	    IF Empty(oBrwPPP:ACOLS[i,nPosTip])
	       lret:=.F. 
	       MsgAlert(STR0145) //"Item não poderá ser gravado devido o parâmetro pagamento tipo prestador(BMF) não estar preenchido."
	       Exit
	    Endif
	Next i
Endif

Return lret


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCHKBMI ºAutor  ³Robson Nayland      º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para checar os registros na tabela BMG               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSCHKBMI(oBrwPPPPRE)
Local lret	:=.T.
Local nPosTip := PLRETPOS("BMI_CODRDA",oBrwPPPPRE:AHEADER)
Local I

IF nPosTip > 0 
	For i:=1 to Len(oBrwPPPPRE:ACOLS)
	    IF Empty(oBrwPPPPRE:ACOLS[i,nPosTip])
	       lret:=.F. 
	       MsgAlert(STR0146) //"Item não poderá ser gravado devido o parâmetro pagamento prestador(BMH) não estar preenchido."
	       Exit
	    Endif
	Next i
Endif

Return lret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCHKBMI ºAutor  ³Robson Nayland      º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para checar os registros na tabela BMG               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSCHKBMM(oBrwBMM)
Local lret 		:=.T.
Local nPosTip 	:= PLRETPOS("BMM_CODESP",oBrwBMM:AHEADER)
Local I

IF nPosTip > 0 
	For i:=1 to Len(oBrwBMM:ACOLS)
	    IF Empty(oBrwBMM:ACOLS[i,nPosTip])
	       lret:=.F. 
	       MsgAlert(STR0147) //"Item não poderá ser gravado devido o parâmetro pagamento especialidade (BML) não estar preenchido."
	       Exit
	    Endif
	Next i
Endif

Return lret


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCHKBMI ºAutor  ³Robson Nayland      º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para checar os registros na tabela BMG               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSCHKBKB(oBrwBKB)
Local lret 		:=.T.
Local nPosTip 	:= PLRETPOS("BKB_CODOPE",oBrwBKB:AHEADER)
Local I

IF nPosTip > 0 
	For i:=1 to Len(oBrwBKB:ACOLS)
	    IF Empty(oBrwBKB:ACOLS[i,nPosTip])
	       lret:=.F. 
	       MsgAlert(STR0148) //"Item não poderá ser gravado devido o parâmetro pagamento operadora (BKA) não estar preenchido."
	       Exit
	    Endif
	Next i
Endif

Return lret
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSCHKBT8 ºAutor  ³Robson Nayland      º Data ³  03/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para checar os registros na tabela BT8              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSCHKBT8(oBrwCob,cCodpsa)
Local lret 		:=.T.
Local nPosTip 	:= PLRETPOS("BT8_CODPSA",oBrwCob:AHEADER)
Local nPosPad 	:= PLRETPOS("BT8_CODPAD",oBrwCob:AHEADER)
Local I

IF nPosTip > 0 
	For i:=1 to Len(oBrwCob:ACOLS)
	    IF oBrwCob:ACOLS[i,nPosTip]==cCodpsa .And. oBrwCob:ACOLS[i,nPosPad] == cCodpad 
	       If ALTERA
	          lret:=.T.
	          Exit 	
	       EndIf   
	       lret:=.F. 
	       MsgAlert(STR0149) //"Código de procedimento duplicado"
	       Exit
	    Endif
	Next i
Endif

Return lret

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL660VldLnºAutor  ³Vinicius Ledesma    º Data ³  26/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para validar a faixa etaria da Forma de Pagamento no º±±
±±º          ³momento da inclusao da linha.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PL660VldLn(cAlias,cCodfor)

LOCAL lret :=.F.
LOCAL aArea
LOCAL cValidIni := ""
LOCAL cValidFin := ""
DEFAULT cCodFor := ""

If TYPE("M->"+cAlias+"_IDAINI") == "U" .Or. TYPE("M->"+cAlias+"_IDAFIN") == "U"
	Return(.T.)
EndIf

aArea := GetArea()

If cCodfor <> '106' 
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek( cAlias+"_IDAINI" )
		cValidIni := AllTrim(SX3->X3_VALID)
	EndIf
	If dbSeek( cAlias+"_IDAFIN" )
		cValidFin := AllTrim(SX3->X3_VALID)
	EndIf
Else
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek( cAlias+"_QTDMIN" )
		cValidIni := AllTrim(SX3->X3_VALID)
	EndIf
	If dbSeek( cAlias+"_QTDMAX" )
		cValidFin := AllTrim(SX3->X3_VALID)
	EndIf

Endif

If !Empty(cValidIni) .And. !Empty(cValidFin) .And. &cValidIni .And. &cValidFin

	lret := .T.

Else

	Alert(STR0152)

Endif

RestArea(aArea)

Return lret                                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PL660HSal  ³ Autor ³ Victor Ferreira    ³ Data ³ 28.11.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Apresenta a dialog com informacoes de historicos de       ³±±
±±³          ³ reajuste de cobranca de acordo com a forma selecionada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PL269HSal()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL660HSal()
LOCAL aArea			:= GetArea()
LOCAL cCodFor		:= oBrwFor:FieldGet("BT9_CODFOR")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste dados nescessarios...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If 	Empty(cCodFor)
	MsgAlert("Preencha os dados da Forma de Cobrança antes de continuar")
	Return
Endif

If cCodFor <> "108"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega por faixa etaria...                                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PLSHISFAI("BYC",BQC->( BQC_CODINT+BQC_CODEMP+BQC_NUMCON+;
					BQC_VERCON+BQC_SUBCON+BQC_VERSUB+;
					cCodProSel+cVersaoSel),;
					"BYC->( BYC_FILIAL+BYC_CODOPE+BYC_CODEMP+"+;
					"BYC_CONEMP+BYC_VERCON+BYC_SUBCON+"+;
					"BYC_VERSUB+BYC_CODPRO+BYC_VERPRO)",1)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega por faixa salarial...                                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea('SIX')
	SIX->(dbSetOrder(1))
	If !SIX->(dbSeek('BPR4'))
		MsgAlert("Antes de executar essa opção, é necessário executar o update de compatibilização dos dicionários de dados do chamado 'TIAMQP'")
		RestArea(aArea)
		Return
	Else
		RestArea(aArea)
		PLSHISFAI("BPR",BQC->( BQC_CODINT+BQC_CODEMP+BQC_NUMCON+;
						BQC_VERCON+BQC_SUBCON+BQC_VERSUB+;
						cCodProSel+cVersaoSel),;
						"BPR->( BPR_FILIAL+BPR_OPEREA+BPR_CODEMP+"+;
						"BPR_CONEMP+BPR_VERCON+BPR_SUBCON+"+;
						"BPR_VERSUB+BPR_CODPRO+BPR_VERSAO)",4)
	Endif
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA660PRDº Autor ³ Alexandre Villar   º Data ³ 23/10/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica alteracoes de Faixas Etarias e Descontos do Sub   º±±
±±º          ³ Contrato.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PLSA660PRD( cCodPagX , cCodProX , cVersaoX )

Local cChaveX		:= ""

Default cCodPagX	:= ""
Default cCodProX	:= ""
Default cVersaoX	:= ""

If Empty(cCodPagX) .Or. Empty(cCodProX) .Or. Empty(cVersaoX)
	Return()
EndIf

cChaveX := cCodPagX + cCodProX + cVersaoX

If Empty(aCodProA) .Or. AScan( aCodProA , cChaveX ) == 0
	aAdd( aCodProA , { cChaveX , cCodProX , cVersaoX , cCodPagX } )
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA660CHKº Autor ³ Alexandre Villar   º Data ³ 23/10/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica alteracoes de Faixas Etarias e Descontos do Sub   º±±
±±º          ³ Contrato.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaPLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLSA660CHK( cCodIntX  , cCodEmpX  , cNumConX , cVerConX , cSubConX  , cVerSubX )   

Local aChvBA1		:= {}
Local aDadFai		:= {}
Local aDadDes		:= {}
Local aChvBA3		:= {}
Local lNovo		:= .T.
Local lProc		:= .T.
Local nI			:= 0
Local nX			:= 0
Local nY			:= 0
Local nJ			:= 0
Local cFile		:= ""
Local cChvBA1		:= ""
Local cChvBA3		:= ""
//Local cChvBDK    	:= "" RETIRAR 17-06
Local cChvBDQ    	:= ""
Local cChvBBU    	:= ""
Local cChvBFY    	:= ""
Local cCodProX	:= ""
Local cVersaoX	:= ""
Local cCodPagX	:= ""
Local cMsgX		:= ""
Local cMask     	:= STR0189 + " (*.TXT) |*.txt|" //"Arquivos Texto"
Local oDlgChk
Local oDlgLog
Local oBotOk
Local oBotCan

//Private lCheck01	:= .T. RETIRAR 17-06
Private lCheck02	:= .T.
Private lCheck03	:= .T.
Private lCheck04	:= .T.
Private lAllChk 	:= .T.
//Private oCheck01 17-06
Private oCheck02
Private oCheck03
Private oCheck04
Private oChkAll 

Default cCodIntX	:= ""
Default cCodEmpX	:= ""
Default cNumConX	:= ""
Default cVerConX	:= ""
Default cSubConX	:= ""
Default cVerSubX	:= ""

cAlert := STR0186//"Foram identificadas alterações nas propriedades da forma de cobrança"
cAlert += STR0187//' dos produtos do contrato. Selecione os níveis específicos para'
cAlert += STR0188//' realizar a atualização ou clique em "Cancelar" para manter os dados atuais:'

DEFINE DIALOG oDlgChk TITLE STR0049 FROM 0,0 TO 220,410 PIXEL

@ 01,05 TO 35,205 PIXEL OF oDlgChk LABEL STR0185//"Réplica das propriedades de cobrança"

@ 08,07 SAY oSayCon PROMPT cAlert SIZE 200,35 OF oDlgFolder PIXEL

//@ 40,06 CHECKBOX oCheck01 VAR lCheck01 PROMPT STR0163 PIXEL SIZE 300, 09 OF oDlgChk //"BDK - Faixas Etárias do Usuário" RETIRAR 17-06
@ 50,06 CHECKBOX oCheck02 VAR lCheck02 PROMPT STR0170 PIXEL SIZE 300, 09 OF oDlgChk //"BBU - Faixas Etárias da familia"
@ 60,06 CHECKBOX oCheck03 VAR lCheck03 PROMPT STR0173 PIXEL SIZE 300, 09 OF oDlgChk //"BDQ - Descontos dos usuários"
@ 70,06 CHECKBOX oCheck04 VAR lCheck04 PROMPT STR0174 PIXEL SIZE 300, 09 OF oDlgChk //"BFY - Descontos por Familias"

@ 85,06 BUTTON oBotOk 	PROMPT "&Ok" 		ACTION	{|| lProc := .T. , oDlgChk:End()} SIZE 45, 11 OF oDlgChk PIXEL
@ 85,53 BUTTON oBotCan 	PROMPT STR0183	ACTION	{|| lProc := .F. , oDlgChk:End()} SIZE 45, 11 OF oDlgChk PIXEL //"&Cancelar"

@ 100,06 CHECKBOX oChkAll VAR lAllChk PROMPT STR0184 PIXEL SIZE 300, 09 OF oDlgChk //"Marcar/Desmarcar todos"
  oChkAll:bChange := {||CheckAll()}
	
ACTIVATE DIALOG oDlgChk CENTERED

If Len(aCodProA) > 0 .And. !Empty(aCodProA) .And. lProc

	cMsgX := STR0153 + CRLF //"Log de atualização das propriedades das formas de cobrança dos produtos:"
	cMsgX += Replicate("-",50) + CRLF

	cMsgX += STR0191 + CRLF //"Tabelas selecionados para atualização:"
	//cMsgX += Iif(lCheck01,STR0163 + CRLF,"") //"BDK - Faixas Etárias do Usuário" RETIRAR 17-06
	cMsgX += Iif(lCheck02,STR0170 + CRLF,"") //"BBU - Faixas Etárias da familia"
	cMsgX += Iif(lCheck03,STR0173 + CRLF,"") //"BDQ - Descontos dos usuários"
	cMsgX += Iif(lCheck04,STR0174 + CRLF,"") //"BFY - Descontos por Familias"
	
	cMsgX += Replicate("-",50) + CRLF	
	
	For nI := 1 To Len(aCodProA)

		cCodProX := aCodProA[nI][02]
		cVersaoX := aCodProA[nI][03]
		cCodPagX := aCodProA[nI][04]
			
		cMsgX	+= STR0154 + cCodIntX +"/"+ cCodEmpX + CRLF // " - Operadora/GrupoEmpresa: "
		cMsgX	+= STR0155 + cNumConX +"/"+ cVerConX + CRLF // " - Contrato/Versão: "
		cMsgX	+= STR0156 + cSubConX +"/"+ cVerSubX + CRLF //" - SubContrato/Versão: "
		cMsgX	+= STR0157 + AllTrim( Posicione("BI3",1,xFilial("BI3")+cCodIntX+cCodProX+cVersaoX,"BI3_DESCRI") ) +"/"+ cVersaoX + CRLF //" - Produto/Versão: " 
		cMsgX	+= STR0158 + AllTrim( Posicione("BJ1",1,xFilial("BJ1")+cCodPagX,"BJ1_DESCRI") )+ CRLF //" - Forma de Pagamento: "
			
		DBSelectArea("BA1")  //LEVANTAMENTO DO NUMERO DE REGISTROS DO USUARIO
		cChvBA1 := xFilial("BA1") + cCodIntX + cCodEmpX + cNumConX + cVerConX + cSubConX + cVerSubX
		BA1->(DBSetOrder(13))//BA1_FILIAL + BA1_CODINT + BA1_CODEMP + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB + BA1_MATRIC + BA1_TIPREG
		If BA1->(DBSeek(cChvBA1))
			While BA1->(!Eof()) .And. BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB) == cChvBA1
				If  Empty(BA1->BA1_DATBLO) .And. Empty(BA1->BA1_MOTBLO)
					DBSelectArea("BA3")
					cChvBA3     := BA1->( BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB )
					BA3->(DBSetOrder(1))//BA3_FILIAL+BA3_CODINT+BA3_CODEMP+BA3_MATRIC+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB
					If BA3->( DBSeek( xFilial("BA3") + cChvBA3 ) )
						If  (BA3->BA3_CODPLA == cCodProX .And. BA3->BA3_VERSAO == cVersaoX)  .and. Ascan(aChvBA3,{|X| X[1] == ( BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_MATRIC + BA3->BA3_FORPAG )}) == 0
							aAdd(aChvBA3 , {( BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_MATRIC + BA3->BA3_FORPAG ) , BA3->BA3_MATRIC , BA3->BA3_FORPAG , BA3->(Recno()) } )
						Endif
					Endif
					If BA3->BA3_FORPAG == cCodPagX .And. Empty(BA3->BA3_DATBLO) .And. Empty(BA3->BA3_MOTBLO)
						If aScan( aChvBA1 ,( BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC+BA1->BA1_TIPREG ) ) == 0 .and. (BA1->BA1_CODPLA == cCodProX .And. BA1->BA1_VERSAO == cVersaoX)
							aAdd( aChvBA1 , {( BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_MATRIC + BA1->BA1_TIPREG ) , BA1->BA1_MATRIC , BA1->BA1_TIPREG , BA1->(Recno()) } )
						EndIf
					EndIf
				Endif
				BA1->(DBSkip())
			EndDo
		EndIf

		aDadFai := {}
		DBSelectArea("BTN") //LEVANTAMENTO DO NUMERO DE REGISTROS DA FAIXA ETARIA DO GRUPO
		cChvBTN := xFilial("BTN") + cCodIntX + cCodEmpX + cNumConX + cVerConX + cSubConX + cVerSubX + cCodProX + cVersaoX + cCodPagX
		BTN->(DBSetOrder(1))//BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO+BTN_CODFOR+BTN_CODQTD+DTOS(BTN_TABVLD)+BTN_CODFAI

		If BTN->( DBSeek( cChvBTN ) )
			While BTN->(!Eof()) .And. BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO+BTN_CODFOR) == cChvBTN
				aAdd( aDadFai ,{;
					BTN->BTN_CODFAI,;
					BTN->BTN_IDAINI,;
					BTN->BTN_IDAFIN,;
					BTN->BTN_VALFAI,;
					BTN->BTN_QTDMIN,;
					BTN->BTN_QTDMAX,;
					BTN->BTN_TIPUSR,;
					BTN->BTN_GRAUPA,;
					BTN->BTN_SEXO,;
					BTN->BTN_TABVLD} )
				BTN->( DBSkip() )
			EndDo
		Else
			Loop //Caso não encontre a BTN, a alteração/inclusão foi feita na forma de cobrança dos opcionais, onde o mesmo não irá atualizar	
		EndIf

		/*If lCheck01 RETIRAR 17-06 INI
			
			If Empty(aChvBA1)
				cMsgX += Replicate("-",25) + CRLF
				cMsgX += STR0164 + CRLF //"Não foram encontrados registros para Atualizar as Faixas Etárias no Nível do Usuário (BDK)."
			Else
				//Faixa Etaria
				cMsgX += Replicate("-",25) + CRLF
				cMsgX += STR0163 + CRLF //"BDK - Faixas Etárias do Usuário"
				cMsgX += STR0161 + cValToChar(Len(aChvBA1)) +STR0162 + CRLF // " Foram selecionadas [" ## "] usuários para Atualizar."

				//BDK - Faixas Etárias do Usuário
				Begin Transaction
					LjMsgRun(STR0166,,) //"Atualizando Faixas Etárias dos usuários -  BDK..."
					//DELECAO DOS REGISTROS DA FAIXA ETARIA DO USUARIO
					For nX := 1 To Len( aChvBA1 )
						DBSelectArea("BDK")
						cChvBDK := xFilial("BDK") + aChvBA1[nX][01]//aChvBA1 , BA1->BA1_CODINT + BA1->BA1_CODEMP + BA1->BA1_MATRIC + BA1->BA1_TIPREG
						BDK->(DBSetOrder(2))//BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG+BDK_CODFAI 
						If BDK->( DBSeek( cChvBDK ) )
							While BDK->(!Eof()) .And. BDK->( BDK_FILIAL + BDK_CODINT + BDK_CODEMP + BDK_MATRIC + BDK_TIPREG ) == cChvBDK
								lDeleta := .T.
											
								For nY := 1 To Len( aDadFai )
									If aDadFai[nY][01] == BDK->BDK_CODFAI  //Codigos iguais o sistema não deleta para poder atualizar/alterar os dados.
										lDeleta := .F.
									EndIf
								Next nY
											
								If lDeleta //caso sistema não encontrar o codigo da faixa da BTN(faixa etaria do grupo) nos códigos da BDK(faixa etaria do usuario) ira deletar
									RecLock( "BDK" , .F. )
									BDK->( DBDelete() )
									BDK->( MSUnlock() )
								EndIf
								BDK->(DBSkip())
							EndDo
						EndIf
					Next nX
								
					If !Empty(aDadFai)
						For nX := 1 To Len( aChvBA1 )
							For nY := 1 To Len( aDadFai )
	
								lNovo := .T.
								DBSelectArea("BDK")
								cChvBDK := xFilial("BDK") + aChvBA1[nX][01]
								BDK->(DBSetOrder(2))//BDK_FILIAL+BDK_CODINT+BDK_CODEMP+BDK_MATRIC+BDK_TIPREG+BDK_CODFAI
								If BDK->( DBSeek( cChvBDK ) )
									While BDK->(!Eof()) .And. BDK->( BDK_FILIAL + BDK_CODINT + BDK_CODEMP + BDK_MATRIC + BDK_TIPREG ) == cChvBDK
										If BDK->BDK_CODFAI == aDadFai[nY][01]
											If BDK->BDK_IDAINI <> aDadFai[nY][02] .Or. BDK->BDK_IDAFIN <> aDadFai[nY][03] .Or. BDK->BDK_VALOR <> aDadFai[nY][04]
												RecLock( "BDK" , .F. )
												BDK->BDK_ANOMES	:= cValToChar( Year( Date() ) ) + StrZero( Month( Date() ) , 2 )	//ANO + MES
												BDK->BDK_IDAINI	   := aDadFai[nY][02]		//BTN->BTN_IDAINI
												BDK->BDK_IDAFIN	   := aDadFai[nY][03]		//BTN->BTN_IDAFIM
																			
												If BDK->BDK_VALOR <> aDadFai[nY][02]
													BDK->BDK_VLRANT	:= BDK->BDK_VALOR			//Valor Atual
													BDK->BDK_VALOR		:= aDadFai[nY][04]	//BTN->BTN_VALFAI
												EndIf
																			
												BDK->( MSUnlock() )
											EndIf
											lNovo := .F.
										EndIf
										BDK->(DBSkip())
									EndDo
								EndIf
											
								If lNovo
									BDK->( RecLock( "BDK" , .T. ) )
									BDK->BDK_FILIAL	   := xFilial("BDK")
									BDK->BDK_CODINT	:= cCodIntX
									BDK->BDK_CODEMP	:= cCodEmpX
									BDK->BDK_MATRIC	:= aChvBA1[nX][02]
									BDK->BDK_TIPREG	:= aChvBA1[nX][03]
									BDK->BDK_CODFAI	:= aDadFai[nY][01]
									BDK->BDK_IDAINI 	   := aDadFai[nY][02]
									BDK->BDK_IDAFIN	   := aDadFai[nY][03]
									BDK->BDK_VALOR		:= aDadFai[nY][04]
									BDK->( MSUnlock() )
								EndIf
							Next nY
						Next nX
					EndIf
				End Transaction
			
			EndIf

		Endif*/ //RETIRAR 17-06 FIM

		//BBU - Faixas Etárias da familia
		If lCheck02
					
			Begin Transaction
					
				LjMsgRun(STR0168,,) //"Atualizando Faixas Etárias da familia - BBU..."
				

			
				If Empty(aChvBA3)
							
					cMsgX += Replicate("-",25) + CRLF
					cMsgX += STR0171 + CRLF //"Não foram encontrados registros para Atualizar as Faixas Etárias do Grupo (BBU)."
							
				Else
					
					cMsgX += Replicate("-",25) + CRLF							
					cMsgX += STR0170 + CRLF //"BBU - Faixas Etárias da familia"
					cMsgX += STR0161+ cValToChar(Len(aChvBA3)) +STR0169 + CRLF // " Foram selecionadas [" ## "] faixas etárias da familia para Atualizar."
					
					//DELECAO DOS REGISTROS DA FAIXA ETARIA DA FAMILIA
					For nX := 1 To Len( aChvBA3 )
						DBSelectArea("BBU")
						cChvBBU := xFilial("BBU") + aChvBA3[nX][01]// BA3->BA3_CODINT + BA3->BA3_CODEMP + BA3->BA3_MATRIC + BA3->BA3_FORPAG
						BBU->(DBSetOrder(1))//BBU_FILIAL + BBU_CODOPE + BBU_CODEMP + BBU_MATRIC + BBU_CODFOR + BBU_CODFAI
						If BBU->( DBSeek( cChvBBU ) )
							While BBU->(!Eof()) .And. BBU->( BBU_FILIAL + BBU_CODOPE + BBU_CODEMP + BBU_MATRIC + BBU_CODFOR ) == cChvBBU
															
								lDeleta := .T.
															
								For nY := 1 To Len( aDadFai )
																
									If aDadFai[nY][01] == BBU->BBU_CODFAI  //Codigos iguais o sistema não deleta para poder atualizar/alterar os dados.
										lDeleta := .F.
									EndIf
		
								Next nY
															
								If lDeleta //caso sistema não encontrar o codigo da faixa da BTN(faixa etaria do grupo) nos códigos da BBU(faixa etaria do grupo) ira deletar
																
									RecLock( "BBU" , .F. )
									BBU->( DBDelete() )
									BBU->( MSUnlock() )
																
								EndIf
								BBU->(DBSkip())
							EndDo
						EndIf
					Next nX
										
					If !Empty(aDadFai)
										
						For nX := 1 To Len( aChvBA3 )
												
							For nY := 1 To Len( aDadFai )
													
								lNovo := .T.
													
								DBSelectArea("BBU")
								cChvBBU := xFilial("BBU") + aChvBA3[nX][01]
								BBU->(DBSetOrder(2))//BBU_FILIAL+BBU_CODOPE+BBU_CODEMP+BBU_MATRIC+BBU_CODFOR+BBU_SEXO+BBU_TIPUSR+BBU_GRAUPA
								If BBU->( DBSeek( cChvBBU ) )
									While BBU->(!Eof()) .And. BBU->( BBU_FILIAL + BBU_CODOPE + BBU_CODEMP + BBU_MATRIC + BBU_CODFOR ) == cChvBBU
										If BBU->BBU_CODFAI == aDadFai[nY][01]
											If BBU->BBU_IDAINI <> aDadFai[nY][02] .Or. BBU->BBU_IDAFIN <> aDadFai[nY][03] .Or. BBU->BBU_VALFAI <> aDadFai[nY][04]
												RecLock( "BBU" , .F. )
												BBU->BBU_ANOMES	:= cValToChar( Year( Date() ) ) + StrZero( Month( Date() ) , 2 )
												BBU->BBU_IDAINI	   := aDadFai[nY][02]
												BBU->BBU_IDAFIN	   := aDadFai[nY][03]
												If BBU->BBU_VALFAI <> aDadFai[nY][04]
													BBU->BBU_VLRANT	:= BBU->BBU_VALFAI
													BBU->BBU_VALFAI  	:= aDadFai[nY][04]
												EndIf
												BBU->BBU_TIPUSR		:= aDadFai[nY][07]
												BBU->BBU_GRAUPA	:= aDadFai[nY][08]
												BBU->BBU_SEXO		:= aDadFai[nY][09]
												BBU->BBU_TABVLD	:= aDadFai[nY][10]
												BBU->( MSUnlock() )
											EndIf
											lNovo := .F.
										EndIf
										BBU->(DBSkip())
									EndDo
								EndIf
													
								If lNovo
									BBU->( RecLock( "BBU" , .T. ) )
									BBU->BBU_FILIAL	:= xFilial("BBU")
									BBU->BBU_CODOPE	:= cCodIntX
									BBU->BBU_CODEMP	:= cCodEmpX
									BBU->BBU_MATRIC	:= aChvBA3[nX][02]
									BBU->BBU_CODFOR	:= aChvBA3[nX][03]
									BBU->BBU_CODFAI	:= aDadFai[nY][01]
									BBU->BBU_IDAINI	:= aDadFai[nY][02]
									BBU->BBU_IDAFIN	:= aDadFai[nY][03]
									BBU->BBU_VALFAI	:= aDadFai[nY][04]
									BBU->BBU_TIPUSR	:= aDadFai[nY][07]
									BBU->BBU_GRAUPA	:= aDadFai[nY][08]
									BBU->BBU_SEXO		:= aDadFai[nY][09]
									BBU->BBU_TABVLD	:= aDadFai[nY][10]
									BBU->( MSUnlock() )
								EndIf
														
							Next nY
											
						Next nX
											
					EndIf
					      
				Endif
			End Transaction
		Endif

		//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
		//º Recupera as Informacoes referentes aos descontos do Sub-Contrato.		 º
		//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼					
		DBSelectArea("BFT")
		cChvBFT := xFilial("BFT") + cCodIntX + cCodEmpX + cNumConX + cVerConX + cSubConX + cVerSubX + cCodProX + cVersaoX + cCodPagX
		BFT->( DBSetOrder(1) ) //BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB+BFT_CODPRO+BFT_VERPRO+BFT_CODFOR+BFT_CODQTD+BFT_CODFAI
		If BFT->( DBSeek( cChvBFT ) )
					
			While BFT->(!Eof()) .And. BFT->(BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB+BFT_CODPRO+BFT_VERPRO+BFT_CODFOR) == cChvBFT
						
				aAdd( aDadDes ,	{ ;
					BFT->BFT_CODFAI	,;
					BFT->BFT_TIPUSR	,;
					BFT->BFT_GRAUPA,;
					BFT->BFT_TIPO		,;
					BFT->BFT_PERCEN,;
					BFT->BFT_VALOR	,;
					BFT->BFT_QTDDE	,;
					BFT->BFT_QTDATE	,;
					BFT->BFT_DATDE	,;
					BFT->BFT_DATATE	 ,;
					BFT->BFT_CODFOR,;
					BFT->BFT_AUTOMA,;
					} )
				BFT->(DBSkip())
						
			EndDo
					
		EndIf

		//BDQ - Descontos dos usuários
		If lCheck03
		
			If Empty(aChvBA1) .Or. Empty(aDadDes)
				cMsgX += Replicate("-",25) + CRLF
				cMsgX += STR0193 + CRLF //"Não foram encontrados registros para Atualizar as Faixas de Descontos no Nível do Usuário (BDQ)."
			Else

				cMsgX += Replicate("-",25) + CRLF							
				cMsgX += STR0173 + CRLF //"BDQ - Descontos dos usuários"
				cMsgX += STR0161+ cValToChar(Len(aChvBA3)) +STR0190 + CRLF // " Foram selecionadas [" ## "] faixas de descontos dos usuário para Atualizar."

				Begin Transaction
					
					LjMsgRun(STR0173,,) //"BDQ - Descontos dos usuários"
					//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
					//º Verifica para apagar Faixas que Nao existem mais no Sub-Contrato.		 º
					//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
					For nX := 1 To Len( aChvBA1 )
									
						DBSelectArea("BDQ")
						cChvBDQ := xFilial("BDQ") + aChvBA1[nX][01] // CodInt + CodEmp + Matric + TipReg
						BDQ->(DBSetOrder(1))//BDQ_FILIAL+BDQ_CODINT+BDQ_CODEMP+BDQ_MATRIC+BDQ_TIPREG+BDQ_CODFAI
						If BDQ->( DBSeek( cChvBDQ ) )
							While BDQ->(!Eof()) .And. BDQ->( BDQ_FILIAL + BDQ_CODINT + BDQ_CODEMP + BDQ_MATRIC + BDQ_TIPREG ) == cChvBDQ
								RecLock( "BDQ" , .F. )
								BDQ->( DBDelete() )
								BDQ->( MSUnlock() )
								BDQ->(DBSkip())
							EndDo
						EndIf
					Next nX
								
					//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
					//º Atualiza/Cria as Faixas no Cadastro de Descontos em nivel de Usuario.	 º
					//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
					If !Empty(aDadFai)
						For nX := 1 To Len( aChvBA1 )
							For nY := 1 To Len( aDadFai )
								For nJ:= 1 to Len(ADaddES)
	
									If ADadFai[nY,01] <> aDadDes[nJ][01]
										loop
									Endif
												
									BDQ->( RecLock( "BDQ" , .T. ) )
									BDQ->BDQ_FILIAL	:= xFilial("BDQ")
									BDQ->BDQ_CODINT	:= cCodIntX
									BDQ->BDQ_CODEMP	:= cCodEmpX
									BDQ->BDQ_MATRIC	:= aChvBA1[nX][02]
									BDQ->BDQ_TIPREG	:= aChvBA1[nX][03]
									BDQ->BDQ_CODFAI	:= aDadDes[nJ][01]
									BDQ->BDQ_TIPO		:= aDadDes[nJ][04]
									BDQ->BDQ_PERCEN	:= aDadDes[nJ][05]
									BDQ->BDQ_VALOR	:= aDadDes[nJ][06]
									BDQ->BDQ_QTDMIN	:= aDadDes[nJ][07]
									BDQ->BDQ_QTDMAX	:= aDadDes[nJ][08]
									BDQ->BDQ_DATDE	:= aDadDes[nJ][09]
									BDQ->BDQ_DATATE	:= aDadDes[nJ][10]
									BDQ->( MSUnlock() )
									
								Next J
							Next nY
						Next nX
					EndIf
				End Transaction
			EndIf
		Endif

		//BFY - Descontos por Familias
		If lCheck04
			
			If Empty(aChvBA3) .Or. Empty(aDadDes)
				cMsgX += Replicate("-",25) + CRLF
				cMsgX += STR0194 + CRLF //"Não foram encontrados registros para Atualizar as Faixas Etárias no Nível do Usuário (BDK)."
			Else
				cMsgX += Replicate("-",25) + CRLF							
				cMsgX += STR0174 + CRLF //"BFY - Descontos por Familias"
				cMsgX += STR0161+ cValToChar(Len(aChvBA3)) +STR0192 + CRLF // " Foram selecionadas [" ## "] faixas de descontos da Família para Atualizar."

				Begin Transaction
					LjMsgRun(STR0175,,) //"Atualizando os Descontos por familia(BFY)....."
					//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
					//º Verifica para apagar Faixas que Nao existem mais no Sub-Contrato.		 º
					//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
					For nX := 1 To Len( aChvBA3 )
									
						DBSelectArea("BFY")
						cChvBFY := xFilial("BFY") + aChvBA3[nX][01]
						BFY->( DBSetOrder(1) )
						If BFY->( DBSeek( cChvBFY ) )
										
							While BFY->(!Eof()) .And. (BFY->BFY_FILIAL+BFY->BFY_CODOPE+BFY->BFY_CODEMP+BFY->BFY_MATRIC+BFY->BFY_CODFOR ) == cChvBFY
								RecLock( "BFY" , .F. )
								BFY->( DBDelete() )
								BFY->( MSUnlock() )
								BFY->(DBSkip())
							EndDo
										
						EndIf
								
					Next nX
								
					//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
					//º Atualiza/Cria as Faixas no Cadastro de Descontos em nivel de Familia.	 º
					//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
					If !Empty(aDadFai)
								
						For nX := 1 To Len( aChvBA3 )
							For nY := 1 To Len( aDadFai )
								For nJ:= 1 to Len(ADaddES)
	
									If ADadFai[nY,01] <> aDadDes[nJ][01]
										Loop
									Endif
												
									BFY->( RecLock( "BFY" , .T. ) )
									BFY->BFY_FILIAL := xFilial("BFY")
									BFY->BFY_CODOPE := cCodIntX
									BFY->BFY_CODEMP := cCodEmpX
									BFY->BFY_MATRIC := aChvBA3[nX][02]
									BFY->BFY_CODFAI := aDadDes[nJ][01]
									BFY->BFY_TIPUSR := aDadDes[nJ][02]
									BFY->BFY_GRAUPA := aDadDes[nJ][03]
									BFY->BFY_TIPO	  := aDadDes[nJ][04]
									BFY->BFY_PERCEN := aDadDes[nJ][05]
									BFY->BFY_VALOR  := aDadDes[nJ][06]
									BFY->BFY_QTDDE  := aDadDes[nJ][07]
									BFY->BFY_QTDATE := aDadDes[nJ][08]
									BFY->BFY_DATDE  := aDadDes[nJ][09]
									BFY->BFY_DATATE := aDadDes[nJ][10]
									BFY->BFY_CODFOR := aDadDes[nJ][11]
									BFY->BFY_AUTOMA := aDadDes[nJ][12]
									BFY->( MSUnlock() )
											
								Next nJ
							Next nY
						Next nX
					EndIf
				End Transaction
			EndIf
		Endif
	Next nI
EndIf

If lProc
	//Exibe o Log
	__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cMsgX)

	DEFINE MSDIALOG oDlgLog TITLE "Atualização concluída." From 3,0 to 340,417 PIXEL
	
	@ 5,5 GET oMemo  VAR cMsgX MEMO SIZE 200,145 OF oDlgLog PIXEL
	  oMemo:bRClicked := {||AllwaysTrue() } 
	
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog PIXEL //Apaga
	DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cMsgX))) ENABLE OF oDlgLog PIXEL
	
	ACTIVATE MSDIALOG oDlgLog CENTER
	
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  |CheckAll  ºAutor  ³Microsiga       		º Data ³  06/05/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcar/Desmarcar todos os CheckBox de Guias                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Static Function CheckAll(cNomChk,cNomObj,nQtdChk) 
Local nFor 		:= 0
Default cNomChk	:= "lCheck"
Default cNomObj	:= "oCheck"  
Default nQtdChk 	:= 4 

lAllChk := !lAllChk

For nFor := 2 to nQtdChk //17-06
	&(cNomChk + StrZero(nFor,2)) := !lAllChk
	&(cNomObj + StrZero(nFor,2) + ":Refresh()") 
Next

Return