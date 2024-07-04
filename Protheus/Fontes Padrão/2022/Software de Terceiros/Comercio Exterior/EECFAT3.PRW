#include "EEC.CH"
#include "EECFAT3.CH"
#define EEM_DV  "5"

Static aStrSC5,aStrEEC,aStrSC6,aStrEE9

/*
Programa : EECFAT3
Objetivo : Integracao com Siga Advanced - Notas Fiscais de Devolução
Autor    : Eduardo C. Romanini
Data/Hora: 04/01/2007 10:44
Obs.     :
*/


/*
Funcao      : EECFAT3
Parametros  : cCall - VLD - Validação
                      GRV - Gravação
              lExclui - .T. - Exclusão
                        .F. - Inclusão
Retorno     : lRet - .T./.F.
Objetivos   : Atualizar Valores de Embarque na Geração de NFs de Devolução
Autor       : Eduardo C. Romanini
Data/Hora   : 04/01/2007 10:45
Obs.        : Chamado do fonte MATA103.prx
Revisão     : Wilsimar Fabrício em 30/06/09: tratamento de devolução quando se usa o fluxo
              alternativo de integração com o faturamento (MV_AVG0141 e MV_AVG0067 -
              função AvIntEmb() deste programa).
              As funcionalidades desta implementação resumem-se em:
              1. apagar os campos EE9_NF e EE9_SERIE quando já realizada a comparação de notas fiscais;
              2. gerar um novo pedido de venda, a partir dos itens devolvidos;
              3. gravar o número do novo pedido gerado na tabela EXD;
              4. gravar a nota fiscal de devolução na tabela EEM.

              WFS 04/08/09 - incluído o tratamento para considerar o desconto na verificação
              do total da nota fiscal contra a parcela de câmbio. Campo acrescentado no array aTotDev.

*/
*-----------------------------*
Function EECFAT3(cCall,lExclui)
*-----------------------------*
Local lRet := .T.
Local nInc := 0
// ASK 20/08/2007 - Não rodar a função quando a chamada for do MACanDelF1 pelo EIC
//Local aOldHeader := aClone(aHeader)
//Local aOldCols   := aClone(aCols)
Local aOldHeader , aOldCols

Local aOrd := SaveOrd({"EE7","EE8","EE9","EEC","SD2","SC5"})

Local nPosIt    := 0
Local nPosQua   := 0
Local nPosTot   := 0
Local nPosNFO   := 0
Local nPosSeO   := 0
Local nPosItO   := 0
Local nPosDesc  := 0
Local aNfEES    := {}

//Inicio da Declaração das Variáveis que serão utilizadas para gravação do Embarque
Private lConsolida := .F.
Private aNfDev  := {}
Private cFilBr := "", cFilEx := ""
Private cFilSYS:=xFilial("SYS")
Private lContNfCompara := EasyGParam("MV_AVG0130",,.T.) // By JPP - 13/12/2006 - 16:00 - Habilitar a rotina de comparação de notas fiscais na integração com o Contábil

Private nSelecao := ALTERAR

If Type("aHeader") <> "A" .And. Type("aCols") <> "A" .OR. IsInCallStack("DI154NFE")// ASK 20/08/2007 - Não rodar a função quando a chamada for do MACanDelF1(MATA103X) pelo EIC(EICDI154)
   Return .T.
EndIf

aOldHeader := aClone(aHeader)
aOldCols   := aClone(aCols)

Private lIntermed := EECFlags("INTERMED")
Private lIntegra  := .T.

If lIntermed
   Private aConsolida := {}
   Ap104KeyX3(aConsolida) // acerta tamanho

   Private aGrpCpos  := {"WP_FLAG",;
                         "EE9_PEDIDO","EE9_ORIGEM","EE9_COD_I" ,"EE9_VM_DES",;
                         "EE9_FORN"  ,"EE9_FOLOJA","EE9_FABR"  ,"EE9_FALOJA",;
                         "EE9_PART_N","EE9_PRECO" ,"EE9_UNIDAD","EE9_SLDINI",;
                         "EE9_PRCTOT","EE9_PRCINC","EE9_PSLQUN","EE9_PSLQTO",;
                         "EE9_EMBAL1","EE9_QTDEM1","EE9_QE"    ,"EE9_PSBRUN",;
                         "EE9_PSBRTO","WP_SLDATU"}

   Private aGrpInfo  := {"S",;
                         "S","S","S","S",;
                         "S","S","S","S",;
                         "S","N","S","T",;
                         "T","T","S","T",;
                         "S","T","S","S",;
                         "T","T"}

   Private lConsolOffShore := .F.

EndIf

Private lConsign := EECFlags("CONSIGNACAO")

If lConsign .And. !Type("cTipoProc") == "C"
   Private cTipoProc := PC_RG
EndIf

