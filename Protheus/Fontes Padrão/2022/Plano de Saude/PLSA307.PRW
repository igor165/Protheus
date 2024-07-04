
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"

#define K_Atend     3
#define K_Alt       4

Function PLSA307
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Definicao de variaveis...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cAlias     := "BBD"                                                    
LOCAL oBrw
LOCAL bAjustBrw  := { || oBrw := GetObjBrow(), PLSA305Tel(BTH->BTH_DATA,oBrw,cCodInt,cLocal,cCdAmbu,cDsAmbu) }
LOCAL cPerg      := "PLA307"
LOCAL cCodLoja
LOCAL cLocal
LOCAL cCodInt
LOCAL cDsambu
LOCAL cSQL
LOCAL oSay
LOCAL _cFil307                                                                
LOCAL nRcBAU
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta opcoes da rotina...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cSala
PRIVATE cCdAmbu
PRIVATE cCodSala
PRIVATE aCdCores  := { { 'BR_AMARELO' ,'Encaixe'  },;
                        { 'BR_CINZA'   ,'Agendado'  },;
                        { 'BR_AZUL'    ,'Atendido'  },;
                        { 'BR_VERDE'   ,'Espera'    } }

PRIVATE aCores    := { { 'BBD_STATUS = "1" .And. BBD_ENCAIX = "1"',aCdCores[1,1] },;
                        { 'BBD_STATUS = "1"',aCdCores[2,1] },;
                        { 'BBD_STATUS = "4"',aCdCores[3,1] },;
                        { 'BBD_STATUS = "5"',aCdCores[4,1] } }

PRIVATE aRotina   := MenuDef()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define o cabecalho da tela de atualizacoes                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cCadastro := "Atendimento"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca parametros da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("SX1")

If ! Pergunte(cPerg,.T.)
   Return
Endif   

cCodInt  := mv_par01
cLocal   := mv_par02
cdatade := mv_par03
cdataate := mv_par04
PRIVATE dData  := dDataDe
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca o medico logado...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BAU_CODIGO, R_E_C_N_O_ REG FROM "+RetSQLName("BAU")+" WHERE "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BAU_CODCFG = '"+RetCodUsr()+"'"
PLSQuery(cSQL,"Trb307")

If ! Trb307->(Eof())
   cCodLoja := Trb307->BAU_CODIGO
   nRcBAU   := Trb307->REG
Else
   MsgInfo("O Vinculo Rede de Atendimento X Usuario Configurador deve ser feito antes de entrar nesta opcao")
   Trb307->(DbCloseArea())
   Return
Endif                     
Trb307->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no medico...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbSetOrder(1))
BAU->(DbGoTo(nRcBAU))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca em qual sala ele esta...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT BGF_CODIGO, BGF_NSALA, BGF_CDAMBU FROM "+BGF->(RetSQLName("BGF"))+" WHERE "
cSQL += "BGF_FILIAL = '"+xFilial("BGF")+"' AND "
cSQL += "D_E_L_E_T_ = '' AND "
cSQL += "BGF_CODLOJ = '"+cCodLoja+"' AND "
cSQL += "BGF_CODINT = '"+cCodInt+"' AND "
cSQL += "BGF_CODLOC = '"+cLocal+"' AND "
cSQL += "BGF_STATUS = '1'"

PLSQuery(cSQL,"Trb307")

Trb307->(DbGoTop())
If ! Trb307->(Eof())
   cSala   := Trb307->BGF_NSALA       
   cCdAmbu := Trb307->BGF_CDAMBU
   cDsambu := BSD->(Posicione("BSD",1,xFilial("BSD")+cCdAmbu,"BSD_DSAMBU"))
   cCodSala:= Trb307->BGF_CODIGO  
Endif
Trb307->(DbCloseArea())

If Empty(cSala)
   MsgInfo("Por favor, confira os parametros informados na entrada da rotina.")
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro padrao...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
_cFil307 := "BBD_FILIAL = '"+xFilial("BBD")+"' .And. "
_cFil307 += "BBD_CODIGO = '"+Subs(cCodLoja,1,6)+"' .And. "
_cFil307 += " ( dtos(BBD_DATA) >= '"+dtos(dDataDe)+"' .And. dtos(BBD_DATA) <= '"+dtos(dDataAte)+"' ) .And. "
_cFil307 += "BBD_LOCAL = '"+Subs(cLocal,1,3)+"' "

BBD->(DbSetFilter({||&_cFil307},_cFil307))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama mBrowse padrao...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->(DbSetOrder(1))
BBD->(DbSeek(xFilial(cAlias)))