If (EEC->(FieldPos("EEC_UNIDAD")) # 0) .And. (EE9->(FieldPos("EE9_UNPES")) # 0) .And.;
   (EE9->(FieldPos("EE9_UNPRC")) # 0)
   Private lConvUnid :=.t.
EndIf

Private lNFCompara := .F.

Private lBACKTO    := EasyGParam("MV_BACKTO",,.F.) .AND. ChkFile("EXK") ;
                      .AND. EE8->( FieldPos("EE8_INVPAG") > 0 ) .AND. EE9->( FieldPos("EE9_INVPAG") > 0  );
                      .And. (!lConsign .Or. cTipoProc $ PC_BN+PC_BC)
//Cria variáveis para uso nas funções do Drawback
Private lIntDraw := (!lConsign .OR. !lBackTo) .And. EasyGParam("MV_EEC_EDC",,.F.) .And. ( EasyGParam("MV_AVG0024",,"") != AvGetM0Fil() .Or. Empty( EasyGParam("MV_AVG0024",,"") ) )//Verifica se existe a integração com o Módulo SIGAEDC e se está na filial de Off-Shore
Private lIntFina := EasyGParam("MV_EEC_EFF",,.F.) //Verifica se existe a integração com o Módulo SIGAEFF
SX3->(DBSETORDER(2))
Private lExistEDD   := SX3->(dbSeek("EDD_FILIAL"))
Private lOkEE9_ATO  := SX3->(dbSeek("EE9_ATOCON"))
Private lYSTPMODU   := SX3->(DBSEEK("YS_TPMODU")) .AND. SX3->(DBSEEK("YS_MOEDA"))
Private lOkYS_PREEMB:= SX3->(dbSeek("YS_PREEMB")) .and. SX3->(dbSeek("YS_INVEXP"))
Private lIntEmb := EECFlags("INTEMB")

lTemTPMODU := SX3->(DbSeek("ECF_TPMODU"))

If lIntDraw .And. lConsign .And. cTipoProc $ PC_VR+PC_VB
   lIntDraw := .F.
EndIf

//Selecionar Pedido(Integrado com Faturamento - SIGAFAT) não Faturado.
Private lSelNotFat := EasyGParam("MV_AVG0067", .F., .F., xFilial("EE9"))

Private lNRotinaLC := .f.
//Define se é a nova rotina de Carta de Crédito
lNRotinaLC :=    (EEL->(FieldPos("EEL_SLDVNC")) # 0) ;
           .And. (EEL->(FieldPos("EEL_SLDEMB")) # 0) ;
           .And. (EEL->(FieldPos("EEL_RENOVA")) # 0)

//Define se é o tratamento de comissão com mais de um agente por item.
Private lTratComis := EasyGParam("MV_AVG0077",,.F.)


//Variaveis para verificação de campos para estorno da contabilização
Private aEstornaECF:={}, aIncluiECF:={}, cFilECF, cFilECG
Private lOkEstor:= SX3->(dbSeek("ECF_PREEMB")) .And. SX3->(dbSeek("ECF_FASE")) .And. SX3->(dbSeek("ECF_PREEMB")) .And. ;
                   SX3->(dbSeek("EEQ_FASE")) .And. SX3->(dbSeek("EEQ_EVENT")) .And. SX3->(dbSeek("EEQ_NR_CON")) .And. ;
			       SX3->(dbSeek("EET_DTDEMB"))
Private lContEst  := EasyGParam("MV_CONTEST",,.T.)   // Gera Estorno para contabilização
Private lIntCont  := EasyGParam("MV_EEC_ECO",,.F.)   // Define Integração entre SIGAEEC - SIGAECO

Private lCommodity := EECFlags("COMMODITY")

Private lPagtoAnte := EasyGParam("MV_AVG0039",,.f.)

//Define se haverão os novos tratamentos de alteração de valores após o embarque.
Private lAltValPosEmb := EasyGParam("MV_AVG0081",,.f.)

//Habilita os novos tratamentos de multi Off-Shore
Private lMultiOffShore := EasyGParam("MV_AVG0083",,.f.) .And. EEC->(FieldPos("EEC_NIOFFS")) > 0;
                                                   .And. EEC->(FieldPos("EEC_CLIENF")) > 0;
                                                   .And. EEC->(FieldPos("EEC_CLOJAF")) > 0

//Flag para habilitar/desabilitar a rotina de levantamento de campos e replicação de dados na filial de off-shore. */
Private lReplicaDados := EasyGParam("MV_AVG0079",,.f.)


Private aDiscount := {{"801","101"},; // Desconto sobre invoice.
                      {"802","101"},; // Abatimento sobre invoice.
                      {"803","102"},; // Desconto sobre frete.
                      {"804","103"},; // Desconto sobre seguro.
                      {"805","120"},; // Desconto sobre comissão - A Remeter.
                      {"806","121"},; // Desconto sobre comissão - Conta Gráfica.
                      {"807","122"}}  // Desconto sobre comissão - Deduzir da Fatura.

Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND.;
                     EEQ->( FieldPos("EEQ_TP_CON") ) > 0 .AND. EF1->(FieldPos("EF1_CAMTRA")  ) > 0 //HVR 25/04/06 - VERIFICA SE EF1_CAMTRA EXISTE .and. EF1->(FieldPos("EF1_CAMTRA")) > 0 .and.;

Private aDeletados := {}
Private cEvent     := ""

Private aApropria := {}
//**
Private oSayPesBru,oSayPesLiq

//Guarda as invoices e os campos do Back To Back
Private aColsBtB   :={}
Private aHeaderBtB :={}

//Necessario para que o filtro possa ser atualizado
Private cFilter

//Usada nas validações da vinculação dos itens
Private aItemVinc := {}
Private aDetail := {}

If lBACKTO
   cFilEXK := xFilial("EXK")
   AP106Cols(OC_EM)
Endif

Private aDesvinculados := {} // Controle de Saldo de L/C.
Private aItensDesv     := {}

Private lReplicacao := .f.
Private aAgDeletados:={}, aInDeletados:={}, aDeDeletados:={}, aNoDeletados:={}
Private aNFDeletados:={}

Private cArqCapInv
Private aInvEnchoice, aInvBrowse

Private cArqDetInv,cArq2DetInv
Private aDetInvBrowse
Private aDetInvEnchoice,aAltDetInv
Private aCInvDeletados := {}
Private aDInvDeletados := {}
Private lRefazRateio   := .F.

Private cWHENOD,cVIA,cWHENSA1,cWHENSA2,lMV0039,aMEMOITEM

aMEMOITEM := {{"EE9_DESC","EE9_VM_DES"}}

If EECFlags("AMOSTRA")
   aAdd(aMEMOITEM,{"EE9_QUADES","EE9_DSCQUA"})
EndIf

//Fim da Declaração de Variáveis utilizadas na gravação do Embarque
Private cSeqDev    := ""
Private cNfOri     := ""
Private cSerieOri  := ""
Private cItOri     := ""
Private cImport    := ""
Private lEmbarque  := .F.
Private lDtemba    := .F.
Private cEmbarque  := ""
Private cNFSPedido := ""
Private cNFSItemPV := ""
Private cPedExp    := ""
Private cSequen    := ""
Private nQtdDev    := 0
Private aMsg       := {}
Private cMsg       := ""
Private cParc      := ""
Private aTotDev    := {}
Private cMoeda     := ""
Private nQtdNF     := 0
Private aDel       := {}
Private nOldDev    := 0
Private lDevTotal  := .F.
Private lExcDevTot := .F.
Private aNFApaga   := {}
Private dDtEmba

Private lNfRemessa := .F.
If EasyGParam("MV_AVG0174",.T.)
   lNfRemessa := EasyGParam("MV_AVG0174",.F.,.F.) .and. lIntegra
EndIf

Private aCabPV:= {}
Private aItensPV:= {}
Private aItemEmbTemp:= {}
Private aItemEmb:= {}
Private aNfDevEES:= {}

Default lExclui    := .F.

Begin Sequence

   //Verificar se a Nota é Devolução
   Do Case
      Case cTipo == "D"

           //O EECFAT3 irá rodar todas as linhas do aCols, portanto o programa apenas será rodado uma vez.
           If Valtype(SD1->D1_ITEM) <> "U"
              If Right(AllTrim(SD1->D1_ITEM),2) <> "01"
                 Break
              EndIf
           EndIf

           //A validação da exclusão da NF de Devolução é feita antes de carregar a tela da Nota.
           //Com isso o aCols não é carregado.
           If cCall == "VLD" .and. lExclui

              //Preenche o aheader
              SX3->(DbSetOrder(1))
              SX3->(DbSeek("SD1"))
              While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO == "SD1")
                 If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
                    AADD(aHeader,{ TRIM(x3titulo()),;
                                   SX3->X3_CAMPO,;
                                   SX3->X3_PICTURE,;
                                   SX3->X3_TAMANHO,;
                                   SX3->X3_DECIMAL,;
                                   Iif(Alltrim(SX3->X3_CAMPO) == "D1_ITEM",".T.",SX3->X3_VALID) ,;
                                   SX3->X3_USADO,;
                                   SX3->X3_TIPO,;
                                   SX3->X3_ARQUIVO,;
                                   SX3->X3_CONTEXT})

			     EndIf
                 SX3->(dbSkip())
              EndDo

           	  SD1->(DbSetOrder(1))
              If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
                 While SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC     + D1_SERIE      + D1_FORNECE      + D1_LOJA) == ;
                                           xFilial("SD1")  +SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA


                    //Cria uma linha em branco no aCols
                    aAdd(aCols,Array(Len(aHeader)+1))

                    //Preenche o aCols
                    For nInc := 1 to Len(aHeader)
                       aCols[Len(aCols)][nInc]   := If(aHeader[nInc][10] <> "V",SD1->(&(aHeader[nInc][2])),)
                    Next
                    aCols[Len(aCols)][Len(aHeader)+1] := .F.

                    SD1->(DbSkip())
                 EndDo
              EndIf
           EndIf

           nPosIt    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
           nPosQua   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
           nPosTot   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
           nPosNFO   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
           nPosSeO   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
           nPosItO   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
           nPosDesc  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})

           //Looping no aCols para Valores Totais da NF de Devolução
           For nInc := 1  to Len(aCols)

              //Verifica se a Linha foi excluída
              //If aCols[nInc][Len(aHeader)+1]
              If aCols[nInc][Len(aCols[nInc])]
                 Loop
              EndIf

              nPos := aScan(aTotDev,{|e| e[1] == aCols[nInc][nPosNFO] .and. e[2] == aCols[nInc][nPosSeO]})

              If nPos > 0
                 aTotDev[nPos][3] += aCols[nInc][nPosTot]
                 aTotDev[nPos][4] += aCols[nInc][nPosQua]
                 aTotDev[nPos][5] += aCols[nInc][nPosDesc]
              Else
                 //            1 - Nota Fiscal     ,2 - Serie           ,3 - Vl. Devolvido   ,4 - Qtd. Devolvida  ,5 - Vl. Desconto
                 aAdd(aTotDev,{aCols[nInc][nPosNFO],aCols[nInc][nPosSeO],aCols[nInc][nPosTot],aCols[nInc][nPosQua],aCols[nInc][nPosDesc]})
              EndIf

           Next

           //Looping no Array de Notas Fiscas para Verificar se existe embarque, já embarcado.
           For nInc := 1 to Len(aTotDev)

              cNfOri    := aTotDev[nInc][1]
              cSerieOri := aTotDev[nInc][2]
              nValdev   := aTotDev[nInc][3]

              //Verifica se Existe Embarque para o Item da Nf de Devolução
              SD2->(DbSetOrder(3))
              If SD2->(DbSeek(xFilial("SD2")+AvKey(cNfOri,"D2_DOC")+AvKey(cSerieOri,"D2_SERIE")))
                 //Verifica se já existe Embarque para a Nota Fiscal de Saída
                 If !Empty(SD2->D2_PREEMB)
                    cEmbarque := SD2->D2_PREEMB
                    EEC->(DbSetOrder(1))
                    If EEC->(DbSeek(xFilial("EEC")+cEmbarque))
                       cMoeda  := EEC->EEC_MOEDA
                       cImport := EEC->EEC_IMPORT
                       If !Empty(EEC->EEC_DTEMBA)
                          lDTemba := .T.
                          dDtEmba := EEC->EEC_DTEMBA
                          If cCall == "VLD"
                             FAT3Valid(lExclui,.F.)
                          ElseIf cCall == "GRV"
                             FAT3Grava(lExclui,.F.)
                          EndIf
                       EndIf
                    EndIf
                 EndIf
              EndIf
           Next

           //Refaz o Looping no aCols para Tratamento individual de Cada Item
           For nInc := 1  to Len(aCols)

              //Verifica se a Linha foi excluída
              //If aCols[nInc][Len(aHeader)+1]
              If aCols[nInc][Len(aCols[nInc])]
                 Loop
              EndIf

              cSeqDev   := aCols[nInc][nPosIt]  //Sequencia da ND de Devolução
              nQtdDev   := aCols[nInc][nPosQua] //Quantidade devolvida
              nValDev   := aCols[nInc][nPosTot] //Valor Devolvido
              cNfOri    := aCols[nInc][nPosNFO] //Nota Fiscal de Origem
              cSerieOri := aCols[nInc][nPosSeO] //Serie da Nota Fiscal de Origem
              cItOri    := aCols[nInc][nPosItO] //Item da Nota Fiscal de Origem

              //Pesquisa a NF de Origem
              SD2->(DbSetOrder(3))
              If SD2->(DbSeek(xFilial("SD2")+AvKey(cNfOri,"D2_DOC")+AvKey(cSerieOri,"D2_SERIE")))
                 While SD2->(!EOF()) .and. SD2->(D2_FILIAL + D2_DOC + D2_SERIE) == xFilial("SD2")+cNfOri+cSerieOri
                    If SD2->D2_ITEM == AvKey(cItOri,"D2_ITEM")
                       //Verifica se já existe Embarque para a Nota Fiscal de Saída
                       If !Empty(SD2->D2_PREEMB)
                          lEmbarque := .T.
                          cEmbarque := SD2->D2_PREEMB
                       EndIf

                       If !lExclui
                           If nQtdDev == SD2->D2_QUANT - SD2->D2_QTDEDEV .Or. SD2->D2_QUANT == SD2->D2_QTDEDEV
                              lDevTotal := .T.
                           Else
                              lDevTotal := .F. //LRS - 12/11/2015
                           EndIf
                       Else//Exclusão da nota de devolucao
                           If nQtdDev == SD2->D2_QTDEDEV .And. SD2->D2_QUANT == SD2->D2_QTDEDEV
                              lExcDevTot := .T.
                           Else
                              lExcDevTot := .F.
                           EndIf
                       EndIf

                       cNFSPedido := SD2->D2_PEDIDO
                       cNFSItemPV := SD2->D2_ITEMPV
                       nQtdNF     := SD2->D2_QUANT
                       nOldDev    := SD2->D2_QTDEDEV
                       Exit
                    EndIf
                    SD2->(DbSkip())
                 EndDo
              EndIf

              //Pesquisa Pedido de Venda com base na Nota Fiscal de Saída
              SC5->(DbSetOrder(1))
              If SC5->(DbSeek(xFilial("SC5")+AvKey(cNFSPedido,"C5_NUM")))
                 cPedExp := SC5->C5_PEDEXP
              EndIf

              //** AAF 10/08/2007 - Se a Nota não possui pedido na exportação, é nota nascional!
              If Empty(cPedExp)
                 Loop
              EndIf
              //**
              //Pesquisa Itens do Pedido de Exportação
              EE8->(DbSetOrder(1)) //EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN
              If EE8->(DbSeek(xFilial("EE8")+AvKey(cPedExp,"EE8_PEDIDO")))
                 While EE8->(!EOF()) .and. EE8->EE8_FILIAL + EE8->EE8_PEDIDO == xFilial("EE8") + AvKey(cPedExp,"EE8_PEDIDO")

                    //Verifica o Item refernte a NF de Saída
                    If EE8->EE8_FATIT == AvKey(cNFSItemPV,"EE8_FATIT")
                       cSequen := EE8->EE8_SEQUEN
                       Exit
                    EndIf

                    EE8->(DbSkip())
                 EndDo
              //Else
                 //lRet := .F.
                 //Break
              EndIf

              If lEmbarque

                 //Tratamento para Itens que já foram Embarcados
                 EEC->(DbSetOrder(1))
                 If EEC->(DbSeek(xFilial("EEC")+cEmbarque))
                    If !Empty(EEC->EEC_DTEMBA)
                       lDtEmba := .T.
                    EndIf
                 EndIf
              EndIf

              If cCall == "VLD"
                 FAT3Valid(lExclui,.T.)
              ElseIf cCall == "GRV"
                 FAT3Grava(lExclui,.T.)
              EndIf

              nQtdDev   := aCols[nInc][nPosQua] //Quantidade devolvida
              nValDev   := aCols[nInc][nPosTot] //Valor Devolvido

              //WFS 30/06/09 ---
              //Início do tratamento para quando usado o fluxo alternativo de integração
              If AvIntEmb() .And. cCall == "GRV" .And. !lExclui

                 //Limpa o conteúdo do campo EE9_NF e EE9_SERIE quando já realizado a comparação de notas fiscais
                 //Posiciona no registro a ser gravado na tabela EES, para os tratamentos da função AE100GrvEEM
                 Fat3LimpaEE9()

                 //Posicionamento da tabela EEC para os tratamentos da função AE100GrvEEM
                 EEC->(DBSeek(xFilial() + cPedExp))

                 //Força a gravação das tabelas EEM e EES, para a manutenção
                 //do histórico da integração.
                 AE100GrvEEM(cNFSPedido, cNFSItemPV, cNfOri, cSerieOri, EE8->(Ap101FilNf()),;
                             aCols[nInc][nPosQua], aCols[nInc][nPosTot])

                 //Array para a gravação dos itens da nota de devolução na tabela EES
                 AAdd(aNfEES, {"EES_FATSEQ", aCols[nInc][nPosIt]})
                 AAdd(aNfEES, {"EES_PREEMB", cPedExp})
                 AAdd(aNfEES, {"EES_PEDIDO", EE9->EE9_PEDIDO})
                 AAdd(aNfEES, {"EES_SEQUEN", EE9->EE9_SEQUEN})
                 AAdd(aNfEEs, {"EES_COD_I" , EE9->EE9_COD_I })
                 AAdd(aNfEES, {"EES_QTDE"  , aCols[nInc][nPosQua]})
                 AAdd(aNfEES, {"EES_VLNF"  , aCols[nInc][nPosTot]})

                 /* WFS 17/07/2009
                    Estes campos não existem no aCols e, neste ponto, ainda não
                    foram gravados na tabela SD1.
                 AAdd(aNfEES, {"EES_VLMERC", SD1->(D1_TOTAL - D1_VALFRE - D1_SEGURO - D1_DESPESA + D1_VALDESC)})
                 AAdd(aNfEES, {"EES_VLFRET", SD1->D1_VALFRE})
                 AAdd(aNfEES, {"EES_VLSEGU", SD1->D1_SEGURO})
                 AAdd(aNfEES, {"EES_VLOUTR", SD1->(D1_DESPESA - D1_VALDESC)}) */

                 AAdd(aNfDevEES, AClone(aNfEES))
                 aNfEES:= {}
                 //Alimenta o array aItensPV, para a geração do novo pedido
                 Fat3GeraItens()
              EndIf
              // ---
           Next

           //WFS 01/07/09 ---
           //Se a variável cPedExp está vazia é porque o pedido de venda não tem origem
           //no módulo de exportação
           If AvIntEmb() .And. !Empty(cPedExp)

              //Se não for exclusão da devolução
              If !lExclui .And. cCall == "GRV"
                 //Alimenta o array aCabPV, para a geração do novo pedido
                 Fat3GeraCab()

                 //Variável requerida pela função AvMata410. Será usada na função Fat3GravaEXD().
                 M->EEC_PEDFAT:= ""
                 AVMata410(aCabPV, aItensPV, INCLUIR, "EMB")

                 MsgInfo(STR0014 + M->EEC_PEDFAT, STR0013) //Número do Pedido no Faturamento: ###, Aviso

                 //A variável cTipo é alterada para "S" pela função Mata410 após a chamada MsExecAuto
                 //realizada pela AvMata410. O tipo deve ser "D", referente à nota fiscal de devolução
                 //em processo.
                 cTipo:= "D"

                 //Gravação do pedido gerado na tabela EXD
                 Fat3GravaEXD()

                 //Gravação da nota fiscal de devolução nas tabelas EEM e EES.
                 Fat3GrvEEMDev()

              ElseIf lExclui
                 lRet:= Fat3ExcluiDev(cCall)
              EndIf
           EndIf
           //---

           If Len(aMsg) > 0

              lRet := .F.

              cMsg := STR0001 + If(lExclui,STR0002,STR0003) + ENTER + ENTER //"A Nota de Devolução não poderá ser "###"excluída."###"gerada."

              For nInc := 1 to Len(aMsg)
                 Do Case
                     Case aMsg[nInc][1] == "QTD"

                        cMsg += STR0004 + aMsg[nInc][2] + ENTER +; //"Verifique se a quantidade devolvida no(s) Item(s): "
                              STR0005 + ENTER + ENTER //"é a mesma das Notas Fiscais de Origem."

                     Case aMsg[nInc][1] == "PARC"

                        cMsg += STR0006 + ENTER +; //"Não existem parcelas de Câmbio não Liquidadas "
                              STR0007 + If(lExclui,STR0008,STR0009) + ENTER + ENTER //"suficientes para que o valor devolvido seja "###"restaurado."###"abatido."

                     Case aMsg[nInc][1] == "EXC802"

                        cMsg += STR0010 +ENTER +; //"A Parcela de Cambio referente a essa NF de Devolução"
                              STR0011 + ENTER + ENTER //"já foi liquidada."

                     Case aMsg[nInc][1] == "ATO"

                        cMsg += aMsg[nInc][2]

                 EndCase

              Next

              EECView(cMsg,STR0012) //"Atenção"

           EndIf

   End Case

End Sequence

aHeader := aClone(aOldHeader)
aCols   := aClone(aOldCols)
RestOrd(aOrd)

Return lRet

/*
Funcao      : FAT3Valid
Parametros  : lItem - .T. - Lopping em cada linha do aCols.
                      .F. - Looping para cada NF de Saída
Retorno     : lRet - .T./.F.
Objetivos   : Validar se a Nota de Devolução poderá ser gerada.
Autor       : Eduardo C. Romanini
Data/Hora   : 04/01/2007 10:45
Obs.        :
Revisão     : WFS 04/08/09 - incluído o tratamento para considerar o desconto na verificação
              do total da nota fiscal contra a parcela de câmbio
*/
*--------------------------------------*
Static Function FAT3Valid(lExclui,lItem)
*--------------------------------------*
Local lRet      := .T.
Local lParc     := .F.
Local lTem802   := .F.
Local lLiq802   := .T.
Local lLiq101   := .T.
Local cMsgAux   := ""
Local nTotDev   := 0
Local nValParc  := 0

Local lNFCambio := EasyGParam("MV_EEC0045",,.F.) //LGS-03/08/2015 //O Default do parametro é .F., se ligar vai permitir gerar nf de devolução com cambio liquidado. //LGS-24/07/2015
Default lItem := .T.

Begin Sequence

   If lItem

      If !lExclui

         iF EE9->( dbsetorder(1),dbseek( xFilial("EE9")+cPedExp+cSequen+cEmbarque  ) )
            While EE9->( ! EOF() ) .AND. EEC->(EEC_FILIAL+EEC_PREEMB) == EE9->(EE9_FILIAL+EE9_PREEMB)
               iF EE9->EE9_NF+EE9->EE9_SERIE+EE9->EE9_SEQUEN+EE9->EE9_PREEMB == cNfOri+cSerieOri+cSequen+cEmbarque
                  If ! Empty(EE9->EE9_ATOCON)
                     cMsgAux := "O processo de exportação "+Alltrim(EEC->(EEC_FILIAL+EEC_PREEMB))+" possui vínculo com o ato concessório "+Alltrim(EE9->EE9_ATOCON)+" para o produto "+Alltrim(EE9->EE9_COD_I)+". Antes de prosseguir com a operação de devolução o ato concessório deve ser estornado do embarque de exportação."
                     aAdd(aMsg,{"ATO",cMsgAux})
                     lRet := .F.
                  EndIf
               EndIf
               EE9->( dbSkip() )
            EndDo
         EndIf

         If lDtemba
            //Valida a Devolução Total da Nota de Devolução
            /*
            If nQtdNF == (nQtdDev + nOldDev)
               nPos := aScan(aMsg,{|e| e[1] == "QTD"})
               If nPos > 0
                  aMsg[nPos][2] +=  ", " + cSeqDev
               Else
                  aAdd(aMsg,{"QTD",cSeqDev})
               EndIf

               lRet := .F.
            EndIf
            */
         EndIf

      EndIf

   Else

      If !lExclui

         If lDtemba

            //Verifica se existe parcelas de Câmbio em aberto e com valor suficiente para
            //que o valor devolvido seja descontado.

            nPos := aScan(aTotDev,{|e| e[1] == cNfOri .and. e[2] == cSerieOri})

            //Nopado por WFS em 04/08/2009
            //nTotDev := aTotDev[nPos][3] //Recebe o Valor Devovlido para a NF de Origem
            nTotDev:= aTotDev[nPos][3] - aTotDev[nPos][5] //Recebe o valor devolvido menos o valor do desconto para a NF de Origem

            EEQ->(DbSetOrder(1))
            If EEQ->(DbSeek(xFilial("EEQ")+cEmbarque))
               While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL+EEQ_PREEMB) == xFilial("EEQ")+cEmbarque
                  If EEQ->EEQ_EVENT == "101" .and. EEQ->EEQ_FASE == "E" .and. EEQ->EEQ_TIPO == "R"
                     If Empty(EEQ->EEQ_PGT)
                        //nValParc += (EEQ->EEQ_VL * BuscaTaxa(cMoeda,dDataBase)) nopado por WFS em 04/08/09
                        nValParc += (EEQ->EEQ_VL * BuscaTaxa(cMoeda, dDtEmba))
                     EndIf
                  EndIf
                  EEQ->(DbSkip())
               EndDo

               If Round(nValParc,AvSX3("D2_TOTAL",4)) >= nTotDev
                  lParc := .T.
               EndIf

               If !lParc .And. !lNFCambio //LGS-24/07/2015
                  nPos := aScan(aMsg,{|e| e[1] == "PARC"})
                  If nPos == 0
                     aAdd(aMsg,{"PARC",Nil})
                     lRet := .F.
                  EndIf
               EndIf
            EndIf
         EndIf

      Else

         If lDtemba

            //Verifica se existe parcelas de Câmbio em aberto e com valor suficiente para
            //que o valor devolvido seja descontado.

            EEQ->(DbSetOrder(1))
            If EEQ->(DbSeek(xFilial("EEQ")+cEmbarque))
               While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL+EEQ_PREEMB) == xFilial("EEQ")+cEmbarque
                  If EEQ->EEQ_EVENT == "802" .and. Left(EEQ->EEQ_OBS,AVSX3("EE9_NF",AV_TAMANHO)) == /*cNFOri*/ AvKey( AllTrim(cNfOri)+"-"+AllTrim(cSerieOri) , "EE9_NF")
                     lTem802 := .T.
                     If Empty(EEQ->EEQ_PGT)
                        lLiq802 := .F.
                     EndIf
                  EndIf
                  If EEQ->EEQ_EVENT == "101" .and. EEQ->EEQ_FASE == "E" .and. EEQ->EEQ_TIPO == "R"
                     If Empty(EEQ->EEQ_PGT)
                        lLiq101 := .F.
                     EndIf
                  EndIf
                  EEQ->(DbSkip())
               EndDo
            EndIf

            //Verifica se existe Parcela 802
            If lTem802
               If lLiq802
                  nPos := aScan(aMsg,{|e| e[1] == "EXC802"})
                  If nPos == 0
                     aAdd(aMsg,{"EXC802",Nil})
                     lRet := .F.
                  EndIf
               EndIf

               If lLiq101 .And. !lNFCambio //LGS-24/07/2015
                  nPos := aScan(aMsg,{|e| e[1] == "PARC"})
                  If nPos == 0
                     aAdd(aMsg,{"PARC",Nil})
                     lRet := .F.
                  EndIf
               EndIf

            Else
               If lLiq101 .And. !lNFCambio //LGS-24/07/2015
                  nPos := aScan(aMsg,{|e| e[1] == "PARC"})
                  If nPos == 0
                     aAdd(aMsg,{"PARC",Nil})
                     lRet := .F.
                  EndIf
               EndIf
            EndIf

         EndIf

      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : FAT3Grava
Parametros  : lExclui - .T. - Exclusão
                        .F. - Inclusão
              lItem -   .T. - Lopping em cada linha do aCols.
                        .F. - Looping para cada NF de Saída
Retorno     : lRet - .T./.F.
Objetivos   : Atualizar os Valores de Embarque relacionandos a NF de Devolução
Autor       : Eduardo C. Romanini
Data/Hora   : 04/01/2007 10:45
Obs.        :
*/
*--------------------------------------*
Static Function FAT3Grava(lExclui,lItem)
*--------------------------------------*
Local lRet       := .T.
Local lExcEmb    := .F.
Local lExcItem   := .F.

Local cOldMod    := cModulo
Local cParcDel   := ""

Local nOldMod    := nModulo
Local nInc2      := 0
Local nZ         := 0
Local nDevTot    := 0
Local nEmbTot    := 0

Local aWorks     := {}
Local aCpo       := {}
Local aSemSX3    := {}
Local aOrd       := SaveOrd({"EEC","EE9","SC6","SD2","EE8"})

//NCF - 03/08/2017
Local aOrdEEQ    := {}
Local i, nLastPr101, cLastPrCmb, nVlrPrcCmb
Local nRecAbTmp
Private aCampos  := Array(EEQ->(FCount()))
Private aFat3Alt := {}
Private cWORKEEQ   := ""
Private cWORKEEQ2  := ""
Private cWORKEEQ5  := ""
Private cWORKEEQ6  := ""
Default lItem    := .T. 