BBD->(mBrowse(006,001,022,075,cAlias, , , , , K_Atend, aCores, , , ,bAjustBrw))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera filtro antes de sair da rotina...                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->(DbClearFilter())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return


Function PLSA307MOV(cAlias,nReg,nOpc)
Local I__f := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis locais...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL oDlg
LOCAL oFolder
LOCAL oEnc01
LOCAL oEnc02
LOCAL cAliasEnc := "BTH"
LOCAL nRegEnc   := 0          

LOCAL oSay                         
LOCAL nOpca   := 0                                           
LOCAL cHorIni := ""

LOCAL bOK     := { || nOpca := 1,If((Obrigatorio(aGets,aTela)),oDlg:End(),(nOpca:=3,.F.))}
LOCAL bCanc   := {|| If(MsgYesNo(__cMsgAban),(nOpca := 0, oDlg:End()),.F.) }
LOCAL cPrefFil:= "PLSA315"          

LOCAL nHMsg

LOCAL aCabBTI := {}
LOCAL aDadBTI := {}
LOCAL aTrbBTI := {}
LOCAL aCpo01  := {}
LOCAL aCpo02  := {}
LOCAL nOrdBTH := BTH->(IndexOrd())
LOCAL nRecBTH := BTH->(Recno())

LOCAL aCabBPJ := {}
LOCAL aDadBPJ := {}
LOCAL aTrbBPJ := {}


PRIVATE oBrwEvo
PRIVATE aCabEvo := {}
PRIVATE aDadEvo := {}
PRIVATE cCodPac := BBD->BBD_CODPAC
PRIVATE lEvol   := .F.

PRIVATE nOpcUpt := nOpc

PRIVATE oBrwBTI
PRIVATE oBrwBPJ
PRIVATE aTela   := {}
PRIVATE aGets   := {}
PRIVATE aCols   := {}
PRIVATE aHeader := {}                                                        
PRIVATE aButtons:= {}

PRIVATE oMemo01
PRIVATE cMemo01 := ""

PRIVATE oMemo02
PRIVATE cMemo02 := ""

PRIVATE oMemo03
PRIVATE cMemo03 := ""

PRIVATE oMemo04
PRIVATE cMemo04 := ""

PRIVATE oMemo05
PRIVATE cMemo05 := ""

PRIVATE oMemo06
PRIVATE cMemo06 := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё testa se existem registros no Browse...                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BBD->(Eof())
   Return
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё testa se pode alterar...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc <> K_Atend .And. BBD->BBD_STATUS <> "4"
   MsgInfo("Nao e possivel alterar ou visualizar sem realizar o atendimento")
   Return
Endif              
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta aButtons se for atendimento...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aButtons,{"POSCLI",{ || PLSA307Grv(nOpc,M->BTH_CODATE)},"Gravar Dados"})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no usuario...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(DbSetOrder(2))
BA1->(DbSeek(xFilial("BA1")+BBD->BBD_CODPAC))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend
   Copy cAliasEnc To Memory Blank          
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta dados...                                                           Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nOpc == K_Atend
      M->BTH_CODATE := PLSA305Num(dDataBase)
   Endif   
   M->BTH_DATA   := dDataBase
   M->BTH_HORINI := Time()
   M->BTH_CODPAC := BBD->BBD_CODPAC
   M->BTH_NOMPAC := BBD->BBD_NOME
   M->BTH_IDADE  := IF(!Empty(BA1->BA1_DATNAS),Calc_Idade(dDataBase,BA1->BA1_DATNAS),0)
Else
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posiciona no atendimento da consulta posicionada...                      Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BTH->(DbSetOrder(1))
   BTH->(DbSeek(xFilial("BTH")+BBD->(BBD_NUMATE)))

   Copy cAliasEnc To Memory
   nRegEnc := BTH->(Recno())
Endif   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados das Solicitacoes...                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BTI" TO aCabBTI For .T.
If nOpc == K_Incluir
   Store COLS Blank "BTI" TO aDadBTI FROM aCabBTI
Else
   BTI->(DbSetOrder(1))
   If ! BTI->(DbSeek(xFilial("BTI")+BTH->BTH_CODATE))
      Store COLS Blank "BTI" TO aDadBTI FROM aCabBTI
   Else
      Store COLS "BTI" TO aDadBTI FROM aCabBTI VETTRAB aTrbBTI While BTI->(BTI_FILIAL+BTI_CODATE) == xFilial("BTI")+BTH->BTH_CODATE
   Endif