Begin Sequence

   //Mudar identificação do módulo
   nModulo := 29
   cModulo := "EEC"
   lTemAgente:= .F. // Private do EECAE100

   If lItem //Tratamento por Item

      IF(EasyEntryPoint("EECFAT3"),ExecBlock("EECFAT3",.F.,.F.,"ALTERA_QTD_DEVOLVIDA"),) //LRS - 21/06/2016

      //Pesquisa Itens do Pedido de Exportação e Altera o Saldo
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(xFilial("EE8")+AvKey(cPedExp,"EE8_PEDIDO")+AvKey(cSequen,"EE8_SEQUEN")))
         EE8->(RecLock("EE8",.F.))
         If lExclui
            If !lDtemba  .and. !lEmbarque
               EE8->EE8_SLDATU := EE8->EE8_SLDATU + nQtdDev    //NCF - 29/06/2018 - Inversão de sinal de (+) para (-) visto que se trata de estorno da devolução e esta
            EndIf
         Else
            If !lDtemba
               //MFR 13/01/2021 OSSME-5477
               //If !(lDevTotal .and. lEmbarque)  
               If !lEmbarque                 
                  EE8->EE8_SLDATU := EE8->EE8_SLDATU - nQtdDev   //NCF - 29/06/2018 - Inversão de sinal de (-) para (+) visto que se trata de devolução e esta
               EndIf                                             //                   deve então acrescentar ao saldo atualizado.
            EndIf                                                //MFR - 12/01/2021 OSSME-5466 O correto é MENOS mesmo, pois uma vez devolvida não pode ser faturada novamente
         EndIf
         EE8->(MsUnlock())
      EndIf

      //Tratamento para Notas com Embarque, cuja Data de Embarque está vazia.
      If lEmbarque

         If !lDtEmba

            If lDevTotal //Devolução Total da NF de Origem

               //Verifica a Quantidade total devolvida para a Nota de Origem
               nPos := aScan(aTotDev,{|e| e[1] == cNfOri .and. e[2] == cSerieOri})

               If nPos > 0
                  nDevTot := aTotDev[nPos][4]
               EndIf

               //Verifica a quantidade total do embarque para a Nota de Devolução
               /*EE9->(DbSetOrder(3))
               If EE9->(DbSeek(xFilial("EE9")+AvKey(cEmbarque,"EE9_PREEMB")))
                  While EE9->(!EOF()) .and. EE9->(EE9_FILIAL + EE9_PREEMB) == xFilial("EE9")+cEmbarque
                     nEmbTot += EE9->EE9_SLDINI
                     EE9->(DbSkip())
                  EndDo
               EndIf*/
               nEmbTot := QtdTotEmba(AvKey(cEmbarque,"EE9_PREEMB"))

               //Verifica se a quantidade devolvida para a Nota é a mesma do Embarque
               If nDevTot == nEmbTot
                  lExcEmb  := .T. //Exclui todo o embarque
               Else
                  lExcItem := .T. //Exclui apenas o Item.
               EndIf

               If lExcEmb

                  EEC->(DbSetOrder(1))
                  If EEC->(DbSeek(xFilial("EEC")+AvKey(cEmbarque,"EEC_PREEMB")))
                     M->EEC_PREEMB := EEC->EEC_PREEMB
                     //DFS - Antes, era usado a função AE100DelEmb = Deleta o Embarque, porém ao gerar nota de devolucao, o sistema deletava o embarque
                     // voltava o saldo para o pedido, mas não voltava para o pedido de venda.
                     AE100CanEmb(EEC->EEC_FILIAL,EEC->EEC_PREEMB)
                  EndIf

               ElseIf lExcItem

                  EE9->(DbSetOrder(1))
                  If SeekEE9("EE9",AvKey(cPedExp,"EE9_PEDIDO"),AvKey(cSequen,"EE9_SEQUEN"),AvKey(cNfOri,"EE9_NF"),AvKey(cSerieOri,"EE9_SERIE")) //EE9->(DbSeek(xFilial("EE9")+AvKey(cPedExp,"EE9_PEDIDO")+AvKey(cSequen,"EE9_SEQUEN")))

                     EE7->(DbSetOrder(1))
                     If EE7->(DbSeek(xFilial("EE7")+EE9->EE9_PEDIDO))
                        If (EE7->(FieldPos("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM )
                           AE100GrvItSD2(EE9->EE9_PEDIDO,EE9->EE9_SEQUEN," ",EE9->EE9_NF,EE9->EE9_SERIE)
                        EndIf
                     EndIf

                     Aadd(aNFApaga,AvKey(EE9->EE9_NF,"EEM_NRNF")+AvKey(EE9->EE9_SERIE,"EEM_SERIE"))

                     If lIntDraw .and. lOkEE9_ATO .and. !Empty(EE9->EE9_ATOCON) .and. !Empty(EE9->EE9_SEQED3)

                        ED3->(DbSeTorder(2))
                        If ED3->(dbSeek(xFilial("ED3")+EE9->EE9_ATOCON+EE9->EE9_SEQED3))
                           If !ED3->( IsLocked() )
                              ED3->(RECLOCK("ED3",.F.))
                           EndIf
                           ED3->ED3_SALDO += EE9->EE9_QT_AC
                           ED3->ED3_SALNCM += AVTransUnid(ED3->ED3_UMPROD,ED3->ED3_UMNCM,ED3->ED3_PROD,EE9->EE9_QT_AC)
                           EEC->(DbSetOrder(1))
                           If EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB ))
                              If(EEC->EEC_COBCAM=="1",ED3->ED3_SAL_CO+=EE9->EE9_VL_AC,ED3->ED3_SAL_SE+=EE9->EE9_VL_AC)
                           Endif
                           ED3->(msUnlock())
                        Endif

                     EndIf

                     MSMM(EE9->EE9_DESC,,,,EXCMEMO)
                     EE9->(RecLock("EE9",.F.))
                     nQtde := EE9->EE9_SLDINI
                     EE9->(dbDelete())
                     EE9->(MSUnlock())

                     //AE100Saldo(cPedExp,cSequen,nQtde,.T.)

                  EndIf

               EndIf

            Else

               aWorks := Ae102SetWorks()

               //Carrega variáveis de Memória e Works
               For nInc2 := 1 TO EEC->(FCount())
                  M->&(EEC->(FIELDNAME(nInc2))) := EEC->(FieldGet(nInc2))
               Next nInc2
               M->EEC_VVLIE:= "" //campo virtual

               M->EEC_MARCAC := MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
               M->EEC_OBS    := MSMM(EEC->EEC_CODMEM,AVSX3("EEC_OBS",AV_TAMANHO),,,LERMEMO)
               M->EEC_GENERI := MSMM(EEC->EEC_DSCGEN,AVSX3("EEC_GENERI",AV_TAMANHO),,,LERMEMO)
               M->EEC_OBSPED := MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO),,,LERMEMO)

	           If EEC->(FieldPos("EEC_INFGER")) # 0 //AAF 22/05/2015 - Inicializar este memo caso exista.
			      M->EEC_VMINGE := MSMM(EEC->EEC_INFGER,AVSX3("EEC_VMINGE",AV_TAMANHO),,,LERMEMO)
               EndIf

               lConsolOffShore := ((M->EEC_INTERM $ cSim) .And. lConsolida)

               AE102LoadEmb(cEmbarque)

               If !lExcDevTot 
                  WorkIp->(DbGoTop())
                  //While WorkIp->(!EOF())
                  If SeekEE9("WorkIp",AvKey(cPedExp,"EE9_PEDIDO"),AvKey(cSequen,"EE9_SEQUEN"),AvKey(cNfOri,"EE9_NF"),AvKey(cSerieOri,"EE9_SERIE"))
                     //If WorkIp->EE9_SEQUEN == cSequen
                        //Ajusta a quantidade
                        If lExclui
                           WorkIp->EE9_SLDINI := WorkIp->EE9_SLDINI + nQtdDev //Qtde da NF de Saída + Qtde da NF de Devolução
                        Else
                           WorkIp->EE9_SLDINI := WorkIp->EE9_SLDINI - nQtdDev //Qtde da NF de Saída - Qtde da NF de Devolução
                        EndIf
                     //EndIf
                     //WorkIp->(DbSkip())
                  EndIf
                  //EndDo
               EndIf

               If lExclui .And. M->EEC_STATUS == ST_PC //Cancelado
                  M->EEC_STATUS := IIF(Empty(M->EEC_DTENDC), ST_DC,ST_AE)
                  M->EEC_FIM_PE := AVCTOD("")
               EndIf
               //Altera o Embarque
               Ae102SetGrvEmb(.F.,.T.)

               //Deleta as Woks
               Ae102DelWorks(aWorks)
            EndIf

            //Grava Campos de Devolução no EES
            If EES->(FieldPos("EES_QTDDEV")) > 0 .and. EES->(FieldPos("EES_VALDEV")) > 0
               EES->(DbSetOrder(1))
               If EES->(DbSeek(xFilial("EES")+AvKey(cEmbarque,"EES_PREEMB")+AvKey(cNfOri,"EES_NRNF")))
                  While EES->(!EOF()) .and. EES->(EES_FILIAL+EES_PREEMB+EES_NRNF) == xFilial("EES")+AvKey(cEmbarque,"EES_PREEMB")+AvKey(cNfOri,"EES_NRNF")
                     If EES->EES_SEQUEN == AvKey(cSequen,"EES_SEQUEN") .and. EES->EES_SERIE == AvKey(cSerieOri,"EES_SERIE")
                        If lDevTotal
                           If lExcItem
                              EEM->(DbSetOrder(1))
                              If EEM->(DbSeek(xFilial("EEM")+EES->EES_PREEMB+EEM_NF+EES->EES_NRNF))
                                 EEM->(RecLock("EEM",.F.))
                                 EEM->EEM_VLNF   -= EES->EES_VLNF
                                 EEM->EEM_VLMERC -= EES->EES_VLMERC
                                 EEM->EEM_VLFRET -= EES->EES_VLFRET
                                 EEM->EEM_VLSEGU -= EEM->EEM_VLSEGU
                                 EEM->EEM_VLNFM  -= EES->EES_VLNFM
                                 EEM->EEM_VLMERM -= EES->EES_VLMERM
                                 EEM->EEM_VLFREM -= EES->EES_VLFREM
                                 EEM->EEM_VLSEGM -= EEM->EEM_VLSEGM

                                 //Verifica se o EEM foi zerado, e em caso positivo deleta.
                                 If Empty(EEM->EEM_VLNF)
                                    EEM->(DbDelete())
                                 EndIf

                                 EEM->(MsUnlock())
                              EndIf

                              EES->(RecLock("EES",.F.))
                              EES->(DbDelete())
                              EES->(MsUnlock())
                           Else
                              EES->(RecLock("EES",.F.))
                              EES->EES_QTDDEV += nQtdDev
                              EES->EES_VALDEV += nValDev / BuscaTaxa(cMoeda,dDataBase)
                              EES->(MsUnlock())
                           EndIf
                        Else
                           EES->(RecLock("EES",.F.))
                           If lExclui
                              EES->EES_QTDDEV -= nQtdDev
                              EES->EES_VALDEV -= nValDev / BuscaTaxa(cMoeda,dDataBase)
                           Else
                              EES->EES_QTDDEV += nQtdDev
                              EES->EES_VALDEV += nValDev / BuscaTaxa(cMoeda,dDataBase)
                           EndIf
                           EES->(MsUnlock())
                        EndIf
                     EndIf
                     EES->(DbSkip())
                  EndDo
               EndIf
            EndIf
         EndIf
      EndIf

   Else //Tratamento por Nota Fiscal de Saída - !lItem

      //Data de Embarque Preenchida
      If lDtEmba

         //Cria a Work "TMP" e carrega variáveis de memória para utilizar o tratamento do EECAF200.prw

         //Obs: O Código abaixo foi diretamente retirado do fonte EECAF200.prw

         aAdd(aSemSX3,{"TMP_RECNO","N",07,0})

         aAdd(aSemSX3,{"TMP_PARC" ,"C",03,0})

         cWORKEEQ  := E_CRIATRAB("EEQ",aSemSX3,"TMP")
         INDREGUA("TMP",cWORKEEQ+TEOrdBagExt(),"EEQ_PARC" ,"AllwayTrue()","AllwaysTrue()","Processando Arquivo Temporario")

         cWORKEEQ2  := CRIATRAB(,.F.)
         INDREGUA("TMP",cWORKEEQ2+TEOrdBagExt(),"EEQ_ORIGEM" ,"AllwayTrue()","AllwaysTrue()","Processando Arquivo Temporario")

         cWorkEEQ5  := CriaTrab(,.F.)
         IndRegua("TMP",cWorkEEQ5+TEOrdBagExt(),"EEQ_PARVIN+EEQ_PARC","AllwayTrue()","AllwaysTrue()","Processando Arquivo Temporario")

         If EECFlags("FRESEGCOM")
            cWorkEEQ6  := CriaTrab(,.f.)
            IndRegua("TMP",cWorkEEQ6+TEOrdBagExt(),"EEQ_EVENT","AllwayTrue()","AllwaysTrue()","Processando Arquivo Temporario")
            Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt()),(cWorkEEQ6+TEOrdBagExt())
         Else
            Set Index to (cWORKEEQ+TEOrdBagExt()),(cWORKEEQ2+TEOrdBagExt()),(cWORKEEQ5+TEOrdBagExt())
         EndIf

         //Carrega "TMP"
         EEQ->(DBSETORDER(1))
         EEQ->(DBSEEK(XFILIAL("EEQ")+cEmbarque))

         Do While ! EEQ->(EOF()) .AND.;
                    EEQ->(EEQ_FILIAL+EEQ_PREEMB) = (XFILIAL("EEQ")+cEmbarque)

            If lPagtoAnte
               If EEQ->EEQ_TIPO = "A" // Verifica se o lançamento é um adiantamento.
                  IF !EECFlags("FRESEGCOM") .Or. EEQ->EEQ_FASE <> "E"
                     EEQ->(DbSkip())
                     Loop
                  EndIf
               Endif
            EndIf
            
             TMP->(DBAPPEND())
            AVREPLACE("EEQ","TMP")
            TMP->TMP_RECNO := EEQ->(RecNo())

            If EECFlags("FRESEGCOM")
               TMP->EEQ_VLFCAM := Round((TMP->EEQ_VL-TMP->EEQ_CGRAFI),2)
            EndIf

            If lExclui
               If EEQ->EEQ_EVENT == "802" .and. Left(EEQ->EEQ_OBS,AVSX3("EE9_NF",AV_TAMANHO)) == /*cNFOri*/ AvKey( AllTrim(cNfOri)+"-"+AllTrim(cSerieOri) , "EE9_NF")
                  cParcDel := EEQ->EEQ_PARC
                  aDadosEv802 := {}
                  FOR i:=1 To EEQ->(Fcount())
                     aAdd(aDadosEv802, &("EEQ->"+EEQ->(FIELDNAME(i)) ) )
                  Next i               
               EndIf
            EndIf
            
            //NCF - 04/08/2017
            If EEQ->EEQ_EVENT == '101' .OR. EEQ->EEQ_EVENT == '603'
               nLastPr101 := TMP->(Recno())
            EndIf
            cLastPrCmb := EEQ->EEQ_PARC 
            
            EEQ->(DBSKIP())
         EndDo

         If lExclui
            TMP->(DbSetOrder(1))
            If !Empty(cParcDel)
               If TMP->(DbSeek(cParcDel))
               
                  //Restaura o valor descontado em outras Parcelas
                  Af201DelDiscount()

                  If !Empty(TMP->TMP_RECNO)
                     aAdd(aDel,{TMP->TMP_RECNO,cEmbarque})
                  EndIf

                  TMP->(RecLock("TMP",.F.,.T.))
                  TMP->(dbDelete())
                  TMP->(msUnlock())
               EndIf
            EndIf

         ElseIf ValType(nLastPr101) == "N"
            TMP->(dbGoto(nLastPr101)) //NCF - 04/08/2017 - Posicionar na última parcela 101 para carregar dados.
            //Carrega as Varíaveis de Memória com os Dados da Parcela de Câmbio de Desconto
            For nInc2 := 1 To TMP->(FCount())
               M->&(TMP->(FieldName(nInc2))) := TMP->(FieldGet(nInc2))
            Next

            If EECFlags("FRESEGCOM")
               M->EEQ_DESIMP := Posicione("SA1",1,xFilial("SA1")+cImport,"A1_NREDUZ")
            EndIf

            M->EEQ_EVENT  := "802"
            M->EEQ_NRINVO := cEmbarque
            M->EEQ_PARC   := SomaIt(cLastPrCmb)                   //NCF - 03/08/2017
            M->EEQ_VCT    := dDataBase
            M->EEQ_PARVIN := TMP->EEQ_PARVIN
            M->EEQ_MOEDA  := cMoeda
            M->EEQ_PARI   := 1
            M->EEQ_VL     := nValDev / TxDevolucao(cMoeda, cNfOri, cSerieOri, M->EEQ_IMPORT, M->EEQ_IMLOJA)//BuscaTaxa(cMoeda,dDataBase)
            M->EEQ_FINNUM := ""                                   //NCF - 03/08/2017
            M->EEQ_CGRAFI := 0 //Zerar o valor para não duplicar
            M->EEQ_AREMET := 0
            M->EEQ_ADEDUZ := 0
            aDeletados := {}
           
            If EECFlags("FRESEGCOM")
               Af201AddDiscount(M->EEQ_EVENT,INC_DET)
            EndIf

            //Apaga Registros da tabela EEQ.
            If Len(aDeletados) > 0
               TMP->(dbCloseArea()) //Fecha a work antes de iniciar a integracao para nao dar conflito com works do contabil
               For nInc2:=1 To Len(aDeletados)
                  EEQ->(DbGoTo(aDeletados[nInc2]))
                  
                  If IsIntEnable("001") .And. !Empty(EEQ->EEQ_FINNUM) //NCF - 07/08/2017 - Deletar os títulos antes de deletar o câmbio
                     If EEQ->EEQ_EVENT == "101"    
                        AvStAction("007")   
                     EndIf
                  EndIf
                  
                  EEQ->(RecLock("EEQ",.F.))
                  EEQ->(DbDelete())
                  EEQ->(MsUnlock())
                  
               Next
               If Select("TMP") > 0
                  TMP->(dbCloseArea()) //Fecha a work, pois pode ser a work criada durante a integração
               EndIf
            EndIf
            //Caso a work seja fechada durante alguma integração, força a reabertura.
            If Select("TMP") == 0
                  Af200AbTmp()
            EndIf
            TMP->(DbAppend())

            Af201SetVlFCam()

            AvReplace("M","TMP")

            TMP->TMP_RECNO := 0

            If Empty(TMP->EEQ_ORIGEM)
               TMP->EEQ_PARVIN := TMP->EEQ_PARC
               TMP->TMP_PARC   := TMP->EEQ_PARVIN
            EndIf

         EndIf

         If lExclui
            For nInc2 := 1 to Len(aDel)
               If aDel[nInc2][2] == cEmbarque

                  EEQ->(DbGoTo(aDel[nInc2][1]))

                  EEQ->(RecLock("EEQ",.F.))
                  EEQ->(DbDelete())
                  EEQ->(MsUnlock())
               EndIf
            Next
         EndIf
         
         TMP->(DbGoTop())
         Do While TMP->(!EOF())
            nRecAbTmp := TMP->(Recno())
            If TMP->TMP_RECNO == 0
               EEQ->(RecLock("EEQ",.T.))

               AvReplace("TMP","EEQ")
               
               If lExclui .And. TMP->EEQ_EVENT == "101"
                  FOR i:=1 To EEQ->(Fcount())
                     &("EEQ->"+EEQ->(FIELDNAME(i))) := aDadosEv802[i] 
                  Next i 
                  EEQ->EEQ_EVENT := "101" 
               EndIf

               If lPagtoAnte
                    EEQ->EEQ_FASE := "E"
               EndIf

               EEQ->EEQ_TIPO   := If(EEQ->EEQ_EVENT == "101","R","P")
               EEQ->EEQ_PREEMB := cEmbarque
               EEQ->EEQ_OBS    := AllTrim(cNfOri)+"-"+AllTrim(cSerieOri)

               If TMP->EEQ_NROP <> EEQ->EEQ_NROP
                  EEQ->EEQ_NROP := TMP->EEQ_NROP
               EndIf
               
               //EEQ->(msUnlock())
               
               If IsIntEnable("001") .And. Empty(EEQ->EEQ_FINNUM) //NCF - 07/08/2017 - Incluir o título após incluir nova parcela de 101
                  If EEQ->EEQ_EVENT == "101"   
                     TMP->(dbCloseArea()) //Fecha a work, pois pode ser a work criada durante a integração
                     AvStAction("005")
                  EndIf   
               EndIf
               EEQ->(msUnlock())
            Else
               EEQ->(dbGoTo(TMP->TMP_RECNO))

               EEQ->(RecLock("EEQ",.F.))
               AvReplace("TMP","EEQ")
               EEQ->(msUnlock())
               If aScan(aFat3Alt, {|x| x == TMP->(recno())} ) > 0
                  If EEQ->EEQ_EVENT == "101"
                     TMP->(dbCloseArea()) //Fecha a work, pois pode ser a work criada durante a integração
                     AvStAction("006")  //NCF - 07/08/2017 - Alterar o título a receber com o novo valor
                  EndIf
               EndIf
            Endif
            //Caso a work seja fechada durante alguma integração, força a reabertura.
            If Select("TMP") > 0
               TMP->(dbCloseArea()) //Fecha a work, pois pode ser a work criada durante a integração
            EndIf
            If Select("TMP") == 0
                  Af200AbTmp()
                  TMP->(DbGoTo(nRecAbTmp))
            EndIf
            //NCF - 04/08/2017
            If TMP->EEQ_EVENT == '802' .And.  EEQ->EEQ_EVENT == '802'
               TMP->TMP_RECNO := EEQ->(Recno())
               nRecEEQ802     := EEQ->(Recno())
            EndIf

            Tmp->(DbSkip())
         EndDo

      EndIf
   EndIf