Endif    
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da Obstetricia.....                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BPJ" TO aCabBPJ For .T.
If nOpc == K_Incluir
   Store COLS Blank "BPJ" TO aDadBPJ FROM aCabBPJ
Else
   BPJ->(DbSetOrder(1))
   If ! BPJ->(DbSeek(xFilial("BPJ")+BTH->BTH_CODATE+BTH->BTH_CODPAC))
      Store COLS Blank "BPJ" TO aDadBPJ FROM aCabBPJ
   Else
      Store COLS "BPJ" TO aDadBPJ FROM aCabBPJ VETTRAB aTrbBPJ While BPJ->(BPJ_FILIAL+BPJ_CODATE+BPJ_CODPAC) == xFilial("BPJ")+BTH->BTH_CODATE+BTH->BTH_CODPAC
   Endif
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta evolucao do paciente...                                       Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BTH" TO aCabEvo For .T.

BTH->(DbSetOrder(2))
If BTH->(DbSeek(xFilial("BTH")+cCodPac))
   Store COLS "BTH" TO aDadEvo FROM aCabEvo While BTH->(BTH_FILIAL+BTH_CODPAC) == xFilial("BTH")+cCodPac For BTH->(Recno()) <> nRecBTH
   lEvol := Len(aDadEvo)>0
Endif
BTH->(DbSetOrder(nOrdBTH))
BTH->(DbGoTo(nRecBTH))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no proximo horario...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend .And. BBD->BBD_STATUS == "4" .And. nOpcUpt <> K_Alterar
   Return
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no usuario...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(DbSetOrder(2))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados dos MEMO...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cMemo01 := M->BTH_QUEPRI
cMemo02 := M->BTH_QUEDOE
cMemo03 := M->BTH_QUECLI
cMemo04 := M->BTH_QUIFAM
cMemo05 := M->BTH_DESREC
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 000,000 TO ndLinFin,ndColFin
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define folder...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lEvol
   @ 018,004 FOLDER oFolder SIZE 390,240 OF oDlg       PIXEL PROMPTS  "Atendimento",; 
                                                                       "Solicitacoes de Exames",;
                                                                       "Evolucao do Paciente",;
                                                                       "Ficha Obstetrica"
Else
   @ 018,004 FOLDER oFolder SIZE 390,240 OF oDlg       PIXEL PROMPTS  "Atendimento",; 
                                                                       "Solicitacoes de Exames",;
                                                                       "Ficha Obstetrica"
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define enchoice...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
STORE FIELD "BTH" TO aCpo01 FOR AllTrim(X3_CAMPO) $ "BTH_CODATE,BTH_CODPAC,BTH_NOMPAC"
                                
STORE FIELD "BTH" TO aCpo02 FOR AllTrim(X3_CAMPO) $ "BTH_DATRET,BTH_PESO,BTH_ALTURA,BTH_PREART,BTH_PRECAR,BTH_TEMPER,BTH_CID,BTH_DESCID,BTH_IDADE"

aSvaTela := {}
aTela    := {}
aGets    := {}
cVar     := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
aadd(aSvaTela,{})
oEnc01 := MsMGet():New(cAliasEnc ,nRegEnc ,K_Alterar,,,,aCpo01,{005,005,045,190},aCpo01,,,,,oFolder:aDialogs[1],,,.T.,cVar)       

aSvaTela[len(aSvaTela)] = aClone(aTela)
aTela    := {}
aGets    := {}
cVar     := "aSvaTela["+AllTrim(Str(Len(aSvaTela)+1))+"]"
aadd(aSvaTela,{})
oEnc02 := MsMGet():New(cAliasEnc ,nRegEnc ,K_Alterar,,,,aCpo02,{160,005,225,381},aCpo02,,,,,oFolder:aDialogs[1],,,.F.,cVar)       
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta memo...                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 005,195 Say oSay PROMPT "QP - Queixa Principal" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 015,195 GET oMemo01 VAR cMemo01 MEMO SIZE 185, 030 OF oFolder:aDialogs[1] PIXEL

@ 045,005 Say oSay PROMPT "HDA - Historico de Doenca Atual" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 055,005 GET oMemo02 VAR cMemo02 SIZE 186, 030 OF oFolder:aDialogs[1] PIXEL MEMO

@ 045,195 Say oSay PROMPT "HCC - Historico Clinica Cirurgica" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 055,195 GET oMemo03 VAR cMemo03 SIZE 186, 030 OF oFolder:aDialogs[1] PIXEL MEMO