End Sequence

If Select("TMP") > 0
   If EECFlags("FRESEGCOM")
      //TMP->(E_EraseArq("TMP",cWorkEEQ,cWorkEEQ2,cWorkEEQ5,cWorkEEQ6))
      E_EraseArq(cWorkEEQ,cWorkEEQ2,cWorkEEQ5)
   Else
      //TMP->(E_EraseArq("TMP",cWorkEEQ,cWorkEEQ2,cWorkEEQ5))
      E_EraseArq(cWorkEEQ,cWorkEEQ2,cWorkEEQ5)
   EndIf
EndIf

nModulo := nOldMod
cModulo := cOldMod

RestOrd(aOrd)

Return lRet

/*
Funcao      : FAT3VerNFDev()
Parametros  : cEmbarque,cNF,cSerie,cFatIt
Retorno     : nRet - Quantidade Devolvida
Objetivos   : Verifica se existe quantidade devolvida para o Embarque
Autor       : Eduardo C. Romanini
Data/Hora   : 06/03/2007 10:45
Obs.        :
*/
*------------------------------------------------*
Function FAT3VerNFDev(cEmbarque,cNF,cSerie,cFatIt)
*------------------------------------------------*
Local nRet := 0

Local lTemParc := .F.

Begin Sequence

   //Verifica se Existe quantidade devolvida.
   SD2->(DbSetOrder(3))
   If SD2->(DbSeek(xFilial("SD2")+cNF+cSerie))
      While SD2->(!EOF()) .and. SD2->(D2_FILIAL + D2_DOC + D2_SERIE) == xFilial("SD2")+cNF+cSerie
         If SD2->D2_ITEM == cFatIt
            If SD2->D2_QTDEDEV > 0
               nRet := SD2->D2_QTDEDEV
            EndIf
            Exit
         EndIf
         SD2->(DbSkip())
      EndDo
   EndIf

   //Verifica se tem Parcela de Câmbio criada através da manutenção de NFs de Devolução.
   EEQ->(DbSetOrder(1))
   If EEQ->(DbSeek(xFilial("EEQ")+cEmbarque))
      While EEQ->(!EOF()) .and. EEQ->(EEQ_FILIAL + EEQ_PREEMB) == xFilial("EEQ")+cEmbarque
         If EEQ->EEQ_EVENT == "802"
            If Left(EEQ->EEQ_OBS,AVSX3("EE9_NF",AV_TAMANHO)) == cNF
               lTemParc := .T.

               //Apaga a Parcela de Devolução
               EEQ->(RecLock("EEQ",.F.))
               EEQ->(DbDelete())
               EEQ->(MsUnlock())

            EndIf
         EndIf
         EEQ->(DbSkip())
      EndDo
   EndIf

   //Se não existir Parcela de Câmbio para a NF de Devolução o Embarque não será atualizado.
   If !lTemParc
      nRet := 0
   EndIf

End Sequence

Return nRet

/*
Funcao      : FAT3EmbGerPV
Parametros  : nOpc: Operação realizada no Embarque:
                    3 - INCLUIR,
                    4 - ALTERAR,
                    5 - EXCLUIR
              cTipo: Operação que será realizada para a geração do Pedido de Venda:
                     "VLD" - Validação,
                     "GRV" - Gravação.
Retorno     : lRet
Objetivos   : Essa função irá validar e gravar um Pedido de Venda no módulo de Faturamento (SigaFat) a partir do Embarque,
              quando o fluxo de integração alternativa (MV_AVG0141) estiver habilitado.
Autor       : Eduardo C. Romanini
Data/Hora   : 13/05/2008 10:45
Obs.        : Essa função é chamada a partir do fonte EECAE100.prw
*/
*-------------------------------*
Function FAT3EmbGerPV(nOpc,cTipo)
*-------------------------------*
Local lRet := .F.

Local aOrd := SaveOrd({"EEC"})

Private lEECAuto  := EasyGParam("MV_EECAUTO",.F.,.F.)

If( aStrSC5 = Nil , aStrSC5 := SC5->(dbStruct()) , )
If( aStrSC6 = Nil , aStrSC6 := SC6->(dbStruct()) , )
If( aStrEEC = Nil , aStrEEC := EEC->(dbStruct()) , )
If( aStrEE9 = Nil , aStrEE8 := EE9->(dbStruct()) , )

Begin Sequence

   /////////////
   //Validação//
   /////////////
   If cTipo == "VLD"
      lRet := FAT3ValPV(nOpc)

      If !lRet
         Break
      Endif

   ////////////
   //Gravacao//
   ////////////
   Elseif cTipo == "GRV"
      If Empty(M->EEC_FATURA)
         lRet := .T.
         Break
      Endif

      lRet := FAT3GravaPV(nOpc)

   /////////////////////////////////
   //Mensagem no Final da Gravação//
   /////////////////////////////////
   ElseIf cTipo == "MSG"
      If nOpc == INCLUIR
         If Empty(M->EEC_FATURA)
            lRet := .T.
            Break
         Endif

         If !lEECAuto
            EECMsg(STR0014 + Transf(M->EEC_PEDFAT,AVSX3("C5_NUM",AV_PICTURE)), STR0013) //"Número do Pedido no Faturamento: "###"Aviso"
         Endif
      Endif
      lRet := .t.

   Else
      lRet := .t.

   Endif

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : FAT3ValPV
Parametros  : nOpc: Operação realizada no Embarque:
                    3 - INCLUIR,
                    4 - ALTERAR,
                    5 - EXCLUIR
Retorno     : lRet
Objetivos   : Essa função irá verificar se um Pedido de Venda poderá ser gerado no módulo de Faturamento (SigaFat) a partir do Embarque,
              quando o fluxo de integração alternativa (MV_AVG0141) estiver habilitado.
Autor       : Eduardo C. Romanini
Data/Hora   : 13/05/2008 15:45
Obs.        :
*/
*----------------------*
Function FAT3ValPV(nOpc)
*----------------------*
Local lRet  := .T.

Local cItem := "00"

Local aOrd  := SaveOrd({"WorkIP","SA1","SY6","SYF","SC6"})

Begin Sequence

   /////////////////////////////////
   //Valida o Importador utilizado//
   /////////////////////////////////
   SA1->(DbSetOrder(1))
   If !SA1->(DbSeek(xFilial("SA1")+M->EEC_IMPORT+M->EEC_IMLOJA))
      EECHelp(" ",1,"AVG0005023") //MsgStop("Importador não cadastrado !","Aviso")
      lRet := .f.
      Break
   Endif

   M->EEC_FATURA := dDataBase

   ////////////////////////////////////////////////////////////////////
   //Verifica se será gerado Pedido de Venda para Embarque de Amostra//
   ////////////////////////////////////////////////////////////////////
   If M->EEC_AMOSTR == "1"  // GFP - 15/06/2015
      //If !EECMsg("Deseja registrar Amostra no SIGAFAT ?", "Integração", "MsgNoYes") //"Deseja registrar Amostra no SIGAFAT ?"###"Integração"
         M->EEC_FATURA := CTOD("")
      //EndIf

   Else

      ////////////////////////////////////
      //Verifica a Condição de Pagamento//
      ////////////////////////////////////
      SY6->(DbSetOrder(1))
      If SY6->(DbSeek(xFilial("SY6")+AvKey(M->EEC_CONDPA,"Y6_COD")+AvKey(M->EEC_DIASPA,"Y6_DIAS_PA")))
         If Empty(SY6->Y6_SIGSE4)
            EECHelp(" ",1,"AVG0005024") //MsgStop("O campo Cond.Pagto no SIGA não foi digitado no cadastro de Cond.Pagto","Aviso")
            lRet := .F.
            Break
         EndIf
      EndIf

      ////////////////////
      //Verifica a Moeda//
      ////////////////////
      SYF->(DbSetOrder(1))
      If SYF->(DbSeek(xFilial("SYF")+AvKey(M->EEC_MOEDA,"YF_MOEDA")))
         If Empty(SYF->YF_MOEFAT)
            EECHelp(" ",1,"AVG0005025") //MsgStop("O campo Moeda no SIGA  não foi digitado no cadastro de Moedas","Aviso")
            lRet := .F.
            Break
         EndIf
      EndIf

   EndIf

   cItem := SeqItem(cItem)

   WorkIp->(dbGoTop())
   While WorkIp->(!Eof())

      ////////////////////////////////////////////////////////////
      //Verifica se excedeu o limite de itens do Pedido de Venda//
      ////////////////////////////////////////////////////////////
      If cItem > "Z9"
         EECHelp(" ",1,"AVG0005026") //MsgStop("Excedeu o limite de itens do SIGAFAT !")
         lRet := .F.
         Break
      Endif

      cItem := SomaIt(cItem)

      WorkIp->(dbSkip())
   Enddo

   ////////////////////////////////////////////////////////////////////////////////
   //Ponto de Entrada para adição de validações para a geração do Pedido de Venda//
   ////////////////////////////////////////////////////////////////////////////////
   If EasyEntryPoint("EECFAT3")
      ExecBlock("EECFAT3",.F.,.F.,{"PE_VALID"})
   Endif

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : FAT3GravaPV
Parametros  : nOpc: Operação realizada no Embarque:
                    3 - INCLUIR,
                    4 - ALTERAR,
                    5 - EXCLUIR
Retorno     : lRet
Objetivos   : Essa função irá gerar um Pedido de Venda no módulo de Faturamento (SigaFat) a partir do Embarque,
              quando o fluxo de integração alternativa (MV_AVG0141) estiver habilitado.
Autor       : Eduardo C. Romanini
Data/Hora   : 13/05/2008 10:45
Obs.        :
*/
*------------------------*
Function FAT3GravaPV(nOpc)
*------------------------*
Local lRet      := .T.
Local lConvUnid := (EEC->(FieldPos("EEC_UNIDAD")) <> 0) .And. (EE9->(FieldPos("EE9_UNPES")) <> 0) .And. (EE9->(FieldPos("EE9_UNPRC")) <> 0)
Local lDelItem  := .F.
Local lGeraLog  := EasyGParam("MV_EECFLOG",, .F.)
Local lTESEmb   := EE9->(FieldPos("EE9_TES")) <> 0 .and.  EE9->(FieldPos("EE9_CF")) <> 0
Local lSegUnMed := .F.

Local cCampo    := ""
Local cCpoComum := ""
Local cCpoEEC   := ""
Local cCpoEE9   := ""
Local cItem     := "00"
Local cUnidade  := ""
Local cTES      := ""
Local cPedido   := ""
Local cPedFat   := ""
Local cSequen   := ""
Local cItPedPai := ""

Local nInd       := 0
Local nInc       := 0
Local nPos       := 0
Local nQtdUniMed := 0
Local nPrcUniMed := 0
Local nQtdVen    := 0

Local bVar

Local dEntrega

Local aOrd   := SaveOrd({"WorkIp","SA1","SY6","WorkIn","SYF","EE7","EE8","SC6"})
Local aPVatu := {}

Local lMoedTit:= AllTrim(EasyGParam("MV_MOEDTIT",,"N")) == "S" .And.;
                   SC5->(FieldPos("C5_MOEDTIT")) > 0

Private aCab        := {}
Private aItens      := {}
Private aReg        := {}
Private aSC6NaoAlt  := {"C6_OP","C6_NUMOP","C6_ITEMOP"} //Campos dos Itens do PV que não deverão ter seu valor alterado na integração.

Private lMSErroAuto := .F.
Private lMSHelpAuto := .F.

Begin Sequence

   ////////////////////////////////////////////////////////////
   //Ponto de Entrada para rotina adicional antes da montagem//
   //dos arrays para integração com o Faturamento.           //
   ////////////////////////////////////////////////////////////
   If EasyEntryPoint("EECFAT3")
      ExecBlock("EECFAT3",.F.,.F.,{"PE_ANTES_INT",nOpc})
   EndIf

   //////////////////////////////////////////////////////////
   //Incio da Gravação dos dados da Capa do Pedido de Venda//
   //////////////////////////////////////////////////////////
   If nOpc == INCLUIR
      If lEECAuto
         aAdd(aCab,{"C5_NUM",AvKey(M->EEC_PREEMB,"C5_NUM"),nil}) // Nro.do Pedido de Venda
      Else
         aAdd(aCab,{"C5_NUM",,nil}) // Nro.do Pedido de Venda
      EndIf
   Else
      aAdd(aCab,{"C5_NUM",M->EEC_PEDFAT,nil})
   EndIf

   aAdd(aCab,{"C5_TIPO","N",nil}) //Tipo de Pedido - "N"-Normal

   SA1->(DbSetOrder(1))
   If SA1->(DbSeek(xFilial("SA1")+M->EEC_IMPORT+M->EEC_IMLOJA))
      aAdd(aCab,{"C5_CLIENTE",SA1->A1_COD,nil})  //Cod. Cliente
      aAdd(aCab,{"C5_LOJACLI",SA1->A1_LOJA,nil}) //Loja Cliente
      aAdd(aCab,{"C5_TIPOCLI","X",nil}) //Tipo Cliente
   EndIf

   SY6->(DbSetOrder(1))
   If SY6->(DbSeek(xFilial("SY6")+M->EEC_CONDPA+AvKey(M->EEC_DIASPA,"Y6_DIAS_PA")))
      aAdd(aCab,{"C5_CONDPAG",SY6->Y6_SIGSE4,nil}) //Condição de Pagamento
   EndIf

   If WorkIn->(dbSeek("J"))
      aAdd(aCab,{"C5_BANCO",WorkIn->EEJ_CODIGO,nil}) // Banco
   Endif

   aAdd(aCab,{"C5_EMISSAO",M->EEC_DTPROC,nil}) //Data de Emissão

   SYF->(DbSetOrder(1))
   If SYF->(DbSeek(xFilial("SYF")+M->EEC_MOEDA))
      aAdd(aCab,{"C5_MOEDA",SYF->YF_MOEFAT,nil}) //Moeda
   EndIf

   aAdd(aCab,{"C5_PESOL",M->EEC_PESLIQ,nil}) //Peso Liquido

   aAdd(aCab,{"C5_PBRUTO",M->EEC_PESBRU,nil}) //Peso Bruto

   aAdd(aCab,{"C5_PEDEXP",M->EEC_PREEMB,nil}) //Embarque

   If EECFlags("COMMODITY")
      aAdd(aCab,{"C5_REAJUST",EasyGParam("MV_AVG0111",,SPACE(3)),nil}) //Campo Formula
   Endif

   aAdd(aCab,{"C5_FRETE"  ,M->EEC_FRPREV + M->EEC_FRPCOM,nil}) //Valor do Frete

   aAdd(aCab,{"C5_SEGURO" ,M->EEC_SEGPRE,nil}) //Valor do Seguro

   aAdd(aCab,{"C5_DESPESA",M->EEC_DESPIN,nil}) //Valor de Despesas Adicionais

   //Geração de títulos na moeda estrangeira
   If lMoedTit
      AAdd(aCab,{"C5_MOEDTIT", Posicione("SYF", 1,xFilial("SYF") + M->EEC_MOEDA, "YF_MOEFAT"), Nil})
   EndI
   ////////////////////////////////////////////////////////////////////////////
   //Adiciona no array aCab os Campos que possuem a mesma terminação de nomes//
   //na tabela EEC (Capa do Embarque) e SC5(Cada do Pedido de Venda).        //
   ////////////////////////////////////////////////////////////////////////////
   For nInd := 1 To Len(aStrSC5)
      cCampo := aStrSC5[nInd][1]

      If aScan(aCab,{|x| x[1] == cCampo }) == 0 .And. !("FILIAL"$cCampo)
         cCpoComum := SubStr(cCampo,4)
         cCpoEEC   := Left("EEC_" + cCpoComum,10)

         If (nPos := aScan(aStrEEC,{|x| x[1] = cCpoEEC }) ) > 0

            If aStrEEC[nPos][2] = aStrSC5[nInd][2] .And.;
               aStrEEC[nPos][3] = aStrSC5[nInd][3] .And.;
               aStrEEC[nPos][4] = aStrSC5[nInd][4]

               cCpoEEC := "M->" + cCpoEEC

               bVar := MemVarBlock(SubStr(cCpoEEC,4))
               If ValType(bVar) == "B"
                  Aadd(aCab,{cCampo,Eval(bVar),Nil })
               EndIf

            EndIf
         EndIf
      EndIf
   Next

   //////////////////////////////////////////////////////
   //Ponto de Entrada para inclusão/alteração de campos//
   //a serem integrados na capa do Pedido de Venda     //
   //////////////////////////////////////////////////////
   If EasyEntryPoint("EECFAT3")
      ExecBlock("EECFAT3",.F.,.F.,{"PE_GRVCAPA",nOpc})
   Endif

   ///////////////////////////////////////////////////////////
   //Incio da Gravação dos dados de Itens do Pedido de Venda//
   ///////////////////////////////////////////////////////////
   aItens := {}

   cItem := SeqItem(cItem)

   WorkIp->(DbGoTop())
   While WorkIp->(!EOF())

      aReg   := {}

      If SB1->(DbSeek(xFilial("SB1")+WorkIp->EE9_COD_I))

         //WFS 27/05/2010
         lSegUnMed:= If(AllTrim(WorkIp->EE9_UNIDAD) == AllTrim(SB1->B1_SEGUM), .T., .F.)

         If ! SB2->(DbSeek(xFilial("SB1")+SB1->B1_COD+SB1->B1_LOCPAD))
            CriaSB2(SB1->B1_COD,SB1->B1_LOCPAD)
         Endif
      Endif

      //////////////////////////////////////////////////////////////////////////////////////
      //Caso o item tenha não esteja marcado e não tenha sido previamente gravado na base,//
      //  não será realizada a integração.                                                //
      //////////////////////////////////////////////////////////////////////////////////////
      If Empty(WorkIP->WP_FLAG) .and. WorkIP->WP_RECNO == 0
         WorkIp->(DbSkip())
         Loop
      EndIf

      /////////////////////////////////////////////////////////////////////////
      //Caso o mesmo item do Pedido de Venda tenha sido quebrado no Embarque,//
      //este será consolidado em apenas um.                                  //
      /////////////////////////////////////////////////////////////////////////
      nPos := aScan(aItens,{|x| x[2][2]==WorkIp->EE9_FATIT})

      If nPos > 0
         If !Empty(WorkIp->EE9_NF)
            aItens[nPos][5][2] += WorkIp->EE9_SLDINI
         EndIf
      Else

         aAdd(aReg,{"C6_NUM",aCab[1][2],nil}) //Pedido de Venda

         If !Empty(WorkIp->EE9_FATIT)
            aAdd(aReg,{"C6_ITEM",WorkIp->EE9_FATIT,nil}) // Item Sequencial
         Else
            aAdd(aReg,{"C6_ITEM",cItem,nil}) // Item Sequencial
         EndIf

         aAdd(aReg,{"C6_PRODUTO",WorkIp->EE9_COD_I,nil}) // Cod.Item

         nQtdVen  := WorkIp->EE9_SLDINI
         cUnidade := WorkIp->EE9_UNIDAD

         nPrcUniMed := WorkIp->EE9_PRECOI

         ////////////////////////////////////////////////////////////////////////////////
         //Converte o Preço para a Unidade de Medida do campo EE9_UNPRC (U.M. do Preço)//
         ////////////////////////////////////////////////////////////////////////////////
         If lConvUnid
            If !Empty(WorkIp->EE9_UNPRC) .And. WorkIp->EE9_UNPRC <> cUnidade
               nQtdUniMed := AvTransUnid(WorkIp->EE9_UNPRC,cUnidade,WorkIp->EE9_COD_I,1,.F.)
               nPrcUniMed := Round(WorkIp->EE9_PRECOI/nQtdUniMed,AvSx3("EE9_PRECOI",AV_DECIMAL))
            EndIf
         EndIf

         //WFS 27/05/2010
         //Conversão da segunda unidade de medida, conforme o cadastro do produto.
         //Sempre será enviada a quantidade e o valor conforme a primeira unidade de medida.

         If lSegUnMed
            aAdd(aReg,{"C6_UNSVEN",nQtdVen,nil}) //DFS - 22/09/2011 - Inclusão de tratamento para segunda unidade de medida quando o PE for alterado
            Fat2SegUnidade(@cUnidade, @nQtdVen, @nPrcUniMed)
         EndIf


         aAdd(aReg,{"C6_UM",cUnidade,nil}) // Unidade

         //aAdd(aReg,{"C6_QTDVEN",WorkIp->EE9_SLDINI,nil}) // Quantidade nopado por WFS em 27/05/2010
         AAdd(aReg, {"C6_QTDVEN", nQtdVen, Nil})

         aAdd(aReg,{"C6_PRCVEN",nPrcUniMed,nil}) // Preco Unit. Venda

         aAdd(aReg,{"C6_PRUNIT",nPrcUniMed,nil}) // Preco Unit.

         cTES := "501"
         cCF  := "663"

         ////////////////////////////////////////////////////////////////////////////////////
         //Posiciona o Registro do Pedido de Exportação correspondente ao Item do Embarque,//
         //já que algumas informações necessárias para o Pedido de Venda existem apenas no //
         //Pedido de Exportação.                                                           //
         ////////////////////////////////////////////////////////////////////////////////////
         EE8->(DbSetOrder(1))
         If EE8->(DbSeek(xFilial("EE8")+WorkIp->EE9_PEDIDO+WorkIp->EE9_SEQUEN+WorkIp->EE9_COD_I))

            If !lTESEmb
               If !Empty(EE8->EE8_TES)
                  cTES := EE8->EE8_TES
               EndIf

               If !Empty(EE8->EE8_CF)
                  cCF  := EE8->EE8_CF
               EndIf

            Else
               If !Empty(WorkIp->EE9_TES)
                  cTES := WorkIp->EE9_TES
               EndIf

               If !Empty(WorkIp->EE9_CF)
                  cCF  := WorkIp->EE9_CF
               EndIf
            EndIf

            dEntrega := EE8->EE8_DTENTR

            If Empty(dEntrega)
               dEntrega := EE8->EE8_DTPREM
            EndIf

            cSequen   := EE8->EE8_SEQUEN
            cItPedPai := EE8->EE8_FATIT

            EE7->(DbSetOrder(1))
            If EE7->(DbSeek(xFilial("EE7")+EE8->EE8_PEDIDO))
               cPedido := EE7->EE7_PEDIDO
               cPedPai := EE7->EE7_PEDFAT
            EndIf

            ////////////////////////////////////////////////////
            //Array com os pedidos que deverão ser atualizados//
            ////////////////////////////////////////////////////
            If aScan(aPvAtu,cPedido) == 0
               aAdd(aPvAtu,cPedido)
            EndIf

         EndIf

         aAdd(aReg,{"C6_TES",cTES,nil}) // Tipo de Saida

         aAdd(aReg,{"C6_CF",cCF,nil})  // Classificacao Fiscal

         aAdd(aReg,{"C6_ENTREG",dEntrega,nil})  // Dt.Entrega

         aAdd(aReg,{"C6_VALDESC",Round(WorkIp->EE9_VLDESC,AvSX3("C6_VALDESC",AV_DECIMAL)),nil})  //Desconto

         If nOpc == INCLUIR
            //////////////////////////////////////////////////////////////////////////////////////////
            //Verifica se os campos do array aSC6NaoAlt estão preenchidos no Pedido de Venda.       //
            //Em Caso Positivo grava o seu valor no array aReg para que as informações desses campos//
            //não sejam alteradas no Pedido de Venda.                                               //
            //Porém no caso de inclusão as informações do array aSC6NaoAlt são copiadas do Pedido   //
            //de Venda Pai (Relacionado ao Pedido de Exportação.)                                   //
            //////////////////////////////////////////////////////////////////////////////////////////
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek(xFilial("SC6") + AvKey(cPedPai,"C6_NUM") + AvKey(cItpedPai,"C6_ITEM")))
               For nInc:=1 To Len(aSC6NaoAlt)
                 If !Empty(SC6->&(aSC6NaoAlt[nInc]))
                    aAdd(aReg,{aSC6NaoAlt[nInc],SC6->&(aSC6NaoAlt[nInc]),nil})
                 EndIf
               Next
            EndIf

         ElseIf nOpc == ALTERAR
            //////////////////////////////////////////////////////////////////////////////////////////
            //Verifica se os campos do array aSC6NaoAlt estão preenchidos no Pedido de Venda.       //
            //Em Caso Positivo grava o seu valor no array aReg para que as informações desses campos//
            //não sejam alteradas no Pedido de Venda.                                               //
            //////////////////////////////////////////////////////////////////////////////////////////
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek(xFilial("SC6") + AvKey(aCab[1,2],"C6_NUM") + AvKey(aReg[2,2],"C6_ITEM")))
               For nInc:=1 To Len(aSC6NaoAlt)
                  If !Empty(SC6->&(aSC6NaoAlt[nInc]))
                    aAdd(aReg,{aSC6NaoAlt[nInc],SC6->&(aSC6NaoAlt[nInc]),nil})
                 EndIf
               Next
            EndIf
         EndIf

         //////////////////////////////////////////////////////////////////////////
         //Indica se o Item será excluído ou incluido/alterado no Pedido de Venda//
         //////////////////////////////////////////////////////////////////////////
         If !Empty(WorkIP->WP_FLAG)
            aAdd(aReg,{"AUTDELETA","N",nil})
            lDelItem := .F.
         Else
            If WorkIP->WP_RECNO <> 0
               aAdd(aReg,{"AUTDELETA","S",nil})
               lDelItem := .T.
            EndIf
         EndIf

         ////////////////////////////////////////////////////////////////////////////
         //Adiciona no array aReg os Campos que possuem a mesma terminação de nomes//
         //na tabela EE9 (Itens do Embarque) e SC6(Itens do Pedido de Venda).      //
         ////////////////////////////////////////////////////////////////////////////
         For nInd := 1 TO Len(aStrSC6)
            cCampo := aStrSC6[nInd][1]

            If aScan(aReg,{|x| x[1] == cCampo }) == 0 .And. !("FILIAL"$cCampo)
               cCpoComum := SubStr(cCampo,4)
               cCpoEE9   := Left("EE9_" + cCpoComum,10)

              If ( nPos := aScan(aStrEE9,{|x| x[1] = cCpoEE9 }) ) > 0
                  If aStrEE9[nPos][2] = aStrSC6[nInd][2] .And.;
                     aStrEE9[nPos][3] = aStrSC6[nInd][3] .And.;
                     aStrEE9[nPos][4] = aStrSC6[nInd][4]

                     If WorkIp->(FieldPos(cCpoEE9)) > 0 .And. !Empty(WorkIp->(FieldGet(FieldPos(cCpoEE9))))
                        Aadd(aReg,{cCampo,WorkIp->(FieldGet(FieldPos(cCpoEE9))),Nil })
                     EndIf

                  EndIf
               EndIf
            EndIf
         Next

         If lDelItem

            /////////////////////////////////////////////////////////
            //Ponto de Entrada para rotina adicional na exclusão do//
            //item do Pedido de Venda                              //
            /////////////////////////////////////////////////////////
            If EasyEntryPoint("EECFAT3")
               ExecBlock("EECFAT3",.F.,.F.,{"PE_DELITEM",nOpc})
            EndIf

         Else

            //////////////////////////////////////////////////////
            //Ponto de Entrada para inclusão/alteração de campos//
            //a serem integrados nos itens do Pedido de Venda   //
            //////////////////////////////////////////////////////
            If EasyEntryPoint("EECFAT3")
               ExecBlock("EECFAT3",.F.,.F.,{"PE_GRVITEM",nOpc})
            Endif

         EndIf

         aAdd(aItens,aClone(aReg))

      EndIf

      If Empty(WorkIp->EE9_FATIT)
         WorkIp->EE9_FATIT := cItem
         cItem := SomaIt(cItem)
      EndIf

      lSegUnMed:= .F.
      WorkIp->(DbSkip())
   EndDo

   /////////////////////////////////
   //Ordena os Itens por Sequencia//
   /////////////////////////////////
   aSort(aItens,,,{ |x,y| x[2,2] < y[2,2] })

   ///////////////////
   //Gravação do Log//
   ///////////////////
   If lGeraLog
      LogFat(nOpc, aCab, aItens, "1")
   EndIf

   // WFS 26/05/2010 - Inversão da ordem de atualização/ criação de pedidos
   Begin Transaction

      ///////////////////////////////////////////////////////
      //Atualiza o saldo do Pedido de Venda Pai relacionado//
      ///////////////////////////////////////////////////////
      FAT3PVSaldo(aPvAtu,nOpc)


      ////////////////////////////////////////////////////
      //Integração com o Faturamento.                   //
      //Criação/Alteração/Exclusão do Pedido de Venda.  //
      ////////////////////////////////////////////////////
      lRet := AVMata410(aCab, aItens, nOpc, "EMB")

      If lMSErroAuto
         MostraErro()
         lRet := .F.
      EndIf

      If !lRet
         RollBackDelTran("")
      EndIf

   End Transaction


   ///////////////////
   //Gravação do Log//
   ///////////////////
   If lGeraLog
      LogFat(nOpc, aCab, aItens, "2")
   EndIf

   /* WFS 26/05/2010 - Inversão da ordem de atualização/ criação de pedidos

   ///////////////////////////////////////////////////////
   //Atualiza o saldo do Pedido de Venda Pai relacionado//
   ///////////////////////////////////////////////////////
   If lRet
      FAT3PVSaldo(aPvAtu,nOpc)
   EndIf */

   /////////////////////////////////////////////////////////////////
   //Ponto de Entrada chamado no fim da atualização do faturamento//
   /////////////////////////////////////////////////////////////////
   If EasyEntryPoint("EECFAT3")
      ExecBlock("EECFAT3",.F.,.F.,{"FIM_GRVPV",nOpc})
   Endif

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Função     : SeqItem
Parametros : cItem
Objetivo   : Obter o número do item a ser incluído no pedido do faturamento.
Autor      : Eduardo C. Romanini
Data e Hora: 13/05/08 12:30
*/
*-----------------------------*
Static Function SeqItem(cItem)
*-----------------------------*
Local aOrd  := SaveOrd({"WorkIp"})
cItem:= AllTrim(cItem)

Begin Sequence

   WorkIp->(DbSetOrder(1))
   WorkIp->(dbGoBottom())

   While WorkIp->WP_RECNO == 0 .And. WorkIp->(!Bof())
      WorkIp->(DbSkip(-1))
   EndDo

   If WorkIp->EE9_FATIT > cItem
      cItem := WorkIp->EE9_FATIT
   EndIf

   cItem := SomaIt(cItem)

End Sequence

RestOrd(aOrd,.T.)

Return (cItem)

/*
Funcao      : FAT3VerInt
Parametros  :
Retorno     :
Objetivos   : Essa função irá verificar a integridade de dados entre o Embarque e o Pedido de Venda gerado no Faturamento.
Autor       : Eduardo C. Romanini
Data/Hora   : 14/05/2008 10:00
Obs.        : Essa função é chamada a partir do fonte EECAE100.prw
*/
*-------------------*
Function FAT3VerInt()
*-------------------*
Local lDifPreco     := .F.
Local lDifItens     := .F.
Local lNaoConfPreco := EasyGParam("MV_AVG0052",,.F.)

Local nItensEE9 := 0
Local nItensSC6 := 0
Local nPrecoEE9 := 0
Local nPrecoSC6 := 0
Local nPos      := 0

Local aItensEE9 := {}
Local aOrd      := SaveOrd({"WorkIp","SC6"})

Begin Sequence

   WorkIp->(DbSetOrder(1))
   WorkIp->(DbGoTop())

   /////////////////////////////////////////////////////////
   //Conta o número de itens e calcula o total do Embarque//
   /////////////////////////////////////////////////////////
   While WorkIp->(!EOF())

      If !Empty(WorkIP->WP_FLAG)

         ////////////////////////////////////////////////////////////////////////////////////
         //Agrupa os itens relacionados ao mesmo item do pedido que já possuem Nota Fiscal,//
         //já que esses itens são quebrados no Embarque.                                   //
         ////////////////////////////////////////////////////////////////////////////////////
         //nItensEE9++
         nPos := aScan(aItensEE9,{|x| x[1] == WorkIp->EE9_FATIT})

         If nPos == 0
            aAdd(aItensEE9,{WorkIp->EE9_FATIT,WorkIp->EE9_NF,WorkIp->EE9_SERIE})
         Else
            If Empty(WorkIp->EE9_NF) .or. (!Empty(WorkIp->EE9_NF) .and. Empty(aItensEE9[nPos][2]))
               aAdd(aItensEE9,{WorkIp->EE9_FATIT,WorkIp->EE9_NF,WorkIp->EE9_SERIE})
            EndIf
         EndIf

         If GetNewPar("MV_AVG0017","S") == "S" // Na integração com o Faturamento, o C6_PRECO é o preço FOB ? (S/N)
            nPrecoEE9 += WorkIp->EE9_PRCINC
         Else
            nPrecoEE9 += WorkIp->EE9_PRCTOT
         Endif

      EndIf

      WorkIp->(DbSkip())
   EndDo

   //////////////////////////////////////////////
   //Verifica a quantidade de itens no Embarque//
   //////////////////////////////////////////////
   nItensEE9 := Len(aItensEE9)

   SC6->(DbSetOrder(1))
   If SC6->(DbSeek(xFilial("SC6")+AvKey(M->EEC_PEDFAT,"C6_NUM")))

      ////////////////////////////////////////////////////////////////
      //Conta o número de itens e calcula o total do Pedido de Venda//
      ////////////////////////////////////////////////////////////////
      While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. AvKey(M->EEC_PEDFAT,"C6_NUM") == SC6->C6_NUM
         nItensSC6++
         nPrecoSC6 += SC6->C6_VALOR
         SC6->(DbSkip())
      EndDo
   EndIf

   ///////////////////////////////////////////////////////////////////////////////////////////
   //Verifica se o número de itens do Embarque é igual ao número de itens do Pedido de Venda//
   ///////////////////////////////////////////////////////////////////////////////////////////
   If nItensEE9 <> nItensSC6
      lDifItens := .T.
   EndIf

   nPrecoEE9 := Round(nPrecoEE9, EECPreco("EE9_PRCTOT", AV_DECIMAL))

   /////////////////////////////////////////////////////
   //Verifica se não deve efetuar conferencia de Preço//
   /////////////////////////////////////////////////////
   If !lNaoConfPreco
      If nPrecoEE9 <> nPrecoSC6
         lDifPreco:=.T.
      EndIf
   EndIf

   If lDifItens

      //////////////////////////////////////////////////////
      //Exibe tela com os detalhes da falha de integridade//
      //////////////////////////////////////////////////////
      AP100Error(nItensEE9,nItensSC6,nPrecoEE9,nPrecoSC6)

   Else
      If lDifPreco

         //////////////////////////////////////////////////////
         //Exibe tela com os detalhes da falha de integridade//
         //////////////////////////////////////////////////////
         AP100Error(nItensEE9,nItensSC6,nPrecoEE9,nPrecoSC6)

      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return

/*
Funcao      : FAT3PVSaldo
Parametros  : aAtuPV : Array com os Pedidos que serão atualizados
              nOpc   : Operação executada no Embarque.
Retorno     : lRet
Objetivos   : Atualiza o saldo do Pedido de Venda Pai (relacionado ao Pedido) com base
              no Pedido de Venda Filho (relacionado ao Embarque).
Autor       : Eduardo C. Romanini
Data/Hora   : 19/05/2008 10:00
Obs.        :
Revisão     : WFS 05/03/2010 - Implementação dos tratamentos da grade; inclusão do código
              do produto na chave de busca.
*/
*-------------------------------*
Function FAT3PVSaldo(aAtuPv,nOpc)
*-------------------------------*
Local lRet      := .T.
Local lItNotBlq := .F.