@ 085,005 Say oSay PROMPT "HF - Historico Familiar" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 095,005 GET oMemo04 VAR cMemo04 SIZE 186, 030 OF oFolder:aDialogs[1] PIXEL MEMO

@ 085,195 Say oSay PROMPT "RC - Receita" SIZE 100, 006 OF oFolder:aDialogs[1] PIXEL COLOR CLR_HBLUE
@ 095,195 GET oMemo05 VAR cMemo05 MEMO SIZE 185, 030 OF oFolder:aDialogs[1] PIXEL

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta browse com as solicitacoes de exames...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oBrwBTI := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[2],nil    , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabBTI,aDadBTI,.F.,"BTI",K_Alterar,"Solicitacoes")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta browse evolucao do paciente...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF lEvol
   oBrwBTH := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[3],nil    , nil ,nil    ,nil   ,nil, .T.   , nil  ,.T.   ,nil   ,aCabEvo,aDadEvo,.F.,"BTH",K_Visualizar,"Evolucao do Paciente")
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta browse com a Ficha Obstetrica...                                   Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   oBrwBPJ := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[4],nil , nil ,nil,nil ,nil, .T. , nil ,.T. ,nil ,aCabBPJ,aDadBPJ,.F.,"BPJ",K_Alterar,"Obstetricia")
ELSE
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Monta browse com a Ficha Obstetrica...                                   Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   oBrwBPJ := TPLSBRW():New(010,005,383,220,nil  ,oFolder:aDialogs[3],nil , nil ,nil ,nil ,nil, .T. , nil ,.T. ,nil ,aCabBPJ,aDadBPJ,.F.,"BPJ",K_Alterar,"Obstetricia")
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCanc,.F.,aButtons)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata confirmacao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
   If nOpc == K_Atend .Or. nOpc == K_Alterar
      PLSA307Grv(nOpc,M->BTH_CODATE)
   Endif 
Else
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSA307GRV Ё Autor Ё Tulio Cesar         Ё Data Ё 08.07.02 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Grava os dados sem a necessidade de se fechar a tela...    Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA307Grv(nOpc,cCodAte)
Local I__f := 0
LOCAL aChave                                                                  
LOCAL lNovo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa se existe na base de dados...                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BTH->(DbSetOrder(1))
lNovo := !BTH->(DbSeek(xFilial("BTH")+cCodAte))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da transacao...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza agenda como efetuada...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Copy "BBD" To Memory

If nOpc == K_Atend .And. lNovo
   M->BBD_NUMATE := PLSA305Num(dDataBase)
Endif   

M->BBD_STATUS := "4"
M->BBD_CODPAC := M->BTH_CODPAC
M->BBD_NOME   := M->BTH_NOMPAC
M->BBD_NSALA  := cSala
M->BBD_CDAMBU := cCdAmbu
M->BBD_CODSAL := cCodSala

BBD->(PLUPTENC("BBD",K_Alterar))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza arquivo de consultas a partir de agendas medicas...             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == K_Atend
   M->BTH_CODATE := M->BBD_NUMATE
Endif

M->BTH_QUEPRI := cMemo01
M->BTH_QUEDOE := cMemo02
M->BTH_QUECLI := cMemo03
M->BTH_QUIFAM := cMemo04
M->BTH_DESREC := cMemo05
M->BTH_HORFIN := Time()
If lNovo
   BTH->(PLUPTENC("BTH",K_Incluir))
Else
   BTH->(PLUPTENC("BTH",K_Alterar))
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava solicitacoes...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aChave := {} 
aadd(aChave,{"BTI_CODATE",M->BTH_CODATE})
oBrwBTI:Grava(aChave)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava Obstetricia....                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aChave := {} 
aadd(aChave,{"BPJ_CODATE",M->BTH_CODATE})
aadd(aChave,{"BPJ_CODPAC",M->BTH_CODPAC})
oBrwBPJ:Grava(aChave)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza transacao...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
End Transaction
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё03/04/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё	  1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01   , "AxPesqui"   , 0 , K_Pesquisar  , 0 , .F.},;
                        { STRPL02  , "PLSA307MOV" , 0 , K_Visualizar , 0 , Nil},;
                        { "Atendimento" , "PLSA307MOV" , 0 , K_Atend      , 0 , Nil},;
                        { STRPL04     , "PLSA307MOV" , 0 , K_Alt        , 0 , Nil} }
Return(aRotina)