Local cPedPai := ""

Local nInc    := 0
Local i       := 0
Local nSC6Rec := 0
Local nPesLiq := 0
Local nPesBru := 0
Local nPos    := 0

Local aOrd      := SaveOrd({"SC5","SC6","WorkIp"})
Local aVars     := {}
Local aAtuBlq   := {}
Local aItZera   := {}

Private aDeletados := {}
Private aGrdRec    := {}
////////////////////////////////////////////////////////////////////////////
//Variavel utilizada para controle de cálculo do Peso no fonte EECFAT2.prw//
////////////////////////////////////////////////////////////////////////////
Private lAtuPesEmb :=.T.

Begin Sequence

   For nInc:= 1 To Len(aAtuPv)

      nPesLiq := 0
      nPesBru := 0

      lEECFAT := .T.

      ////////////////////////////////////////////////////////////////
      //Criação da Works para a integração com o Pedido de Venda Pai//
      ////////////////////////////////////////////////////////////////
      aVars := Ap102SetWorks()

      ///////////////////////////////////////////////////////////////
      //Carrega as informações de Capa do Pedido de Exportação para//
      //atualizar o Pedido de Venda Pai.                           //
      ///////////////////////////////////////////////////////////////
      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(xFilial("EE7")+AvKey(aAtuPv[nInc],"EE7_PEDIDO")))

         For i := 1 to EE7->(FCount())
            M->&(EE7->(FIELDNAME(i))) := EE7->(FieldGet(i))
         Next

         cPedPai := EE7->EE7_PEDFAT

      EndIf

      ////////////////////////////////////////////////////////////////
      //Carrega as informações de Itens do Pedido de Exportação para//
      //atualizar o Pedido de Venda Pai.                            //
      ////////////////////////////////////////////////////////////////
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(xFilial("EE8")+AvKey(aAtuPv[nInc],"EE8_PEDIDO")))
         While EE8->(!EOF()) .and. EE8->(EE8_FILIAL + EE8_PEDIDO) == xFilial("EE8")+AvKey(aAtuPv[nInc],"EE8_PEDIDO")

            WorkIt->(dbAppend())
            AvReplace("EE8","WorkIt")

            WorkIt->EE8_RECNO  := EE8->(RecNo())

            /////////////////////////////////////////////////////////////////
            //Verifica o saldo do Item que está sendo utilizado no Embarque//
            /////////////////////////////////////////////////////////////////
            WorkIp->(DbSetOrder(1))
            If WorkIp->(DbSeek(EE8->EE8_PEDIDO + EE8->EE8_SEQUEN + If(lGrade, EE8->EE8_ITEMGR, ""))) .and. !Empty(WorkIp->WP_FLAG)
               If nOpc == INCLUIR .or. nOpc == ALTERAR

                  If WorkIp->WP_SLDATU > 0
                     WorkIt->EE8_SLDATU := WorkIp->WP_SLDATU //Saldo a ser atualizado.
                  Else
                     ///////////////////////////////////////////////////////////////////
                     //Caso o saldo seja zero, a qtd. do Item do Pedido de Venda será //
                     //zerada manualmente após a integração.                          //
                     ///////////////////////////////////////////////////////////////////
                     WorkIt->EE8_SLDATU := WorkIp->EE9_SLDINI

                     aAdd(aItZera,{cPedPai,EE8->EE8_FATIT,EE8->EE8_COD_I})
                  EndIf

                  aAdd(aAtuBlq,{cPedPai,EE8->EE8_FATIT,WorkIp->WP_SLDATU,EE8->EE8_COD_I})

                  ////////////////////////////////////////////////////////////////////////////////
                  //Atualização dos Pesos, com base no saldo para atualização do Pedido de Venda//                                            //
                  ////////////////////////////////////////////////////////////////////////////////
                  nPesLiq += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIp->WP_SLDATU,M->EE7_PEDFAT)[1]
                  nPesBru += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIp->WP_SLDATU,M->EE7_PEDFAT)[2]

               ElseIf nOpc == EXCLUIR

                  WorkIt->EE8_SLDATU += WorkIp->EE9_SLDINI //Saldo a ser atualizado.
                  aAdd(aAtuBlq,{cPedPai,EE8->EE8_FATIT,WorkIp->EE9_SLDINI,EE8->EE8_COD_I})

                  //////////////////////////////////////////////////////////////////////////////////////
                  //Atualização dos Pesos, com base na quantidaded para atualização do Pedido de Venda//                                            //
                  //////////////////////////////////////////////////////////////////////////////////////
                  nPesLiq += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIp->EE9_SLDINI,M->EE7_PEDFAT)[1]
                  nPesBru += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIp->EE9_SLDINI,M->EE7_PEDFAT)[2]

               EndIf

            Else
               ///////////////////////////////////////////////////////////////////////////////
               //Se o Saldo do Item já foi totalmente utilizado em outros embarques, que não//
               //o corrente, estes também deverão ter seu saldo zerado no Pedido de Venda   //
               //manualmente.                                                               //
               ///////////////////////////////////////////////////////////////////////////////
               If EE8->EE8_SLDATU == 0

                  /////////////////////////////////////////////
                  //Indica se o Item acabou de ser desmarcado//
                  /////////////////////////////////////////////
                  If WorkIp->WP_SLDATU > 0

                     WorkIt->EE8_SLDATU := WorkIp->WP_SLDATU

                     aAdd(aAtuBlq,{cPedPai,EE8->EE8_FATIT,WorkIp->WP_SLDATU,EE8->EE8_COD_I})

                     ////////////////////////////////////////////////////////////////////////////////
                     //Atualização dos Pesos, com base no saldo para atualização do Pedido de Venda//                                            //
                     ////////////////////////////////////////////////////////////////////////////////
                     nPesLiq += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIp->WP_SLDATU,M->EE7_PEDFAT)[1]
                     nPesBru += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIp->WP_SLDATU,M->EE7_PEDFAT)[2]

                  Else

                     WorkIt->EE8_SLDATU := EE8->EE8_SLDINI
                     aAdd(aItZera,{cPedPai,EE8->EE8_FATIT,EE8->EE8_COD_I})

                     aAdd(aAtuBlq,{cPedPai,EE8->EE8_FATIT,WorkIt->EE8_SLDATU,EE8->EE8_COD_I})

                     ////////////////////////////////////////////////////////////////////////////////
                     //Atualização dos Pesos, com base no saldo para atualização do Pedido de Venda//                                            //
                     ////////////////////////////////////////////////////////////////////////////////
                     nPesLiq += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,EE8->EE8_SLDATU,M->EE7_PEDFAT)[1]
                     nPesBru += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,EE8->EE8_SLDATU,M->EE7_PEDFAT)[2]

                  EndIf

               Else
                  //////////////////////////////////////////////////////////////////////////////////////////////////
                  //Se o item foi desmarcado, mas já possuia saldo não utilizado antes, terá o seu saldo ajustado.//
                  //////////////////////////////////////////////////////////////////////////////////////////////////
                  If WorkIp->WP_SLDATU > 0

                     WorkIt->EE8_SLDATU := EE8->EE8_SLDATU + WorkIp->WP_SLDATU

                     aAdd(aAtuBlq,{cPedPai,EE8->EE8_FATIT, WorkIt->EE8_SLDATU,EE8->EE8_COD_I})

                     ////////////////////////////////////////////////////////////////////////////////
                     //Atualização dos Pesos, com base no saldo para atualização do Pedido de Venda//                                            //
                     ////////////////////////////////////////////////////////////////////////////////
                     nPesLiq += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIt->EE8_SLDATU,M->EE7_PEDFAT)[1]
                     nPesBru += CalcPeso(EE8->EE8_PEDIDO,EE8->EE8_FATIT,WorkIt->EE8_SLDATU,M->EE7_PEDFAT)[2]

                  EndIf

               EndIf

            EndIf

            If lGrade
               nPos:= AScan(aGrdRec, {|x| x[1] == WorkIt->EE8_SEQUEN})
               If nPos > 0
                  AAdd(aGrdRec[nPos][2], {WorkIt->EE8_SLDINI, WorkIt->EE8_COD_I, EE8->(RecNo())})
               Else
                  AAdd(aGrdRec, {WorkIt->EE8_SEQUEN, {{WorkIt->EE8_SLDINI, WorkIt->EE8_COD_I, EE8->(RecNo())}}})
               EndIf
            EndIf

            EE8->(DbSkip())
         EndDo

         M->EE7_PESLIQ := nPesLiq
         M->EE7_PESBRU := nPesBru

      EndIf

      ///////////////////////////////////////////
      //Atualiza o Saldo do Pedido de Venda Pai//
      ///////////////////////////////////////////
      EECFAT2(ALTERAR,"GRV")

      /////////////////////////////////////////////
      //Apaga as Works criadas para a integração.//
      /////////////////////////////////////////////
      If(aVars[01] <> Nil,WorkIt->(E_EraseArq(aVars[1])),nil)
      If(aVars[02] <> Nil,WorkEm->(E_EraseArq(aVars[2])),nil)
      If(aVars[03] <> Nil,WorkAg->(E_EraseArq(aVars[3])),nil)
      If(aVars[04] <> Nil,WorkIn->(E_EraseArq(aVars[4])),nil)
      If(aVars[05] <> Nil,WorkDe->(E_EraseArq(aVars[5])),nil)
      If(aVars[06] <> Nil,WorkNo->(E_EraseArq(aVars[6])),nil)
      If(aVars[07] <> Nil .and. aVars[8] <> Nil,WorkDoc->(E_EraseArq(aVars[7],aVars[8])),nil)
      If(aVars[09] <> Nil,WorkGrp->(E_EraseArq(aVars[9])),nil)
      If(aVars[10] <> Nil,WORKSLD_AD->(E_EraseArq(aVars[10])),nil)

   Next

   ///////////////////////////////////////////////////////////////
   //Zera a quantidade dos itens do Pedido de Venda manualmente.//
   ///////////////////////////////////////////////////////////////
   FAT3ZeraIt(aItZera)

   //////////////////////////////////////////////////////////////////////////////////////
   //Controla o bloqueio ou desbloqueio do Pedido de Venda Pai de acordo com cada item.//
   //////////////////////////////////////////////////////////////////////////////////////
   FAT3PVBlq(aAtuBlq,nOpc)

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : FAT3VerBlq
Parametros  : nOpc : Operação executada no Pedido de Exportação.
Retorno     : lRet
Objetivos   : Bloqueia ou desbloqueia o Pedido de venda relacionado ao Pedido de Exportação.
Autor       : Eduardo C. Romanini
Data/Hora   : 06/03/2008 10:00
Obs.        : Essa função é chamada na gravação do Pedido de Exportação.
Revisão     : WFS 05/03/2010 - Implementação dos tratamentos da grade; inclusão do código
              do produto na chave de busca.
*/
*-----------------------*
Function FAT3VerBlq(nOpc)
*-----------------------*
Local lRet := .T.

Local aAtuBlq := {}
Local aItZera := {}
Local aOrd    := SaveOrd({"WorkIt","EEC","EE9"})

Begin Sequence

   If nOpc == ALTERAR

      WorkIt->(DbGoTop())
      While WorkIt->(!EOF())

         EE9->(DbSetOrder(1))
         If EE9->(DbSeek(xFilial("EE9")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN))

            ////////////////////////////////////////////////////////////////////////
            //Verifica se o Embarque possui o no fluxo de integração com o SigaFat//
            ////////////////////////////////////////////////////////////////////////
            If FAT3IntFat(EE9->EE9_PREEMB,nOpc)

               aAdd(aAtuBlq,{M->EE7_PEDFAT,WorkIt->EE8_FATIT,WorkIt->EE8_SLDATU,WorkIt->EE8_COD_I})

               ///////////////////////////////////////////////////////////////////////////////
               //Esse Item terá a sua quantidade zerada manualmente, para controle de saldo.//
               ///////////////////////////////////////////////////////////////////////////////
               If WorkIt->EE8_SLDATU == 0
                  aAdd(aItZera,{M->EE7_PEDFAT,WorkIt->EE8_FATIT,WorkIt->EE8_COD_I})
               EndIf

            EndIf

         EndIf

         WorkIt->(DbSkip())
      EndDo

   EndIf

   ///////////////////////////////////////////////////////////////
   //Zera a quantidade dos itens do Pedido de Venda manualmente.//
   ///////////////////////////////////////////////////////////////
   FAT3ZeraIt(aItZera)

   //////////////////////////////////////////////////////////////////////////////////////
   //Controla o bloqueio ou desbloqueio do Pedido de Venda Pai de acordo com cada item.//
   //////////////////////////////////////////////////////////////////////////////////////
   FAT3PVBlq(aAtuBlq,nOpc)

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : FAT3ZeraIt
Parametros  : aItZera : Array com os Itens que devem ter a sua quantidade zerada no Pedido de venda.
Retorno     : lRet
Objetivos   : Zera manualmente o saldo dos itens do Pedido de venda, para controle de saldo.
Autor       : Eduardo C. Romanini
Data/Hora   : 06/03/2008 10:00
Obs.        : Essa função é chamada na gravação do Pedido de Exportação.
Revisão     : WFS 05/03/2010 - Implementação dos tratamentos da grade; inclusão do código
              do produto na chave de busca.

*/
*--------------------------*
Function FAT3ZeraIt(aItZera)
*--------------------------*
Local lRet := .T.
Local aPedidos := {}, lZera := .F.
Local nInc := 0

Begin Sequence

   For nInc := 1 To Len(aItZera)
      SC6->(DbSetOrder(1)) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
      If SC6->(DbSeek(xFilial("SC6")+AvKey(aItZera[nInc][1],"C6_NUM")+AvKey(aItZera[nInc][2],"C6_ITEM")+AvKey(aItZera[nInc][3],"C6_PRODUTO")))


         If aScan(aPedidos, aItZera[nInc][1]) == 0
         	aAdd(aPedidos, aItZera[nInc][1])
         EndIf

         SC6->(RecLock("SC6",.F.))

         SC6->C6_QTDVEN  := 0
         SC6->C6_QTDENT  := 0
         SC6->C6_PRCVEN  := 0
         SC6->C6_VALOR   := 0
         SC6->C6_VALDESC := 0
         SC6->C6_PRUNIT  := 0
         //WFS 09/06/10 - tratamentos quando usada a segunda unidade de medidas
         SC6->C6_UNSVEN  := 0

         SC6->(MsUnlock())

      EndIf
   Next

   For nInc := 1 To Len(aPedidos)
      If SC5->(DbSeek(xFilial("SC5")+AvKey(aPedidos[nInc],"C5_NUM")))
      	 lZera := .T.
         SC6->(DbSeek(xFilial()+AvKey(aPedidos[nInc],"C6_NUM")))
         While SC6->(C6_FILIAL+C6_NUM == xFilial()+AvKey(aPedidos[nInc],"C6_NUM"))
         	If SC6->C6_QTDVEN > 0
         		lZera := .F.
         	EndIF
         	SC6->(DbSkip())
         EndDo
         If lZera
         	If SC5->(RecLock("SC5", .F.))
         		SC5->C5_LIBEROK := 'E'
         		SC5->(MsUnlock())
         	EndIf
         EndIf
      EndIf
   Next


End Sequence

Return lRet

/*
Funcao      : FAT3PVBlq
Parametros  : aAtuBlq : Array com as informações dos Pedidos que devem ser verificados para bloqueio/desbloqueio.
              nOpc    : Operação executada no Pedido/Embarque de Exportação.
Retorno     : lRet
Objetivos   : Bloqueia ou desbloqueia o Pedido de venda relacionado ao Pedido de Exportação.
Autor       : Eduardo C. Romanini
Data/Hora   : 06/03/2008 10:00
Obs.        : Essa função é chamada na gravação do Pedido de Exportação.
Revisão     : WFS 05/03/2010 - Implementação dos tratamentos da grade; inclusão do código
              do produto na chave de busca.
*/
*--------------------------------*
Function FAT3PVBlq(aAtuBlq,nOpc)
*--------------------------------*
Local lRet   := .T.
Local nSC6Rec := 0 // SVG - 15/03/2011 -
Local nSaldo := 0
Local nInc   := 0

Begin Sequence

   For nInc := 1 To Len(aAtuBlq)

      nSaldo := aAtuBlq[nInc][3]

      If nSaldo > 0

         SC5->(DbSetOrder(1))
         If SC5->(DbSeek(xFilial("SC5")+AvKey(aAtuBlq[nInc][1],"C5_NUM")))

            ////////////////////////////////////////////////////////
            //Verifica se a capa do pedido de Venda está bloqueada//
            ////////////////////////////////////////////////////////
            If Alltrim(SC5->C5_LIBEROK) == "S"

               ///////////////////////////////////////
               //Liberação a capa do Pedido de Venda//
               ///////////////////////////////////////
               SC5->(RecLock("SC5",.F.))
               SC5->C5_LIBEROK := Space(AvSX3("C5_LIBEROK",AV_TAMANHO))
               SC5->C5_NOTA    := Space(AvSX3("C5_NOTA",AV_TAMANHO))
               SC5->(MsUnlock())
            EndIf
         EndIf

         SC6->(DbSetOrder(1))
         If SC6->(DbSeek(xFilial("SC6")+AvKey(aAtuBlq[nInc][1],"C6_NUM")+AvKey(aAtuBlq[nInc][2],"C6_ITEM")+AvKey(aAtuBlq[nInc][4],"C6_PRODUTO")))

            nSC6Rec := SC6->(RecNo())


            ///////////////////////////////////////////////////////
            //Pedido de Venda Bloqueado por Eliminação de Resíduo//
            ///////////////////////////////////////////////////////
            If AllTrim(SC6->C6_BLQ) == "R"

               ////////////////////////////////////////////
               //Retira o Bloqueio do Pedido de Venda Pai//
               ////////////////////////////////////////////
               If SC6->(RecLock("SC6",.F.))
                  SC6->C6_BLQ := Space(2)
                  SC6->(MsUnlock())
               EndIf

            EndIf
         EndIf

      Else

         If nOpc == INCLUIR .or. nOpc == ALTERAR

            lItNotBlq := .F.

            /////////////////////////////////////////////////////////////////////////
            //Veririca se apenas o Item será bloqueado ou                          //
            //se o pedido inteiro será bloqueado(todos os itens já foram bloqueado)//
            /////////////////////////////////////////////////////////////////////////
            SC6->(DbSetOrder(1))
            If SC6->(DbSeek(xFilial("SC6")+AvKey(aAtuBlq[nInc][1],"C6_NUM")))

               While SC6->(!EOF()) .and. SC6->(C6_FILIAL + C6_NUM) == xFilial("SC6")+AvKey(aAtuBlq[nInc][1],"C6_NUM")

                  //////////////////////////////////////////////////////////////
                  //Verifica se o item não é o mesmo que está sendo atualizado//
                  //////////////////////////////////////////////////////////////
                  If SC6->C6_ITEM <> AvKey(aAtuBlq[nInc][2],"C6_ITEM")
                      nSC6Rec := SC6->(RecNo())
                     /////////////////////////////////////////////////////////////////////////
                     //Verifica se existe algum item que ainda não foi bloqueado por resíduo//
                     /////////////////////////////////////////////////////////////////////////
                     If AllTrim(SC6->C6_BLQ) <> "R"
                        lItNotBlq := .T.
                     EndIf
                  EndIf

                  SC6->(DbSkip())
               EndDo

            EndIf

            If lItNotBlq
               /////////////////////////////////////////////////////////////////////
               //Se o Pedido de Venda possuir algum item que não esteja bloqueado,//
               //apenas o item que está sendo atualizado que será bloqueado.      //
               /////////////////////////////////////////////////////////////////////
               MaResDoFat(nSC6Rec,.F.,.F.)
            Else
               /////////////////////////////////////////////////////////////////
               //Se todos os itens já foram bloqueados, então a capa do Pedido//
               //de Venda também será bloqueado.                              //
               /////////////////////////////////////////////////////////////////
               MaResDoFat(nSC6Rec,.F.,.T.)
            EndIf

         EndIf
      EndIf
   Next

End Sequence

Return lRet

/*
Funcao      : FAT3DelNF
Parametros  : cNf    : Número da Nota Fiscal
              cSerie : Série da Nota Fiscal
Retorno     : lRet
Objetivos   : Apaga as tabelas EES e EEM referente a Nota Fiscal.
Autor       : Eduardo C. Romanini
Data/Hora   : 09/06/2008 16:00
Obs.        : Essa função é chamada na função AE100ITGRAVA() do fonte EECAE102.prw
              e apaga os arquivos EES e EEM caso a Nota Fiscal não exista no módulo
              de Faturamento.
              Essa função também é chamada da função AE101Grava(), onde foi incluído
              um tratamento para consistir as tabelas EEM/ EES com as SF2/ SD2 quando
              o fluxo alternativo de integração com o faturamento estiver habilitado.
*/
*----------------------------*
Function FAT3DelNF(cNf,cSerie)
*----------------------------*
Local lRet := .T.

Local aOrd := SaveOrd({"EEM","EES"})

Begin Sequence

   EEM->(DbSetOrder(1))
   If EEM->(DbSeek(xFilial("EEM")+M->EEC_PREEMB+EEM_NF+AvKey(cNf,"EEM_NRNF")))
      EEM->(RecLock("EEM",.F.))
      EEM->(DbDelete())
      EEM->(MsUnlock())
   EndIf

   EES->(DbSetOrder(1))
   If EES->(DbSeek(xFilial("EES")+M->EEC_PREEMB+AvKey(cNf,"EES_NRNF")))
      EES->(RecLock("EES",.F.))
      EES->(DbDelete())
      EES->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : FAT3VerGPV
Parametros  : nOpc : Operação executada no Pedido de Exportação.
Retorno     : lRet
Objetivos   : Verifica se algum dos Pedidos vinculados ao Embarque não possuem
              Pedido de Venda (graças ao campo EE7_GPV = Não) e não permite a
              gravação do Embarque.
Autor       : Eduardo C. Romanini
Data/Hora   : 09/06/2008 16:00
Obs.        : Essa função é chamada na validação do Embarque.
*/
*-----------------------*
Function FAT3VerGPV(nOpc)
*-----------------------*
Local lRet := .T.

Local aOrd := SaveOrd({"EEC","WorkIp","EE7"})

Begin Sequence

   If EE7->(FieldPos("EE7_GPV")) == 0
      Break
   EndIf

   If nOpc == INCLUIR .or. nOpc == ALTERAR
      WorkIp->(DbGoTop())
      While WorkIp->(!EOF())

         EE7->(DbSetOrder(1))
         If EE7->(DbSeek(xFilial("EE7")+WorkIp->EE9_PEDIDO))

            If EE7->EE7_GPV $ cNao
               lRet := .F.
               Exit
            EndIf
         EndIf

         WorkIp->(DbSkip())
      EndDo

      If !lRet
         MsgInfo("O Embarque não poderá ser gerado porque um dos seus Pedidos não gerou Faturamento " +;
                 "graças ao campo " + Alltrim(AVSX3("EE7_GPV",AV_TITULO))+" .","Atenção")
         Break
      EndIf

   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Funcao      : AvIntEmb
Parametros  : Nenhum
Retorno     : lRet
Objetivos   : Verifica se o ambiente está devidamente configurado para executar a
              rotina de integração com o faturamento a partir do Embarque.
Autor       : Eduardo C. Romanini
Data/Hora   : 04/08/2008 16:00
Obs.        : Essa função é chamada pelos fontes do Faturamento.
*/
*-----------------*
Function AvIntEmb()
*-----------------*
Local lRet := .F.

Begin Sequence

   If EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))
      lRet := .T.
   EndIf

End Sequence

Return lRet

/*
Funcao      : FAT3IntFat
Parametros  : cEmbarque : Código do Embarque
              nOpc      : Operação executada no Embarque de Exportação.
Retorno     : lRet
Objetivos   : Verifica se o Embarque de Exportação poderá gerar Pedido
              de Venda no Faturamento, ou se será utilizada a integração
              antiga do Faturamento.
Autor       : Eduardo C. Romanini
Data/Hora   : 10/11/2008 15:00
*/
*---------------------------------*
Function FAT3IntFat(cEmbarque,nOpc)
*---------------------------------*
Local lRet := .T.

Local aOrd := SaveOrd({"EEC","SC5"})

Begin Sequence

   /*	WFS - 14/10: O cliente FleckSteel desabilitará o fluxo.
    	Ajustado o tratamento para manter em funcionamento os processos em andamento
   If !EECFlags("INTEMB") .Or. (EEC->(FieldPos("EEC_PEDFAT")) > 0 .And. !Empty(EEC->EEC_PEDFAT))*/
   If !EECFlags("INTEMB") .And. (EEC->(FieldPos("EEC_PEDFAT")) == 0 .Or. Empty(EEC->EEC_PEDFAT))
      lRet := .F.
      Break
   EndIf

   If nOpc <> INCLUIR

      EEC->(DbSetOrder(1))

      If !EEC->(DbSeek(xFilial("EEC")+AvKey(cEmbarque,"EEC_PREEMB")))
         lRet := .F.
         Break
      EndIf

      ////////////////////////////////////////////////////////////////////
      //Verifica se não existe Pedido de Venda Gerado para esse Embarque//
      ////////////////////////////////////////////////////////////////////
      If Empty(EEC->EEC_PEDFAT)
         lRet := .F.
         Break
      Else
         ////////////////////////////////////////////////////////////////////////
         //Verifica se o Pedido de Venda gerado realmente existe no Faturamento//
         ////////////////////////////////////////////////////////////////////////
         SC5->(DbSetOrder(1))
         If !SC5->(DbSeek(xFilial("SC5")+AvKey(EEC->EEC_PEDFAT,"C5_NUM")))
            lRet := .F.
            Break
         EndIf
      EndIf

   EndIf

   //////////////////////////////////////////////////////
   //Ponto de Entrada para inclusão/alteração de campos//
   //a serem integrados nos itens do Pedido de Venda   //
   //////////////////////////////////////////////////////
   If EasyEntryPoint("EECFAT3")
      lRet := ExecBlock("EECFAT3",.F.,.F.,{"INTFAT",nOpc})

      If !lRet
         Break
      EndIf

   Endif

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Fat3LimpaEE9
Parametros  :
Retorno     :
Objetivo    : Limpar os campos EE9_NF e EE9_SERIE dos processos em que já foi realizada a comparação
              de notas fiscais.
              Armazenar informações dos itens do embarque para a geração do novo pedido de vendas e
              gravação do histórico nas tabelas EEM e EXD.
              Posiciona no registro da tabela EE9 a ser gravado na tabela EES (histórico).
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 30/06/09
Obs.        : Usa as variáveis private cNFSPedido, cNFSItemPV e cPedExp correspondente ao número processo de
              embarque quando usado o fluxo alternativo de integração.
*/

Static Function Fat3LimpaEE9()
Local aOrd:= SaveOrd("EE9")
Local cItemPV:= AllTrim(cNFSItemPV)

Begin Sequence

   //Verifica se a nota fiscal já foi devolvida alguma vez.
   //Neste caso, o item do pedido de vendas pode ser outro.
   EXD->(DBSetOrder(1)) //EXD_FILIAL + EXD_PREEMB + EXD_SEQEMB + EXD_ITEM + EXD_PEDFAT + EXD_ITEMPV
   If EXD->(DBSeek(xFilial() + AvKey(cPedExp, "EXD_PREEMB")))
      While EXD->(!Eof()) .And.;
            EXD->(EXD_FILIAL + EXD_PREEMB) == (EXD->(xFilial()) + AvKey(cPedExp, "EXD_PREEMB"))

         If AllTrim(cNFSPedido) == AllTrim(EXD->EXD_PEDFAT) .And.;
            AllTrim(cNFSItemPV) == AllTrim(EXD->EXD_ITEMPV)

            cItemPV:= Posicione("EE9", 3, EXD->(xFilial()) + AvKey(EXD->EXD_PREEMB, "EE9_PREEMB") + ;
                                AvKey(EXD->EXD_SEQEMB, "EE9_SEQEMB"), "EE9_FATIT")
            Exit
         EndIf
         EXD->(DBSkip())
      End
   EndIf


   cPedExp:= AvKey(cPedExp, "EE9_PREEMB")

   EE9->(DBSetOrder(2)) //EE9_FILIAL + EE9_PREEMB + EE9_PEDIDO + EE9_SEQUEN
   EE9->(DBSeek(xFilial() + cPedExp))

   //Tratamento para limpar o conteúdo dos campos EE9_NF e EE9_SERIE
   While EE9->(!Eof()) .And.;
         EE9->(EE9_FILIAL + EE9_PREEMB) == (EE9->(xFilial()) + cPedExp)

      If AllTrim(EE9->EE9_FATIT) == AllTrim(cItemPV)

         EE9->(RecLock("EE9", .F.))
         EE9->EE9_NF:= ""
         EE9->EE9_SERIE:= ""
         EE9->(MsUnlock())

         //Armazenamento do item do embarque, para gravação na tabela EXD.
         //Armazenamento dos pesos líquidos e brutos unitários, para recálculo na geração do novo pedido.
         AAdd(aItemEmbTemp, {AllTrim(cNFSPedido) + AllTrim(cNFSItemPV), EE9->EE9_SEQEMB,;
                             EE9->EE9_PSLQUN, EE9->EE9_PSBRUN})

         Exit

      EndIf

      EE9->(DBSkip())
   End

End Sequence

RestOrd(aOrd)
Return

/*
Funcao      : Fat3GeraItens()
Parametros  :
Retorno     :
Objetivo    : Gerar o array aItensPV, para a criação do pedido de vendas a partir dos itens devolvidos.
              Vincular os itens do pedido com os itens do embarque, para a gravação do histórico (EXD).
              Rotina usada quando o fluxo alternativo de integração está habilitado (EECFlags("INTEMB")).
Autor       : Wilsimar Fabrício da Silva
Data/Hora   : 01/07/2009
Obs.        : Usa as variáveis privates cNFSPedido, cNFSItemPV, nQtdDev, nValDev, aItemEmb, aItemEmbTemp
*/

Static Function Fat3GeraItens()
Local aOrd:= SaveOrd("SC6"),;
      aReg:= {}
Local cChave:= ""
Local nCont:= 0,;
      nPos:= 0,;
      nPercDescont:= 0
Local cItem:= StrZero(Len(aItensPV) + 1, AvSX3("C6_ITEM", AV_TAMANHO))

Begin Sequence

   SC6->(DBSetOrder(1)) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
   SC6->(DBSeek(xFilial() + AvKey(cNFSPedido, "C6_NUM") + AvKey(cNFSItemPV, "C6_ITEM")))

   For nCont:= 1 To SC6->(FCount())
      AAdd(aReg, {SC6->(FieldName(nCont)), SC6->(FieldGet(nCont)), Nil})
   Next

   //o pedido de venda será gerado com as mesmas quantidades devolvidas
   nPos:= AScan(aReg, {|x| AllTrim(x[1]) == "C6_QTDVEN"})
   aReg[nPos][2]:= nQtdDev

   nPos:= AScan(aReg, {|x| AllTrim(x[1]) == "C6_PRCVEN"})
   aReg[nPos][2]:= (nValDev/ nQtdDev) / RecMoeda(dDataBase, SC5->C5_MOEDA)

   nPos:= AScan(aReg, {|x| AllTrim(x[1]) == "C6_VALOR"})
   aReg[nPos][2]:= nValDev  / RecMoeda(dDataBase, SC5->C5_MOEDA)

   //gatilho para recálculo do desconto do item
   nPos:= AScan(aReg, {|x| AllTrim(x[1]) == "C6_DESCONT"})
   nPercDescont:= aReg[nPos][2]

   nPos:= AScan(aReg, {|x| AllTrim(x[1]) == "C6_VALDESC"})
   aReg[nPos][2]:= Round(((nValDev / RecMoeda(dDataBase, SC5->C5_MOEDA)) * nPercDescont), AvSX3("C6_VALDESC", AV_DECIMAL))

   //correção da sequência do item
   nPos:= AScan(aReg, {|x| AllTrim(x[1]) == "C6_ITEM"})
   aReg[nPos][2]:= cItem

   //vinculação do item do novo pedido com o item do embarque, para gravação na tabela EXD
   cChave:= AllTrim(cNFSPedido) + AllTrim(cNFSItemPV)
   If (nPos:= AScan(aItemEmbTemp, {|x| x[1] == cChave})) > 0
      AAdd(aItemEmb, {cItem, aItemEmbTemp[nPos][2],; //EEQ_SEQEMB
                             aItemEmbTemp[nPos][3],; //EE9_PSLQUN
                             aItemEmbTemp[nPos][4]}) //EE9_PSBRUN
   EndIf

   //Acrescenta os dados coletado no array aItensPV, para a integração com o faturamento
   AAdd(aItensPV, AClone(aReg))

End Sequence

RestOrd(aOrd)
Return

/*
Funcao      : Fat3GeraCab()
Parametros  :
Retorno     :
Objetivo    : Gerar o array aCabPV, para a criação do pedido de vendas a partir dos itens devolvidos.
              Rotina usada quando o fluxo alternativo de integração está habilitado (EECFlags("INTEMB")).
Autor       : Wilsimar Fabrício da Silva
Data        : 01/07/2009
Obs.        : Usa as variáveis privates cNFSPedido e aItemEmb
*/

Static Function Fat3GeraCab()
Local aOrd:= SaveOrd({"SC5", "EE9"})
Local nCont:= 0,;
      nPos:= 0,;
      nPesLiq:= 0,;
      nPesBru:= 0

Begin Sequence

   //Geração dos dados da capa (SC5)
   //A princício, os dados do novo pedido será o mesmo do pedido de referência da nota fiscal devolvida.
   SC5->(DBSetOrder(1))
   SC5->(DBSeek(xFilial() + AvKey(cNFSPedido, "C5_NUM")))

   For nCont:= 1 To SC5->(FCount())
      AAdd(aCabPV, {SC5->(FieldName(nCont)), SC5->(FieldGet(nCont)), Nil})
   Next

   nPos:= aScan(aCabPv, {|x| AllTrim(x[1]) == "C5_NUM"})

   //Numeração do pedido de vendas. Não será considerado o parâmetro
   //MV_EECAUTO pois trata-se de um novo pedido para o mesmo processo.
   aCabPV[nPos][2]:= ""

   //Ajuste da data de emissão
   nPos:= aScan(aCabPv, {|x| AllTrim(x[1]) == "C5_EMISSAO"})
   aCabPV[nPos][2]:= dDataBase

   //Recálculo dos pesos bruto e líquido
   For nCont:= 1 To Len(aItensPV)

      nPos:= AScan(aItensPV[nCont], {|x| AllTrim(x[1]) == "C6_QTDVEN"})

      nPesLiq += aItensPV[nCont][nPos][2] * aItemEmb[nCont][3] //Qtd. devolvida * EE9_PSLQUN
      nPesBru += aItensPV[nCont][nPos][2] * aItemEmb[nCont][4] //Qtd. devolvida * EE9_PSBRUN
   Next

   nPos:= aScan(aCabPV, {|x| AllTrim(x[1]) == "C5_PESOL"})
   aCabPV[nPos][2]:= nPesLiq

   nPos:= aScan(aCabPV, {|x| AllTrim(x[1]) == "C5_PBRUTO"})
   aCabPV[nPos][2]:= nPesBru

   //Ajuste das despesas e descontos, de acordo com o lançamento da nota de entrada
   nPos:= aScan(aCabPV, {|x| AllTrim(x[1]) == "C5_FRETE"})
   aCabPV[nPos][2]:= SF1->F1_FRETE / RecMoeda(dDataBase, SC5->C5_MOEDA)

   nPos:= aScan(aCabPV, {|x| AllTrim(x[1]) == "C5_SEGURO"})
   aCabPV[nPos][2]:= SF1->F1_SEGURO / RecMoeda(dDataBase, SC5->C5_MOEDA)

   nPos:= aScan(aCabPV, {|x| AllTrim(x[1]) == "C5_DESPESA"})
   aCabPV[nPos][2]:= SF1->F1_DESPESA / RecMoeda(dDataBase, SC5->C5_MOEDA)

   nPos:= aScan(aCabPV, {|x| AllTrim(x[1]) == "C5_DESCONT"})
   aCabPV[nPos][2]:= SF1->F1_DESCONT / RecMoeda(dDataBase, SC5->C5_MOEDA)

End Sequence

RestOrd(aOrd)
Return

/*
Funcao      : Fat3GravaEXD()
Parametros  :
Retorno     :
Objetivo    : Gravar o histórico dos novos pedidos gerados após a devolução.
Autor       : Wilsimar Fabrício da Silva
Data        : 02/07/2009
Obs.        : Usa a variável private cPedExp
*/

Static Function Fat3GravaEXD()
Local aOrd:= SaveOrd("SC6")
Local cPedido:= M->EEC_PEDFAT,;
      cItem:= Replicate("0", AvSX3("EXD_ITEM", AV_TAMANHO))
Local nCont:= 1


Begin Sequence

   SC6->(DBSetOrder(1))
   SC6->(DBSeek(xFilial() + AvKey(cPedido, "C6_NUM")))

   While SC6->(C6_FILIAL + C6_NUM) == (SC6->(xFilial()) + AvKey(cPedido, "C6_NUM"))

      cItem:= SomaIt(cItem)

      EXD->(RecLock("EXD", .T.))
      EXD->EXD_FILIAL:= EXD->(xFilial())
      EXD->EXD_PREEMB:= cPedExp
      EXD->EXD_SEQEMB:= aItemEmb[nCont++][2] //EE9_SEQEMB
      EXD->EXD_ITEM  := cItem
      EXD->EXD_PEDFAT:= SC6->C6_NUM
      EXD->EXD_ITEMPV:= SC6->C6_ITEM
      EXD->(MsUnlock())

      SC6->(DBSkip())
   End

End Sequence

RestOrd(aOrd)
Return

/*
Funcao      : Fat3GrvEEMDev()
Parametros  :
Retorno     :
Objetivo    : Gravar a nota fiscal de devolução na tabela EEM e EES
Autor       : Wilsimar Fabrício da Silva
Data        : 03/07/2009
Obs.        : Usa as variáveis privates aNfDevEES, cNFSPedido, cNFSItemPV, cPedExp e cMoeda
*/

Static Function Fat3GrvEEMDev()
Local aOrd:= SaveOrd({"EEM", "SYF"})
Local cFornece:= "",;
      cLoja:= ""
Local lFound:= .F.
Local nTaxa:= 0,;
      nPos:= 0,;
      nCont:= 0

Begin Sequence

   cNota:= SF1->F1_DOC
   cSerie:= SF1->F1_SERIE
   cFornece:= SF1->F1_FORNECE
   cLoja:= SF1->F1_LOJA

   cPedExp:= AvKey(cPedExp, "EEM_PREEMB")

   EEM->(DBSetOrder(1)) //FILIAL + PREEMB + TIPOCA + NRNF + TIPONF
   If EEM->(DBSeek(xFilial() + cPedExp + EEM_NF + AvKey(cNota, "EEM_NRNF") + EEM_DV))
      While EEM->(!Eof() .And. EEM_FILIAL == xFilial()) .And.;
            EEM->EEM_PREEMB == cPedExp .And.;
            EEM->EEM_TIPOCA == EEM_NF .And.;
            EEM->EEM_NRNF   == cNota

         If AllTrim(EEM->EEM_SERIE) == AllTrim(cSerie) .And. EEM->(Ap101FilNf()) == EEM->(xFilial())
            lFound:= .T.
            Exit
         Endif

         EEM->(DBSkip())
      End
   EndIf

   If !lFound

      EEM->(RecLock("EEM", .T.))
      EEM->EEM_FILIAL:= xFilial("EEM")
      EEM->EEM_PREEMB:= cPedExp
      EEM->EEM_TIPOCA:= EEM_NF //Nota Fiscal
      EEM->EEM_NRNF  := cNota
      EEM->EEM_SERIE := cSerie
      EEM->EEM_TIPONF:= EEM_DV //Devolução
      EEM->EEM_DTNF  := SF1->F1_EMISSAO
      EEM->EEM_VLNF  := SF1->F1_VALBRUT
      EEM->EEM_VLMERC:= SF1->F1_VALMERC
      EEM->EEM_VLFRET:= SF1->F1_FRETE
      EEM->EEM_VLSEGU:= SF1->F1_SEGURO
      EEM->EEM_OUTROS:= SF1->F1_DESPESA
      EEM->EEM_MODNF := AModNot(SF1->F1_ESPECIE)

      If EECFlags("FATFILIAL")
         EEM->EEM_FIL_NF:= EEM->(xFilial())
      EndIf

      //Conversão de moeda
      If Empty(cMoeda)
         cMoeda:= Posicione("EEC", 1, EEC->(xFilial()) + cPedExp, "EEC_MOEDA")
      EndIf

      SYF->(DBSetOrder(1)) //YF_FILIAL + YF_MOEDA
      SYF->(DBSeek(xFilial() + cMoeda))

      If EECFLAGS("CAFE")
         nTaxa:= RecMoeda(SF1->F1_EMISSAO - 1, SYF->YF_MOEFAT)
      Else
         nTaxa:= RecMoeda(SF1->F1_EMISSAO, SYF->YF_MOEFAT)
      EndIf

      EEM->EEM_TXTB  := nTaxa
      EEM->EEM_TXFRET:= nTaxa
      EEM->EEM_TXSEGU:= nTaxa
      EEM->EEM_TXOUDE:= nTaxa
      EEM->EEM_VLNFM := Round((SF1->F1_VALBRUT/nTaxa), AvSX3("EEM_VLNFM" , AV_DECIMAL))
      EEM->EEM_VLMERM:= Round((SF1->F1_VALMERC/nTaxa), AvSX3("EEM_VLMERM", AV_DECIMAL))
      EEM->EEM_VLFREM:= Round((SF1->F1_FRETE/nTaxa)  , AvSX3("EEM_VLFREM", AV_DECIMAL))
      EEM->EEM_VLSEGM:= Round((SF1->F1_SEGURO/nTaxa) , AvSX3("EEM_VLSEGM", AV_DECIMAL))
      EEM->EEM_OUTROM:= Round((SF1->F1_DESPESA/nTaxa), AvSX3("EEM_OUTROM", AV_DECIMAL))

      //Código Fiscal
      If (nPos:= AScan(aHeader, {|x| AllTrim(x[1]) == "D1_CF"})) > 0
         EEM->EEM_CF:= aCols[1][nPos]
      Else
         EEM->EEM_CF:= SD1->D1_CF
      EndIf

      EEM->(MsUnlock())


      //Gravação da tabela EES
      For nCont:= 1 To Len(aNfDevEES)

         EES->(RecLock("EES", .T.))

         EES->EES_FILIAL:= EES->(xFilial())

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_PREEMB"})
         EES->EES_PREEMB:= aNfDevEES[nCont][nPos][2]

         EES->EES_NRNF := SF1->F1_DOC
         EES->EES_SERIE:= SF1->F1_SERIE
         EES->EES_DTNF := SF1->F1_EMISSAO

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_FATSEQ"})
         EES->EES_FATSEQ:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_COD_I"})
         EES->EES_COD_I:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_PEDIDO"})
         EES->EES_PEDIDO:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_SEQUEN"})
         EES->EES_SEQUEN:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_QTDE"})
         EES->EES_QTDE:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_VLNF"})
         EES->EES_VLNF:= aNfDevEES[nCont][nPos][2]

         /* WFS 17/07/2009
            Estes campos não existem no aCols e, neste ponto, ainda não
            foram gravados na tabela SD1.

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_VLMERC"})
         EES->EES_VLMERC:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_VLFRET"})
         EES->EES_VLFRET:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_VLSEGU"})
         EES->EES_VLSEGU:= aNfDevEES[nCont][nPos][2]

         nPos:= AScan(aNfDevEES[nCont], {|x| AllTrim(x[1]) == "EES_VLOUTR"})
         EES->EES_VLOUTR:= aNfDevEES[nCont][nPos][2] */

         If EECFlags("FATFILIAL")
            EES->EES_FIL_NF:= EES->(xFilial())
         EndIf

         /* WFS 17/07/2009
            Estes campos não existem no aCols e, neste ponto, ainda não
            foram gravados na tabela SD1.

         If FieldPos("EES_VLMERM") > 0 .And. FieldPos("EES_VLFREM") > 0 .And.;
            FieldPos("EES_VLSEGM") > 0 .And. FieldPos("EES_VLOUTM") > 0

            EES->EES_VLMERM:= Round((EES->EES_VLMERC/nTaxa), AvSX3("EES_VLMERM", AV_DECIMAL))
            EES->EES_VLFREM:= Round((EES->EES_VLFRET/nTaxa), AvSX3("EES_VLFREM", AV_DECIMAL))
            EES->EES_VLSEGM:= Round((EES->EES_VLSEGU/nTaxa), AvSX3("EES_VLSEGM", AV_DECIMAL))
            EES->EES_VLOUTM:= Round((EES->EES_VLOUTR/nTaxa), AvSX3("EES_VLOUTM", AV_DECIMAL))
         EndIf */

         If FieldPos("EES_VLNFM") > 0
            EES->EES_VLNFM:= Round((EES->EES_VLNF/nTaxa), AvSX3("EES_VLNFM",  AV_DECIMAL))
         EndIf

         EES->(MsUnlock())
      Next
   EndIf

End Sequence

RestOrd(aOrd)
Return

/*
Funcao      : Fat3ExcluiDev()
Parametros  :
Retorno     :
Objetivo    : Excluir os lançamentos realizados quando a nota de devolução for excluída.
              A exclusão só será realizada se o pedido não tiver sido faturado.
Autor       : Wilsimar Fabrício da Silva
Data        : 07/07/2009
Obs.        : Usa as variáveis private cNfOri, cNFSPedido e cPedExp correspondente ao número processo de
              embarque quando usado o fluxo alternativo de integração.
*/

Static Function Fat3ExcluiDev(cCall)
Local aOrd:= SaveOrd({"EXD", "SC5", "SC6", "EEM"}),;
      aReg:= {}
Local cPedRef:= "",;
      cNfRef:= ""
Local lRet:= .T.
Local nCont:= 0

Begin Sequence

   cPedExp:= AvKey(cPedExp, "EXD_PREEMB")

   //Busca a última ocorrência para o processo
   EXD->(DBSetOrder(2)) //EXD_FILIAL + EXD_PREEMB + EXD_PEDFAT
   If EXD->(AvSeekLast(xFilial() + cPedExp))

      cPedRef:= AvKey(EXD->EXD_PEDFAT, "C5_NUM")

      SC5->(DBSetOrder(1))
      SC5->(DBSeek(xFilial() + cPedRef)) //se encontrou na tabela EXD, então existe na SC5.

      cNfRef:= SC5->C5_NOTA

      If !Empty(cNfRef)
         //Se o pedido foi faturado, a exclusão não será realizada.
         MsgInfo(STR0001 + STR0002 + ENTER + STR0015 + AllTrim(cPedRef) + STR0016 + ;
                 ENTER + STR0017 + AllTrim(cNfRef) + ".", STR0013) //A Nota de Devolução não poderá ser excluída. O pedido ### referente ao processo de exportação já foi faturado. Nota Fiscal: ###, Atenção
         lRet:= .F.
      ElseIf cCall == "GRV"
         //Exclusão da tabela EXD
         While EXD->(!Bof()) .And.;
               EXD->(EXD_FILIAL + EXD_PREEMB + EXD_PEDFAT) == (EXD->(xFilial()) + cPedExp + cPedRef)

            EXD->(RecLock("EXD", .F.))
            EXD->(DBDelete())
            EXD->(MsUnlock())

            EXD->(DBSkip(-1))
         End


         //Exclusão do pedido de vendas
         //Dados da capa do pedido - registro posicionado acima
         aCabPv:= {}
         For nCont:= 1 To SC5->(FCount())
            AAdd(aCabPv, {SC5->(FieldName(nCont)), SC5->(FieldGet(nCont)), Nil})
         Next


         //Dados dos itens do pedido
         aItensPv:= {}
         SC6->(DBSetOrder(1)) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
         SC6->(DBSeek(xFilial() + cPedRef))
         While !SC6->(Eof()) .And.;
               SC6->(C6_FILIAL + C6_NUM) == (SC6->(xFilial()) + cPedRef)

            For nCont:= 1 To SC6->(FCount())
               AAdd(aReg, {SC6->(FieldName(nCont)), SC6->(FieldGet(nCont)), Nil})
            Next
            AAdd(aItensPv, AClone(aReg))
            SC6->(DBSkip())
         End
         lRet:= AVMata410(aCabPv, aItensPv, EXCLUIR, "EMB")


         //Exclusão da tabela EEM
         EEM->(DBSetOrder(1)) //EEM_FILIAL + EEM_PREEMB + EEM_TIPOCA + EEM_NRNF + EEM_TIPONF
         If EEM->(DBSeek(xFilial() + AvKey(cPedExp, "EEM_PREEMB") + EEM_NF +;
                         AvKey(SF1->F1_DOC, "EEM_NRNF") + EEM_DV))

            While EEM->(!Eof()) .And.;
                  EEM->EEM_FILIAL == EEM->(xFilial()) .And.;
                  EEM->EEM_PREEMB == AvKey(cPedExp, "EEM_PREEMB") .And.;
                  EEM->EEM_TIPOCA == EEM_NF .And.;
                  EEM->EEM_NRNF   == AvKey(SF1->F1_DOC, "EEM_NRNF") .And.;
                  EEM->EEM_TIPONF == EEM_DV

               If EEM->EEM_SERIE  == AvKey(SF1->F1_SERIE, "EES_SERIE")
                  EEM->(RecLock("EEM", .F.))
                  EEM->(DBDelete())
                  EEM->(MsUnlock())
               EndIf

               EEM->(DBSkip())
            End
         EndIf


         //Exclusão da tabela EES
         EES->(DBSetOrder(1)) //EES_FILIAL + EES_PREEMB + EES_NRNF
         If EES->(DBSeek(xFilial() + AvKey(cPedExp, "EES_PREEMB") + AvKey(SF1->F1_DOC, "EES_NRNF")))
            While EES->(!Eof()) .And.;
                  EES->(EES_FILIAL + EES_PREEMB + EES_NRNF) == ;
                  EES->(xFilial()) + AvKey(cPedExp, "EES_PREEMB") + AvKey(SF1->F1_DOC, "EES_NRNF")

               If EES->EES_SERIE == AvKey(SF1->F1_SERIE, "EES_SERIE")
                  EES->(RecLock("EES", .F.))
                  EES->(DBDelete())
                  EES->(MsUnlock())
               EndIf

               EES->(DBSkip())
            End
         EndIf

         lRet:= .T.
      EndIf
   EndIf
End Sequence

RestOrd(aOrd)
Return lRet

/*
Função     : SeekEE9()
Parametros : cTabela    - Alias da tabela a ser utilizada na query
             cPedExp    - Codigo do Pedido de Exportação
             cSequen    - Sequencia do item
             cNfOri     - Número da Nota Fiscal de Origem
             cSerieOri  - Série da Nota Fiscal de Origem
Retorno    : lRet       - Retorna .T. se encontrou o registro a ser posicionado.
Objetivos  : Posicionar o item na EE9/WorkIP com base nos dados enviados por parâmetro
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 26/02/2021
*/
Static Function SeekEE9(cTabela,cPedExp,cSequen,cNfOri,cSerieOri)
Local lRet  := .F.
Local cQuery:= ""
Local cAliasSeek := GetNextAlias()
Local aNotSX3 := {{"RECNO","N",10,0}}

cQuery := " SELECT R_E_C_N_O_ RECNO"
If cTabela == "EE9"
   cQuery += " FROM " + RetSQLName("EE9") + " "
Else
   cQuery += " FROM " + TETempName(cTabela) + " "
EndIf

cQuery += " WHERE "

If cTabela == "EE9"
   cQuery += " EE9_FILIAL = '" + xFilial("EE9") + "' AND "
EndIf

cQuery += "   EE9_PEDIDO = '" + cPedExp + "'    AND "
cQuery += "   EE9_SEQUEN = '" + cSequen + "'    AND "
cQuery += "   EE9_NF	    = '" + cNfOri + "'     AND "
cQuery += "   EE9_SERIE  = '" + cSerieOri + "'  AND "
cQuery += "   D_E_L_E_T_ = ' ' "

EasyWkQuery(cQuery,cAliasSeek,,aNotSX3)

If (cAliasSeek)->(!Eof()) .And. (cAliasSeek)->(EasyRecCount()) == 1
   (cTabela)->(dbGoTo((cAliasSeek)->(RECNO)))
   lRet := .T.
EndIf


(cAliasSeek)->(dbCloseArea())

Return lRet

/*
Função     : QtdTotEmba()
Parametros : cEmbarque  - Código do Embarque de Exportação
Retorno    : nRet       - Soma da quantidade total dos itens vinculados ao Embarque.
Objetivos  : Somar as quantidade de todos os itens do Embarque
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data/Hora  : 01/03/2021
*/
Static Function QtdTotEmba(cEmbarque)
Local nRet     := 0
Local cQuery   := ""
Local cAliasQtd:= GetNextAlias()

cQuery := " SELECT SUM(EE9_SLDINI) EE9_SLDINI"
cQuery += " FROM " + RetSQLName("EE9") + " "
cQuery += " WHERE "
cQuery += "   EE9_FILIAL = '" + xFilial("EE9")  + "' AND "
cQuery += "   EE9_PREEMB = '" + cEmbarque       + "' AND "
cQuery += "   D_E_L_E_T_ = ' ' "

EasyWkQuery(cQuery,cAliasQtd)

If (cAliasQtd)->(!Eof())
   nRet := (cAliasQtd)->(EE9_SLDINI)
EndIf

(cAliasQtd)->(dbCloseArea())

Return nRet


Static Function TxDevolucao(cMoeda, cNFOrig, cSerOrig, cCliente, cLoja)
Local nRet := 0
Local dTxMoeFat
Local nTxMoeda
Local aAreaSF2 := SF2->(GetArea())
Default cMoeda := "R$"
SF2->(dbSetOrder(1)) //F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA
If SF2->(dbSeek(xFilial("SF2") + AvKey(cNFOrig,"F2_DOC") + AvKey(cSerOrig,"F2_SERIE") + AvKey(cCliente,"F2_CLIENTE") + AvKey(cLoja,"F2_LOJA")))
   dTxMoeFat := IIF(!Empty(SF2->F2_DTTXREF),SF2->F2_DTTXREF,SF2->F2_EMISSAO)
   nTxMoeda := If(Alltrim(cMoeda) == "R$",1,SF2->F2_TXMOEDA)
   IF nTxMoeda == 0
      nRet := RecMoeda(dTxMoeFat, Posicione("SYF", 1, xFilial("SYF") + cMoeda, "YF_MOEFAT"))
   ENDIF
EndIf
RestArea(aAreaSF2)

Return IIF(nRet == 0, BuscaTaxa(cMoeda,dDataBase),nRet)