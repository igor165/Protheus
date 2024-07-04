#INCLUDE "EECAP102.ch"
#include "EEC.CH"
#DEFINE ST_AP "N" //NCF - 11/08/2014 - Status do Pedido = "Aguardando Aprovação da Proforma"
#DEFINE ST_PA "O" //NCF - 11/08/2014 - Status do Pedido = "Proforma Aprovada"
#define ST_PB "P" //NCF - 03/02/2015 - Proforma em Edição
/*
funcao    : EECAP102
Objetivo  : 1. Definir campos que devem aparecer na enchoice
                  2. Criar WorkIt basea do no EE8
Autor     : Heder M Oliveira
Data/Hora : 22/12/98 17:30
REVISAO   : LCS.01/11/2005 - 10:25 -> CRIACAO DO PONTO DE ENTRADA EECPPE07 COM
            PARAMIXB = 'PSBRUN'. NECESSARIO PARA ATENDER UMA NECESSIDADE DA BUNGE.
            ANALISE FEITA JUNTAMENTE COM O ALEXANDER DA EXPORTACAO
Revisao   :-Luciano Campos de Santana - 27/03/2003
            Quando for gravar os campos ee7_prctot e ee7_prcinc, gravar com
            arredondamento p/ duas casas decimais
Revisão   : Jeferson Barros Jr. 23/07/01 13:25 - Melhoria no desempenho da manutenção de processos.
            LUCIANO C.SANTANA - 09/10/2001 - ACERTO DA CONDICAO DE PAGTO.
            AMARRADA COM O IMPORTADOR. NAO MOSTRAVA A DESCRICAO DA COND.PAG.
            TRAZER O VALOR DO PRODUTO DO ARQUIVO SB1.
REVISAO.: -Luciano Campos de SAntana - 31/10/2001
           Quando for trocado o codigo do importador, o agente recebedor de
           comissao tambem sera alterado, conforme o cadastro do importador

           WFS - Fev/ Mar 2010: Implementações para o uso do recurso Grade de Produtos.
*/


/*
aCampoItem    := vetor de produtos EE8
aHDEnchoice   := vetor do header EE7
aItemEnchoice := vetor do header do EE8

WorkIn := identificador de alias de instituicoes
WorkAg := identificador de alias de agentes
WorkIt := identificador de alias de produtos
WorkDe := identificador de alias de despesas
WorkEm := identificador de alias de Embalagens
WorkNo := identificador de alias de Notify's

novas variaveis devem ser criadas como LOCAL para evitar
redundâncias com sistema.
*/
*-----------------------------------
Function EECAP102(lItens)
*-----------------------------------
Local bAddWork, aOrd, j:=0, y:=0, z:=0
Local aSaveOrd := SaveOrd("SX3", 1)
Default lItens:= .T.

If Type("lIntPrePed") == "U"  // GFP - 27/05/2014
   lIntPrePed := .F.
EndIf

Begin Sequence
   aHDEnchoice:={"EE7_PEDIDO","EE7_DTPEDI","EE7_DTPROC","EE7_STTDES","EE7_DTSLCR",;
                 "EE7_MOTSIT","EE7_DSCMTS","EE7_IMPORT","EE7_IMPODE","EE7_CLIENT",;
                 "EE7_CLIEDE","EE7_FORN","EE7_FORNDE","EE7_EXPORT","EE7_EXPODE"  ,;
                 "EE7_CONSIG","EE7_CONSDE","EE7_CONDPA","EE7_DIASPA","EE7_DESCPA",;
                 "EE7_FRPPCC","EE7_VIA","EE7_VIA_DE","EE7_ORIGEM","EE7_DEST","EE7_PAISET",;
                 "EE7_INCOTE","EE7_PGTANT","EE7_SL_LC","EE7_LC_NUM","EE7_EMBAFI" ,;
                 "EE7_CALCEM","EE7_IDIOMA","EE7_TIPCOM","EE7_VALCOM","EE7_FIM_PE","EE7_TIPCVL",;
                 "EE7_FRPREV","EE7_SEGPRE","EE7_MOEDA","EE7_OBS","EE7_REFIMP"    ,;
                 "EE7_MARCAC","EE7_OBSPED","EE7_PRECOA","EE7_CUBAGE","EE7_SEGURO",;
                 "EE7_GENERI","EE7_SL_EME","EE7_LICIMP","EE7_DSCORI","EE7_DSCDES",;
                 "EE7_REFAGE","EE7_MPGEXP","EE7_DSCMPE","EE7_FOLOJA","EE7_IMLOJA",;
                 "EE7_EXLOJA","EE7_COLOJA","EE7_BELOJA","EE7_CLLOJA","EE7_BENEF" ,;
                 "EE7_BENEDE","EE7_ENDBEN","EE7_ENDIMP","EE7_TIPTRA","EE7_EXLIMP",;
                 "EE7_DTLIMP","EE7_RESPON","EE7_END2BE","EE7_END2IM","EE7_DESCON",;
                 /*"EE7_AMOSTR",*/"EE7_DESPIN","EE7_FRPCOM","EE7_BRUEMB","EE7_DECPES",;
                 "EE7_DECPRC","EE7_DECQTD"/*,"EE7_TPDESC"*/}                                     //NCF - 05/09/2013 - Retirada do campo EE7_TPDESC do array para inclusão condicional

   If EECFlags("AMOSTRA")
      aAdd(aHDENCHOICE,"EE7_ENVAMO")
   Else
      aAdd(aHDENCHOICE,"EE7_AMOSTR")
   EndIf

   If SX3->(dbSetOrder(2),dbSeek("EE7_TPDESC"))
      aAdd(aHDENCHOICE,"EE7_TPDESC")
   EndIf

   IF TYPE("EE7->EE7_DESP1")<>"U"
      aAdd(aHDENCHOICE,"EE7_DESP1")
   ENDIF

   IF TYPE("EE7->EE7_DESP2")<>"U"
      aAdd(aHDENCHOICE,"EE7_DESP2")
   ENDIF

   If EE7->(FieldPos("EE7_ENDCON")) > 0
      aAdd(aHDENCHOICE,"EE7_ENDCON")
   EndIf

   If EE7->(FieldPos("EE7_DESSEG")) > 0 //LRS 11/09/2015
      aAdd(aHDENCHOICE,"EE7_DESSEG")
   EndIf

   If EE7->(FieldPos("EE7_END2CO")) > 0
      aAdd(aHDENCHOICE,"EE7_END2CO")
   EndIf

   //RMD - 23/09/13 - Campo para informar o valor do frete já embutido nos itens
   If EE7->(FieldPos("EE7_FREEMB")) > 0 .And. EasyGParam("MV_EEC0039",,.F.)
      aAdd(aHdEnchoice, "EE7_FREEMB")
   EndIf

   IF lIntegra .Or. AvFlags("EEC_LOGIX") //se integrado ao faturamento ou integrado à outro ERP via mensagem única
      IF EE7->(FIELDPOS("EE7_GPV")) # 0
         AADD(aHDENCHOICE,"EE7_GPV")
      ENDIF
      If lIntegra
         AAdd(aHDEnchoice,"EE7_PEDFAT")
      EndIf
      If lIntPrePed
         AAdd(aHDEnchoice,"EE7_PEDERP")
      EndIf
      n := 0
      nPos := aScan(aHDEnchoice,"EE7_DTSLCR")
      IF nPos > 0
         aHDEnchoice := aDel(aHDEnchoice,nPos)
         n ++
      Endif
      nPos := aScan(aHDEnchoice,"EE7_DTAPCR")
      IF nPos > 0
         aHDEnchoice := aDel(aHDEnchoice,nPos)
         n ++
      Endif
      aHDEnchoice := aSize(aHDEnchoice,Len(aHDEnchoice)-n)        // By JPP - 09/12/04 10:55 - Correção do nome da variavel aHDEnchoice.
   Endif

   If lLibCredAuto .And. !lIntegra
      nPos := aScan(aHDEnchoice,"EE7_DTSLCR")

      If nPos > 0
         aHDEnchoice := aDel(aHDEnchoice,nPos)
         aHDEnchoice := aSize(aHDEnchoice,Len(aHDEnchoice)-1)     // By JPP - 09/12/04 10:55 - Correção do nome da variavel aHDEnchoice.
      EndIf
   EndIf

   If EE7->(FieldPos("EE7_TABPRE")) > 0
      aAdd(aHDEnchoice,"EE7_TABPRE")
   EndIf

   If EE7->(FieldPos("EE7_QTD20"))  > 0 .And. EE7->(FieldPos("EE7_QTD40")) > 0 .And.;
      EE7->(FieldPos("EE7_QTD40H")) > 0

      aAdd(aHDEnchoice,"EE7_QTD20")
      aAdd(aHDEnchoice,"EE7_QTD40")
      aAdd(aHDEnchoice,"EE7_QTD40H")
   EndIf

   If EE7->(FieldPos("EE7_TIPSEG")) > 0
      aAdd(aHDEnchoice, "EE7_TIPSEG")
   EndIf

   aItemEnchoice:={"EE8_COD_I","EE8_PART_N","EE8_FORN","EE8_FABR" ,;
                   "EE8_PRECO","EE8_SLDINI","EE8_DTENTR","EE8_FOLOJA"   ,;
                   "EE8_VM_DES","EE8_QE","EE8_DTPREM","EE8_EMBAL1","EE8_PSLQUN"    ,;
                   "EE8_PSBRUN","EE8_QTDEM1","EE8_UNIDAD","EE8_POSIPI","EE8_NLNCCA",;
                   "EE8_NALSH","EE8_FPCOD","EE8_GPCOD","EE8_DPCOD","EE8_FALOJA",;
                   "EE8_PRECOI","EE8_REFCLI","EE8_PERCOM", "EE8_CODNOR", "EE8_VM_NOR"}// ** By JBJ - 03/04/02 - 11:07

   //RMD
   If EECFLAGS("AMOSTRA")
      If Ap104VerPreco()
         aAdd(aItemEnchoice,"EE8_PRECO2")   // FJH - Adicionando os campos novos de preco.
         aAdd(aItemEnchoice,"EE8_PRECO3")
         aAdd(aItemEnchoice,"EE8_PRECO4")
         aAdd(aItemEnchoice,"EE8_PRECO5")
      Endif
      aAdd(aItemEnchoice, "EE8_CODQUA")//Campos de Qualidade
      aAdd(aItemEnchoice, "EE8_DSCQUA")
      aAdd(aItemEnchoice, "EE8_CODPEN")//Campos de Peneira
      aAdd(aItemEnchoice, "EE8_DSCPEN")
      aAdd(aItemEnchoice, "EE8_CODTIP")//Campos de Tipo
      aAdd(aItemEnchoice, "EE8_DSCTIP")
      aAdd(aItemEnchoice, "EE8_CODBEB")//Campos de Bebida
      aAdd(aItemEnchoice, "EE8_DSCBEB")
   EndIf

   //LRS - 20/10/2015 - adicionando campos opcionais
   IF EE8->(FieldPos("EE8_OPC")) > 0
      aAdd(aItemEnchoice,"EE8_OPC")
   Endif

   IF EE8->(FieldPos("EE8_MOP")) > 0
      aAdd(aItemEnchoice,"EE8_MOP")
   Endif
   //LRS - 02/02/2016 - adicionando campo Ato Concessorio
   IF EE8->(FieldPos("EE8_ATOCON")) > 0
      aAdd(aItemEnchoice,"EE8_ATOCON")
   Endif

   IF EE8->(FieldPos("EE8_DTQNCM")) > 0
      aAdd(aItemEnchoice,"EE8_DTQNCM")
   Endif

   IF EE8->(FieldPos("EE8_TPONCM")) > 0
      aAdd(aItemEnchoice,"EE8_TPONCM")
   Endif

   // FJH - 03/02/06
   If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0
      aAdd(aItemEnchoice,"EE8_DESCON")
   Endif

   IF lIntegra
      aAdd(aItemEnchoice,"EE8_FATIT")

      IF Type("EE8->EE8_TES") == "C"
         aAdd(aItemEnchoice,"EE8_TES")
      Endif

      IF Type("EE8->EE8_CF") == "C"
         aAdd(aItemEnchoice,"EE8_CF")
      Endif

      //RNLP - Adicionando campo Tipo de Operação - TES Inteligente
      If EE8->(FieldPos("EE8_OPER")) > 0
         aAdd(aItemEnchoice,"EE8_OPER")
      Endif

      //DFS - 23/02/11 - Inclusão de tratamento para verificar se será exibido ou não o campo na Exportação.

      If EasyGParam("MV_EECFAT",,.T.)// LRS 18/10/13 - Verifica se o parametros MV_EECFAT esta habilitado
      	SX3->(DbSetOrder(2))
      		IF SX3->(DbSeek("C6_RESERV")) .AND. SX3->(DbSeek("EE8_RESERV"));//LRS 18/10/13 - Adicionado a verificação do Campo EE8_RESERV
       			.AND. cNivel >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT <> "V" .AND. X3Uso(SX3->X3_USADO)
         			aAdd(aItemEnchoice,"EE8_RESERV")
      		Endif
      EndIf

      IF Type("EE8->EE8_DTVALI") == "D"
         aAdd(aItemEnchoice,"EE8_DTVALI")
      Endif

      IF Type("EE8->EE8_LOTECT") == "C"
         aAdd(aItemEnchoice,"EE8_LOTECT")
      Endif
      IF Type("EE8->EE8_NUMLOT") == "C"
         aAdd(aItemEnchoice,"EE8_NUMLOT")
      Endif
   Endif

   // ** JPM - 02/06/05 - Campo Tipo de comissão para o item
   If EE8->(FieldPos("EE8_TIPCOM")) > 0
      aAdd(aItemEnchoice,"EE8_TIPCOM")
   EndIf

   /* by jbj - 28/06/04 16:15 - Os campos de intermediação são disponibilizados para manutenção
                                apenas com a rotina de intermediação ligada e somente para a
                                filial do brasil. */

   If lIntermed .And. (xFilial("EE7") <> cFilEx)
      aAdd(aHDEnchoice,"EE7_INTERM")
      aAdd(aHDEnchoice,"EE7_COND2")
      aAdd(aHDEnchoice,"EE7_DIAS2")
      aAdd(aHDEnchoice,"EE7_INCO2")
      aAdd(aHDEnchoice,"EE7_PERC")
      aAdd(aItemEnchoice,"EE8_PRENEG")
      If EE8->(FieldPos("EE8_DIFE2")) <> 0
         aAdd(aItemEnchoice,"EE8_DIFE2") //ER - 28/12/05 às 14:50
      EndIf

      // ** JPM - 15/03/06 - Unidade de Medida do Preço de Negociação.
      nPos := AScan(aItemEnchoice,"EE8_UNPRNG")
      If lConvUnid .And. Type("EE8->EE8_UNPRNG") <> "U"
         If nPos = 0
            AAdd(aItemEnchoice,"EE8_UNPRNG")
         EndIf
      Else
         If nPos > 0
            ADel(aItemEnchoice,nPos)
            ASize(aItemEnchoice,Len(aItemEnchoice)-1)
         EndIf
      EndIf
      // **

   EndIf

   If lCommodity
      aAdd(aItemEnchoice,"EE8_VM_FIX")
      aAdd(aItemEnchoice,"EE8_MESFIX")
      aAdd(aItemEnchoice,"EE8_DTFIX ")
      aAdd(aItemEnchoice,"EE8_DIFERE")
      //aAdd(aItemEnchoice,"EE8_DTCOTA") RMD - 27/01/06
      aAdd(aItemEnchoice,"EE8_PRCFIX")
      aAdd(aItemEnchoice,"EE8_QTDFIX")
      aAdd(aItemEnchoice,"EE8_QTDLOT")
   EndIf

   If lConvUnid
      aAdd(aHDENCHOICE,"EE7_UNIDAD")  // Unidade de medida para a capa do pedido.
      aAdd(aItemEnchoice,"EE8_UNPRC") // Unidade de medida para o preco
      aAdd(aItemEnchoice,"EE8_UNPES") // Unidade de medida para o peso
   EndIf

   /* By JBJ - 26/07/04 - 14:09 - O campo de nro do rv fica disponível apenas para a filial brasil no caso
                                  de ambientes com a rotina de off-shore instalada. */
   If EE8->(FieldPos("EE8_RV")) > 0
      If lIntermed
         If (AvGetM0Fil() == cFilBr)
            aAdd(aItemEnchoice,"EE8_RV")
         EndIf
      Else
         aAdd(aItemEnchoice,"EE8_RV")
      EndIf
   Endif

   // JPM - 06/07/05 - Campos de vinculação a itens de L/C
   If EECFlags("ITENS_LC")
      If EasyGParam("MV_AVG0096",,.f.)
         aAdd(aItemEnchoice,"EE8_LC_NUM")
      EndIf
      aAdd(aItemEnchoice,"EE8_SEQ_LC")
   EndIf

   aAgEnchoice := {"EEB_CODAGE","EEB_NOME","EEB_TIPOAG"}
   aNoEnchoice := {"EEN_IMLOJA","EEN_IMPODE","EEN_IMPORT","EEN_ENDIMP","EEN_END2IM"}

   aAgEnchoice:= AddCpoUser(aAgEnchoice,"EEB","1")

   // ** By JBJ - 05/06/03 - 17:47 - Retirar campos para tratamento de comissao realizado por agente.
   If EECFlags("COMISSAO")
      // ** Capa do pedido.
      aDelCapa := {"EE7_TIPCOM","EE7_TIPCVL","EE7_VALCOM","EE7_REFAGE"}

      For j:=1 To Len(aDelCapa)
         nPos := aScan(aHDEnchoice,aDelCapa[j])
         If nPos > 0
            aHDEnchoice := aDel(aHDEnchoice,nPos)
            aHDEnchoice := aSize(aHDEnchoice,Len(aHDEnchoice)-1)   // By JPP - 09/12/04 10:55 - Correção do nome da variavel aHDEnchoice.
         EndIf
      Next

      aNewCapa:={"EE7_DSCCOM"}
      For y:=1 To Len(aNewCapa)
         aAdd(aHDEnchoice,aNewCapa[y])
      Next

      // ** Campos item.
      aNewCmpItem := {"EE8_CODAGE","EE8_DSCAGE","EE8_VLCOM"}
      For z:=1 To Len(aNewCmpItem)
         aAdd(aItemEnchoice,aNewCmpItem[z])
      Next
   EndIf

   //AOM - 21/06/2011 - Operacao Especial
   If AvFlags("OPERACAO_ESPECIAL")
      AAdd(aItemEnchoice,"EE8_CODOPE")
      AAdd(aItemEnchoice,"EE8_DESOPE")
   EndIF


   // ** JPM - 24/01/06 - Compra FOB
   If Type("lCompraFOB") = "L" .And. lCompraFOB
      AAdd(aItemEnchoice,"EE8_UNPRCC")
      AAdd(aItemEnchoice,"EE8_PRCCOM")
      AAdd(aItemEnchoice,"EE8_DIFCPR")
      AAdd(aHdEnchoice,"EE7_SHIPPE")
      AAdd(aHdEnchoice,"EE7_SHLOJA")
   Else
      If (nPos := AScan(aItemEnchoice,"EE8_UNPRCC")) > 0
         ADel(aItemEnchoice,nPos)
         ASize(aItemEnchoice,Len(aItemEnchoice)-1)
      EndIf
      If (nPos := AScan(aItemEnchoice,"EE8_PRCCOM")) > 0
         ADel(aItemEnchoice,nPos)
         ASize(aItemEnchoice,Len(aItemEnchoice)-1)
      EndIf
      If (nPos := AScan(aItemEnchoice,"EE8_DIFCPR")) > 0
         ADel(aItemEnchoice,nPos)
         ASize(aItemEnchoice,Len(aItemEnchoice)-1)
      EndIf
      If (nPos := AScan(aHdEnchoice,"EE7_SHIPPE")) > 0
         ADel(aHdEnchoice,nPos)
         ASize(aHdEnchoice,Len(aHdEnchoice)-1)
      EndIf
      If (nPos := AScan(aHdEnchoice,"EE7_SHLOJA")) > 0
         ADel(aHdEnchoice,nPos)
         ASize(aHdEnchoice,Len(aHdEnchoice)-1)
      EndIf
   EndIf
   // **

   // BAK - campo para ser gravado o pedido real da integracao
   If AvFlags("EEC_LOGIX") .And. EE8->(FieldPos("EE8_PEDERP")) > 0
      AAdd(aItemEnchoice,"EE8_PEDERP")
   EndIf

   If EECFlags("AMOSTRA_BASE")
      aAdd(aHdEnchoice, "EE7_AMBASE")
   EndIf

   If lIntPrePed
      AAdd(aHDEnchoice,"EE7_DTSLAP")
   EndIf

   /* by CAF 08/08/2001 14:48 - Controlar os campos que vão aparecer na tela pelo ATUSX para a versão padrão
   aDeEnchoice := {"EET_PEDIDO","EET_DESPES","EET_DESCDE","EET_DESADI",;
                   "EET_VALORR","EET_BASEAD","EET_DOCTO","EET_PAGOPO",;
                   "EET_RECEBE","EET_REFREC"}
   */
   aDeEnchoice := nil

   aInEnchoice := {"EEJ_CODIGO","EEJ_AGENCI","EEJ_NUMCON","EEJ_NOME","EEJ_TIPOBC","EEJ_FAVORE","EEJ_BENEDE"}

   // by CRF 25/10/2010 - 10:43
   aInEnchoice := AddCpoUser(aInEnchoice,"EEJ","1")

   //** Tratamento p/ o work de Embalagens...
   IF ! Inclui
      // ***** Grava WorkEm, com informacoes do EEK ***** \\
      If lItens    // TLM 14/12/2007 - Se os itens não forem copiados a função EECPPE07 não deve ser acionada.
         AP100WkEmb(EE7->EE7_PEDIDO,EE8->EE8_SEQUEN,EE8->EE8_EMBAL1)
      EndIf
   Endif

   //** Tratamento p/ o work de Agentes...
   bAddWork  := {|| WorkAg->(dbAppend()),AP100AGGrava(.T.,OC_PE)}
   EEB->(DBSETORDER(1))

   IF ! Inclui
      EEB->(dbSeek(xFilial("EEB")+EE7->EE7_PEDIDO+OC_PE))
      EEB->(dbEval(bAddWork,,{|| !EEB->(EOF()) .AND. EEB->EEB_FILIAL == xFilial("EEB") .And.;
            EEB->EEB_PEDIDO == EE7->EE7_PEDIDO.AND.EEB->EEB_OCORRE==OC_PE}))
   Endif

   //** Tratamento p/ o work de Instituicoes Financeiras ...
   bAddWork := {|| WorkIn->(dbAppend()),AP100INSGrava(.T.,OC_PE)}
   EEJ->(DBSETORDER(1))

   IF ! Inclui
      EEJ->(dbSeek(xFilial("EEJ")+EE7->EE7_PEDIDO+OC_PE))
      EEJ->(dbEval(bAddWork,,{||  !EEJ->(EOF()) .AND. EEJ->EEJ_FILIAL == xFilial("EEJ") .And.;
           EEJ->EEJ_PEDIDO == EE7->EE7_PEDIDO.AND.EEJ->EEJ_OCORRE==OC_PE}))
   Endif

   //** Tratamento p/ o work de Despesas ...
   bAddWork := {|| WorkDe->(dbAppend()),AP100DSGrava(.T.,OC_PE)}
   EET->(DBSETORDER(1))

   IF ! Inclui
      cKey := AVKey(EE7->EE7_PEDIDO,"EET_PEDIDO")
      EET->(dbSeek(xFilial("EET")+cKey+OC_PE))
      EET->(dbEval(bAddWork,,{||EET->EET_FILIAL == xFilial("EET") .And.;
              EET->EET_PEDIDO+EET->EET_OCORRE == AvKey(cKey,"EET_PEDIDO")+OC_PE}))
   Endif

   //** Tratamento p/ o work de Notify's ...
   bAddWork := {|| WorkNo->(dbAppend()),AP100NoGrv(.T.,OC_PE)}
   EEN->(DBSETORDER(1))

   IF ! Inclui
      EEN->(dbSeek(xFilial("EEN")+EE7->EE7_PEDIDO+OC_PE))
      EEN->(dbEval(bAddWork,,{||  !EEN->(EOF()) .AND. EEN->EEN_FILIAL == xFilial("EEN") .And.;
            EEN->EEN_PROCES == EE7->EE7_PEDIDO.AND.EEN->EEN_OCORRE==OC_PE}))
   Endif

   //** Tratamento p/ o work de atividades ...
   IF Select("EXB") > 0
      If !Inclui
         bAddWork := {|| AP100DocGrava(.T.,OC_PE)}
         aOrd := SaveOrd("EXB")
         EXB->(dbSetOrder(2))
         EXB->(dbSeek(xFilial("EXB")+AvKey("","EXB_PREEMB")+M->EE7_PEDIDO+"1"))
         EXB->(dbEval(bAddWork,,{|| EXB->(!Eof()) .And. EXB->EXB_FILIAL == xFilial("EXB") .And.;
                                    EXB->EXB_TIPO = "1" .And. EXB->EXB_PEDIDO == M->EE7_PEDIDO .And.;
                                    Empty(EXB->EXB_PREEMB)}))
         RestOrd(aOrd)
      EndIf
   Endif


   /*
   ER - 16/08/05. Carrega as arrays aEE8CamposEditaveis e aEE7CamposEditaveis, e permite que campos do pedido
                  definido no SX3 como X3_PROPRI = "U"(usuário) possam ser editados.
   */

   IF Len(aEE8CamposEditaveis) == 0
      aEE8CamposEditaveis := aClone(aItemEnchoice)

      SX3->(dbSeek("EE8"))

      While SX3->(!Eof() .and. X3_ARQUIVO = "EE8")
         If SX3->(X3_PROPRI = "U" .and. aScan(aEE8CamposEditaveis, {|x| x == AllTrim(X3_CAMPO)}) = 0)
            aAdd(aEE8CamposEditaveis, AllTrim(SX3->X3_CAMPO))
         EndIf
         SX3->(dbSkip())
      End

   EndIf

   IF len(aEE7CamposEditaveis) == 0
      aEE7CamposEditaveis := aClone(aHDEnchoice)

      SX3->(dbSeek("EE7"))
      While SX3->(!Eof() .and. X3_ARQUIVO = "EE7")
         If SX3->(X3_PROPRI = "U" .and. aScan(aEE7CamposEditaveis, {|x| x == AllTrim(X3_CAMPO)}) = 0)
            aAdd(aEE7CamposEditaveis, AllTrim(SX3->X3_CAMPO))
         EndIf
         SX3->(dbSkip())
      End
   EndIF

   If (Type("lEE7Auto") <> "L" .Or. !lEE7Auto) .And. EasyGParam("MV_AVG0094",, .F.) .and. EE7->(FieldPos("EE7_INTEGR") > 0 .and. EE7_INTEGR = "S")

     nPos := aScan(aEE8CamposEditaveis, "EE8_SLDINI")
      If nPos > 0
         aDel(aEE8CamposEditaveis,nPos)
         aSize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
      EndIf

   EndIf

   If nSelecao == APRVCRED .OR. (nSelecao <> INCLUIR .and. !Empty(EE7->EE7_DTAPCR))
      aAdd(aEE7CamposEditaveis, "EE7_DTAPCR")
   EndIf

   If lIntPrePed
      If aRotina[nSelecao][4] == APRVPROF .OR. (nSelecao <> INCLUIR .and. !Empty(EE7->EE7_DTAPPE))
         aAdd(aEE7CamposEditaveis, "EE7_DTAPPE")
      EndIf
   EndIf

   IF EasyEntryPoint("EECPPE07")
      ExecBlock("EECPPE07",.F.,.F.)
   Endif

End Sequence

RestOrd(aSaveOrd, .T.)

Return 

/*
Programa        : EECCAP102.PRW
Objetivo        : Gerar total fob e cif da tela de item do pedido
Autor           : Mauricio Frison
Data/Hora       : 14/12/2021
Obs.            :
*/
FUNCTION AP102GerTotIt()
   Local nVlrTotal //Variável qeu irá conter o frete, seguro, despesas e desconto a ser considerado no valor Cif
   Local nArredUnit := EasyGParam("MV_AVG0109",, 4)
   Local nArredTot  := EasyGParam("MV_AVG0110",, 2)   
   Local nCount := 2 //deixamos fixo 2, pois só interessa o rateio pra o item em questão
                     //2 para que não aplique o ajuste de diferença no próprio item, invalidando assim o rateio
   Local nDespIt,nFrtIt,nDescIt
   Local aDespesas := X3DIReturn(OC_PE)
   Local nFrtCapa := M->EE7_FRPREV + M->EE7_FRPCOM 
   Local nPrcTotCapa


   nVlrTotal:=0

   //MFR 14/12/2021 OSSME-6434
   //M->EE8_PRCINC := Round(M->EE8_PRECO * M->EE8_SLDINI,nArredTot) //Valor Fob
   //M->EE8_PRCTOT := Round(M->EE8_PRECO * M->EE8_SLDINI,nArredTot) //Valor Cif

   nVltotIt := (AvTransUnid(M->EE8_UNIDAD,M->EE8_UNPRC,M->EE8_COD_I,M->EE8_SLDINI,.F.); //Apura Valor Total do item
               *Round(M->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)))

   //MFR 14/12/2021 OSSME-6434 colocado abaixo da linha da conversão da unidade de medida        
   
   M->EE8_PRCINC := Round(nVltotIt,nArredTot) //Valor Fob
   M->EE8_PRCTOT := Round(nVltotIt,nArredTot) //Valor Cif                    


   If  nOpci == INC_DET
         nPrcTotCapa :=  M->EE7_TOTFOB  + nVltotIt   // Apura o valor novo total do processo na inclusão
   Else 
         nPrcTotCapa := M->EE7_TOTFOB - (WorkIt->EE8_PRECO * WORKIT->EE8_SLDATU) + nVltotIt  // Apura o valor novo total do processo na alteração               
   EndIf    

   nDespIt := AP100getDesp(aDespesas,nPrcTotCapa,nVltotIt,nCount,nArredUnit)
   nFrtIt  := AP100getFrt(nPrcTotCapa,nVltotIt,nCount,nArredUnit,nFrtCapa,M->EE7_PESLIQ,M->EE8_PSLQTO,M->EE7_PESBRU,M->EE8_PSBRTO)
   nDescIt := AP100getD(nPrcTotCapa,nVltotIt,nCount,nArredUnit,"M->EE7")

   nVlrTotal+= nDespIt + nFrtIt - nDescIt
   // Apura os valores finais para o valor fob e incoterm
   If nVlrTotal > 0
      IF M->EE7_PRECOA $ cSim
         M->EE8_PRCTOT+= nVlrTotal  //Valor incoterm
      Else
         M->EE8_PRCINC-= nVlrTotal //Valor Fob
         M->EE8_PRECOI := Round(M->EE8_PRCINC / M->EE8_SLDINI,nArredUnit)
      Endif
   EndIf   
 Return M->EE8_PRCINC


/*
Programa        : EECPPE07.PRW
Objetivo        : 1. calcular totais por itens e embalagens
Autor           : Heder M Oliveira
Data/Hora       : 18/07/99 Heder M Oliveira
Obs.            :
Revisão         : WFS 04/03/2010
                  Tratamentos de cálculo de pesos quando usado o recurso grade
*/
FUNCTION EECPPE07(ParamIXB,lOk,cCpo)
Local aGrdQtdEmb:= {}
Local cCpoCont:= ""

//Local lPesoManual := .f.
Local lBrutoXQtde := .f.
Local lRetPto := .t.          // By JPP - 17/06/2005 - 10:40
Local lLoop

Local nQtdEmb    := 0
Local nPesEmb    := 0
Local nQuant     := 0
Local nQe        := 0
Local nLinha     := 0
Local nColuna    := 0
Local nLinAcols  := 0
Local nQtdEmbItem:= 0

Private lPesoManual := .F.   //HFD - 09.mar.2009

Default lOk  := .f.
Default cCpo := ""

//WFS 22/04/09 - Para verificar se houve alteração na unidade de medida da capa do processo
Static cOldUn:= ""

Begin Sequence

   DO CASE
      CASE PARAMIXB=="PRECOS"

         AP102GerTotIt()

      CASE PARAMIXB=="PESOS_TRB"
           M->EE8_SLDINI := EE8->EE8_SLDINI
           M->EE8_PSLQUN := EE8->EE8_PSLQUN
           M->EE8_QTDEM1 := EE8->EE8_QTDEM1
           M->EE8_EMBAL1 := EE8->EE8_EMBAL1
           M->EE8_SEQUEN := EE8->EE8_SEQUEN
           M->EE8_QE     := EE8->EE8_QE
           M->EE8_PSBRUN := EE8->EE8_PSBRUN
           M->EE8_PSBRTO := EE8->EE8_PSBRTO
           M->EE8_PSLQTO := EE8->EE8_PSLQTO
           M->EE8_SLDATU := EE8->EE8_SLDATU

           EECPPE07("PESOS",.T.)

           WorkIt->EE8_PSLQTO := M->EE8_PSLQTO
           WorkIt->EE8_PSBRUN := M->EE8_PSBRUN
           WorkIt->EE8_PSBRTO := M->EE8_PSBRTO
           If lGrade
              WorkIt->EE8_QTDEM1:= M->EE8_QTDEM1
           EndIf

      CASE PARAMIXB=="PESOS" //CALCULO DE PESO LIQUIDOS E BRUTOS
           If Type("lArtificial") = "L"// chamada das rotinas da MsGetDb
              lLoop := !lArtificial .And. lConsolItem
           Else
              lLoop := .f.
           EndIf

           If lLoop
              AuxIt->(DbGoTop())
           EndIf

           While If(lLoop,AuxIt->(!Eof()),.t.)
              If lLoop
                 If AuxIt->DBDELETE
                    AuxIt->(DbSkip())
                    Loop
                 EndIf
                 Ap104AuxIt(3,,.t.) //Carrega variáveis de memória
              EndIf

               // Digitação de peso total por linha
               lPesoManual := GetNewPar("MV_AVG0009",.F.) .Or. (SB1->(FieldPos("B1_REPOSIC")) > 0 .AND. Posicione("SB1",1,xFilial("SB1")+workit->EE8_COD_I,"B1_REPOSIC") $cSim)

               // ** JPM - 23/02/06 - Quando um dos pesos totais não estiver preenchido, então o sistema deve recalcular.
               If lPesoManual .And. (Empty(M->EE8_PSLQTO) .Or. Empty(M->EE8_PSBRTO))
                  lPesoManual := .F.
               EndIf

               // ** JPM - 23/02/06 - Quando o usuário digitar os seguintes campos, deve forçar o recálculo dos pesos totais
               If lPesoManual .And. cCpo $ "EE8_SLDINI/EE8_EMBAL1/EE8_PSLQUN/EE8_QTDEM1/EE8_PSBRUN/"
                  lPesoManual := .F.
               EndIf

               // Calcula Peso Bruto Total = Qtde*Peso Bruto Unit.
               lBrutoXQtde := EasyGParam("MV_AVG0063",,.F.)
               If EasyEntryPoint("EECAP102") // By JPP - 17/06/05 - 10:40 - Inclusão do ponto de entrada
                  lRetPto := ExecBlock("EECAP102",.f.,.f.,{"PE_PESOS"})
                  If ValType(lRetPto) <> "L"
                     lRetPto := .t.
                  EndIf
               EndIf
               IF ! lPesoManual .And. ! lOk
                  M->EE8_PSLQTO:=M->EE8_SLDINI*M->EE8_PSLQUN //PESO LIQUIDO TOTAL
               Endif


               //WFS - 22/04/09 ---
               //Quando carrega a primeira vez, os conteúdos da Work e da Memória são os mesmos.
               If WorkIt->EE8_UNPES == M->EE8_UNPES
                  cOldUn:= M->EE8_UNPES
               EndIf

               //Se estiver em branco, assume o padrão do sistema (kg).
               If Empty(cOldUn)
                  cOldUn:= "KG"
               EndIf
               //Verifica se a conversão de unidade de medida está cadastrada
               If AvTransUnid(cOldUn, M->EE8_UNPES, M->EE8_COD_I, M->EE8_PSLQUN, .T.) == Nil
                  EasyHelp(STR0094 + cOldUn + STR0095 + M->EE8_UNPES + STR0104 + ENTER +; //STR0094 "A conversão de " //STR0095 "para" //STR0104 "  não está cadastrada."
                           STR0096, STR0051) //Atenção // STR0096 "Acesse Atualizações/ Tabelas Siscomex para realizar o cadastro."
                  M->EE8_UNPES:= cOldUn
                  Break
               Else
                  cOldUn:= M->EE8_UNPES
               EndIf
               //---


               If lRetPto // By JPP - 17/06/05 - 10:40 - Se for falso não calcula os pesos.
                  IF !lBrutoXQtde .And. M->EE7_BRUEMB $ cSim

                     //CALCULAR PESOS BRUTOS
                     EE5->(DBSETORDER(1))
                     EE5->(DBSEEK(XFILIAL("EE5")+M->EE8_EMBAL1))

                     M->EE8_PSBRUN:=(M->EE8_PSLQUN*M->EE8_QE)+AvTransUnid("KG", If(ValType(M->EE8_UNPES) == "C", M->EE8_UNPES, WorkIt->EE8_UNPES), If(ValType(M->EE8_COD_I) == "C", M->EE8_COD_I, WorkIt->EE8_COD_I), EE5->EE5_PESO, .F.)

                     // LCS.01/11/2005 - 10:25
                     IF EasyEntryPoint("EECPPE07")
                        ExecBlock("EECPPE07",.F.,.F.,"PSBRUN")
                     Endif

                     IF ! lPesoManual .And. ! lOk

                        /***************************
                           WFS 04/03/2010 - Tratamentos de cálculo dos pesos quando usado o recurso grade
                           Considerando 3 itens do tipo grade:
                           1º com 10 un.
                           2º com 20 un.
                           3º com 10 un.
                           e uma embalagem onde seja possível colocar 20 unidades.
                           A quantidade total será 40 un. e, o com o cálculo padrão, a quantidade de embalagem será
                           2. No entanto, quando a grade estiver habilitada, após a gravação do processo serão gerados
                           três registros para os itens, totalizando 3 embalagens, duas delas com uma quantidade menor
                           do produto do que o comportado pela embalagem.
                           Outra implementação se refere à multiplas embalagens. Neste caso foi criado o array aGrdQtdEmb
                           que conterá a quantidade de embalagens para cada item digitado na grade, de modo a calcular
                           o acúmulo dos pesos das embalagens vinculadas à principal.
                        *************************************************************************************************/

                        If nOpcI == INC_DET
                           nLinAcols:= WorkIt->(EasyRecCount()) + 1
                        Else
                           nLinAcols:= WorkIt->(RecNo())
                        EndIf

                        cCpoCont:= M->EE8_COD_I
                        nQe     := M->EE8_QE

                        If lGrade .And. MatGrdPrrf(@cCpoCont)

                           nQtdEmb:= 0
                           nQtdEmbItem:= 0

                           For nLinha:= 1 To Len(oGrdExp:aColsGrade[nLinAcols])
                              For nColuna:= 2 To Len(oGrdExp:aHeadGrade[nLinAcols])

                                 nQuant:= oGrdExp:aColsFieldByName("EE8_SLDINI", nLinAcols, nLinha, nColuna)

                                 If nQuant > 0
                                    If nQuant <= nQe
                                       nQtdEmb += 1
                                       nQtdEmbItem:= 1
                                    Else
                                       If (nQuant % nQe) > 0
                                          nQtdEmb += Int(nQuant / nQe) + 1
                                          nQtdEmbItem:= Int(nQuant / nQe) + 1
                                       Else
                                          nQtdEmb += nQuant / nQe
                                          nQtdEmbItem:= Int(nQuant / nQe)
                                       EndIf
                                    EndIf
                                    AAdd(aGrdQtdEmb, nQtdEmbItem)
                                    nQtdEmbItem:= 0
                                 EndIf
                              Next
                           Next
                           M->EE8_QTDEM1:= nQtdEmb
                        ElseIf !Empty(M->EE8_QE)

                           nQuant     := M->EE8_SLDINI
                           nQe        := M->EE8_QE

                           If nQuant <= nQe
                              nQtdEmb := 1
                           Else
                              If (nQuant % nQe) > 0
                                 nQtdEmb := Int(nQuant / nQe) + 1
                              Else
                                 nQtdEmb := nQuant / nQe
                              EndIf
                           EndIf
                        EndIf

                        nPesEmb:= nQtdEmb * AvTransUnid("KG", If(ValType(M->EE8_UNPES) == "C", M->EE8_UNPES, WorkIt->EE8_UNPES),;
                                    If(ValType(M->EE8_COD_I) == "C", M->EE8_COD_I, WorkIt->EE8_COD_I), EE5->EE5_PESO, .F.)

                        If lGrade
                           For nLinha:= 1 To Len(aGrdQtdEmb)
                              nPesEmb += MultiEmbal(aGrdQtdEmb[nLinha], M->EE8_EMBAL1)
                           Next
                        Else
                           nPesEmb += MultiEmbal(nQtdEmb, M->EE8_EMBAL1)
                        EndIf

                        M->EE8_PSBRTO := M->EE8_PSLQTO + nPesEmb

                     Endif
                  ELSE
                     // Alterado por Heder M Oliveira - 2/21/2000
                     M->EE8_PSBRUN:=IF(EMPTY(M->EE8_PSBRUN),M->EE8_PSLQUN,M->EE8_PSBRUN)//PESO BRUTO UNITARIO

                     // LCS.01/11/2005 - 10:25
                     IF EasyEntryPoint("EECPPE07")
                        ExecBlock("EECPPE07",.F.,.F.,"PSBRUN")
                     Endif

                     IF ! lPesoManual .And. ! lOk
                        IF !lBrutoXQtde
                           M->EE8_PSBRTO:=M->EE8_QTDEM1*M->EE8_PSBRUN //PESO BRUTO TOTAL
                        Else
                           M->EE8_PSBRTO:=M->EE8_SLDINI*M->EE8_PSBRUN //PESO BRUTO TOTAL
                        Endif
                     Endif
                  ENDIF
               EndIf

              If lLoop
                 Ap104AuxIt(4,.t.,.t.)
                 AuxIt->(DbSkip())
              Else
                 Exit
              EndIf
           EndDo

           If lLoop
              Ap104AuxIt(7,.t.)
              AuxIt->(DbGoTop())
           EndIf

      CASE PARAMIXB=="EMBALA" //CALCULO DE QUANTIDADE DE EMBALAGENS

           CalcEmbalagem()

      CASE PARAMIXB=="CALCEMB"
           AP100WkEmb(M->EE7_PEDIDO,M->EE8_SEQUEN,M->EE8_EMBAL1)

   ENDCASE

   lREFRESH:=.T.

End Sequence

RETURN .t.


/*
Programa        : MultiEmbal
Objetivo        : Calcular o peso de multiplas embalagens
Parâmetros      : nQtdEmb - quantidade da embalagem principal
                : cEmbalagem - embalagem principal
Retorno         : nPesEmb - peso total das múltiplas embalagens
Autor           : Wilsimar Fabrício da Silva
Data/Hora       : 05/03/2010
Obs.            :
Revisão         :
*/

Static Function MultiEmbal(nQtdEmb, cEmbalagem)
Local aOrd     := SaveOrd({"EEK", "EE5"})
Local nPesEmb  := 0
Local cLastEmb := ""

Default nQtdEmb:= 0
Default cEmbalagem:= ""

Begin Sequence

   EE5->(DBSetOrder(1)) //EE5_FILIAL + EE5_CODEMB
   EEK->(DBSetOrder(1)) //EEK_FILIAL + EEK_TIPO + EEK_CODIGO + EEK_SEQ

   If EEK->(DBSeek(xFilial("EEK") + OC_EMBA + cEmbalagem))

      While EEK->(!Eof()) .And.;
            EEK->EEK_FILIAL == xFilial("EEK") .And.;
            EEK->EEK_TIPO   == OC_EMBA .And.;
            EEK->EEK_CODIGO == cEmbalagem

         If EE5->(DBSeek(xFilial("EE5") + EEK->EEK_EMB))

            If nQtdEmb <= EEK->EEK_QTDE
               nQtdEmb:= 1
            Else
               If (nQtdEmb % EEK->EEK_QTDE) > 0
                  nQtdEmb:= Int(nQtdEmb / EEK->EEK_QTDE) + 1
               Else
                  nQtdEmb:= nQtdEmb / EEK->EEK_QTDE
               EndIf
            EndIf

            nPesEmb += (AvTransUnid("KG", If(ValType(M->EE8_UNPES) == "C", M->EE8_UNPES, WorkIt->EE8_UNPES),;
                     If(ValType(M->EE8_COD_I) == "C", M->EE8_COD_I, WorkIt->EE8_COD_I), EE5->EE5_PESO, .F.) * nQtdEmb)
            cLastEmb := EEK->EEK_EMB
         EndIf

         EEK->(dbSkip())
         // quando o código for diferente é que passou pelo último resgistro e caso já tenha passado não passa de novo
         If !AvFlags("EEC_LOGIX") .And. EEK->EEK_CODIGO <> cEmbalagem
            If !EEK->(DBSeek(xFilial("EEK") + OC_EMBA + cLastEmb))
               Exit
            else
               cEmbalagem:= cLastEmb // depois de posicionar cEnbalagem recebe o último registro para fazer o loop novamente
            EndIf
         EndIf

      EndDo
   EndIf

End Sequence

RestOrd(aOrd)
Return nPesEmb


/*
Programa        : CalcEmbalagem
Objetivo        :
Parâmetros      : lWork
Retorno         :
Autor           :
Data/Hora       :
Obs.            :
Revisão         :
*/

STATIC FUNCTION CalcEmbalagem( lWork )

   Local nRecWork := WorkEm->(RecNo())
   Local nOrdWork := WorkEm->(IndexOrd())

   Local nRecEEK  := EEK->(RecNo())
   Local nOrdEEK  := EEK->(IndexOrd())

   Local nQtdeEmb := M->EE8_QTDEM1

   Default lWork := .F.

   If Type("lEE7Auto") <> "L"
      lEE7Auto:= .F.
   EndIf

   EEK->(dbSetOrder(1))

   WorkEm->(dbSetOrder(1))
   WorkEm->(dbSeek(M->EE7_PEDIDO+M->EE8_SEQUEN+M->EE8_EMBAL1))

   While !WORKEM->(Eof()) .And. WORKEM->(EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO) ==;
                                 M->EE7_PEDIDO+M->EE8_SEQUEN+M->EE8_EMBAL1

      IF EEK->(dbSeek(xFilial("EEK")+OC_EMBA+WorkEm->EEK_CODIGO+WorkEm->EEK_SEQ))
         IF ( nQtdeEmb % EEK->EEK_QTDE ) != 0
            IF ! lWork
               If !lEE7Auto                                                                      //NCF - 17/10/2013
                  //MsgStop(STR0036+AllTrim(WorkEm->EEK_EMB)+STR0037,STR0038) //"Embalagem "###" com espaço livre !"###"Aviso"
                    MsgInfo(STR0110 + " '" +; //"A embalagem Cod.:"
                            AllTrim(WorkEm->EEK_EMB) + "' " + STR0003 + ": " +; //"Descrição"
                            "'" + Alltrim(Posicione("EE5", 1, xFilial("EE5")+WorkEm->EEK_EMB, "EE5_DESC")) + "' "+;
                            STR0111 + ENTER + STR0112,; //"possui espaço livre." "Avalie se a distribuição de embalagens está correta."
                            STR0038) //"Aviso"
               EndIf
            ENDIF
            // WorkEm->EEK_QTDE := Val(Str(nQtdeEmb/EEK->EEK_QTDE,AVSX3("EEK_QTDE",AV_TAMANHO),AVSX3("EEK_QTDE",4)))
            WorkEm->EEK_QTDE := Int(nQtdeEmb/EEK->EEK_QTDE)+1
         Else
            // *** caf 23/12/1999 WorkEm->EEK_QTDE := Int(nQtdeEmb/EEK->EEK_QTDE)
            WorkEm->EEK_QTDE := nQtdeEmb/EEK->EEK_QTDE
         Endif

         nQtdeEmb         := WorkEm->EEK_QTDE
      Endif
      WorkEm->(dbSkip())
   Enddo

   WorkEm->(dbSetOrder(nOrdWork))
   WorkEm->(dbGoTo(nRecWork))

   EEK->(dbSetOrder(nOrdEEK))
   EEK->(dbGoTo(nRecEEK))

Return NIL

*-----------------------------------------------------------------------------*
* FIM DO PROGRAMA EECPPE07.PRW                                                *
*-----------------------------------------------------------------------------*

/*
Funcao      : AP100Crit(cCampo)
Parametros  : cCampo:= Campo a ser validado
Retorno     : .T./.F.
Objetivos   : Validar dados lancados
Autor       : Heder M Oliveira
Data/Hora   : 11/01/98 13:50
Revisao     :
Obs.        :
*/
Function AP100Crit(cCampo,lMENSA,lOK)
   Local lRet:=.T.,cOldArea:=select(),cSK:="",cMenserr:="",cCOMPERR , nVar := 0 , cSeek:="", nRec:=0, nTaxa1 , nTaxa2
   Local nOrdSY9,nTotal := 0, i,;
         bTotal := {|| nTotal += If(lConvUnid,;
                                    (AvTransUnid(WorkIt->EE8_UNIDAD,WorkIt->EE8_UNPRC,WorkIt->EE8_COD_I,WorkIt->EE8_SLDINI,.F.)*;
                                     WorkIt->EE8_PRECO),WorkIt->(EE8_SLDINI*EE8_PRECO))}

   Local aORD:=SAVEORD({"SY9","SY6","EE9"}), lAux,  cTipmen:="",nFob:=0
   Local nA,nB,nC,nD, lAtuStatus := .t.
   Local cFil, /*cFilEx, cFilBr,*/ aUnid
   Local cMsg, nSaldo, nTotalAEmb, nSldLC, nSldLCReais, cPreemb, aProdutos, lControlaPeso
   Local nPos := 0

   Local nTaxaSeguro := EasyGParam("MV_AVG0124",,10)
   Local aOrdEXJ := SaveOrd("EXJ") //MCF - 11/05/2015
   Local nPreco 
   Local nDesconto
   //LOCAL aORDSX3 := {SX3->(INDEXORD()),SX3->(RECNO())}
   Default lMENSA:=.T.,lOK:=.F.
   Private lmsgDescon:= .T.
   Begin Sequence

      //DFS - 05/10/12 - Verifica o tipo da variavel
      If Type("lFaturado") <> "L"
         lFaturado := .F.
      EndIf
      //MFR 01/10/2019 OSSME-3309
      If ExistBlock("EECAP102")
         ExecBlock("EECAP102",.F.,.F.,{"AP100CRIT",cCampo})
      Endif
      
      Do Case

         Case cCampo == "EE7_PEDIDO"
             IF M->EE7_STATUS <> ST_RV .And. Left(AllTrim(M->EE7_PEDIDO), 1) == "*"
                EasyHelp(STR0062, STR0049) //"O No. do Pedido não pode conter *, como simbolo inicial. Definição reservada para Pedido especial com R.V. sem vinculação."
                lRet := .F.
             EndIf
             If lIntermed
                lRet := AP104VldOffShore(nSelecao, xFilial("EE7") == cFilBr)
             EndIf

         Case cCampo == "EE7_DTPEDI"
             IF M->EE7_DTPEDI > M->EE7_DTPROC
                Help(" ",1,"AVG0000083")
                lRet := .F.
             Endif

         Case cCampo =="EE7_DTSLCR"
             If !EMPTY(M->EE7_DTSLCR) .AND. M->EE7_DTSLCR < M->EE7_DTPEDI
                 HELP(" ",1,"AVG0000068")
                 lRET:=.F.
             ELSEIF EMPTY(M->EE7_DTSLCR)
                 IF M->EE7_STATUS <> ST_RV
                    M->EE7_STATUS:=ST_SC
                    //atualizar descricao de status
                    DSCSITEE7()
                 Endif
             EndIf
         Case cCampo =="EE7_DTAPCR"
             //atualizar status e validar se dt. apr. credito >=dt sol.credit
             If EMPTY(M->EE7_DTAPCR)
                IF M->EE7_STATUS <> ST_RV
                   IF ( !EMPTY(M->EE7_DTSLCR) )
                      M->EE7_STATUS:=ST_LC
                   ELSE
                      M->EE7_STATUS:=ST_SC
                   ENDIF
                   DSCSITEE7()
                Endif
             ELSEIf M->EE7_DTAPCR < M->EE7_DTSLCR
                HELP(" ",1,"AVG0000069")
                lRET:=.F.
             ElseIf M->EE7_TOTITE==0
                HELP(" ",1,"AVG0000070")
                lRET:=.F.
             ELSEIF EMPTY(M->EE7_DTSLCR) .and. lAPROVA
                 HELP(" ",1,"AVG0000071")
                 lRET:=.F.
             Else

                 IF !Inclui
                    aOrdEE9 := SaveOrd("EE9",1)
                    lAtuStatus := ! EE9->(dbSeek(xFilial()+M->EE7_PEDIDO))
                    RestOrd(aOrdEE9,.T.)
                 Endif

                 IF M->EE7_STATUS == ST_RV
                    lAtuStatus := .f.
                 Endif

                 IF lAtuStatus
                    M->EE7_STATUS:=ST_CL
                 Endif
                 //atualizar descricao de status
                 DSCSITEE7()
             EndIf
         Case cCampo =="EE7_DTSLAP"
             If !EMPTY(M->EE7_DTSLAP)
                If M->EE7_DTSLAP < M->EE7_DTPEDI
                   MsgAlert("Data de Solicitação de Aprovação da Proforma não pode ser menor que a data de sua emissão!","AVISO")//HELP(" ",1,"AVG0000068")
                   lRET:=.F.
                Else
                   M->EE7_STATUS:= ST_AP ////Aguardando Aprovação da Proforma
                EndIf
             ELSEIF EMPTY(M->EE7_DTSLAP)
                 M->EE7_STATUS:= ST_PB
             EndIf
             //atualizar descricao de status
             DSCSITEE7()

         Case cCampo =="EE7_DTAPPE"
            //atualizar status e validar se dt. aprv. proforma >=dt Pedido
            If EMPTY(M->EE7_DTAPPE)
               //IF M->EE7_STATUS <> ST_CL //wfs - a aprovação do crédito ocorrerá no ERP
                  IF ( !EMPTY(M->EE7_DTSLAP) )
                     M->EE7_STATUS:= ST_AP ////Aguardando Aprovação da Proforma
                  ELSE
                     M->EE7_STATUS:= ST_PB //Proforma em Edição //ST_CL
                  ENDIF
                  DSCSITEE7()
               //Endif
            ELSEIf M->EE7_DTAPPE < M->EE7_DTSLAP
               MsgAlert("Data de Aprovação da Proforma não pode ser menor que a data de Solicitação da Aprovação!","AVISO")//HELP(" ",1,"AVG0000069")
               lRET:=.F.
            ElseIf M->EE7_TOTITE==0
               HELP(" ",1,"AVG0000070")
               lRET:=.F.
            ElseIf M->EE7_DTAPPE < M->EE7_DTPEDI
               MsgAlert('Data de aprovação da Proforma não pode ser menor que a data de sua emissão!','AVISO')
               lRET := .F.
            ElseIf EMPTY(M->EE7_DTSLAP) .And. lAPROVAPF
               MsgAlert('Nao e possivel aprovar a Proforma uma vez que a data de solicitacao de aprovacao nao foi informada!','AVISO')
               lRET := .F.
            Else

               IF !Inclui
                  aOrdEE9 := SaveOrd("EE9",1)
                  lAtuStatus := ! EE9->(dbSeek(xFilial()+M->EE7_PEDIDO))
                  RestOrd(aOrdEE9,.T.)
               Endif

               IF M->EE7_STATUS == ST_PA
                  lAtuStatus := .f.
               Endif

               IF lAtuStatus
                  M->EE7_STATUS := ST_PA
               Endif
               //atualizar descricao de status
               DSCSITEE7()
            EndIf

         CASE cCAMPO = "EE7_GPV"
              IF M->EE7_GPV $ cNAO
                 lREFRESH      := .T.
               //M->EE7_DTSLCR := M->EE7_DTPROC //LRS 29/11/2013
               //M->EE7_DTAPCR := M->EE7_DTPROC //LRS 29/11/2013
                 IF M->EE7_STATUS <> ST_RV
                    M->EE7_STATUS := ST_SC //LRS 29/11/2013 - Trocado o Status para "aguardando solicitacao de credito"
                    DSCSITEE7() //atualizar descricao de status
                 Endif
              ENDIF
         CASE cCAMPO == "EE7_AMOSTR"

            IF !lLibCredAuto
               cOpcao := AP102CboxAmo("M->EE7_AMOSTR")  // GFP - 03/11/2015
               IF (cOpcao == "2")  // GFP - 03/11/2015
                  IF M->EE7_STATUS <> ST_RV
                     If lIntegra
                        M->EE7_STATUS:= ST_AF
                     Else
                        M->EE7_STATUS:=ST_CL
                     EndIF
                  Endif
               ENDIF
               IF (cOpcao <> "2")  // GFP - 03/11/2015
                  lREFRESH:=.T.
                  M->EE7_DTSLCR:=M->EE7_DTPROC
                  M->EE7_DTAPCR:=M->EE7_DTPROC

                  // ** By JBJ - 28/08/01 - 10:59
                  IF M->EE7_STATUS <> ST_RV
                     If (cOpcao == "4") .AND. lIntegra  // GFP - 03/11/2015
                        M->EE7_STATUS:= ST_AF
                     Else
                        M->EE7_STATUS:=ST_CL
                     EndIF
                  Endif
                  // **

                //atualizar descricao de status
                DSCSITEE7()

               ELSEIF (nSelecao = 3) .or. (lALTERA .AND. !lAPROVA .AND. EMPTY(M->EE7_DTAPCR)) .or. (lALTERA .AND. !lAPROVAPF .AND. If(lIntPrePed,EMPTY(M->EE7_DTAPPE),.T.) )
                  lREFRESH:=.T.

                  If !lOk //Não limpa quando for gravação.
                     M->EE7_DTSLCR := CriaVar("EE7_DTSLCR")
                     M->EE7_DTAPCR := CriaVar("EE7_DTAPCR")
                     If lIntPrePed
                        M->EE7_DTSLAP := CriaVar("EE7_DTSLAP")
                        M->EE7_DTAPPE := CriaVar("EE7_DTAPPE")
                     EndIf
                  EndIf

                   // ** By JBJ - 28/08/01 - 11:13
                  IF M->EE7_STATUS <> ST_RV .AND. EE7->EE7_STATUS < ST_AE    // GFP - 24/10/2014
                     If lIntegra .And. !lFaturado
                        M->EE7_STATUS:=ST_AF
                     ElseIf lFaturado //DFS - 08/11/10 - Inclusão de Status Faturado.
                        M->EE7_STATUS:=ST_FA
                     Else
                        If Empty(M->EE7_DTSLCR)
                           M->EE7_STATUS := ST_SC //Aguardando solicitacao de credito.
                        Else
                           M->EE7_STATUS := ST_LC //Aguardando liberacao de credito.
                        EndIf
                     EndIf
                  Endif
               Endif
               //atualizar descricao de status
               DSCSITEE7()
            ENDIF
         Case cCampo == "EE7_FRPREV"  //necessario lancar frete
             If Type("lEE7Auto") == "L" .And. !lEE7Auto
                SYJ->(DBSETORDER(1))
                SYJ->(DBSEEK(XFILIAL("SYJ")+M->EE7_INCOTE))
                If SYJ->YJ_CLFRETE $ cSim .and. M->EE7_FRPREV==0
                   If AVFLAGS("EEC_LOGIX_PREPED") //05/05/2014 - Não permite gravar seguro zerado se incoterm prever Seguro
                      lRet:=.F.                   //             e integração para envio do pedido ao ERP LOGIX estiver ativa
                   Else
                      lRet:=.T.
                   EndIf
                   HELP(" ",1,"AVG0000066",,"FRETE",2,1)
                ElseIf SYJ->YJ_CLFRETE $ cNao .AND. M->EE7_FRPREV#0
                    lRet:=.F.
                    M->EE7_FRPREV:=0
                    HELP(" ",1,"AVG0000067",,"FRETE",2,1)
                EndIf
             Else
                lRet := .T.
             EndIf

         Case cCampo == "EE7_SEGPRE" .OR. cCampo == "EE7_SEGURO"
               SYJ->(dbSetOrder(1))
               SYJ->(dbSeek(XFILIAL("SYJ")+M->EE7_INCOTE))

               //ER - Utilização de Parametro para Calcular taxa de Seguro
               nTaxaSeguro := 1 + (nTaxaSeguro / 100)

               If cCampo == "EE7_SEGURO"
                  IF ( M->EE7_SEGURO # 0 )
                     IF M->EE7_PRECOA $ cSim
                        nRecNo := WorkIt->(RecNo())
                        WorkIt->(dbGoTop())
                        WorkIt->(dbEval(bTotal,{||.t.}))
                        WorkIt->(dbGoTo(nRecNo))

                        IF EE7->(FieldPos("EE7_DESSEG")) > 0 .And. M->EE7_DESSEG == "1" //LRS - 11/09/2015
                           nA            := nTOTAL + M->EE7_FRPREV - M->EE7_DESCON
                        Else
                           nA            := nTOTAL+M->EE7_FRPREV
                        EndIF

                        nB            := (M->EE7_SEGURO/100) * nTaxaSeguro
                        nC            := 1 - nB
                        nD            := nA / nC

                        If EasyGParam("MV_AVG0183", .F., .F.) //habilita o cálculo direto do seguro previsto (total x percentual do seguro)
                           //WFS 28/07/2009 - Alterado como melhoria, conforme chamado 077797.
                           M->EE7_SEGPRE := ROUND(nA * nB,AVSX3("EE7_SEGPRE",AV_DECIMAL))
                        Else
                           M->EE7_SEGPRE := ROUND(nD-nA,AVSX3("EE7_SEGPRE",AV_DECIMAL))
                        EndIf
                     Else
                        M->EE7_SEGPRE := ROUND(M->EE7_TOTPED*nTaxaSeguro*(M->EE7_SEGURO/100),AVSX3("EE7_SEGPRE",AV_DECIMAL))
                     Endif
                  Else
                     If lMENSA .And. M->EE7_TIPSEG == "1"
                        M->EE7_SEGPRE := 0
                     EndIf

                  Endif
               ElseIf cCampo == "EE7_SEGPRE"

                  If lMensa .And. !lOk
                     M->EE7_SEGURO := 0
                  EndIf
               EndIf

               If Type("lEE7Auto") == "L" .And. !lEE7Auto
                  If SYJ->YJ_CLSEGUR $ cSim .and. (M->EE7_SEGPRE==0.AND.M->EE7_SEGURO==0)
                     If AVFLAGS("EEC_LOGIX_PREPED") //05/05/2014 - Não permite gravar seguro zerado se incoterm prever Seguro
                        lRet:=.F.                   //             e integração para envio do pedido ao ERP LOGIX estiver ativa
                     Else
                        lRet:=.T.
                     EndIf
                     IF ( lMENSA ) .and. cCampo == "EE7_SEGPRE"
                        HELP(" ",1,"AVG0000066",,"SEGURO",2,1)
                     ENDIF
                  ElseIf SYJ->YJ_CLSEGUR $ cNao .AND. (M->EE7_SEGPRE#0.OR.M->EE7_SEGURO#0)
                     lRet:=.F.
                     M->EE7_SEGPRE:=0
                     M->EE7_SEGURO:=0
                     IF ( lMENSA ) .and. cCampo == "EE7_SEGPRE"
                        HELP(" ",1,"AVG0000067",,"SEGURO",2,1)
                     ENDIF
                  EndIf
               Else
                  lRet := .T.
               EndIf

               // by CAF 15/03/2000 14:07
               IF lMensa
                  AP100PrecoI(,,.T.)//LRS - 25/10/2018
               Endif

               lREFRESH:=.T.

         Case cCampo $ "EE7_IMPORT|EE7_IMLOJA"

             If nSelecao == ALTERAR .And. (M->EE7_IMPORT <> EE7->EE7_IMPORT .or. (!Empty(M->EE7_IMLOJA) .And. M->EE7_IMLOJA <> EE7->EE7_IMLOJA)) .And. EE9->(DbSetOrder(1),DbSeek(xFilial()+M->EE7_PEDIDO))
                EasyHelp(STR0089,STR0051)//"O pedido possui vinculação com processo de embarque, portanto o importador não poderá ser alterado."###"Atenção"
                lRet := .F.
                Break
             EndIf

            lRet := TEVlCliFor(M->EE7_IMPORT,M->EE7_IMLOJA,"SA1","1|4")

            IF lRET .AND. SA1->(dbSetOrder(1),MSSeek(xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA))
                if ! EMPTY(SA1->A1_CONDPAG) .AND. ! lOK
                    M->EE7_CONDPA := SA1->A1_CONDPAG
                    M->EE7_DIASPA := SA1->A1_DIASPAG
                    SY6->(DBSETORDER(1),DBSEEK(XFILIAL("SY6")+M->EE7_CONDPA+STR(M->EE7_DIASPA,AVSX3("EE7_DIASPA",AV_TAMANHO),0)))
                    M->EE7_DESCPA := MSMM(SY6->Y6_DESC_P,50,1)
                Endif
                If EXJ->(dbSetOrder(1),dbSeek(xFilial("EXJ")+M->EE7_IMPORT+M->EE7_IMLOJA))
                    cVia := ""
                    Do Case
                        Case !Empty(SA1->A1_DEST_1) .OR. (EXJ->(FieldPos("EXJ_ORI_1")) # 0 .And. !Empty(EXJ->EXJ_ORI_1)) //MCF - 11/05/2015
                            cVia := AP102ViaTrans(.F.)//If(EXJ->(FieldPos("EXJ_ORI_1"))#0,EXJ->EXJ_ORI_1,""),SA1->A1_DEST_1)
                        Case !Empty(SA1->A1_DEST_2) .OR. (EXJ->(FieldPos("EXJ_ORI_2")) # 0 .And. !Empty(EXJ->EXJ_ORI_2))  //TRP - 14/05/2015 - FIELDPOS()
                            cVia := AP102ViaTrans(.F.)//If(EXJ->(FieldPos("EXJ_ORI_2"))#0,EXJ->EXJ_ORI_2,""),SA1->A1_DEST_2)
                        Case !Empty(SA1->A1_DEST_3) .OR. (EXJ->(FieldPos("EXJ_ORI_3")) # 0 .And. !Empty(EXJ->EXJ_ORI_3)) //TRP - 14/05/2015 - FIELDPOS()
                            cVia := AP102ViaTrans(.F.)//If(EXJ->(FieldPos("EXJ_ORI_3"))#0,EXJ->EXJ_ORI_3,""),SA1->A1_DEST_3)
                    End Case
                    If !Empty(cVia) .And. Empty(M->EE7_VIA) //MCF - 11/05/2015
                        M->EE7_VIA := AllTrim(cVia)
                        lGatVia := .T.
                        AP100Crit("EE7_VIA")
                        lGatVia := .F.
                    Endif
                EndIf
                cDestino := ""
                Do Case
                    Case !Empty(SA1->A1_DEST_1)
                        cDestino := Posicione("SYR",4,xFilial("EE4")+SA1->A1_DEST_1,"YR_VIA")
                    Case !Empty(SA1->A1_DEST_2)
                        cDestino := Posicione("SYR",4,xFilial("EE4")+SA1->A1_DEST_2,"YR_VIA")
                    Case !Empty(SA1->A1_DEST_3)
                        cDestino := Posicione("SYR",4,xFilial("EE4")+SA1->A1_DEST_3,"YR_VIA")
                End Case
                If !Empty(cDestino) .And. Empty(M->EE7_VIA) //MCF - 11/05/2015
                   M->EE7_VIA := AllTrim(cDestino)
                   lGatVia := .T.
                   AP100Crit("EE7_VIA")
                   lGatVia := .F.
                EndIf
            ENDIF

        Case cCampo $ "EE7_CLIENT|EE7_CLLOJA"

            lRet := TEVlCliFor(M->EE7_CLIENT,M->EE7_CLLOJA,"SA1","1|2|3|4| ")

            If lRet .and. lIntermed
               /* by jbj - 24/06/04 17:44 - Com a rotina de off-shore ativa o cliente
               passa a ser obrigatório na filial do Brasil */
               If (M->EE7_INTERM $ cSim) .And. (xFilial("EE7") == cFilBr)
                  If Empty(M->EE7_CLIENT)
                     EasyHelp(STR0063+AvSx3("EE7_CLIENT",AV_TITULO)+STR0064+AvSx3("EE7_CLIENT",15)+STR0065+ENTER+STR0066,STR0051) //"informado para processos com tratamentos de off-shore. //"O campo '"###"' na pasta '"###"' deve ser " "###"Atenção"
                     If lOK .Or. IsMemVar("lEE7Auto") .And. lEE7Auto
                        lRet:=.f.
                     EndIf
                  EndIf
               EndIf
            EndIf

         CASE cCAMPO $ "EE7_CONSIG|EE7_COLOJA"

            lRet := TEVlCliFor(M->EE7_CONSIG,M->EE7_COLOJA,"SA1","2|4")

         Case cCampo $ "EE7_FORN|EE7_FOLOJA"

            // NCF - 28/04/2014 - Tratamento para forçar a carga da variáel de memória do campo EE7_FOLOJA uma vez detectado que a rotina automática Enchauto não
            // está gatilhando a variável quando executado a executo a partir do adapter(EECAP100) de integração com o ERP Logix.
            If AVFLAGS("EEC_LOGIX") .And. IsMemVar("lEE7Auto") .And. lEE7Auto
                If (nPosFornLj := aScan( aAutoCab, {|x| x[1] == "EE7_FOLOJA"} ) ) > 0 .And. ValType(M->EE7_FOLOJA) <> NIL .And. aAutocab[nPosFornLj][2] <> M->EE7_FOLOJA
                    M->EE7_FOLOJA := aAutocab[nPosFornLj][2]
                EndIf
            EndIf

            lRet := TEVlCliFor(M->EE7_FORN,M->EE7_FOLOJA,"SA2","2|3")

        Case cCampo $ "EE7_BENEF|EE7_BELOJA"

           lRet := TEVlCliFor(M->EE7_BENEF,M->EE7_BELOJA,"SA2","3|5")

        Case cCampo $ "EE7_EXPORT|EE7_EXLOJA"

            lRet := TEVlCliFor(M->EE7_EXPORT,M->EE7_EXLOJA,"SA2","3|4")

        Case cCampo $ "EE8_FORN|EE8_FOLOJA"

            lRet := TEVlCliFor(M->EE8_FORN,M->EE8_FOLOJA,"SA2","2|3")

        Case cCampo $ "EE8_FABR|EE8_FALOJA"

            lRet := TEVlCliFor(M->EE8_FABR,M->EE8_FALOJA,"SA2","1|3")

        Case cCampo $ "EEN_IMPORT|EEN_IMLOJA"

            lRet := TEVlCliFor(M->EEN_IMPORT,M->EEN_IMLOJA,"SA1","3|4")

        Case cCampo = "EE7_MOTSIT"
           IF !Empty(M->EE7_MOTSIT)
              // Verifica se a descrição esta cadastrada ...
              lRet := ExistCpo("EE4",M->EE7_MOTSIT)

              cTipmen := Posicione("EE4",1,xFilial("EE4")+M->EE7_MOTSIT,"EE4_TIPMEN")
              If lRet .And. (Val(SubStr(cTipmen,1,1))#1)
                 Help(" ",1,"AVG0005072")// O item selecionado não é uma descrição valida
                 lRet:= .F.
              Endif
           Endif

         Case cCampo = "EE8_PRECO"
            // ** By JBJ - 27/06/02 - 10:35 ...
            If !lCommodity
               lRet:=NaoVazio(M->EE8_PRECO)
            EndIf
            //RMD - 31/08/05
            If EasyGParam( "MV_EECFAT",,.F.) .And. AVSX3("EE8_PRECO",AV_DECIMAL) > AVSX3("C6_PRCVEN",AV_DECIMAL)
               cPreco := STR(M->EE8_PRECO,,AVSX3("EE8_PRECO",AV_DECIMAL))
               nDecimais := AVSX3("EE8_PRECO",AV_DECIMAL) - AVSX3("C6_PRCVEN",AV_DECIMAL)

               For i := 1 to nDecimais
                  If !(SUBSTR(cPreco,-i,1) $ "0")
                     EasyHelp(STR0082 + ALLTRIM(STR(AVSX3("C6_PRCVEN",AV_DECIMAL))) + STR0083,AVSX3("EE8_PRECO",AV_TITULO))
                     lRet := .F.
                     Exit
                  EndIf
               Next
            EndIf

            If EasyGParam("MV_EECFAT",.F.,.F.) .And. nOpcI <> INC_DET
               If WorkIt->EE8_PRECO <> M->EE8_PRECO
                  If IsFaturado(WorkIt->EE8_PEDIDO,WorkIt->EE8_SEQUEN)
                     EasyHelp(STR0092,STR0051)//"Esse item possui NFs geradas no Faturamento. Para alterar o Preço Unitário estorne a NF"###"Atenção"
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

         Case cCampo=="EE7_TIPCOM"  //informar tipo de comissao
             IF ! lOk
                If (EMPTY(M->EE7_TIPCOM) .AND. !EMPTY(M->EE7_TIPCVL) .AND. !EMPTY(M->EE7_VALCOM)) .OR. ;
                   (EMPTY(M->EE7_TIPCOM) .AND. EMPTY(M->EE7_TIPCVL) .AND. !EMPTY(M->EE7_VALCOM)) .OR. ;
                   (EMPTY(M->EE7_TIPCOM) .AND. !EMPTY(M->EE7_TIPCVL) .AND. EMPTY(M->EE7_VALCOM))
                    lRet:=.F.
                    HELP(" ",1,"AVG0000036")
                EndIf
             Endif
         Case cCAMPO=="EE7_TIPCVL"  //informar tipo de valor de comissao
             IF !lOk
                If (!EMPTY(M->EE7_TIPCOM) .AND. EMPTY(M->EE7_TIPCVL) .AND. !EMPTY(M->EE7_VALCOM)) .OR. ;
                   (EMPTY(M->EE7_TIPCOM)  .AND. EMPTY(M->EE7_TIPCVL) .AND. !EMPTY(M->EE7_VALCOM)) .OR. ;
                   (!EMPTY(M->EE7_TIPCOM) .AND. EMPTY(M->EE7_TIPCVL) .AND. EMPTY(M->EE7_VALCOM))
                    lRet:=.F.
                    HELP(" ",1,"AVG0000060")
                EndIf
             Endif

             If M->EE7_TIPCVL = "3" .And. EE8->(FieldPos("EE8_PERCOM")) = 0
                EasyHelp(STR0040,STR0038) //"Opcao invalida. O campo EE8_PERCOM não existe na base !"###"Aviso"
                lRet:=.f.
             EndIf

         Case cCAMPO=="EE7_VALCOM"  //informar comissao
             If (!EMPTY(M->EE7_TIPCOM) .AND. !EMPTY(M->EE7_TIPCVL) .AND. EMPTY(M->EE7_VALCOM)) .OR. ;
                (!EMPTY(M->EE7_TIPCOM) .AND. EMPTY(M->EE7_TIPCVL) .AND. EMPTY(M->EE7_VALCOM)) .OR. ;
                (EMPTY(M->EE7_TIPCOM) .AND. !EMPTY(M->EE7_TIPCVL) .AND. EMPTY(M->EE7_VALCOM))
                 WorkAg->(dbGoTop())
                 lRet:=.T.
                 While !WorkAg->(Eof())
                    If LEFT(WorkAg->EEB_TIPOAG,1)==CD_AGC  //agente a receber comissao
                       lRet:=.F.
                       Exit
                    EndIf
                    WorkAg->(DBSKIP(1))
                 Enddo
                 IF !lRet
                    HELP(" ",1,"AVG0000077")
                 Endif
             EndIf

             // ** By JBJ - 03/04/02 11:14
             If M->EE7_TIPCVL = "1"
                If M->EE7_VALCOM > 99.99
                   EasyHelp(STR0041,STR0038) //"A porcentagem de comissão deve ser inferior a 100 %"###"Aviso"
                   Return .f.
                EndIf
             ElseIf M->EE7_TIPCVL = "2"
                nFob := (M->EE7_TOTPED+M->EE7_DESCON)-(M->EE7_FRPREV+M->EE7_FRPCOM+M->EE7_SEGPRE+;
                                                       M->EE7_DESPIN+AvGetCpo("M->EE7_DESP1")+;
                                                       AvGetCpo("M->EE7_DESP2"))
                IF nFob > 0
                   If M->EE7_VALCOM >= nFob
                      EasyHelp(STR0042,STR0038)  //"O valor da comissão deve ser inferior ao valor FOB."###"Aviso"
                      Return .f.
                   EndIf
                EndIf
             EndIf
         Case cCAMPO=="EE7_LC_NUM"

            EEL->(DbSetOrder(1))

            If EEL->(DbSeek(xFilial("EEL")+M->EE7_LC_NUM)) .And. EECFlags("ITENS_LC")
               If Posicione("EE7",1,M->(EE7_FILIAL+EE7_PEDIDO),"EE7_LC_NUM") <> M->EE7_LC_NUM .And. EEL->EEL_FINALI $ cSim // Se a L/C estiver finalizada, não pode ser utilizada
                  easyhelp(STR0078,STR0038) // "Esta Carta de Crédito já está finalizada. Sendo assim, não poderá ser utilizada.","Aviso"
                  lRet := .f.
                  Break
               EndIf
            EndIf

            If lNRotinaLC .And. !EECFlags("ITENS_LC")// JPM - 28/12/04 - Nova Rotina de Carta de Crédito

               nRec := EE7->(RecNo())
               If !Empty(M->EE7_LC_NUM) .And. lRet

                  EE9->(DbSetOrder(1))
                  EEC->(DbSetOrder(1))
                  nSaldo := 0
                  nTotalAEmb := 0

                  nRec2 := WorkIt->(RecNo())
                  WorkIt->(DbGoTop())
                  While WorkIt->(!EoF())
                     nSaldo  := WorkIt->EE8_SLDATU
                     cPreemb := ""
                     If EE9->(dbSeek(xFilial("EE9")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN))
                        While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                              EE9->EE9_PEDIDO == M->EE7_PEDIDO .And.;
                              EE9->EE9_SEQUEN == WorkIt->EE8_SEQUEN
                           If EE9->EE9_PREEMB <> cPreemb
                              EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
                              cPreemb := EE9->EE9_PREEMB
                           EndIf
                           If Empty(EEC->EEC_DTEMBA) .And. If(lMultiOffShore,Empty(EEC->EEC_NIOFFS),.t.)
                              nSaldo += EE9->EE9_SLDINI
                           EndIf
                           EE9->(DbSkip())
                        EndDo
                     EndIf

                     IF lConvUnid
                        nTotalAEmb += AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC,WorkIt->EE8_COD_I,;
                                                  nSaldo,.F.)*WorkIt->(EE8_PRCUN-If(EasyGParam("MV_AVG0085",,.f.),EE8_VLDESC/EE8_SLDINI,0))
                        WorkIt->(DbSkip())
                     Else
                        nTotalAEmb += nSaldo * WorkIt->(EE8_PRCUN-If(EasyGParam("MV_AVG0085",,.f.),EE8_VLDESC/EE8_SLDINI,0) )//Se o MV está ligado, o desconto não está sendo incluído no preço do item
                        WorkIt->(DbSkip())
                     EndIf
                  EndDo
                  WorkIt->(DbGoTo(nRec2))

                  nTaxa1 := 1
                  nTaxa2 := 1

                  If EEL->EEL_MOEDA <> "R$ "
                     nTaxa1 := BuscaTaxa(EEL->EEL_MOEDA,dDataBase)
                  Endif
                  If M->EE7_MOEDA <> "R$ "
                     nTaxa2 := BuscaTaxa(M->EE7_MOEDA,dDataBase)
                  Endif

                  nSldLC := EEL->EEL_SLDEMB
                  nSldLCReais := (EEL->EEL_SLDEMB * nTaxa1)
                  lRet := (Round(nSldLCReais,2) >= Round(nTotalAEmb * nTaxa2,2))

                  If !lRet
                     cMsg := STR0071+Alltrim(M->EE7_LC_NUM)+STR0072+AllTrim(M->EE7_MOEDA)+" "
                     cMsg += AllTrim(Transf(nTotalAEmb,AvSx3("EE7_TOTPED",AV_PICTURE)))
                     If M->EE7_MOEDA <> "R$ " .And. M->EE7_MOEDA <> EEL->EEL_MOEDA
                        cMsg += " (R$ "+AllTrim(Transf(Round(nTotalAEmb * nTaxa2,2),;
                                AvSx3("EE7_TOTPED",AV_PICTURE)))+")"
                     EndIf
                     cMsg += STR0073+AllTrim(EEL->EEL_MOEDA)+" "
                     cMsg += AllTrim(Transf(nSldLC,AvSx3("EEL_SLDEMB",AV_PICTURE)))
                     If EEL->EEL_MOEDA <> "R$ " .And. M->EE7_MOEDA <> EEL->EEL_MOEDA
                        cMsg += " (R$ " +AllTrim(Transf(Round(nSldLCReais,2),;
                                AvSx3("EEL_SLDEMB",AV_PICTURE)))+")"
                     EndIf
                     cMsg += "."

                     easyhelp(cMsg,STR0038)
                             //"O Saldo da L/C "##" não é suficiente."
                             // Saldo necessário: "##". Saldo L/C: "## ,"Aviso"
                  EndIf

                  EE7->(DbGoTo(nRec))

               EndIf

               If !lRet
                  Break
               EndIf

            EndIf

            If !lOk .And. EECFlags("ITENS_LC")
               nRec := WorkIt->(RecNo())
               WorkIt->(DbGoTop())
               If !Ae107AtuIt()
                  lRet := .f.
               EndIf

               WorkIt->(DbGoTo(nRec))
               If Type("lEE7Auto") <> "L" .Or. !lEE7Auto
                  oMsSelect:oBrowse:Refresh()
               EndIf
               If !lRet
                  Break
               EndIf

            EndIf

         Case cCampo == "EE8_LC_NUM" // JPM - 15/07/05

            If !Empty(M->EE8_LC_NUM)
               If M->EE8_LC_NUM <> M->EE7_LC_NUM
                  M->EE7_LC_NUM := CriaVar("EE7_LC_NUM")
               EndIf

               If Posicione("EEL",1,xFilial("EEL")+M->EE8_LC_NUM,"EEL_FINALI") $ cSim
                  easyhelp(STR0078,STR0038) // "Esta Carta de Crédito já está finalizada. Sendo assim, não poderá ser utilizada.","Aviso"
                  lRet := .f.
                  Break
               EndIf

               If EEL->EEL_CTPROD $ cNao //só valida se a L/C não controlar produtos. Se controla, esta validação é feita no preenchimento da sequência da L/C
                  If !Ae107ValIt(OC_PE,If(nOPCI == INC_DET,WorkIt->(RecNo()),0) )
                     lRet := .f.
                     Break
                  EndIf
               EndIf
            Else
               If !Empty(M->EE7_LC_NUM)
                  M->EE7_LC_NUM := CriaVar("EE7_LC_NUM")
               EndIf
            EndIf

         Case cCAMPO == "EE8_SEQ_LC" // JPM - 19/07/05

            If !Empty(M->EE8_SEQ_LC)
               If Posicione("EXS",1,xFilial("EXS")+M->EE8_LC_NUM+M->EE8_SEQ_LC,"EXS_COD_I" ) <> M->EE8_COD_I
                  EasyHelp(STR0079,STR0038) // "O Produto da Sequência de L/C informada não é igual ao Produto do item atual.","Aviso"
                  lRet := .f.
                  Break
               EndIf

               If !Ae107ValIt(OC_PE,If(nOPCI == INC_DET,0,WorkIt->(RecNo())) )
                  lRet := .f.
                  Break
               EndIf
            EndIf

         Case cCAMPO=="EE7_MARCAC"
              IF ! Inclui
                 Break
              Endif
              // By OMJ 26/02/2003 16:00 - Nao montar a marcacao na Inclusao
              If Empty(M->EE7_MARCAC)
                 M->EE7_MARCAC:=EECMARKS(OC_PE)
              EndIf
         CASE cCAMPO == "EE7_LICIMP"
             IF ( M->EE7_EXLIMP $ cSim .AND. EMPTY(M->EE7_LICIMP))
                lRET:=.F.
                HELP(" ",1,"AVG0000073")
             ENDIF
         CASE cCAMPO == "EE7_DTLIMP"
             IF ( (M->EE7_EXLIMP $ cSim .OR. !EMPTY(M->EE7_LICIMP)).AND.EMPTY(M->EE7_DTLIMP) )
                lRET:=.F.
                HELP(" ",1,"AVG0000074")
             ENDIF
         CASE cCAMPO $ "EE7_VIA/EE7_ORIGEM/EE7_DEST/EE7_TIPTRA"

            If ReadVar() == "M->EE7_VIA" .OR. (Type("lGatVia") # "U" .AND. lGatVia)   // GFP - 27/05/2014
                nVar  := 1
                cSeek := M->EE7_VIA+If(SYR->YR_VIA == M->EE7_VIA,SYR->YR_ORIGEM+SYR->YR_DESTINO,"")
            ElseIf ReadVar() == "M->EE7_ORIGEM"
                nVar  := 2
                cSeek := M->EE7_VIA+M->EE7_ORIGEM+If(SYR->YR_ORIGEM == M->EE7_ORIGEM,M->EE7_DEST,"") //MCF - 23/05/2016
            ElseIf ReadVar() == "M->EE7_DEST"
                nVar  := 3
                cSeek := M->EE7_VIA+M->EE7_ORIGEM+M->EE7_DEST
            Else
                nVar  := 4
                cSeek := M->EE7_VIA+M->EE7_ORIGEM+M->EE7_DEST+M->EE7_TIPTRA
            Endif

             If !EECVia(cSeek)
                EasyHelp(STR0069, STR0038) //"A Via não está cadastrada."###"Aviso"
                lRet := .F.
             EndIf


             If lRet .And. ! lOk  // By JPP - 06/04/2005 - 09:25 - A atualização com os dados da tabela taxas de frete só deverá ser realizada na digitação dos dados.
                If nVar == 1
                   M->EE7_VIA_DE := Posicione("SYQ",1,xFilial("SYQ")+M->EE7_VIA,"YQ_DESCR")
                   M->EE7_ORIGEM := SYR->YR_ORIGEM
                ElseIf nVar < 1
                   M->EE7_VIA_DE := Posicione("SYQ",1,xFilial("SYQ")+M->EE7_VIA,"YQ_DESCR")
                   M->EE7_ORIGEM := Posicione("SYR",1,xFilial("SYR")+M->EE7_VIA/*+M->EE7_ORIGEM*/,"YR_ORIGEM")
                Endif
                If nVar <= 2
                   M->EE7_DEST   := SYR->YR_DESTINO
                Endif
                If nVar <= 3
                   M->EE7_TIPTRA := SYR->YR_TIPTRAN
                Endif

                M->EE7_PAISDT := SYR->YR_PAIS_DE
                M->EE7_PAISET := SYR->YR_PAIS_DE
                M->EE7_TRSTIM := SYR->YR_TRANS_T
                SY9->(dbSetOrder(2))
                IF SY9->(dbSeek(XFILIAL("SY9")+M->EE7_ORIGEM))
                   M->EE7_DSCORI  := SY9->Y9_DESCR
                   M->EE7_URFDSP := SY9->Y9_URF
                   M->EE7_URFENT  := SY9->Y9_URF
                Endif
                M->EE7_DSCDES := Posicione("SY9",2,xFilial("SY9")+M->EE7_DEST,"Y9_DESCR")
                M->EE7_DSCORI := Posicione("SY9",2,xFilial("SY9")+M->EE7_ORIGEM,"Y9_DESCR")
             Endif
             //MFR 05/03/2020 OSSME-4330
             Ap100Crit("EE7_MARCAC") 
             lREFRESH:=.T.

        Case cCampo == "EEB_TIPCVL"
            If AvFlags("COMISSAO_VARIOS_AGENTES")//JPM - 01/02/05 - Nova validação para não haver ag. de perc. p/ item e de Valor Fixo/Percentual no mesmo processo.
               nRec := WorkAg->(RecNo())
               WorkAg->(DbGoTop())
               While WorkAg->(!EoF())
                  /*If WorkAg->(EEB_CODAGE) == M->EEB_CODAGE .Or. Left(WorkAg->EEB_TIPOAG,1) <> CD_AGC Nopado por MCF - 01/10/2015
                     WorkAg->(DbSkip())
                     Loop
                  EndIf*/
                  If M->EEB_TIPCVL == "3" // Comissão por item.
                     If WorkAg->EEB_TIPCVL <> "3" .and. nRec <> WorkAg->(RecNo())
                        easyhelp(STR0074,STR0038)//"Não podem haver agentes de percentual por item e agentes com outro tipo de valor de comissão em um mesmo processo."
                        lRet := .f.
                     EndIf
                  Else
                     If WorkAg->EEB_TIPCVL == "3" .and. nRec <> WorkAg->(RecNo())
                        easyhelp(STR0075+STR0074,STR0038)//"Não podem haver agentes de percentual por item e agentes com outro tipo de valor de comissão em um mesmo processo.""Já existe(m) agente(s) com o tipo do valor de comissão 'percentual por item'."
                        lRet := .f.
                        M->EEB_VALCOM := 0 //MCF - 03/09/2015
                     EndIf
                  EndIf
                  If !lRet
                     WorkAg->(DbGoto(nRec))
                     Break
                  EndIf
                  WorkAg->(DbSkip())
               EndDo
               WorkAg->(DbGoto(nRec))
            EndIf

            //LRS - 21/09/2018
            If M->EEB_TIPCVL = "3" .AND. (Type("lEE7Auto") <> "L" .OR. !lEE7Auto)   // Comissão por item.
               MsgInfo(STR0054+ENTER+;  //"O percentual para este tipo de comissão, deve ser informado "
                       STR0055,STR0038) // "Aviso" //"na tela de edição de itens."
            EndIf

         Case cCampo == "EEB_VALCOM"
             If Type("M->EE7_TOTPED") <> "U"
                cAlias := "EE7"
             Else
                cAlias := "EEC"
             EndIf

             If M->EEB_TIPCVL = "1"
                If M->EEB_VALCOM > 99.99
                   EasyHelp(STR0041,STR0038) //"A porcentagem de comissão deve ser inferior a 100 %"###"Aviso"
                   lRet := .f.
                EndIf
             ElseIf M->EEB_TIPCVL = "2"
                nFob := EECFob(If(cAlias == "EE7",OC_PE,OC_EM))
                /*nFob := (M->&(cAlias+"_TOTPED")+M->&(cAlias+"_DESCON"))-(M->&(cAlias+"_FRPREV")+;
                                                M->&(cAlias+"_FRPCOM")+M->&(cAlias+"_SEGPRE")+;
                                                M->&(cAlias+"_DESPIN")+AvGetCpo("M->"+cAlias+"_DESP1")+;
                                                AvGetCpo("M->"+cAlias+"_DESP2")) */
                IF nFob > 0
                   If M->EEB_VALCOM >= nFob
                      EasyHelp(STR0042,STR0038)  //"O valor da comissão deve ser inferior ao valor FOB."###"Aviso"
                      Return .f.
                   EndIf
                Endif
             EndIf

             If AvFlags("COMISSAO_VARIOS_AGENTES") .And. !lOkAg //MCF - 11/01/2016
                AP100CRIT("EEB_TIPCVL")
             Endif

         // Case cCampo == "EE8_CODAGE" - JPM - 02/06/05
         Case cCampo $ "EE8_CODAGE/EE8_TIPCOM"

            If !Empty(M->EE8_CODAGE)
               //If WorkAg->(DbSeek(M->EE8_CODAGE+CD_AGC)) - JPM - 02/06/05
               If WorkAg->(DbSeek(M->EE8_CODAGE+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+;
                                    If(EE8->(FieldPos("EE8_TIPCOM")) > 0,M->EE8_TIPCOM,"")))

                  If WorkAg->EEB_TIPCVL = "1" // Percentual.
                     M->EE8_PERCOM := WorkAg->EEB_VALCOM
                     M->EE8_VLCOM  := Round(M->EE8_PRCINC*(M->EE8_PERCOM/100),AVSX3("EE8_VLCOM",AV_DECIMAL))

                  ElseIf WorkAg->EEB_TIPCVL = "2" // Valor Fixo.
                     M->EE8_PERCOM := 0
                     M->EE8_VLCOM  := WorkAg->EEB_VALCOM

                  Else // Percentual por item.
                     M->EE8_PERCOM := 0
                     M->EE8_VLCOM  := 0
                  EndIf
               EndIf
            Else
               M->EE8_PERCOM := 0
               M->EE8_VLCOM  := 0
            EndIf

         // ** By JBJ - 28/08/03 - 15:27. (Validação do campo de flag para tratamento de OffShore).
         Case cCampo == "EE7_INTERM"

            If INCLUI
               Break
            EndIf

            Do Case
               Case ALTERA .And. EE7->EE7_INTERM == M->EE7_INTERM
                  Break

               Case ALTERA .And. (EE7->EE7_INTERM <> M->EE7_INTERM) .And. (M->EE7_INTERM $ cSim)

                  EE8->(DbSetOrder(1))
                  EE8->(DbSeek(xFilial("EE8")+M->EE7_PEDIDO))
                  Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == xFilial("EE8") .And.;
                                               EE8->EE8_PEDIDO == M->EE7_PEDIDO
                     If EECFlags("COMMODITY") .Or. EECFlags("CAFE") // By JPP - 03/03/2008 - 16:30 - Não permitir transformar pedido normal em offshore quando existir fixação de preço.
                        If !Empty(EE8->EE8_DTFIX)
                           EasyHelp(STR0091,STR0051) // "Este processo possui fixação de Preço/RV, este campo não pode ser alterado. Estorne a fixação para alterar este campo."###"Atenção"
                           lRet := .F.
                           Break
                        EndIf
                     EndIf
                     If EE8->EE8_SLDINI <> EE8->EE8_SLDATU
                        easyhelp(STR0056+ENTER+; //"Problema:"
                                STR0076+; //"Este processo foi lançado em fase de embarque na filial Brasil. Para que o sistema "
                                STR0077,STR0051) //"gere o pedido na filial de off-shore, o embarque deverá ser eliminado na filial Brasil."###"Atenção"
                        lRet:=.f.
                        Break
                     EndIf
                     EE8->(DbSkip())
                  EndDo
            EndCase
         // JPP - 11/01/05 - 10:15 - Na alteração do Pais é verificado se existe normas vinculadas a produtos.
         Case cCampo == "EE7_PAISET"
              If ! lOK
                 AP100Normas(OC_PE)
              EndIf

         Case cCampo == "EE7_CONDPA"   //RMD - 06/09/05 - Impede que seja incluido um pedido com uma condição de pag. inexistente
            If !ExistCpo("SY6",M->EE7_CONDPA)
               lRet := .F.
               Break
            EndIf

         Case cCampo == "EE8_PERCOM"//LGS-26/12/2014 - Preciso validar antes e calcular se tiver zero pra que o valor da comissao seja calculado
         	If M->EE8_PRCTOT == 0
         	   M->EE8_PRCTOT := M->(EE8_SLDINI * EE8_PRECO)
         	   M->EE8_PRCINC := M->(EE8_SLDINI * EE8_PRECO)
         	EndIf

         Case cCampo == "EE8_VLCOM"  //LRS - 27/11/2014 - Validação para pegar a porcentagem calculada de acordo com o valor digitado
         	If M->EE8_PRCTOT == 0   //LGS-26/12/2014 - Preciso validar antes e calcular se tiver zero pra que o valor da comissao seja calculado
         	   M->EE8_PRCTOT := M->(EE8_SLDINI * EE8_PRECO)
         	   M->EE8_PRCINC := M->(EE8_SLDINI * EE8_PRECO)
            EndIf

            IF M->EE8_VLCOM > M->EE8_PRCINC
  	           EasyHelp(STR0108,STR0051) //Valor da comissão maior que o valor total do item ## Atenção
  	           lRet := .F.
  	        Else
  	           M->EE8_PERCOM:= Round(((M->EE8_VLCOM/M->EE8_PRCINC)*100),Avsx3("EE8_PERCOM",AV_DECIMAL))
            EndIF
            SY6->(DbSetOrder(1))
            If SY6->(DbSeek(xFilial("SY6")+M->EE7_CONDPA))
               If SY6->Y6_TIPO = "3"
                  For nPos := 1 To 10
                     If SY6->&("Y6_DIAS_" + StrZero(nPos, 2)) < 0
                        easyhelp(STR0090,STR0051)//"A condição de pagamento selecionada, contém uma ou mais parcelas de adiantamento. Informe uma condição de pagamento onde não haja parcelas de adiantamento.","Atenção")
                        lRet := .F.
                        Break
                     EndIf
                  Next
               EndIf
            EndIf

         Case cCampo == "EE7_DESSEG" //LRS - 11/09/2015
 	           AP100Crit("EE7_SEGURO",.F.)
         
         Case cCampo == "EE8_DESCON" //RMD - 27/09/19 - Valida se o valor do desconto é compatível com o valor aceito pelo Faturamento e caso negativo ajusta.
            If EasyGParam("MV_EECFAT",,.F.) .And. EasyGParam("MV_AVG0119",,.F.) .And. M->EE8_DESCON > 0
               /* Calcula o desconto de acordo com a função padrão do Faturamento para determinação do preço de venda.
               Nesta função o valor do desconto pode ser ajustado em função da quantidade de casas decimais configuradas no pedido de venda e pela configuração do parâmetro MV_ARREDFAT*/
               nDesconto := M->EE8_DESCON
               nPreco := M->EE8_PRECOI
               if M->EE8_PRECOI ==0 
                  nPreco := M->EE8_PRECO
               EndIf
               
               If nPreco == 0 .And. nDesconto > 0
                  EasyHelp(STR0115,STR0051,STR0116)//"Não é possível informar um Desconto, pois não foi informado o Preço Unitário do item."#####"Informe um Preço Unitário para o item."
                  lRet := .F.
                  Break
               EndIf

               If nDesconto > M->EE8_PRCTOT
                  EasyHelp(STR0117,STR0051,STR0118)//"O valor de desconto não pode ser maior que o total do item."#####"Informe um valor de desconto menor que o valor total do item."
                  lRet := .F.
                  Break
               EndIf

               If nPreco > 0 .And. nDesconto > 0
                  FtDescItem(nPreco,nPreco,M->EE8_SLDINI,M->EE8_PRCTOT,Nil,@nDesconto,Nil,2)
               EndIf               
               
               If nDesconto <> M->EE8_DESCON
                  M->EE8_DESCON := nDesconto
                  if lmsgDescon
                     EasyHelp(StrTran(STR0113, "XXX", Transform(M->EE8_DESCON,AvSx3("EE8_DESCON",AV_PICTURE))), STR0038) //Ao validar a integração com o módulo de Faturamento, o valor do desconto foi alterado para XXX, devido às configurações do módulo.
                  Endif   
               EndIf
            EndIf

      End Case

   End Sequence

   RESTORD(aORD)
   dbselectarea(cOldArea)

Return lRet
/************************************
|                                   |
************************************/
FUNCTION EECVLEE8(cCAMPO)
   Local cCpoCont:= ""

   Local lRet    := .T.,i
   Local lReposic:= Type("SB1->B1_REPOSIC") <> "U"

   Local nLinAcols:= 0
   Local nLinha   := 0
   Local nColuna  := 0
   Local nQuant   := 0
   Local cLocal

   Private lAlterouDesc:= .F.
   Private lExecValid := .T.  

   BEGIN SEQUENCE
     //DFS - 19/07/2011 - Ponto de entrada para que, retire a validação dos campos desejados.
     If EasyEntryPoint("EECAP102")
        ExecBlock("EECAP102",.f.,.f.,{"EECVLEE8_CALC_EMB", cCampo})
     EndIf

     If !lExecValid
        Break
     EndIf
     DO CASE
        CASE cCAMPO="EE8_COD_I"
            SB1->(DBSETORDER(1))
            EE2->(DBSETORDER(1))
            If !ExistCpo("SB1",M->EE8_COD_I)
               lRet := .F.
               Break
            ElseIf SB1->(DBSEEK(xFilial()+M->EE8_COD_I))

               /// VALIDAÇÃO INSERIDA PQ VIA TELA O CAMPO NÃO ESTÁ EDITÁVEL                      //MFR 06/09/2021 OSSME-6137
               IF (!AvFlags("EEC_LOGIX_PREPED") .or. (isMemVar("lEE7Auto") .and. lEE7Auto)) .AND. !Empty(WorkIt->EE8_COD_I) .And.  WorkIt->EE8_COD_I <> M->EE8_COD_I .AND. M->EE8_SLDINI <> M->EE8_SLDATU
                  
                  // STR0114 - "O item XXXXX já tem saldo embarcado e não pode ser alterado!"
                  cMsgLogIt := strtran(STR0114, "XXXXX", (alltrim(M->EE8_SEQUEN) + " - " + alltrim(M->EE8_COD_I) + " - " + alltrim(M->EE8_VM_DES)) )
                  
                  EasyHelp(cMsgLogIt)
                  lRet := .F.
                  Break
               ENDIF

               If EE2->(DBSEEK(XFilIAL()+MC_CPRO+TM_GER+EE7_IDIOMA+AVKEY(SB1->B1_COD,"EE2_COD")))
                  M->EE8_VM_DES := MSMM(EE2->EE2_TEXTO,AVSX3("EE2_VM_TEX")[AV_TAMANHO])
               ELSE
                  //DFS - 09/08/12 - Possibilita a inclusão de tratamentos para a descrição do produto.
                  If EasyEntryPoint("EECAP102")
                     lAlterouDesc:= ExecBlock("EECAP102", .F., .F., "DESC_PROD")
                  EndIf
                  If !lAlterouDesc
                     //NCF - 24/09/2013 - ajuste para integração via Mensagem Única SIGAEEC x LOGIX
                     If ! (Type("lEE7Auto") == "L" .And. lEE7Auto) 
                        HELP(" ",1,"AVG0005001") //MSGINFO("Idioma não encontrado, Padrão: Português","Atenção")
                     EndIf
                     M->EE8_VM_DES := SB1->B1_DESC
                  EndIf
               ENDIF

               IF lReposic
                  IF ! GetNewPar("MV_AVG0009",.F.)
                     IF Posicione("SB1",1,xFilial("SB1")+M->EE8_COD_I,"B1_REPOSIC") $ cSim
                        lLibPes := .t.
                     Else
                        lLibPes := .f.
                     ENDIF
                  Endif
               Endif
               M->EE8_FPCOD :=SB1->B1_FPCOD
               M->EE8_GPCOD :=Posicione("SYC",1,xFilial("SYC")+SB1->B1_FPCOD,"YC_COD_RL")
               M->EE8_DPCOD :=Posicione("EEH",4,xFilial("EEH")+M->EE8_GPCOD,"EEH_COD_RL")
               M->EE8_POSIPI:=SB1->B1_POSIPI
               M->EE8_NLNCCA:=SB1->B1_NALNCCA
               M->EE8_NALSH :=SB1->B1_NALSH
               M->EE8_PRECO := SB1->B1_VLREFUS
               EEH->(DBSETORDER(1))
               lRefresh:=.T.
            ENDIF
        CASE cCAMPO="EE8_PRECO"
            EECPPE07("PRECOS")

        CASE cCAMPO="EE8_SLDINI"

            //Tratamento para itens do tipo grade
            If IsIntFat() .And. nOpcI <> INC_DET .And. lGrade .And. WorkIt->EE8_GRADE $ cSim
               If IsFaturado(WorkIt->EE8_PEDIDO, WorkIt->EE8_SEQUEN)
                  EasyHelp(STR0093, STR0051) //Esse item possui NFs geradas no Faturamento. Para alterar, estorne a NF. ### Atenção
                  lRet := .F.
                  Break
               EndIf
            EndIf

            /***************************
              WFS 04/03/2010 - Tratamentos de cálculo dos pesos quando usado o recurso grade
              Considerando 3 itens do tipo grade:
              1º com 10 un.
              2º com 20 un.
              3º com 10 un.
              e uma embalagem onde seja possível colocar 20 unidades.
              A quantidade total será 40 un. e, o com o cálculo padrão, a quantidade de embalagem será
              2. No entanto, quando a grade estiver habilitada, após a gravação do processo serão gerados
              três registros para os itens, totalizando 3 embalagens, duas delas com uma quantidade menor
              do produto do que o comportado.
            **********************************************************************************************/

            cCpoCont  := M->EE8_COD_I
            nLinAcols := WorkIt->(RecNo())

            If lGrade .And. MatGrdPrrf(@cCpoCont)

               M->EE8_QTDEM1:= 0

               For nLinha:= 1 To Len(oGrdExp:aColsGrade[nLinAcols])
                  For nColuna:= 2 To Len(oGrdExp:aHeadGrade[nLinAcols])

                     nQuant:= oGrdExp:aColsFieldByName("EE8_SLDINI", nLinAcols, nLinha, nColuna)

                     If nQuant > 0
                        If nQuant <= M->EE8_QE
                           M->EE8_QTDEM1 += 1
                        Else
                           If (nQuant % M->EE8_QE) > 0
                              M->EE8_QTDEM1 += Int(nQuant / M->EE8_QE) + 1
                           Else
                              M->EE8_QTDEM1 += nQuant / M->EE8_QE
                           EndIf
                        EndIf
                     EndIf
                  Next
               Next

            Else

              IF !EMPTY(M->EE8_QE)
                  IF (M->EE8_SLDINI % M->EE8_QE) != 0        
                     M->EE8_QTDEM1 := Int(M->EE8_SLDINI/M->EE8_QE)+1 //QUANT.DE EMBAL.                                                                             //NCF - 24/09/2013 - ajuste para integração via Mensagem Única SIGAEEC x LOGIX
                     If !(Type("lEE7Auto") == "L" .And. lEE7Auto)
                        HELP(" ",1,"AVG0000637") //MsgStop("Quantidade informada não e multipla pela quantidade na Embalagem !","Aviso")
                     EndIf
                  Else
                     //DFS - 28/11/12 - Retirado a função Int, para que, sistema não calcule erroneamente (arredondando para menos) a quantidade de embalagem.
                     M->EE8_QTDEM1 := M->EE8_SLDINI/M->EE8_QE //QUANT.DE EMBAL.
                  Endif
               Endif

               EECPPE07("PESOS",,cCampo)
            EndIf

            //RMD - 31/08/05
            If EasyGParam( "MV_EECFAT",,.F.) .And. AVSX3("EE8_SLDINI",AV_DECIMAL) > AVSX3("C6_QTDVEN",AV_DECIMAL)
               cPreco := STR(M->EE8_SLDINI,,AVSX3("EE8_SLDINI",AV_DECIMAL))
               nDecimais := AVSX3("EE8_SLDINI",AV_DECIMAL) - AVSX3("C6_QTDVEN",AV_DECIMAL)

               For i := 1 to nDecimais
                  If !(SUBSTR(cPreco,-i,1) $ "0")
                     EasyHelp(STR0082 + ALLTRIM(STR(AVSX3("C6_QTDVEN",AV_DECIMAL))) + STR0083,AVSX3("EE8_SLDINI",AV_TITULO))
                     lRet := .F.
                     Exit
                  EndIf
               Next
            EndIf

            EECPPE07("PRECOS")
            EECPPE07("EMBALA")
            EECPPE07("PESOS",,cCampo)

        CASE cCAMPO="EE8_PSLQUN"
            EECPPE07("PESOS",,cCampo)

        CASE cCAMPO="EE8_QTDEM1"
            // GFP - 21/07/2012 - Inclusão de calculo de Quantidade na embalagem
            IF !EMPTY(M->EE8_QTDEM1)
               M->EE8_QE := Round(M->EE8_SLDINI/M->EE8_QTDEM1,AVSX3("EE8_QE",4))
               IF (M->EE8_SLDINI % M->EE8_QTDEM1) != 0 .And. !(Type("lEE7Auto") == "L" .And. lEE7Auto)
                     HELP(" ",1,"AVG0000637") //MsgStop("Quantidade informada não e multipla pela quantidade na Embalagem !","Aviso")
               Endif
            Endif
            EECPPE07("EMBALA")
            EECPPE07("PESOS",,cCampo)

        CASE cCAMPO="EE8_QE"
            IF !EMPTY(M->EE8_QE)
               IF (M->EE8_SLDINI % M->EE8_QE) != 0
                  If Type("lEE7Auto") == "L" .And. lEE7Auto                                                                           //NCF - 24/09/2013 - ajuste para integração via Mensagem Única SIGAEEC x LOGIX
                     M->EE8_QTDEM1 := Int(M->EE8_SLDINI/M->EE8_QE)+1 //QUANT.DE EMBAL.
                  Else
                     HELP(" ",1,"AVG0000637") //MsgStop("Quantidade informada não e multipla pela quantidade na Embalagem !","Aviso")
                     M->EE8_QTDEM1 := Int(M->EE8_SLDINI/M->EE8_QE)+1 //QUANT.DE EMBAL.
                  EndIf
               Else
                  M->EE8_QTDEM1 := M->EE8_SLDINI/M->EE8_QE //QUANT.DE EMBAL.
               Endif
            Endif
            EECPPE07("EMBALA")
            EECPPE07("PESOS",,cCampo)

        CASE cCAMPO="EE8_EMBAL1"
            // CAF 21/01/2000 Chamado pelo SX7 EECPPE07("CALCEMB")
            EECPPE07("PESOS",,cCampo)

        CASE cCAMPO="EE8_PSBRUN"
            EECPPE07("PESOS",,cCampo)
        CASE cCAMPO="EE8_DTPREM"
            IF M->EE8_DTPREM < dDataBase
               HELP(" ",1,"AVG0000638") //MsgStop("Data de Previsão de Embarque deve ser maior que a data atual !","Aviso")
               lRet := .F.
               Break
            Endif

        CASE cCAMPO="EE8_DTENTR"
            IF M->EE8_DTENTR < dDataBase
               HELP(" ",1,"AVG0000639") //MsgStop("Data de Entrega deve ser maior que a data atual !","Aviso")
               lRet := .F.
               Break
            Endif
        //DFS - 13/12/12 - Inclusão de tratamento para que, preencha automaticamente o campo Destaque da NCM. Caso não encontre, apresenta mensagem.
        CASE cCAMPO="EE8_DTQNCM"
            If !Empty(M->EE8_DTQNCM) .and. !SYD->( dbSetOrder(3) , dbSeek(xFilial("SYD")+M->EE8_POSIPI)) .and. !(alltrim(M->EE8_DTQNCM) $ SYD->YD_DESTAQU)
               EasyHelp(STR0107,STR0049) //"O Destaque informado não está cadastrado na tabela 'SYD - Cadastro de NCM'. Favor informar um Destaque correto para a NCM selecionada.", "Atenção"
               lRet := .F.
               Break
            EndIf

        CASE cCAMPO="EE8_RESERV"

            cLocal := Posicione("SB1", 1, SB1->(xFilial()) + M->EE8_COD_I, "B1_LOCPAD")

            SC0->(dbSetOrder(2))
            If !SC0->(dbSeek(xFilial("SC0")+M->EE8_COD_I+cLocal+M->EE8_RESERV))
               Help(" ", 1, "A410Res")
               lRet := .F.
               Break
            Else
               If SC0->C0_QUANT <= 0
                  EasyHelp(STR0109,STR0038) //"Não há saldo disponível no item para essa alteração." ### "Aviso"
                  lRet := .F.
                  Break
               EndIf
            EndIf
     ENDCASE
   ENDSEQUENCE

   AP100DetTela(.F.)

RETURN lRET

/*
Funcao      : AP100Import
Parametros  :
Retorno     : Valor da Comissao
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 30/07/99 10:51
Revisao     :
Obs.        :
*/
FUNCTION AP100Import

Local cAgente, nComissao, cX5_DESC,aORD := SAVEORD({"SA1"})

Begin Sequence
   //If !Inclui .Or. cCodImport == M->EE7_IMPORT+M->EE7_IMLOJA
   If cCodImport == M->EE7_IMPORT+M->EE7_IMLOJA
      Break
   Endif
   SA1->(dbSeek(xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA))
   cAgente   := SA1->A1_CODAGE
   nComissao := SA1->A1_COMAGE

   IF SA1->(dbSeek(xFilial("SA1")+cCodImport))
      IF !Empty(SA1->A1_CODAGE)
         IF WorkAg->(dbSeek(SA1->A1_CODAGE))
            // Alterado por Heder M Oliveira - 9/21/1999
            // checar tipo do agente que esta sendo eliminado
            DO While !WorkAg->(Eof())
               // *** CAF 20/12/1999 15:12 IF ( WORKAG->EEB_CODAGE == SA1->A1_CODAGE .AND. WORKAG->EEB_TIPOAG==CD_AGC )
               IF WorkAg->EEB_CODAGE == SA1->A1_CODAGE .And. Left(WorkAg->EEB_TIPOAG,1)==CD_AGC
                  If WorkAg->WK_RECNO <> 0
                     AADD(aAGDELETADOS,WORKAG->WK_RECNO)
                  EndIf
                  WorkAg->(dbDelete())
               Endif
               WORKAG->(DBSKIP())
            Enddo
         Endif
      Endif
   Endif

   cCodImport := M->EE7_IMPORT+M->EE7_IMLOJA
   //MFR 29/10/2019 OSSME-3950
   IF !Empty(cAgente) .And. !Empty(nComissao) .AND. !WorkAg->(dbSeek(cAgente))
      SY5->(dbSetOrder(1))
      SY5->(dbSeek(xFilial()+cAgente))

      WorkAg->(dbAppend())
      WorkAg->EEB_CODAGE := cAgente
      WorkAg->EEB_NOME   := SY5->Y5_NOME
      WorkAg->EEB_TXCOMIS:= nComissao
      WorkAg->EEB_VALCOM := nComissao
      WorkAg->EEB_TIPCVL := CriaVar("EEB_TIPCVL")//"1"

      //Define o conteúdo padrão do tipo da comissão (campo obrigatório)
      WorkAg->EEB_TIPCOM := CriaVar("EEB_TIPCOM")//"2"

      If ! EMPTY(cX5_DESC:=Tabela('YE',CD_AGC))
         WorkAg->EEB_TIPOAG := Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
      Else
         WorkAg->EEB_TIPOAG := SPACE(AVSX3("EEB_TIPOAG",AV_TAMANHO))
      EndIf

      //ER - 18/09/2006
      If EECFlags("FRESEGCOM")
         WorkAg->EEB_FORNEC := SY5->Y5_FORNECE
         WorkAg->EEB_LOJAF  := SY5->Y5_LOJAF
      EndIf

      If EasyEntryPoint("EECAP102") //DFS - 07/01/10 - Inclusão de ponto de entrada para customizar o preenchimento desses campos ao incluir o agente de comissão vinculado no cadastro do cliente.
         ExecBlock("EECAP102",.f.,.f.,{"TP_AGNT_PED"})
      EndIf

   Endif
End Sequence

IF Empty(nComissao)
   nComissao := M->EE7_VALCOM
Endif
RESTORD(aORD,.T.)
Return nComissao

/*
Funcao      : AP100FobImport
Parametros  : cCampo
Retorno     : Fob Cadastrado do importador/client
Objetivos   :
Autor       : Felipe Sales Martinez
Data/Hora   : 26/12/2011 15:37
Revisao     :
Obs.        :
*/
Function AP100FobImport(cCampo)
Local xRet := ""

Begin Sequence

   DBSelectArea("EXJ")

   Do Case

      Case cCampo == "EE7_INCOTE"
            xRet := Posicione("EXJ", 1, xFilial("EXJ")+M->EE7_IMPORT+M->EE7_IMLOJA , "EXJ_INCOTE")

  EndCase

End Sequence

Return xRet



/*
Funcao      : AP100Comissao
Parametros  :
Retorno     :
Objetivos   :
Autor       : Cristiano A. Ferreira
Data/Hora   : 30/07/99 16:42
Revisao     :
Obs.        :
*/

FUNCTION AP100Comissao()

Local oDlg, nOpcao, nValor := M->EEB_TXCOMIS
Local bVar, cLabel, cPicture, nComissao := 0, nOpCom := 0
Local bCancel:={|| oDlg:End()}
Local bOk := {|| If(nComissao > 0,(nOpcao := 1, oDlg:End()),;
                                  MsgInfo(STR0050,STR0051))} //"Informe o valor da comissão !"###"Atenção"

Private aGets[0], aTela[0][0], nUsado := 0

Begin Sequence

   If EECFlags("COMISSAO")
      Break
   EndIf

   IF CD_AGC == Left(M->EEB_TIPOAG,1)

      bVar := MemVarBlock("EE7_VALCOM")
      IF Type("M->EE7_VALCOM") <> "N"
         bVar := MemVarBlock("EEC_VALCOM")
         cAlias := "EEC"
      Else
         cAlias := "EE7"
      Endif

      // Eval(bVar,Eval(bVar)-nValor)
      IF EMPTY(M->EEB_TXCOMIS)
         M->EEB_TXCOMIS:=Eval(bVar)
      Endif

      If Len(ComboX3Box(cAlias+"_TIPCVL")) <= 3 // Nro de Opcoes de comissao
         If &("M->"+cAlias+"_TIPCVL") $ "13"
            cPicture := "@E 99.99"
            cLabel :=  STR0052 //"Percentual"
         Else
            cLabel :=  BscXBox(cAlias+"_TIPCVL",&("M->"+cAlias+"_TIPCVL"))
            cPicture := "@E 999,999,999.99"
         EndIF
      Else
         If &("M->"+cAlias+"_TIPCVL") == "1"
            cPicture := "@E 99.99"
            cLabel :=  STR0052 //"Percentual"
         Else
            cPicture := "@E 999,999,999.99"
            cLabel :=  BscXBox(cAlias+"_TIPCVL",&("M->"+cAlias+"_TIPCVL"))
         EndIF
      EndIf

      nComissao := M->EEB_TXCOMIS

      While .T.
         nOpcao := 0

         Define MsDialog oDlg Title STR0039 From 10,12 TO 19.5,47 OF oMainWnd //"Comissão de Agentes"

            @ 1.1, 0.5 TO 4.8,17 Label STR0053 Of oDlg //"Informe a comissão "

            @ 32,10 Say cLabel Size 50,10 Of oDlg Pixel
            @ 32,65 MsGet nComissao Picture cPicture Size 60,10 Valid Positivo(nComissao) of oDlg Pixel

         Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

         //  By JBJ - 24/03/03.
         IF nOpcao == 1
            M->EEB_TXCOMIS := nComissao
         Endif
         Exit
      Enddo
   Endif

End Sequence

Return .T.

/*
Funcao      : AP100PrecoI
Parametros  : lCalc -> .t. - Calcula os totais.
                       .f. - Verifica o MV_AVG0059 para calcular ou não os totais.
              lMsg ->  .T. - Apresenta mensagens.
                       .F. - Não apresenta mensagens.
Retorno     :
Objetivos   : Regras de formacao de preco com incoterm
Autor       : Cristiano A. Ferreira
Data/Hora   : 31/07/99 11:18
Revisao     : Alterado por Heder M Oliveira - 8/25/1999
Obs.        :
  DEFINICAO P/ CALCULO DO RATEIO DAS DESPESAS
   1-PESO LIQUIDO
   2-PESO BRUTO
   3-PRECO FOB   (PADRAO)
  A VARIAVEL QUE DEFINE QUAL DOS 3 SERA USADO É A: MV_AVG0021

*/
*-------------------------*
FUNCTION AP100PrecoI(lCalc, lMsg, lExAutoPrcI)
*-------------------------*
Local nAuxVal:= 0, nQtd:= 0, nPrecoI:= 0
Local /*nTotRateio := 0, - JPM*/ nFator, nPrecoTot
//Local nVlDespesas, nAuxDesp - JPM
Local nRecWork := WorkIt->(RecNo())
Local nRecAtual, lLastRec := .f., nVal, cVar, cAlias

Local nFATORFRE:=0,nAUXVALFRE//,nAUXDESPFR //JPM
      //nTOTFATFRE := 0,; //JPM
      //nVLFRETE   := M->EE7_FRPREV+M->EE7_FRPCOM,; //JPM
Local nDECPRC    := EasyGParam("MV_AVG0109",, AVSX3("EE8_PRECO"  ,AV_DECIMAL)),; //2,; //4,;
      nDecTot    := EasyGParam("MV_AVG0110",, 2),; //2,; //AvSx3("EE8_PRCTOT" ,AV_DECIMAL),;//JPM
      cRATEIO    := GetNewPar("MV_AVG0021","3"),;
      aAux       := {}

// ** JPM - 01/04/05
Local i/*, aVlDespesas := {{"EE8_VLFRET",0,0,0,2},; //Frete
                         {"EE8_VLSEGU",0,0,0,2},; //Seguro
                         {"EE8_VLOUTR",0,0,0,2},; //Outras despesas internacionais
                         {"EE8_VLDESC",0,0,0,2} } //Desconto   JPM - passada para private, para pto de entrada*/
Local nDespesas, nVlDesp

/* aVlDespesas por dimensão: aVlDespesas[i][1] = Campo da Despesa no Item
                             aVlDespesas[i][2] = Valor da Despesa rateada pelo item atual
                             aVlDespesas[i][3] = Valor Total da Despesa
                             aVlDespesas[i][4] = Quanto da despesa falta pra ser rateada
                             aVlDespesas[i][5] = Casas Decimais

Obs.: o desconto não é despesa, mas receberá quase o mesmo tratamento
*/

Local lPreco := EasyGParam("MV_AVG0085",,.f.) //SE LIGADO, NÃO INCLUI O DESCONTO NO PRECO DO ITEM
Local lDespesas := EE8->(FieldPos("EE8_VLFRET")) > 0 .And. ;
                   EE8->(FieldPos("EE8_VLSEGU")) > 0 .And. ;
                   EE8->(FieldPos("EE8_VLOUTR")) > 0 .And. ;
                   EE8->(FieldPos("EE8_VLDESC")) > 0

Local lEE7_VLFOB := EE7->(FieldPos("EE7_VLFOB")) > 0

Local nRound := 8 //Máximo de casas decimais para resultados de divisões no Protheus
Local aDespesas := X3DIReturn(OC_PE)
Local cUnidadeKg := EasyGParam("MV_AVG0031",,"KG")
Local bUnidade := {|x| If(Empty(x),cUnidadeKg,x) }
Local lAcerto  := EasyGParam("MV_AVG0092",,.t.)//Define se haverá acerto nos itens ao final.
Local lIsRepl := If(Type("lAx100") == "U", .F., lAx100)

//ER - 06/09/2007 - Define se o Desconto será subtraído(.T.) ou somado(.F.) no Valor Fob, quando o preço for fechado.
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.)

Private aVlDespesas :=  {{"EE8_VLFRET",0,0,0,2},; //Frete
                         {"EE8_VLSEGU",0,0,0,2},; //Seguro
                         {"EE8_VLOUTR",0,0,0,2},; //Outras despesas internacionais
                         {"EE8_VLDESC",0,0,0,2}}

If lDespesas
   For i := 1 to Len(aVlDespesas)
      aVlDespesas[i][5] := AvSx3(aVlDespesas[i][1],AV_DECIMAL) //Casas decimais dos campos de acordo com o SX3
   Next
EndIf
// ** Fim

PRIVATE nTOTAL  := 0, nTOTPED := 0

Default lCalc := .f.
Default lMsg  := .T.
Default lExAutoPrcI := .F.

If Type("lDescIt") == "U"
   lDescIt:= .T.
EndIf

Begin Sequence

   If !lExAutoPrcI .And. Type("lEE7Auto") == "L" .And. lEE7Auto
      Break
   EndIf

   If !lCalc
      If EasyGParam("MV_AVG0059",.t.)
         If !EasyGParam("MV_AVG0059",,.f.)
            Break
         EndIf
      EndIf
   EndIf

   // Flag para conversao de unidades do preco, peso e quantidade.
   If Type("lConvUnid") == "U"
      lConvUnid := (EE7->(FieldPos("EE7_UNIDAD")) # 0) .And. (EE8->(FieldPos("EE8_UNPES")) # 0) .And.;
                   (EE8->(FieldPos("EE8_UNPRC"))  # 0)
   EndIf

   // Alterado por Heder M Oliveira - 11/17/1999
   //AP100CRIT("EE7_SEGURO",.F.)

   // ASK - 11/05/2007 Tratamento do Seguro
   If EE7->(FieldPos("EE7_TIPSEG")) > 0
      If M->EE7_TIPSEG == "1"
         AP100CRIT("EE7_SEGURO",.F.)
      ElseIf M->EE7_TIPSEG == "2"
         AP100CRIT("EE7_SEGPRE",.F.)
      EndIf
   EndIf
   //nVlDespesas := (M->EE7_SEGPRE+M->EE7_DESPIN+AvGetCpo("M->EE7_DESP1")+AvGetCpo("M->EE7_DESP2"))-;
   //                   M->EE7_DESCON //JPM

   // ** JPM - 01/04/05
   For i := 1 to Len(aDespesas)
      if !(aDespesas[i][1] $ "FR/FA/SE")
         aVlDespesas[3][3] += M->&(aDespesas[i][2]) //Vl. tot. de outras Desp. Internacionais
      EndIf
   Next

   //NCF - Integracao Msg. Unica Pre-Pedido
   IF AVFLAGS("EEC_LOGIX") .And. AVFLAGS("EEC_LOGIX_PREPED")
      cCompFrete := EasyGParam("MV_EEC0016",,'1')
      Do Case
         Case cCompFrete == '1'
            aVlDespesas[1][3] := M->EE7_FRPREV+M->EE7_FRPCOM //Frete Internacional + Frete Interno
         Case cCompFrete == '2'
            aVlDespesas[1][3] := M->EE7_FRPREV               //Frete Internacional
         Case cCompFrete == '3'
            aVlDespesas[1][3] := M->EE7_FRPCOM               //Frete Interno
         Case cCompFrete == '4'
            aVlDespesas[1][3] := 0                           //Não Calcula
      EndCase
   ELSE
      aVlDespesas[1][3] := M->EE7_FRPREV+M->EE7_FRPCOM //Vl. Total do Frete
   ENDIF

   aVlDespesas[2][3] := M->EE7_SEGPRE               //Vl. Total do Seguro
   aVlDespesas[4][3] := M->EE7_DESCON               //Vl. Total do Desconto

   For i := 1 to Len(aVlDespesas)
      aVlDespesas[i][4] := aVlDespesas[i][3]
   Next

   //nAuxDesp    := nVlDespesas
   //nAUXDESPFRE   := nVLFRETE

   // ** JPM - fim

   M->EE7_TOTPED := 0
   lTotRodape := IF(TYPE("lTotRodape" )<>"L",.F.,lTotRodape) //LGS-01/08/2014
   If lTotRodape  // GFP - 11/04/2014
      M->EE7_TOTFOB := 0
   EndIf

   AP102TOT(cRATEIO)  // CALCULA O TOTAL DO PROCESSO DE ACORDO COM A MV

   nPrecoTot := nTotPed
   
   WorkIt->(dbGoTop())

   Do While ! WorkIt->(Eof())
      IF nTOTPED != 0

         // *** Rateio do valor do frete
         IF cRATEIO = "1"//Rateio por Peso Liquido
            If lConvUnid
               aVlDespesas[1][2] := (aVlDespesas[1][3]/;
                                      AvTransUnid(Eval(bUnidade,M->EE7_UNIDAD), Eval(bUnidade,WorkIt->EE8_UNPES),WorkIT->EE8_COD_I,M->EE7_PESLIQ,.F.))*;
                                         WorkIT->EE8_PSLQTO//WorkIT->EE8_SLDINI
            Else
               aVlDespesas[1][2] := (aVlDespesas[1][3]/M->EE7_PESLIQ)*WorkIT->EE8_PSLQTO//WorkIT->EE8_SLDINI
            Endif

         ELSEIF cRATEIO = "2"//Rateio por Peso Bruto
            If lConvUnid
               aVlDespesas[1][2] := (aVlDespesas[1][3]/;
                                      AvTransUnid(Eval(bUnidade,M->EE7_UNIDAD), Eval(bUnidade,WorkIt->EE8_UNPES),WorkIT->EE8_COD_I,M->EE7_PESBRU,.F.))*;
                                         WorkIT->EE8_PSBRTO//WorkIT->EE8_SLDINI
            Else
               aVlDespesas[1][2] := (aVlDespesas[1][3]/M->EE7_PESBRU)*WorkIT->EE8_PSBRTO//WorkIT->EE8_SLDINI
            Endif
         Else//Rateio por Preço
            If lConvUnid
               nFatorFre := Round((AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                             WorkIt->EE8_SLDINI,.F.) * Round(WorkIt->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL))) / nTotal,nRound)
            Else
               nFatorFre := Round(WorkIt->(Round(EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL))* EE8_SLDINI) / nTotal,nRound)
            EndIf
            aVlDespesas[1][2] := aVlDespesas[1][3] * nFatorFre //JPM - Frete para este item
         Endif
         // *** Final do rateio do frete

         // *** Rateio das demais despesas
         //Busca o preço total de cada item
         IF M->EE7_PRECOA $ cSim
            If lConvUnid
               nFator := (AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC,WorkIt->EE8_COD_I,;
                                  WorkIt->EE8_SLDINI,.F.)*Round(WorkIt->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)))
            Else
               nFATOR := WorkIt->(Round(EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL))*EE8_SLDINI)
            EndIf
         ELSE // se for preço fechado, tira o frete para fazer o rateio, pois o mesmo tem rateio diferenciado
            If lConvUnid
               /*
               nFator := (AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,WorkIt->EE8_SLDINI,.F.)*;
                         Round(WorkIt->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL))) - aVlDespesas[1][2] //(nVLFRETE*nFATORFRE) //JPM
               */
               nFator := (AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,WorkIt->EE8_SLDINI,.F.)*;
                         Round(WorkIt->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)))
            Else
               //nFATOR := WorkIt->(Round(EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL))*EE8_SLDINI) - aVlDespesas[1][2] //(nVLFRETE*nFATORFRE) //JPM
               nFator := WorkIt->(Round(EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL))*EE8_SLDINI)
            EndIf
         ENDIF
         //Encontra o fator de proporção do preço de cada um sobre o preço total do processo
         nFator := Round(nFATOR/nPRECOTOT,nRound)

         //Rateia o valor de cada despesa para o item posicionado, utilizando o fator de proporção

         For i := 2 to Len(aVlDespesas)//Começa a partir da segunda posição, pois o frete foi avaliado a parte
            //Tratamento do desconto
            
            If aVlDespesas[i][1] == "EE8_VLDESC"
               If EasyGParam("MV_AVG0119",,.F.) .And. lDescIt//Desconto por item
                  //Neste caso o valor do desconto é aplicado diretamente no valor do item, sem interferir nos demais
                  aVlDespesas[i][2] := WorkIt->EE8_DESCON
               Else//Desconto informado na capa do processo
                  //Neste caso o valor do desconto é rateado entre os itens, como as demais despesas
                  aVlDespesas[i][2] := aVlDespesas[i][3] * nFator
               EndIf
            Else//Tratamento das demais despesas (rateadas por item)
               aVlDespesas[i][2] := aVlDespesas[i][3] * nFator
            EndIf
         Next

         If EasyEntryPoint("EECAP102") // ** JPM - 12/07/06 - Ponto de entrada para modificar o rateio das despesas
            ExecBlock("EECAP102",.f.,.f.,{"RATEIO_PRECOI"})
         EndIf
         // *** Final do rateio das demais despesas
      Else
         nFator := 0
      Endif

      //nTotRateio += nFator //JPM - 01/04/05
      //nTOTFATFRE += nFATORFRE

      // Verifica se e o ultimo registro ...
      nRecAtual := WorkIt->(RecNo())
      WorkIt->(dbSkip())

      IF WorkIt->(Eof())
         lLastRec := .t.
      Endif

      WorkIt->(dbGoTo(nRecAtual))

      // *** Totaliza o valor das despesas para o item posicionado e faz os ajustes necessários
      nDespesas := 0
      nAuxVal    := 0
      nAuxValFre := 0
      For i := 1 to Len(aVlDespesas)
          WorkIt->&(aVlDespesas[i][1]) := 0
      Next

      For i := 1 to Len(aVlDespesas)
         // *** Atualiza os valores das despesas para o item nos campos correspondentes
         //Grava no campo de despesa da work o valor calculado.
         //MFR01/01/2019
         If aVlDespesas[i][4] > 0
            WorkIt->&(aVlDespesas[i][1]) := Round(aVlDespesas[i][2],aVlDespesas[i][5])
            //Valor restante para ser rateado
            aVlDespesas[i][4] -= WorkIt->&(aVlDespesas[i][1])
         EndIf
         // ***
         if aVlDespesas[i][4] <> 0
            aVlDespesas[i][4] := aVlDespesas[i][4]
         EndIf
         // *** Acerto dos resíduos
         /*
         Caso o parâmetro 'MV_AVG0092' estiver ligado, a WorkIt estiver posicionada no último registro e a despesa atual possuir algum resíduo
         em relação ao valor da despesa na capa do processo e valor rateado, faz o acerto dos resíduos
         */
         If lAcerto .And. lLastRec .And. aVlDespesas[i][4] <> 0
            While WorkIt->(!Bof())
               If WorkIt->&(aVlDespesas[i][1]) + aVlDespesas[i][4] > 0 //Verifica se com o acerto o valor
                                                                       //continua maior que zero
                  WorkIt->&(aVlDespesas[i][1]) += aVlDespesas[i][4] //efetua o acerto
                  nVal := aVlDespesas[i][4] // valor que será acertado nos campos de preço

                  nValPto := nVal

                  If EasyEntryPoint("EECAP100")
                     ExecBlock("EECAP100", .F., .F., {"PRECOI_ATU_PRECO", aVlDespesas[i][1]})
                  EndIf

                  nVal := nValPto

                  aVlDespesas[i][4] := 0 //valor a ser rateado = 0

                  If WorkIt->(RecNo()) <> nRecAtual //se estiver posicionado em um registro diferente do item atual,
                                                    //tem que fazer acertos nos campos de preço, que já foram
                                                    //calculados
                     If aVlDespesas[i][1] <> "EE8_VLDESC"
                        //Se a despesa não for desconto e o preço for fechado, retira o valor da despesa do campo 'Preço FOB'
                        If !(M->EE7_PRECOA $ cSim)
                           If lConvUnid // Conversao da unidade.
                              nQtd := AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                                      WorkIt->EE8_SLDINI,.F.)
                              WorkIt->EE8_PRECOI := Round(((WorkIt->EE8_PRECOI*nQtd)-nVal)/nQtd,nDecPrc)

                           Else
                              WorkIt->EE8_PRECOI := Round((WorkIt->(EE8_PRECOI*EE8_SLDINI)-nVal)/WorkIt->EE8_SLDINI,nDecPrc)
                           EndIf
                           WorkIt->EE8_PRCINC -= nVal
                           //M->EE7_TOTPED -= nVal - Não atualiza o total visto que o total do item não foi atualizado
                        Else
                           //Se for preço aberto adiciona o valor no preço total
                           WorkIt->EE8_PRCTOT += nVal
                           M->EE7_TOTPED += nVal //
                           WorkIt->EE8_PRCUN := Round(WorkIt->(EE8_PRCTOT/EE8_SLDINI),nDecPrc)
                        EndIf

                     ElseIf !lPreco
                        /*
                           No caso do desconto, só faz acerto de desconto se o parâmetro 'MV_AVG0085' estiver
                           desligado (caso contrário o desconto não faz parte da formação do preço do item).
                        */
                        If !(M->EE7_PRECOA $ cSim)
                           If lConvUnid // Conversao da unidade.
                              nQtd := AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I,;
                                      WorkIt->EE8_SLDINI,.F.)

                              //DFS - 22/03/13 - Inclusão de verificação para o campo EE7_TPDESC na rotina de Embarque
                              If EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CSIM .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. lSubDesc
                                 WorkIt->EE8_PRECOI := Round(((WorkIt->EE8_PRECOI*nQtd)+nVal)/nQtd,nDecPrc)
                              Else
                                 WorkIt->EE8_PRECOI := Round(((WorkIt->EE8_PRECOI*nQtd)-nVal)/nQtd,nDecPrc)
                              EndIf

                           Else
                              //DFS - 22/03/13 - Inclusão de verificação para o campo EE7_TPDESC na rotina de Embarque
                              If EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CSIM .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. lSubDesc
                                 WorkIt->EE8_PRECOI := Round((WorkIt->(EE8_PRECOI*EE8_SLDINI)+nVal)/WorkIt->EE8_SLDINI,nDecPrc)
                              Else
                                 WorkIt->EE8_PRECOI := Round((WorkIt->(EE8_PRECOI*EE8_SLDINI)-nVal)/WorkIt->EE8_SLDINI,nDecPrc)
                              EndIf
                           EndIf
                           WorkIt->EE8_PRCINC += nVal
                           //M->EE7_TOTPED += nVal
                        Else
                           WorkIt->EE8_PRCTOT -= nVal
                           M->EE7_TOTPED -= nVal //
                           WorkIt->EE8_PRCUN := Round(WorkIt->(EE8_PRCTOT/EE8_SLDINI),nDecPrc)
                        EndIf

                     EndIf

                  EndIf

                  Exit
               EndIf
               WorkIt->(DbSkip(-1))
            EndDo
            WorkIt->(dbGoTo(nRecAtual))
         EndIf

         // *** Totaliza o valor das despesas em variáveis auxiliares para uso em ponto de entrada
         If aVlDespesas[i][1] = "EE8_VLFRET"
            nAuxValFre += WorkIt->&(aVlDespesas[i][1])
            nAuxValFre := Round(nAuxValFre,AVSX3(aVlDespesas[i][1],AV_DECIMAL))
         ElseIf aVlDespesas[i][1] <> "EE8_VLDESC"
            nAuxVal    += WorkIt->&(aVlDespesas[i][1])
            nAuxVal    := Round(nAuxVal,AVSX3(aVlDespesas[i][1],AV_DECIMAL))
         ElseIf !lPreco //só considera o desconto na formação de preço se o MV estiver desligado.
            If M->EE7_PRECOA $ cNao
               //DFS - 22/03/13 - Inclusão de verificação para o campo EE7_TPDESC na rotina de Embarque
               If (EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CNAO) .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. !lSubDesc
                  nAuxVal -= WorkIt->&(aVlDespesas[i][1])
               Else
                  nAuxVal += WorkIt->&(aVlDespesas[i][1])
               EndIf

               nAuxVal := Round(nAuxVal,AVSX3(aVlDespesas[i][1],AV_DECIMAL))

            EndIf
         EndIf

         //RMD - 27/11/13 - Isola o valor da depesa na variável nVal antes de totalizar, para possibilitar customização
         nVal := 0

         If aVlDespesas[i][1] <> "EE8_VLDESC"
            nVal += If(lAcerto,WorkIt->&(aVlDespesas[i][1]),aVlDespesas[i][2])
         ElseIf !lPreco //só considera o desconto na formação de preço se o MV estiver desligado.
            If M->EE7_PRECOA $ cNao
               //DFS - 22/03/13 - Inclusão de verificação para o campo EE7_TPDESC na rotina de Embarque
               If (EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CNAO) .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. !lSubDesc
                  nVal += If(lAcerto,WorkIt->&(aVlDespesas[i][1]),aVlDespesas[i][2])
               EndIf
            Else
               //DFS - 22/03/13 - Inclusão de verificação para o campo EE7_TPDESC na rotina de Embarque
               If (EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CNAO) .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. !lSubDesc
                  //nDespesas += If(lAcerto,WorkIt->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  nVal += If(lAcerto,WorkIt->&(aVlDespesas[i][1]),aVlDespesas[i][2])
               Else
                  //nDespesas -= If(lAcerto,WorkIt->&(aVlDespesas[i][1]),aVlDespesas[i][2])
                  nVal -= If(lAcerto,WorkIt->&(aVlDespesas[i][1]),aVlDespesas[i][2])
               EndIf
            EndIf
         EndIf

		 nValPto := nVal

		 If EasyEntryPoint("EECAP100")
			ExecBlock("EECAP100", .F., .F., {"PRECOI_ATU_PRECO", aVlDespesas[i][1]})
		 EndIf

		 nVal := nValPto

		 nDespesas += nVal

         nDespesas := Round(nDespesas,AVSX3(aVlDespesas[i][1],AV_DECIMAL))

      Next
      // *** Final da totalização e ajuste das despesas

      // *** Obtenção do Preço FOB unitário
      IF M->EE7_PRECOA $ cSim
         //No caso de preço aberto o Preço FOB é igual ao preço unitário
         nPrecoI := WORKIT->EE8_PRECO
      ELSE
         //No caso de preço fechado o Preço FOB é igual ao preço unitário menos o valor das despesas por unidade
         If lConvUnid // Conversao da unidade.
            nQtd := AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I, WorkIt->EE8_SLDINI,.F.)
            //nPrecoI := (WorkIt->EE8_PRECO*nQtd-nDespesas)/nQtd
            nPrecoI := (Round(WorkIt->EE8_PRECO*nQtd, nDecPrc)-nDespesas)/nQtd
         Else
            //nPrecoI := (WorkIt->(EE8_PRECO*EE8_SLDINI)-nDespesas)/WorkIt->EE8_SLDINI
            nPrecoI := (Round(WorkIt->(EE8_PRECO*EE8_SLDINI), nDecPrc)-nDespesas)/WorkIt->EE8_SLDINI
         EndIf
      ENDIF
      //***

      /* by jbj - 14/10/05 - PARA ACERTAR ARREDONDAMENTO - Para os processos com preço fechado, o sistema gerava não conformidade na apuração do
                             valor total do processo.
      */
      nPrecoI := ROUND(nPRECOI,nDECPRC)

      WorkIt->EE8_PRECOI := nPrecoI

      // by CAF 06/08/2001 14:42 Corrigir problemas de arredondamento
      IF M->EE7_PRECOA $ cSim
         If lConvUnid // Conversao da unidade.
            nQtd := AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I, WorkIt->EE8_SLDINI,.F.)
            WorkIt->EE8_PRCTOT := ROUND((nPrecoI*nQtd)+nDespesas,nDecTot)
            WorkIt->EE8_PRCINC := Round(nQtd*WorkIt->EE8_PRECO,nDecTot)
			WorkIt->EE8_PRCUN  := Round(WorkIt->EE8_PRCTOT/nQtd,nDecPrc)
         Else
		    WorkIt->EE8_PRCTOT := ROUND((nPrecoI*WORKIT->EE8_SLDINI)+nDespesas,nDecTot)
            WorkIt->EE8_PRCINC := Round(WorkIt->EE8_PRECO*WorkIt->EE8_SLDINI,nDecTot)
			WorkIt->EE8_PRCUN  := Round(WorkIt->EE8_PRCTOT/WorkIt->EE8_SLDINI,nDecPrc)
         EndIf
      ELSE
         If lConvUnid
            nQtd := AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I, WorkIt->EE8_SLDINI,.F.)
            WorkIt->EE8_PRCINC := ROUND(WorkIt->EE8_PRECO*nQtd-nDespesas,nDecTot)
            //RMD - 28/10/14 - Subtrai o desconto do valor Total sem alterar o FOB
            If !lPreco .And. (EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CSIM .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. lSubDesc)
               WorkIt->EE8_PRCTOT := Round(nQtd*WorkIt->EE8_PRECO-WorkIt->EE8_VLDESC,nDecTot)
            Else
	           WorkIt->EE8_PRCTOT := Round(nQtd*WorkIt->EE8_PRECO,nDecTot)
	        EndIf
         Else
            WorkIt->EE8_PRCINC := ROUND(WorkIt->EE8_PRECO*WORKIT->EE8_SLDINI-nDespesas,nDecTot)
            WorkIt->EE8_PRCTOT := Round(WorkIt->EE8_PRECO*WorkIt->EE8_SLDINI,nDecTot)
         EndIf
		 WorkIt->EE8_PRCUN := WorkIt->EE8_PRECO
      Endif

      // ** By JBJ - 13/08/03 - 17:56 (Manutenção dos totais da capa e itens do processo).
      aAux:={nAuxVal,nAuxValFre}
      If EasyEntryPoint("EECAP102")
         ExecBlock("EECAP102",.f.,.f.,{"PE_PRECOI",aAux})
      EndIf

      M->EE7_TOTPED += WorkIt->EE8_PRCTOT //ER - 20/11/2007. Realiza o cálculo do total, já com as despesas calculadas.
      WorkIt->(dbSkip())
   EndDo
   //MFR 26/09/2019 OSSME-3309
   nTotPedBr := M->EE7_TOTPED
   if lPreco
      nTotPedBr := nTotPedBr - M->EE7_DESCON
   EndIf   
   

   If EasyEntryPoint("EECAP102") // ** JPM - 12/07/06 - Ponto de entrada antes do cálculo do TOTPED.
      ExecBlock("EECAP102",.f.,.f.,{"ANTES_TOTPED_PRECOI"})
   EndIf

   /* Quando for comissão do tipo a deduzir da fatura, o valor da comissão é subtraído do total líquido. Para os 
      demais tipos de comissão, o valor líquido é o FOB.

      Total FOB = Total no Incoterm - Despesas internacionais
      Total da comissão = percentual x Total FOB
      Total Líquido = Total FOB - Total da comissão (somente se for comissão à deduzir da fatura)
      Total Pedido/Embarque = Total Líquido + Despesas Internacionais */
   
   EECTotCom()
   M->EE7_TOTPED -= AE102CalcAg()

   /*
      Caso o parâmetro 'MV_AVG0085' estiver ligado,  o sistema não considerou o desconto na formação do preço dos itens,
      ele será aplicado diretamente no total do processo, independente do preço ser aberto ou fechado.
   */
   If lPreco
      //DFS - 22/03/13 - Inclusão de verificação para o campo EE7_TPDESC na rotina de Embarque
      If (EE7->(FieldPos("EE7_TPDESC")) > 0 .AND. M->EE7_TPDESC $ CSIM) .OR. EE7->(FieldPos("EE7_TPDESC")) == 0 .AND. lSubDesc
         M->EE7_TOTPED -= M->EE7_DESCON
      Else
         M->EE7_TOTPED += M->EE7_DESCON
      EndIf
   EndIf
      
   M->EE7_VLFOB := EECFob(OC_PE,, .F.)
   lTotRodape := IF(TYPE("lTotRodape" )<>"L",.F.,lTotRodape) //LGS-01/08/2014
   If lTotRodape  // GFP - 11/04/2014
      M->EE7_TOTFOB += nPrecoTot
      M->EE7_TOTLIQ := M->EE7_VLFOB - AE102CalcAg() //LRS- 24/10/2018
   EndIf

   //AAF 30/12/2013 - Arredondar total conforme a quantidade de decimais
   M->EE7_TOTPED := Round(M->EE7_TOTPED,AvSX3("EE7_TOTPED",AV_DECIMAL))

End Sequence

//restaurar ponteiro
WorkIt->(dbGoTo(nRecWork))

M->EE8_PRCTOT := WorkIt->EE8_PRCTOT
M->EE8_PRCINC := WorkIt->EE8_PRCINC

//wfs - reapura o seguro, quando preço fechado
If M->EE7_TIPSEG == "1" .And. M->EE7_PRECOA $ cNao
  AP100CRIT("EE7_SEGURO",.F.)
EndIf

IF Type("oPedido") == "O" .and. lMsg .And. !lIsRepl
   AP100TTELA(.F.)
Endif

If Type("oMsSelect") == "O" .and. lMsg .And. !lIsRepl
   If ValType(oMsSelect:oBrowse) == "O"
      oMsSelect:oBrowse:Refresh()
   EndIf
EndIf

Return .T.

/*
Funcao          : AP100CUBAGEM(lCALCULA)
Parametros      : lCALCULA = SE .T. calcular
Retorno         : Valor cubado
Objetivos       : Calcular cubagem
Autor           : Heder M Oliveira
Data/Hora       : 11/01/98 18:43
Revisao         : Alexsander Martins dos Santos - 15/07/2004 às 16:57.
Obs.            :
*/
Function AP100Cubagem(lCalcula, cFase)
Local nRet       := 0
Local aChave     := {{ "P",  {|| M->EE7_EMBAFI } },;      //Pedido.
                     { "Q",  {|| M->EEC_EMBAFI } },;      //Embarque.
                     { "IP", {|| WorkIT->EE8_EMBAL1 } },; //Item do Pedido.
                     { "IQ", {|| WorkIP->EE9_EMBAL1 } }}  //Item do Embarque.

Default lCalcula := .F.
Default cFase    := "P"

Begin Sequence

   If lCalcula
      If EE5->(dbSeek(xFilial()+Eval(aChave[aScan(aChave, {|x| x[1] == cFase})][2])))
         nRet := EE5->(EE5_HALT*EE5_LLARG*EE5_CCOM)
      EndIf
   EndIf

End Sequence

Return(nRet)

/*
Funcao          : AP101TPAG()
Parametros      : Nenhum
Objetivos       : Retornar descricao de tipo de agente do EEB
Autor           : Heder M Oliveira
Data/Hora       : 15/01/99 08:43
Revisao         :
Obs             :
*/
Function AP101TPAG()
   Local lRet:=.T.,cOldArea:=select(),cX5_DESC
   Begin sequence
      If ! EMPTY(cX5_DESC:=Tabela('YE',Left(M->EEB_TIPOAG,1)))
         M->EEB_TIPOAG:=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
      Else
         M->EEB_TIPOAG:=SPACE(25)
         lRet:=.F.
      EndIf
   Endsequence
   lRefresh:=.T.
   dbselectarea(cOldArea)
Return lRet

/*
Funcao          : AP102CRIAWORK()
Parametros      : Nenhum
Retorno         : .T.
Objetivos       : Criação dos arquivos temporários para manutenção de processos.
Autor           : Jeferson Barros Jr.
Data/Hora       : 23/07/01 - 11:37
Revisao         :
Obs.            :
*/

*------------------------
Function AP102CRIAWORK(lSetWorks)
*------------------------
Local lRet:=.T., cOldArea:=select(), aSemSX3
Local bAddWork, vetEEK, nPos, n , i, cChave, cAux, aBox, cIniBrw, cCampo
Private lGrade := AvFlags("GRADE")

Default lSetWorks := .f.

	//RMD - 23/08/12 - Tratamento específico para manter arquivos de trabalho - Vide EECAE109.
	EECSetKeepUsrFiles()

Begin Sequence

   //atencao ao dar manutencao nas linhas abaixo
   aHeader:={}
   aCampoItem:={{{||WorkIt->EE8_SEQUEN},"",STR0001},;                                        //"Sequência"
                {{||WorkIt->EE8_COD_I},"",STR0002},;                                         //"Cód.Item"
                {{||MEMOLINE(WorkIt->EE8_VM_DES,60,1) },"",STR0003},;                        //"Descrição"
                {{||BUSCAF_F(WorkIt->EE8_FORN+WORKIT->EE8_FOLOJA,.T.)},"",STR0004},;         //"Fornecedor"
                {{||BUSCAF_F(WorkIt->EE8_FABR+WORKIT->EE8_FALOJA,.T.)},"",STR0005},;         //"Fabricante"
                {{||WorkIt->EE8_PART_N},"",STR0006},;                                        //"Part.No."
                {{||WorkIt->EE8_DTPREM},"",STR0007},;                                        //"Prev.Embarque"
                {{||WorkIt->EE8_DTENTR},"",STR0008},;                                        //"Entrega"
                {{||TRANSF(WorkIt->EE8_PRECO,EECPreco("EE8_PRECO", AV_PICTURE))},"",STR0009},; //"Preço Unit."
                {{||WorkIt->EE8_UNIDAD},"",STR0010},; //"Unid.Medida"
                {{||TRANSF(WorkIt->EE8_SLDINI,AVSX3("EE8_SLDINI",AV_PICTURE))},"",STR0011},; //"Quantidade"
                {{||TRANSF(WorkIt->EE8_PRCTOT,EECPreco("EE8_PRCTOT", AV_PICTURE))},"",STR0012},; //"Vlr.Total"
                {{||Transf(WorkIt->EE8_PRCINC,EECPreco("EE8_PRCINC", AV_PICTURE))},"",AvSX3("EE8_PRCINC", AV_TITULO)},;  //"Preço Incoterm"
                {{||TRANSF(WorkIt->EE8_PSLQUN,AVSX3("EE8_PSLQUN",AV_PICTURE))},"",STR0013},; //"Peso Liquído Unitário"
                {{||TRANSF(WorkIt->EE8_PSLQTO,AVSX3("EE8_PSLQTO",AV_PICTURE))},"",STR0014},; //"Peso Liquído Total"
                {{||WorkIt->EE8_EMBAL1},"",STR0015},; //"Embalagem"
                {{||TRANSF(WorkIt->EE8_QTDEM1,AVSX3("EE8_QTDEM1",AV_PICTURE))},"",STR0016},; //"Qtd. Embalagem"
                {{||TRANSF(WorkIt->EE8_PSBRUN,AVSX3("EE8_PSBRUN",AV_PICTURE))},"",STR0017},; //"Peso Bruto Unitário"
                {{||TRANSF(WorkIt->EE8_PSBRTO,AVSX3("EE8_PSBRTO",AV_PICTURE))},"",STR0018},; //"Peso Bruto Total"
                {{||TRANSF(WorkIt->EE8_SLDATU,AVSX3("EE8_SLDATU",AV_PICTURE))},"",STR0019}}  //"Saldo a Embarcar"

    if EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0
        AAdd(aCampoItem,{{||TRANSF(WorkIt->EE8_DESCON,AVSX3("EE8_DESCON",AV_PICTURE))},"",AvSx3("EE8_DESCON", AV_TITULO)})
    endif

   If lGrade .And. EasyGParam("MV_AVG0192",, .F.)
      AAdd(aCampoItem, Nil)
      AIns(aCampoItem, 2)
      aCampoItem[2]:= {{|| WorkIt->EE8_GRADE}, "", AvSx3("EE8_GRADE", AV_TITULO)}
   EndIf

   If Ap104VerPreco() .and. EECFlags("CAFE") // FJH 23/11/05
      AAdd(aCampoItem,{{||TRANSF(WorkIt->EE8_PRECO5,EECPreco("EE8_PRECO5",6))},"","Preco $/Sc50"})
      AAdd(aCampoItem,{{||TRANSF(WorkIt->EE8_PRECO2,EECPreco("EE8_PRECO2",6))},"","Preco $/Sc60"})
      AAdd(aCampoItem,{{||TRANSF(WorkIt->EE8_PRECO3,EECPreco("EE8_PRECO3",6))},"","Preco Cents/Lb"})
      AAdd(aCampoItem,{{||TRANSF(WorkIt->EE8_PRECO4,EECPreco("EE8_PRECO4",6))},"","Preco $/Ton"})
  	Endif

    //RMD - 13/10/08 - Exibe no browse os campos de TES e CFOP, se estiver utilizando a integração nova.
  	If EECFlags("INTEMB")
  	   aAdd(aCampoItem, {{|| WorkIt->EE8_TES }, "", AvSx3("EE8_TES", AV_TITULO)})
  	   aAdd(aCampoItem, {{|| WorkIt->EE8_CF } , "", AvSx3("EE8_CF" , AV_TITULO)})
  	EndIf

   If EE8->(FieldPos("EE8_SLDELI")) > 0
      aAdd(aCampoItem, {{|| TRANSF(WorkIt->EE8_SLDELI, AvSX3("EE8_SLDELI", AV_PICTURE)) }, "", AvSx3("EE8_SLDELI", AV_TITULO)})
   EndIf

   If EE8->(FieldPos("EE8_DTELIM")) > 0
      aAdd(aCampoItem, {{|| WorkIt->EE8_DTELIM }, "", AvSx3("EE8_DTELIM", AV_TITULO)})
   EndIf

  	//AOM - 21/06/2011 - OPerações Especiais
  	If AvFlags("OPERACAO_ESPECIAL")
  	   aAdd(aCampoItem, {{|| WorkIt->EE8_CODOPE }, "", AvSx3("EE8_CODOPE", AV_TITULO)})
  	   //aAdd(aCampoItem, {{|| WorkIt->EE8_DESOPE }, "", AvSx3("EE8_DESOPE", AV_TITULO)})
  	EndIf

    // BAK - campo para ser gravado o pedido real da integracao
  	If AvFlags("EEC_LOGIX") .And. EE8->(FieldPos("EE8_PEDERP")) > 0
  	   aAdd(aCampoItem, {{|| WorkIt->EE8_PEDERP }, "", AvSx3("EE8_PEDERP", AV_TITULO)})
  	EndIf

  	//by CRF 27/10/2010 - 11:06
    aCampoItem :=  AddCpoUser(aCampoItem,"EE8","5","WorkIt")

   // *** Gera Work de Itens ...
   If Select("WorkIt") = 0
      aCampos:=ARRAY(EE8->(FCOUNT()))  //definir tamanho de aCampos eh obrigatorio

      aSemSX3 := {{"EE8_RECNO","N",7,0}}

      IF lIntegra .And. aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_FATIT"}) == 0
         aAdd(aSemSX3,{"EE8_FATIT",AVSX3("EE8_FATIT",AV_TIPO),AVSX3("EE8_FATIT",AV_TAMANHO),AVSX3("EE8_FATIT",AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_CF"   ,AVSX3("EE8_CF"   ,AV_TIPO),AVSX3("EE8_CF"   ,AV_TAMANHO),AVSX3("EE8_CF"   ,AV_DECIMAL)})
         aAdd(aSemSX3,{"EE8_TES"  ,AVSX3("EE8_TES"  ,AV_TIPO),AVSX3("EE8_TES"  ,AV_TAMANHO),AVSX3("EE8_TES"  ,AV_DECIMAL)})
      Endif

      // ** By JBJ - 26/06/2002 - 13:54
      //If lCommodity    // By JPP - Como a rotina de Tratamentos de Café e Controles de quantidades passaram para o padrão, estes campos deverão existir na workit para evitar erros em funções que validam estes campos.
         If aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_STFIX"}) == 0
            aAdd(aSemSX3,{"EE8_STFIX",AVSX3("EE8_STFIX",AV_TIPO),AVSX3("EE8_STFIX",AV_TAMANHO),AVSX3("EE8_STFIX",AV_DECIMAL)})
         EndIf

         If aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_ORIGEM"}) == 0
            aAdd(aSemSX3,{"EE8_ORIGEM",AVSX3("EE8_ORIGEM",AV_TIPO),AVSX3("EE8_ORIGEM",AV_TAMANHO),AVSX3("EE8_ORIGEM",AV_DECIMAL)})
         EndIf

         // JPM - 02/01/05 - Para ser utilizado na vinculação de R.V.
         AAdd(aSemSx3,{"WK_PREEMB",AvSx3("EE9_PREEMB",AV_TIPO),AvSx3("EE9_PREEMB",AV_TAMANHO),AvSx3("EE9_PREEMB",AV_DECIMAL)})
         AAdd(aSemSx3,{"WK_SEQEMB",AvSx3("EE9_SEQEMB",AV_TIPO),AvSx3("EE9_SEQEMB",AV_TAMANHO),AvSx3("EE9_SEQEMB",AV_DECIMAL)})
      //EndIf

      /*
      Criação dos campos WP_EE9REG e WP_EE9SLD na WorkIT, para ser usado na função AP104SLDEMB, onde irá
      alimentar os campos.
      A função AP100GRAVA irá atualizar o EE9_SLDINI.
      Autor: Alexsander Martins dos Santos
      Data e Hora: 04/08/2004 às 09:36.
      */
      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9REG"}) == 0 //Irá armazenar o nº do registro do EE9 para atualizar o EE9_SLDINI.
         aAdd(aSemSX3,{"WP_EE9REG", "N", 12, 0})
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9SLD"}) == 0 //Irá armazenar a qtde.(-/+) para atualizar o EE9_SLDINI.
         aAdd(aSemSX3,{"WP_EE9SLD", AVSX3("EE9_SLDINI", AV_TIPO), AVSX3("EE9_SLDINI", AV_TAMANHO), AVSX3("EE9_SLDINI", AV_DECIMAL)})
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9PLQ"}) == 0 //Irá armazenar o peso liquido (-/+) para atualizar o EE9_PSLQTO.
         aAdd(aSemSX3,{"WP_EE9PLQ", AVSX3("EE9_PSLQTO", AV_TIPO), AVSX3("EE9_PSLQTO", AV_TAMANHO), AVSX3("EE9_PSLQTO", AV_DECIMAL)})
      EndIf

      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "WP_EE9PBR"}) == 0 //Irá armazenar o peso bruto (-/+) para atualizar o EE9_PSBRTO.
         aAdd(aSemSX3,{"WP_EE9PBR", AVSX3("EE9_PSBRTO", AV_TIPO), AVSX3("EE9_PSBRTO", AV_TAMANHO), AVSX3("EE9_PSBRTO", AV_DECIMAL)})
      EndIf

      // JPM - 01/04/05 - Novos campos
      If aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_PRCUN"}) == 0
         If EE8->(FieldPos("EE8_PRCUN"))  > 0 .And. EE8->(FieldPos("EE8_VLFRET")) > 0 .And. ;
            EE8->(FieldPos("EE8_VLSEGU")) > 0 .And. EE8->(FieldPos("EE8_VLOUTR")) > 0 .And. ;
            EE8->(FieldPos("EE8_VLDESC")) > 0

            aAdd(aSemSX3,{"EE8_PRCUN" ,AVSX3("EE8_PRCUN" ,AV_TIPO),AVSX3("EE8_PRCUN" ,AV_TAMANHO),AVSX3("EE8_PRCUN" ,AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLFRET",AVSX3("EE8_VLFRET",AV_TIPO),AVSX3("EE8_VLFRET",AV_TAMANHO),AVSX3("EE8_VLFRET",AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLSEGU",AVSX3("EE8_VLSEGU",AV_TIPO),AVSX3("EE8_VLSEGU",AV_TAMANHO),AVSX3("EE8_VLSEGU",AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLOUTR",AVSX3("EE8_VLOUTR",AV_TIPO),AVSX3("EE8_VLOUTR",AV_TAMANHO),AVSX3("EE8_VLOUTR",AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLDESC",AVSX3("EE8_VLDESC",AV_TIPO),AVSX3("EE8_VLDESC",AV_TAMANHO),AVSX3("EE8_VLDESC",AV_DECIMAL)})
         Else
            aAdd(aSemSX3,{"EE8_PRCUN" ,AVSX3("EE8_PRECO" ,AV_TIPO),AVSX3("EE8_PRECO" ,AV_TAMANHO),AVSX3("EE8_PRECO" ,AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLFRET",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLSEGU",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLOUTR",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
            aAdd(aSemSX3,{"EE8_VLDESC",AVSX3("EE8_PRCTOT",AV_TIPO),AVSX3("EE8_PRCTOT",AV_TAMANHO),AVSX3("EE8_PRCTOT",AV_DECIMAL)})
         Endif
      EndIf

	  //LRS - 20/10/2015 - Adicionar campos na Work
	  If EE8->(FieldPos("EE8_OPC")) > 0 .And. EE8->(FieldPos("EE8_MOP")) > 0
	     aAdd(aSemSX3,{"EE8_OPC" ,AVSX3("EE8_OPC" ,AV_TIPO),AVSX3("EE8_OPC" ,AV_TAMANHO),AVSX3("EE8_OPC" ,AV_DECIMAL)})
	     aAdd(aSemSX3,{"EE8_MOP" ,AVSX3("EE8_MOP" ,AV_TIPO),AVSX3("EE8_MOP" ,AV_TAMANHO),AVSX3("EE8_MOP" ,AV_DECIMAL)})
	  EndIf

      //TRP - 27/01/07 - Campos do WalkThru
      AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
      AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

      If EECFlags("INTERMED") .And. (aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_ORIGV" }) == 0) // EECFlags("CONTROL_QTD") .And. (aScan(aSemSX3,{|x| AllTrim(x[1]) == "EE8_ORIGV" }) == 0)
         AddNaoUsado(aSemSx3,"EE8_ORIGV" )                                                    // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore
      EndIf

      If EECFlags("AMOSTRA")
         AddNaoUsado(aSemSx3, "EE8_QUADES")
      EndIf

      // BAK - campo para ser gravado o pedido real da integracao
      If AvFlags("EEC_LOGIX") .And. EE8->(FieldPos("EE8_PEDERP")) > 0
         aAdd(aSemSX3,{"EE8_PEDERP",AVSX3("EE8_PEDERP",AV_TIPO),AVSX3("EE8_PEDERP",AV_TAMANHO),AVSX3("EE8_PEDERP",AV_DECIMAL)})
      EndIf

      SX3->(DbSetOrder(2))
      If SX3->(DbSeek("EE8_DESCON")) .And. !X3Uso(SX3->X3_USADO)
         AddNaoUsado(aSemSx3, "EE8_DESCON")
      EndIf

      // CRF 22/11/2010 14:49
      aSemSX3 := AddWkCpoUser(aSemSX3,"EE8")

      cNomArq:=EECCriaTrab("EE8",aSemSX3,"WorkIt")

      EECIndRegua("WorkIt",cNomArq+TEOrdBagExt(),"EE8_SEQUEN",;
               "AllwaysTrue()",;
               "AllwaysTrue()",;
               STR0020) //"Processando Arquivo Temporario..."

      Set Index To (cNomArq+TEOrdBagExt())
   EndIf

   // *** Gera Work de Embalagens ...
   If Select("WorkEm") = 0
      vetEEK := {{"EEK_CODIGO", "C", 20,0}, {"EEK_PEDIDO","C",20,0},{"EEK_SEQUEN","C",6,0}}
      cNomArq1 := EECCriaTrab("EEK",vetEEK,"WorkEm")

      EECIndRegua("WorkEm",cNomArq1+TEOrdBagExt(),"EEK_PEDIDO+EEK_SEQUEN+EEK_CODIGO+EEK_SEQ+EEK_EMB")

      Set Index To (cNomArq1+TEOrdBagExt())
   EndIf

   // *** Gera Work de Agentes ...
   If Select("WorkAg") = 0
      bAddWork  := {|| WorkAg->(dbAppend()),AP100AGGrava(.T.,OC_PE)}

      aAgPos    := {55,4,140,261}               //posicao da enchoice
      aAgBrowse := { {"EEB_CODAGE",,STR0021},;  //"Codigo"
                     {"EEB_NOME",,STR0022},;    //"Razão Social"
                     {"EEB_TIPOAG",,STR0023}}  //"Classificação"

      If EE8->(FieldPos("EE8_TIPCOM")) > 0
         AAdd(aAgBrowse,{{||BscxBox("EEB_TIPCOM",WorkAg->EEB_TIPCOM) },,AvSx3("EEB_TIPCOM",AV_TITULO)}) //JPM - 02/06/05
      EndIf

      //CRF
      aAgBrowse :=  AddCpoUser(aAgBrowse,"EEB","2")

      aHEADER:={}
      aSemSX3  := { {"WK_RECNO", "N", 7, 0},{"EEB_OCORRE","C",1,0},{"WK_FILTRO","C",1,0} } //*** GFP 10/08/2011 - Inclusão campo WK_FILTRO

      AddNaoUsado(aSemSX3,"EEB_TOTCOM")

      If EEB->(FieldPos("EEB_FOBAGE")) > 0
         aAdd(aSemSX3,{"EEB_FOBAGE", AvSx3("EEB_FOBAGE",AV_TIPO)   ,;
                                     AvSx3("EEB_FOBAGE",AV_TAMANHO),;
                                     AvSx3("EEB_FOBAGE",AV_DECIMAL)})
      EndIf

      aCampos  := Array(EEB->(FCount()))

      cNomArq2 := EECCriaTrab("EEB",aSemSX3,"WorkAg")
      /*
      IndRegua("WorkAg",cNomArq2+OrdBagExt(),"EEB_CODAGE+EEB_TIPOAG","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
      JPM - 02/06/05 - Tipo de Comissão por Item */
      EECIndRegua("WorkAg",cNomArq2+TEOrdBagExt(),"EEB_CODAGE+EEB_TIPOAG+EEB_TIPCOM","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

      cNomArq22  := EECGetIndexFile("WorkAg", cNomArq2, 1)  // GFP - 27/05/2014
      EECIndRegua("WorkAg",cNomArq22+TEOrdBagExt(),"EEB_NOME","AllwayTrue()","AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

      Set Index To (cNomArq2+TEOrdBagExt()),(cNomArq22+TEOrdBagExt())
   EndIf

   // *** Gera Work de Instituicoes Financeiras ...
   If Select("WorkIn") = 0
      bAddWork := {|| WorkIn->(dbAppend()),AP100INSGrava(.T.,OC_PE)}

      aHEADER := {}
      aSemSX3 := { {"WK_RECNO","N", 7, 0},{"EEJ_OCORRE","C",1,0} }
      aCampos := Array(EEJ->(FCount()))

      aInPos      := {55,4,140,261}               //posicao da enchoice
      aInBrowse   := { {"EEJ_CODIGO",,STR0025},;  //"Código"
                       {"EEJ_AGENCI",,STR0026},;  //"Agência"
                       {"EEJ_NUMCON",,STR0027},;  //"Conta"
                       {"EEJ_NOME"  ,,STR0028},;  //"Nome"
                       {"EEJ_TIPOBC",,STR0029} }  //"Relação"



      // by CRF 21/10/2010 - 10:50
       aInBrowse := AddCpoUser(aInBrowse,"EEJ","2")

      aAdd(aSemSx3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      cNomArq3 := EECCriaTrab("EEJ",aSemSX3,"WorkIn")  // Criacao do arquivo de Trabalho
      EECIndRegua("WorkIn",cNomArq3+TEOrdBagExt(),"EEJ_TIPOBC+EEJ_CODIGO+EEJ_NUMCON","AllwayTrue()",;
               "AllwaysTrue()",STR0024)               //"Processando Arquivo Temporário ..."

      cNomArq32 := EECGetIndexFile("WorkIn", cNomArq3, 1)  // MCF - 09/09/2015
      EECIndRegua("WorkIn",cNomArq32+TEOrdBagExt(),"EEJ_PEDIDO+EEJ_OCORRE","AllwayTrue()",;
               "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

      Set Index To (cNomArq3+TEOrdBagExt()),(cNomArq32+TEOrdBagExt())
   EndIf

   // *** Gera Work de Depesas ...
   If Select("WorkDe") = 0
      aSemSX3  := { {"EET_RECNO", "N", 7, 0}}

      // GFP - 27/04/2012 - Criação do campo Filtro
      aAdd(aSemSX3,{"WK_FILTRO", "C", 1, 0})

      bAddWork := {|| WorkDe->(dbAppend()),AP100DSGrava(.T.,OC_PE)}

      aHeader      := {}
      aCampos      := Array(EET->(FCount()))

      aDePos    := {55,4,140,261} //posicao da enchoice
      aDeBrowse := { {{|| WorkDE->EET_DESPES+" "+if(SYB->(dbSeek(xFilial("SYB")+WorkDE->EET_DESPES)),SYB->YB_DESCR,"")},,STR0030},; //"Despesa"
                         ColBrw("EET_DESADI","WorkDE"),;
                         ColBrw("EET_VALORR","WorkDE"),;
                         {{|| IF(WorkDE->EET_BASEAD $ cSim,STR0031,STR0032) },,STR0033},; //"Sim"###"Não"###"Adianta/o ?"
                         ColBrw("EET_DOCTO","WorkDE") }


            // by CRF - 20/10/2010 - 14:03
      aDeBrowse:= AddCpoUser(aDeBrowse,"EET","2")

      SYB->(DBSETORDER(1)) //Descricao de despesas

      If EET->(FieldPos("EET_SEQ")) > 0
         aAdd(aSemSX3,{"EET_SEQ",AVSX3("EET_SEQ",2),AVSX3("EET_SEQ",3),AVSX3("EET_SEQ",4)})
      EndIf

      If EET->(FieldPos("EET_OCORRE")) > 0
         aAdd(aSemSX3,{"EET_OCORRE",AVSX3("EET_OCORRE",2),AVSX3("EET_OCORRE",3),AVSX3("EET_OCORRE",4)})
      EndIf
      aAdd(aSemSx3,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      cNomArq4 := EECCriaTrab("EET",aSemSX3,"WorkDe")

      EECIndRegua("WorkDe",cNomArq4+TEOrdBagExt(),"EET_PEDIDO+EET_DESPES+Dtos(EET_DESADI)","AllwayTrue()",;
               "AllwaysTrue()",STR0024)  //"Processando Arquivo Temporário ..."

      If EET->(FieldPos("EET_SEQ")) > 0 .And. EET->(FieldPos("EET_OCORRE")) > 0

         cNomArq4A  := EECGetIndexFile("WorkDe", cNomArq4, 1)
         EECIndRegua("WorkDe",cNomArq4A+TEOrdBagExt(),"EET_PEDIDO+EET_OCORRE+EET_SEQ+EET_DESPES","AllwayTrue()",;
         "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         cNomArq4B  := EECGetIndexFile("WorkDe", cNomArq4, 2)
         EECIndRegua("WorkDe",cNomArq4B+TEOrdBagExt(),"EET_PEDIDO+EET_SEQ","AllwayTrue()",;
         "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         Set Index to (cNomArq4+TEOrdBagExt()),(cNomArq4A+TEOrdBagExt()),(cNomArq4B+TEOrdBagExt())
      Else
         Set Index To (cNomArq4+TEOrdBagExt())
      EndIf
   EndIf

   // *** Gera Work de Notify's ...
   If Select("WorkNo") = 0
      bAddWork := {|| WorkNo->(dbAppend()),AP100NoGrv(.T.,OC_PE)}

      aHeader := {}
      aSemSX3 := { {"WK_RECNO","N", 7, 0},{"EEN_OCORRE","C",1,0} }
      aCampos := Array(EEJ->(FCount()))

      aNoPos      := {55,4,140,261}               //posicao da enchoice
      aNoBrowse   := { {"EEN_IMPORT",,STR0034},;  //"Notify"
                       {"EEN_IMLOJA",,STR0035},;  //"Loja"
                       {"EEN_IMPODE",,STR0003} }  //"Descrição"

      // by CRF 22/10/2010 - 09:48
      aNoBrowse := AddCpoUser(aNoBrowse,"EEN","2")

      cNomArq5 := EECCriaTrab("EEN",aSemSX3,"WorkNo")  // Criacao do arquivo de Trabalho
      EECIndRegua("WorkNo",cNomArq5+TEOrdBagExt(),"EEN_IMPORT+EEN_IMLOJA","AllwayTrue()",;
               "AllwaysTrue()",STR0024)               //"Processando Arquivo Temporário ..."
      Set Index To (cNomArq5+TEOrdBagExt())
   EndIf

   // ** By JBJ - 06/08/02 - 10:28
   IF Select("EXB") > 0
      If Select("WorkDoc") = 0
         aHeader    := {}
         aSemSX3    := {{"WK_RECNO","N", 7, 0}}
         aCampos    := Array(EXB->(fCount()))
         cNomArq6   := EECCriaTrab("EXB",aSemSX3,"WorkDoc")
         aDocBrowse := {{{|| If (!Empty(WorkDoc->EXB_FLAG),WorkDoc->EXB_FLAG+"-"+If(WorkDoc->EXB_FLAG="1",STR0043,STR0044),"")},"",STR0045},; //"Específica"###"Padrão(Cliente/País)"###"Tipo de Tarefa"
                        {{|| LoadDoc(WorkDoc->EXB_CODATV)},"",AVSX3("EXB_CODATV",AV_TITULO)},;
                        {{|| If (!Empty(WorkDoc->EXB_DTREAL),Transf(WorkDoc->EXB_DTREAL,"  /  /  "),"")},"",AVSX3("EXB_DTREAL",AV_TITULO)},;
                        {{|| WorkDoc->EXB_OBS},"",AVSX3("EXB_OBS",AV_TITULO)},;
                        {{|| WorkDoc->EXB_USER},"",AVSX3("EXB_USER",AV_TITULO)},;
                        {{|| If (!Empty(WorkDoc->EXB_DATA),Transf(WorkDoc->EXB_DATA,"  /  /  "),"")},"",AVSX3("EXB_DATA",AV_TITULO)}}


         // by CRF 22/10/2010 - 11:03
         aDocBrowse:= AddCpoUser(aDocBrowse,"EXB","2")




         EECIndRegua("WorkDoc",cNomArq6+TEOrdBagExt(),"EXB_ORDEM","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         cNomArq62 := EECGetIndexFile("WorkDoc", cNomArq6, 1)//CriaTrab(,.f.)
         EECIndRegua("WorkDoc",cNomArq62+TEOrdBagExt(),"EXB_CODATV+EXB_TIPO","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."

         dbSelectArea("WorkDoc")
         Set Index To (cNomArq6+TEOrdBagExt()),(cNomArq62+TEOrdBagExt())

         bAddWork := {|| AP100DocGrava(.T.,OC_PE)}
      EndIf
   Endif

   If EECFlags("INTERMED") .And.; // EECFlags("CONTROL_QTD") .And.; // se a rotina de controle de quantidades entre filiais Brasil e Off-Shore estiver ligada...
      !lSetWorks // e se não foi chamada da Ap102SetWorks  // By JPP - 21/09/2006 - 09:00 - A rotina controle de quantidade passou a ser padrão para Off-Shore

      If Select("WorkGrp") = 0 // cria work para agrupamento de itens por origem e pelos campos do aConsolida.

         aHeader := {}
         aCampos := {}
         aSemSx3 := {}
         SX3->(DbSetOrder(2))
         For i := 1 To Len(aGrpCpos) // Adiciona campos para criação da work de agrupamentos.
            SX3->(DbSeek(aGrpCpos[i]))
            If X3Uso(SX3->X3_USADO)
               AAdd(aCampos,AllTrim(aGrpCpos[i]))
            Else
               AddNaoUsado(aSemSx3,AllTrim(aGrpCpos[i]))
            EndIf
         Next
         AAdd(aSemSx3,{"WP_FLAG" ,"C",2,0})
         AAdd(aSemSx3,{"WP_SLDATU" ,"N",AvSx3("EE8_SLDATU",AV_TAMANHO),AvSx3("EE8_SLDATU",AV_DECIMAL)})
         //TRP - 27/01/07 - Campos do WalkThru
         AADD(aSemSX3,{"TRB_ALI_WT","C",03,0})
         AADD(aSemSX3,{"TRB_REC_WT","N",10,0})

         // CRF 22/11/2010 - 14:32
         aSemSx3:= addWkCpoUser(aSemSx3,"EE8")

         cNomArq7   := EECCriaTrab(,aSemSx3,"WorkGrp")
         EECIndRegua("WorkGrp",cNomArq7+TEOrdBagExt(),"EE8_ORIGEM","AllwayTrue()",;
                  "AllwaysTrue()",STR0024) //"Processando Arquivo Temporário ..."
         Set Index To (cNomArq7+TEOrdBagExt())

         aGrpBrowse := {}

         SX3->(DbSetOrder(2))

         For i := 1 To Len(aGrpCpos)
            AAdd(aGrpBrowse,ColBrw(aGrpCpos[i],"WorkGrp")) // campos do browse
            If aGrpCpos[i] = "EE8_ORIGEM"
               aGrpBrowse[Len(aGrpBrowse)][3] := STR0084 //"Sequência/Origem"
            EndIf

            If aGrpCpos[i] = "EE8_VM_DES"
               aGrpBrowse[Len(aGrpBrowse)][1] := {|| MemoLine(WorkGrp->EE8_VM_DES,AvSx3("EE8_VM_DES",AV_TAMANHO),1)}
            EndIf

            // Tratamento condicional para campos que não têm sempre o conteúdo igual, para ficar com um '-' no browse
            If aGrpInfo[i] = "N"
               cCampo := aGrpCpos[i]
               //(quase o mesmo tratamento da avsx3)
               SX3->(DbSeek(cCampo))
               If !Empty(SX3->X3_INIBRW)
                  cIniBrw := AllTrim(SX3->X3_INIBRW)
               Else
                  If !Empty(X3Cbox())
                     aBox := ComboX3Box(cCampo,X3Cbox())
                     cIniBrw := ""
                     For i:=1 To Len(aBox)
                        cIniBrw += "IF(WorkGrp->"+cCampo+" == "+IF(SX3->X3_TIPO=="C","'","")+Substr(aBox[i],1,At("=",aBox[i])-1)+IF(SX3->X3_TIPO=="C","'","")+",'"+Substr(aBox[i],At("=",aBox[i])+1)+"',"
                     Next
                     cIniBrw += "''"+Replic(")",Len(aBox))
                  ElseIf Empty(SX3->X3_PICTURE)
                     cIniBrw := "WorkGrp->"+cCAMPO
                  Else
                     cIniBrw := "Transform(WorkGrp->"+cCAMPO+",'"+AllTrim(SX3->X3_PICTURE)+"')"
                  Endif
               Endif
               cIniBrw := "{|| If(Empty(WorkGrp->" + cCAMPO + "),'-'," + cIniBrw + ") }"
               aGrpBrowse[Len(aGrpBrowse)][1] := &cIniBrw
            EndIf

         Next

      EndIf
   EndIf

   // *** Campos para mudar os Status na Alteracao ...
   aFieldCapa := {"EE7_IMPORT","EE7_CONDPA","EE7_DIASPA","EE7_MPGEXP",;
                  "EE7_INCOTE","EE7_MOEDA","EE7_FRPPCC","EE7_FRPREV" ,;
                  "EE7_SEGPRE","EE7_SEGURO","EE7_PRECOA","EE7_PGTANT",;
                  "EE7_TIPCOM","EE7_TIPCVL","EE7_VALCOM"}

   aFieldItens:= {"EE8_COD_I","EE8_SLDINI","EE8_PRECO",;
                  "EE8_PSLQUN","EE8_PSBRUN"}

   If Type("lPagtoAnte") == "L" .And. lPagtoAnte // Pagamento Antecipado habilitado // By JPP - 14/02/2006 16:55
      If Select("WORKSLD_AD") = 0 // Tabela Temporária utilizada na valida e Tratamento de Adiantamentos vinculados
         aHeader := {}
         aCampos:= Array(EEQ->(fCount()))
         aSemSx3 := {}
         Aadd(aSemSx3,{"EEQ_PREEMB","C",AvSx3("EEQ_PREEMB",AV_TAMANHO),AvSx3("EEQ_PREEMB",AV_DECIMAL)})
         Aadd(aSemSx3,{"WK_FLAG"  ,"C",02,0})
         Aadd(aSemSx3,{"WK_VLEST" ,"N",AVSX3("EEQ_VL",AV_TAMANHO),AVSX3("EEQ_VL",AV_DECIMAL)})
         Aadd(aSemSx3,{"WK_RECNO","N",10,0})
         Aadd(aSemSx3,{"WK_STATUS","C",50,0})

         // by CRF 24/11/2010 - 14:44
         aSemSx3 := AddWkCpoUser(aSemSx3,"EEQ")


         cArqAdiant := EECCriaTrab("EEQ",aSemSx3,"WORKSLD_AD")
         EECIndRegua("WORKSLD_AD",cArqAdiant+TEOrdBagExt(),"EEQ_FASE+EEQ_PREEMB+EEQ_PARC",,,STR0024) //"Processando Arquivo Temporário..."
         Set Index To (cArqAdiant+TEOrdBagExt())
      EndIf
   EndIf

   /* WFS 19/01/2009
      Convênio ICMS 84/2009.
      Criação da Work de Notas Fiscais de Remessa */
   If Type("lNFRemessa") == "L" .And. lNfRemessa
      ChkFile("EYY")
      Select("EYY")
   EndIf

   If Type("lNFRemessa") == "L" .And. lNfRemessa .And.;
      (FieldPos("EYY_PEDIDO") > 0 .And. FieldPos("EYY_SEQUEN") > 0 .And. FieldPos("EYY_FASE") > 0)

      If Select("WK_NFRem") == 0

         aHeader:= {}
         //aSemSX3:= {{"EYY_RECNO","N", 7, 0}}
         aSemSX3:= {{"EYY_RECNO","N", 7, 0},{"EE8_COD_I","C", 15, 0}}//FSY - 08/01/2014
         Aadd(aSemSX3,{"DBDELETE","L",1,0}) //MPG - 15/01/2018 - Este campo deverá ser sempre o último campo da Work

         aCampos:= Array(EYY->(FCount()))

         cArqNFRem := EECCriaTrab("EYY", aSemSX3, "WK_NFRem")
         EECIndRegua("WK_NFRem", cArqNFRem + TEOrdBagExt(), "EYY_PEDIDO + EYY_SEQUEN + EYY_NFENT + EYY_SERENT",;
                   "AllwayTrue()","AllwaysTrue()", STR0024) //"Processando Arquivo Temporário ..."
         Set Index To (cArqNFRem + TEOrdBagExt())
      EndIf
   Else
      lNfRemessa:= .F.
   EndIf

   IF(EasyEntryPoint("EECAP102"),Execblock("EECAP102",.F.,.F.,"CAMPO_EE8"),)  // LRS 21/07/2017
End Sequence

DbSelectArea(cOldArea)
Return lRet

/*
Funcao      : LoadDoc(cCodDoc)
Parametros  : Codigo do documento.
Retorno     : .t.
Objetivos   : Trazer descricao do documento.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/08/2002 09:51
Revisao     :
Obs.        :
*/
*------------------------------*
Static Function LoadDoc(cCodDoc)
*------------------------------*
Local cRet:="", aOrd:=SaveOrd("EEA")

Begin Sequence

   If EEA->(DbSeek(xFilial("EEA")+cCodDoc))
      cRet:=AllTrim(cCodDoc)+" - "+EEA->EEA_TITULO
   EndIf

End Sequence

RestOrd(aOrd)

Return cRet

*---------------------------------*
STATIC FUNCTION AP102TOT(cP_RATEIO)
*---------------------------------*
cP_RATEIO := ALLTRIM(cP_RATEIO)
WORKIT->(DBGOTOP())
DO WHILE ! WORKIT->(EOF())
   IF cP_RATEIO = "1"  // PESO LIQUIDO
      nTOTAL := nTOTAL+WORKIT->EE8_PSLQTO
   ELSEIF cP_RATEIO = "2"  // PESO BRUTO
      nTOTAL := nTotal + WorkIt->EE8_PSBRTO
   ELSE  // PRECO DIGITADO
      If lConvUnid
         nTOTAL := nTOTAL+(AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I, WorkIt->EE8_SLDINI,.F.)*;
                           Round(WorkIt->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)))
         /* By JBJ - 18/12/02.
         nTOTAL := nTOTAL+(AvTransUnid(WorkIt->EE8_UNPRC,WorkIt->EE8_UNIDAD,WorkIt->EE8_COD_I,WorkIt->EE8_PRECO,.F.)*;
                           WorkIt->EE8_SLDINI)
         */
      Else
         nTOTAL := nTOTAL+WORKIT->(Round(EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)*EE8_SLDINI))
      EndIf
   ENDIF
   If lConvUnid
      nTOTPED := nTOTPED+(AvTransUnid(WorkIt->EE8_UNIDAD, WorkIt->EE8_UNPRC, WorkIt->EE8_COD_I, WorkIt->EE8_SLDINI,.F.)*;
                           Round(WorkIt->EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)))
      /* By JBJ - 18/12/02.
      nTOTPED := nTOTPED+(AvTransUnid(WorkIt->EE8_UNPRC,WorkIt->EE8_UNIDAD,WorkIt->EE8_COD_I,WorkIt->EE8_PRECO,.F.)*;
                           WorkIt->EE8_SLDINI)
      */
   Else
      nTOTPED := nTOTPED+WORKIT->(Round(EE8_PRECO,AVSX3("EE8_PRECO",AV_DECIMAL)*EE8_SLDINI))
   EndIf
   //MFR 18/03/2109 OSSME-2319
   nTOTPED := ROUND(nTOTPED,AVSX3("EE7_TOTFOB",AV_DECIMAL))
   WORKIT->(DBSKIP())
ENDDO
RETURN(NIL)
*--------------------------------------------------------------------

/*
Funcao      : SetComissao(cCodDoc)
Parametros  : cOcorrencia => Fase (Pedido ou embarque).
Retorno     : .t.
Objetivos   : Realizar o cálculo da comissao por item.
Autor       : Jeferson Barros Jr.
Data/Hora   : 25/03/2003 15:25
Revisao     :
Obs.        :
*/
*-------------------------------*
Function SetComissao(cOcorrencia)
*-------------------------------*
Local lRet, nRec, cAlias, cWork, nComisItem:=0, nTotFob:=0

Default cOcorrencia := OC_PE

Begin Sequence

   If cOcorrencia == OC_PE
      cAlias := "EE7"
      cWork  := "WorkIt"
   Else
      cAlias := "EEC"
      cWork  := "WorkIp"
   EndIf

   nTotFob := (&("M->"+cAlias+"_TOTPED")+&("M->"+cAlias+"_DESCON"))-(&("M->"+cAlias+"_FRPREV")+;
               &("M->"+cAlias+"_FRPCOM")+&("M->"+cAlias+"_SEGPRE")+&("M->"+cAlias+"_DESPIN")  +;
               AvGetCpo("M->"+cAlias+"_DESP1")+AvGetCpo("M->"+cAlias+"_DESP2"))

   nRec := (cWork)->(Recno())
   (cWork)->(DbGoTop())

   Do While (cWork)->(!Eof())
      If cOcorrencia == OC_PE
         /*
         AMS - Retirado o arredondamento(round), para evitar deflacionamento no total de comissão obtido através do itens.
         nComisItem += Round((cWork)->EE8_PRCINC*((cWork)->EE8_PERCOM/100),2)
         */
         nComisItem += (cWork)->EE8_PRCINC*((cWork)->EE8_PERCOM/100)
      Else
         /*
         AMS - Retirado o arredondamento(round), para evitar deflacionamento no total de comissão obtido através do itens.
         nComisItem += Round((cWork)->EE9_PRCINC*((cWork)->EE9_PERCOM/100),2)
         */
         nComisItem += (cWork)->EE9_PRCINC*((cWork)->EE9_PERCOM/100)
      EndIf

      (cWork)->(DbSkip())
   EndDo

   /*
   AMS - 22/08/2005.
   &("M->"+cAlias+"_VALCOM") := (Round(nComisItem/nTotFob,4)*100)
   */
   &("M->"+cAlias+"_VALCOM") := Round((nComisItem/nTotFob)*100, AVSX3(cAlias+"_VALCOM",AV_DECIMAL))

   (cWork)->(DbGoTo(nRec))

End Sequence

Return lRet

/*
Funcao      : ap102SetWorks()
Parametros  : Nenhum.
Retorno     : aRet - Variáveis para deleção futura das works.
Objetivos   : Declaração de variáveis/Criação de works.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/04/2003 08:32.
Revisao     :
Obs.        :
*/
*----------------------*
Function ap102SetWorks()
*----------------------*
Local aRet:={}

Private cNomArq , cNomArq1, cNomArq2,;
        cNomArq3, cNomArq4, cNomArq5,;
        cNomArq6, cNomArq62, cNomArq7,;
        cArqAdiant, cArqNFRem

Private lIntegra := IsIntFat(), lCommodity:=.f.

Private cFilBr := "", cFilEx := ""

If Type("lGrdExp") == "U"
   Private lGrdExp := AvFlags("GRADE")
EndIf

Begin Sequence

   lCommodity := EECFlags("COMMODITY")

   // ** Cria as works.
   Ap102CriaWork(.t.)

   aRet:={cNomArq, cNomArq1, cNomArq2, cNomArq3,;
          cNomArq4, cNomArq5,cNomArq6, cNomArq62, cNomArq7, cArqAdiant, cArqNFRem}

End Sequence

Return aRet

/*
Funcao      : ap102DelWorks().
Parametros  : aVars.
Retorno     : .t./.f.
Objetivos   : Apagar os arquivos temporários.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/04/2003 08:40.
Revisao     :
Obs.        :
*/
*---------------------------*
Function ap102DelWorks(aVars)
*---------------------------*
Local lRet:=.t.

Begin Sequence

   If ValType(aVars) <> "A"
      Break
      lRet:=.f.
   EndIf

   If(Select("WorkIt")  > 0,WorkIt->(E_EraseArq(aVars[1])),nil)
   If(Select("WorkEm")  > 0,WorkEm->(E_EraseArq(aVars[2])),nil)
   If(Select("WorkAg")  > 0,WorkAg->(E_EraseArq(aVars[3])),nil)
   If(Select("WorkIn")  > 0,WorkIn->(E_EraseArq(aVars[4])),nil)
   If(Select("WorkDe")  > 0,WorkDe->(E_EraseArq(aVars[5])),nil)
   If(Select("WorkNo")  > 0,WorkNo->(E_EraseArq(aVars[6])),nil)
   If(Select("WorkDoc") > 0,WorkDoc->(E_EraseArq(aVars[7],aVars[8])),nil)
   If(Select("WorkGrp") > 0,WorkGrp->(E_EraseArq(aVars[9])),nil)
   If(Select("WORKSLD_AD") > 0,WORKSLD_AD->(E_EraseArq(aVars[10])),) // By JPP - 14/02/2006 - 16:00
   If(Select("Wk_NFRem") > 0,Wk_NFRem->(E_EraseArq(aVars[11])),)//RMD - 07/02/18 - Não estava considerando a work da NF de Remessa, causando erro na reabertura após a replicação

End Sequence

Return lRet

/*
Funcao      : ap102SetGrvPed()
Parametros  : lGrv -> .t. - Incluir pedido.
                      .f. - Alterar pedido.
Retorno     : .t.
Objetivos   : Declarar variaveis necessarias e executar a chamada da funcao ap100Grava.
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/04/2003 17:40.
Revisao     :
Obs.        :
*/
*-----------------------------------*
Function ap102SetGrvPed(lGrv, lAuto)
*-----------------------------------*
Local lRet:=.t.

Private aAgDeletados:={}, aInDeletados:={} , aDeDeletados:={},;
        aNoDeletados:={}, aDocDeletados:={}, aDeletados:={}

Private  lIntermed := .f.,;
         lIntCont  := EasyGParam("MV_EEC_ECO",,.F.),;
         aMemoItem :={{"EE8_DESC","EE8_VM_DES"}}

Private lLibCredAuto := AvFlags("LIBERACAO_CREDITO_AUTO") //EasyGParam("MV_AVG0057",,.F.)

Private cFilBr := "", cFilEx := ""

Private cOcorre := OC_PE
Private lTratComis := EasyGParam("MV_AVG0077",,.F.)

Private lConsign := EECFlags("CONSIGNACAO")
If lConsign .And. !Type("cTipoProc") == "C"
   Private cTipoProc := PC_RG
EndIf

Private lBACKTO    := EasyGParam("MV_BACKTO",,.F.) .AND. ChkFile("EXK") ;
                     .AND. EE8->( FieldPos("EE8_INVPAG") > 0 ) .AND. EE9->( FieldPos("EE9_INVPAG") > 0  );
                     .And. (!lConsign .Or. cTipoProc $ PC_BN+PC_BC)
                     //RMD - 02/05/06 - Não inclui o tratamento de Back To Back no processo regular quando estiver habilitada a rotina específica de Back to Back.

Private lLibPes:= GetNewPar("MV_AVG0009",.F.)
Private aItAlterados := {}
Private lReplicaDados := EasyGParam("MV_AVG0079",,.f.)
Private cArqMain  := "",;
        cArqMain2 := "",;
        cArqMain3 := "",;
        cArqMain4 := ""

If Type("nSelecao") == "U"
   Private nSelecao := VISUALIZAR
EndIf

If Type("aColsBtB") == "U"  // By JPP - 12/03/2007 - 17:30
   Private aColsBtB   :={}
EndIf
If Type("aHeaderBtB") == "U"  // By JPP - 12/03/2007 - 17:30
   Private aHeaderBtB   :={}
EndIf
If Type("cFilEXK") == "U" // By JPP - 12/03/2007 - 17:30
   Private cFilEXK := xFilial("EXK")
EndIf

If Type("lOkEstor") == "U" //ER - 31/05/2007
   Private lOkEstor := SX3->(dbSeek("ECF_PREEMB")) .And. SX3->(dbSeek("ECF_FASE")) .And. SX3->(dbSeek("ECF_PREEMB")) .And. ;
			           SX3->(dbSeek("EEQ_FASE")) .And. SX3->(dbSeek("EEQ_EVENT")) .And. SX3->(dbSeek("EEQ_NR_CON")) .And. ;
			           SX3->(dbSeek("EET_DTDEMB"))
EndIf

If Type("lContEst") == "U" //ER - 31/05/2007
   Private lContEst := EasyGParam("MV_CONTEST",,.T.)
EndIf

If Type("aEstornaECF") == "U" //ER - 31/05/2007
   Private aEstornaECF := {}
EndIf

If Type("aIncluiECF") == "U" //ER - 31/05/2007
   Private aIncluiECF:={}
EndIf

If Type("lGrdExp") == "U"
   Private lGrdExp := AvFlags("GRADE")
EndIf

Default lGrv  := .t.
Default lAuto := .F.
Begin Sequence

    lIntermed := EECFlags("INTERMED")

   // ** Calcula os precos.
   ap100PrecoI(.t.)

   // ** Gera o pedido.
   lOk := Ap100Grava(lGrv,.t., lAuto)

   If !lOk
      Do While __lSX8
         //DFS - 06/10/12 - Chamada da função para salvar no logviewer as transações
         ELinkRollBackTran()
      EndDo
   Else
      While __lSX8
         ConfirmSX8()
      Enddo
   EndIf

End Sequence

Return lRet

/*
Funcao      : AddNaoUsado
Parametros  : aSemSX3
Retorno     : nil
Objetivos   : Adicionar campos não usado no array aSemSX3
Autor       : Cristiano A. Ferreira
Data/Hora   : 04/01/2005 17:14
Revisao     :
Obs.        :
*/
Function AddNaoUsado(aSemSX3,cCpo)

Local aOrd := SaveOrd("SX3",2)

Begin Sequence

   IF SX3->(dbSeek(AvKey(cCpo,"X3_CAMPO"))) .And. ! X3Uso(SX3->X3_USADO)
      aAdd(aSemSX3,{cCpo,AVSX3(cCpo,2),AVSX3(cCpo,3),AVSX3(cCpo,4)})
   Endif

End Sequence

RestOrd(aOrd)

Return NIL

/*
Funcao      : EECFob()
Parametros  : cFase    - OC_PE (Pedido - Default) ou OC_EM (Embarque)
              lMemoria
              lMsg     - .T. = Apresenta mensagens.
                         .F. = Não apresenta mensagens.
Retorno     : Valor Fob
Objetivos   : Calcular o valor FOB de Pedido ou Embarque, da memória ou da base
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 29/01/2005 9:07.
Revisao     :
Obs.        :
*/
*-----------------------------*
Function EECFob(cFase,lMemoria, lMsg)
*-----------------------------*
Local nFob := 0, cAlias, cAliasCpo, nVlComis := 0, nRec, cProcesso, lLoopItens := .f.,cWorkIt,cAliasIt
Local aDespesas, i
Local lForcado := (Type("lMemoria") = "L") /* Define se foi informado o parâmetro que força os
                                              dados serem puxados da base ou da memória */

Local lPreco := EasyGParam("MV_AVG0085",,.f.) //Define se o desconto será incluido na formação de preço do item

Default cFase := OC_PE
Default lMsg  := .T.

Begin Sequence


   If cFase == OC_PE
      cAliasCpo := "EE7"
      cAliasIt  := "EE8"
   Else
      cAliasCpo := "EEC"
      cAliasIt  := "EE9"
   Endif

   If !lForcado
      If Type("M->"+cAliasCpo+"_FILIAL") == "C"
         lMemoria := .t.
      Else
         lMemoria := .f.
      EndIf
   EndIf

   If lMemoria .And. Type("M->"+cAliasCpo+"_FILIAL") == "U" // no caso de ser forçado ter os dados da memória, verifica se os mesmos estão disponíveis.
      If lMsg
         EECMsg(STR0097+ENTER+; //STR0097	"Função EECFob(): Não é possível utilizar os dados da memória. Por hora serão utilizados dados da base de dados. "
                 STR0098 + ProcName(1)+ENTER+; //"Rotina: " //STR0098	"Rotina: "
                 STR0099 + AllTrim(Str(ProcLine(1))), "STR0038", "MsgStop") //STR0099	"Linha : "STR0038	"Aviso"
      EndIf
      lMemoria := .f.
   EndIf

   If lMemoria
      cAlias  := "M"
      cWorkIt := If(cAliasIt == "EE8","WorkIt","WorkIp")
   Else
      cAlias  := cAliasCpo
      If (cAlias)->(Eof())
         Return 0
      EndIf
   EndIf

   If Select("WorkAg") > 0 .And. lMemoria
      nRec := WorkAg->(RecNo())
      WorkAg->(DbGoTop())
      While WorkAg->(!Eof())
         If WorkAg->EEB_TIPCOM == "3"/*Deduzir da fatura*/ .And. Left(WorkAg->EEB_TIPOAG,1) == CD_AGC//Ag. Rec. Comi.
            lLoopItens := .t.
            Exit
         EndIf
         WorkAg->(DbSkip())
      EndDo
      WorkAg->(DbGoTo(nRec))
   Else

      If lMemoria
         cProcesso := AvKey(M->&(cAliasCpo+"_"+If(cFase == OC_PE,"PEDIDO","PREEMB")),"EEB_PEDIDO")
      Else
         cProcesso := AvKey(&(cAlias+"->"+cAliasCpo+"_"+If(cFase == OC_PE,"PEDIDO","PREEMB")),"EEB_PEDIDO")
      EndIf

      EEB->(DbSetOrder(1))
      EEB->(DbSeek(xFilial("EEB")+cProcesso+cFase))
      Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == xFilial("EEB") .And.;
                                   EEB->EEB_PEDIDO == cProcesso .And.;
                                   EEB->EEB_OCORRE == cFase
         If EEB->EEB_TIPCOM == "3"/*Deduzir da fatura*/ .And. Left(EEB->EEB_TIPOAG,1) == CD_AGC//Ag. Rec. Comi.
            nVlComis += EEB->EEB_TOTCOM
         EndIf

         EEB->(DbSkip())
      EndDo
   EndIf

   If lLoopItens
      If lMemoria
         nRec := (cWorkIt)->(RecNo())
         (cWorkIt)->(DbGoTop())
         While (cWorkIt)->(!EoF())
            nFob += (cWorkIt)->&(cAliasIt+"_PRCINC")
            (cWorkIt)->(DbSkip())
         EndDo
         (cWorkIt)->(DbGoTo(nRec))
      Else
         nRec := (cAliasIt)->(RecNo())
         (cAliasIt)->(DbGoTop())
         While (cAliasIt)->(!EoF())
            nFob += (cAliasIt)->&(cAliasIt+"_PRCINC")
            (cAliasIt)->(DbSkip())
         EndDo
         (cAliasIt)->(DbGoTo(nRec))
      EndIf
   Else
      nFob := &(cAlias+"->"+cAliasCpo+"_TOTPED") + nVlComis
      //NCF - 20/08/2013 - Correcao para atender ao campo e parametro que definem subtracao ou soma do desconto ao FOB
      If !lPreco//RMD - 24/10/14 - Verifica também o parâmetro "MV_AVG0085", pois neste caso o desconto já foi considerado em "_TOTPED"
         //MFR 05/11/2019 OSSME-4012                                                                                                                             
	      If if(lMemoria,isMemVar(cAlias+"->"+cAliasCpo+"_TPDESC"),(cAlias)->(FieldPos(cAliasCpo+"_TPDESC")) > 0) .AND. &(cAlias+"->"+cAliasCpo+"_TPDESC") $ CSIM .OR.;  
     		  if(lMemoria,isMemVar(cAlias+"->"+cAliasCpo+"_TPDESC") ,(cAlias)->(FieldPos(cAliasCpo+"_TPDESC")) == 0) .AND. EasyGParam("MV_AVG0139",,.F.)
             nFob += &(cAlias+"->"+cAliasCpo+"_DESCON")
   	      Else
   	         nFob -= &(cAlias+"->"+cAliasCpo+"_DESCON")
   	      EndIf
      EndIf

      aDespesas := If(&(cAlias+"->"+cAliasCpo+"_STATUS") == "Q",{},X3DIReturn(cFase))  // GFP - 01/03/2016 - Quando processo cancelado, zera despesas para não gerar valores negativos em tela.
      For i := 1 to Len(aDespesas)
         If Type(cAlias+"->"+aDespesas[i][2]) <> "U" //FDR - 12/11/13
            nFob -= &(cAlias+"->"+aDespesas[i][2])
         EndIf
      Next
   EndIf

End Sequence

Return nFob

/*
Funcao      : AP102LoadPed(cPedido,cFil).
Parametros  : cPedido:= Pedido a ser Carregado.
              cFil:= Filial do Pedido a ser carregado.
              lSched:= se vem da Integracao.
Retorno     : Nenhum.
Objetivos   : Carregar Memória e Works com os dados do Pedido.
Autor       : Alessandro Alves Ferreira - AAF
Data/Hora   : 08/03/05 15:27
Revisao     :
Obs.        :
*/
*---------------------------------*
Function AP102LoadPed(cPedido,cFil,lSched)
*---------------------------------*
Local aOrd:= SaveOrd({"EE7"})
Local nInc

Default cFil := xFilial("EE7")
Default lSched := .F.

cFilOld:= cFilAnt // Guarda Filial Anterior.
cFilAnt:= cFil    // Seta a filial.

EE7->(DbSetOrder(1))
EE7->(DbSeek(cFil+cPedido))

// *** Cria Work's/Define variaves ...
If lSched // ** By OMJ - 07/07/2005 - Nao exibir tela se for executado via RFC.
   EECAP102()
   lRet := AP100GRTRB(ALTERAR)
Else
   MsAguarde({|| MsProcTxt(STR0100),; //STR0100 "Preparando Dados do Processo ..."
                 EECAP102(),;
                 lRet := AP100GRTRB(ALTERAR) }, STR0101) //STR0101	"Processo de Exportação"
EndIf

cFilAnt:= cFilOld//Retorna a Filial.

RestOrd(aOrd)

Return .t.

/*
Funcao      : AP102CanModify(cProc).
Parametros  : cProc := Processo.
              lShowMessage := Mostra ou não mensagens //JPM - 09/05/05
Retorno     : Nenhum.
Objetivos   : Verificar se o processo poderá ser alterado de acordo com critérios diversos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/04/2005 - 17:05.
Revisao     :
Obs.        :
*/
*-----------------------------------------*
Function AP102CanModify(cProc,lShowMessage)
*-----------------------------------------*
Local lRet := .t., lTemSaldo := .t., lEmbarcado := .t.
Local aOrd:=SaveOrd({"EE7","EE8","EE9","EEC"})
Local cOldProc

Default lShowMessage := .t. //JPM

Begin Sequence

   If Empty(cProc)
      lRet := .f.
      Break
   EndIf

   cProc := AvKey(cProc,"EE7_PEDIDO")

   If nSelecao == APRVCRED
      If xFilial("EE7") == cFilEx
         EE7->(DbSetOrder(1))
         //If EE7->(DbSeek(cFilEx+cProc))
         If EE7->(DbSeek(cFilBr+cProc))  // PLB 12/09/06 - Verificar se o pedido existe na filial Brasil
            If lShowMessage
               //MsgInfo(STR0102,STR0051) //STR0102	"A aprovação de crédito deste pedido deverá ser realizada a partir do pedido lançado na filial Brasil." //STR0051  	Atenção
               EasyHelp(STR0102,STR0051) //STR0102	"A aprovação de crédito deste pedido deverá ser realizada a partir do pedido lançado na filial Brasil." //STR0051  	Atenção
            EndIf
            lRet:=.f.
            Break
         EndIf
      EndIf
   EndIf

   EE9->(DbSetOrder(1))
   EE8->(DbSetOrder(1))
   EEC->(DbSetOrder(1))

   If EE8->(DbSeek(xFilial("EE7")+cProc))
      Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == xFilial("EE8") .And.;
                                   EE8->EE8_PEDIDO == cProc
         Do Case
            Case EE8->EE8_SLDATU > 0
                 lTemSaldo := .t.
                 Break

            Case EE8->EE8_SLDATU == 0
                 cOldProc := ""
                 If EE9->(DbSeek(xFilial("EE9")+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
                    Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9")  .And.;
                                                 EE9->EE9_PEDIDO == EE8->EE8_PEDIDO .And.;
                                                 EE9->EE9_SEQUEN == EE8->EE8_SEQUEN .And. lEmbarcado

                       /* by jbj - Neste ponto o sistema verifica para cada linha do pedido, se todas as linhas
                                   possuem processo de embarque, em caso positivo, posteriormente o sistema irá
                                   exibir alerta ao usuário explicando as validações realizadas. */

                       If cOldProc <> EE9->EE9_PREEMB
                          If EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
                             If Empty(EEC->EEC_DTEMBA)
                                lEmbarcado := .f.
                             EndIf
                          EndIf
                          cOldProc := EE9->EE9_PREEMB
                       EndIf

                       EE9->(DbSkip())
                    EndDo
                 EndIf
         EndCase

         EE8->(DbSkip())
      EndDo

      If lEmbarcado
         If lShowMessage
            //MsgInfo(STR0103,STR0051) //STR0103	"Todas as quantidades dos itens do pedido já foram embarcadas. O sistema não permitirá alterações." //STR0051  	Atenção
            EasyHelp(STR0103,STR0051) //STR0103	"Todas as quantidades dos itens do pedido já foram embarcadas. O sistema não permitirá alterações." //STR0051  	Atenção
         EndIf
         lRet:=.f.
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ap102VldExcIt()
Parametros  : Alias com base no qual serão feitas as validações // JPM - 14/10/05
Retorno     : .T./.F.
Objetivos   : Não permitir excluir itens vinculados a embarque.
Autor       : Julio de Paula Paz
Data/Hora   : 19/08/2005 - 10:00
Revisao     :
Obs.        :
*/
*----------------------------*
Function Ap102VldExcIt(cAlias)
*----------------------------*
Local lRet := .T.
Default cAlias := "WorkIt"

Begin Sequence
   If &(cAlias+"->EE8_SLDINI") # &(cAlias+"->EE8_SLDATU")
      EasyHelp(STR0080,STR0051)  // "Item envolvido em um ou mais embarques. A sua exclusão não será permitida."###"Atenção"
      lRet := .F.
   EndIf
End Sequence
Return lRet

/*
Funcao      : Ap102CpoBrowse()
Objetivos   : Mudar o array de browse para a vinculação de R.V.
Retorno     : Array modificado
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 02/01/2006 - 10:31
*/
*---------------------------*
Function Ap102CpoBrowse(nOpc)
*---------------------------*
Local aRet, nPos1, nPos2, aAux

Begin Sequence

   If aRotina[nOpc][4] <> VINCULAR_RV
      Return aCampoItem
   EndIf

   aRet := aClone(aCampoItem)

   AAdd(aRet,)
   AIns(aRet,5)
   aRet[5] := {"","",""}

   nPos1 := AScan(aRet,{|x| x[3] == STR0019}) //"Saldo a Embarcar"

   aRet[5] := AClone(aRet[nPos1])

   ADel(aRet,nPos1) // exclui a coluna quantidade
   ASize(aRet,Len(aRet)-1) // redimensiona o array

   nPos2 := AScan(aRet,{|x| x[3] == STR0011}) //"Quantidade"

   aAux := AClone(aRet[nPos2])
   ADel(aRet,nPos2) // exclui a coluna saldo
   ASize(aRet,Len(aRet)-1) // redimensiona o array

   aRet[5][3] := STR0086 //"Qtd. A Vinc."

   AAdd(aRet,)
   AIns(aRet,6)
   aRet[6] := aAux

   // Incluir coluna "Embarque"
   AAdd(aRet,Nil)
   AIns(aRet,1)
   aRet[1] := {{|| Transf(WorkIt->WK_PREEMB,AvSx3("EEC_PREEMB",AV_PICTURE))},"",STR0085} //"Nro. Embarque"

End Sequence

Return aRet

/*
Funcao      : Ap102WkVinc()
Objetivos   : Na opção de vinculação de R.V., carregar os itens que estão sem R.V. também.
Retorno     : Nil
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 02/01/2006 - 11:54
*/
*--------------------*
Function Ap102WkVinc()
*--------------------*
Local lCarregou := .f., i, nRec

Begin Sequence

   If Type("nSelecao") <> "N"
      Break
   EndIf

   If aRotina[nSelecao][4] <> VINCULAR_RV
      Break
   EndIf

   EE9->(DbSetOrder(1))

   WorkIt->(DbGoTop())
   While WorkIt->(!EoF())
      If Empty(WorkIt->WK_PREEMB)
         lCarregou := .f.
         nRec := WorkIt->(RecNo())
         EE9->(DbSeek(xFilial()+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN))
         While EE9->(!EoF()) .And. EE9->(EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN) == (xFilial("EE9")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN)
            If !lCarregou
               For i := 1 To WorkIt->(FCount())
                  M->&(WorkIt->(FieldName(i))) := WorkIt->(FieldGet(i))
               Next
               lCarregou := .t.
            EndIf
            WorkIt->(DbAppend())
            AvReplace("M","WorkIt")
            WorkIt->EE8_SLDINI := EE9->EE9_SLDINI
            WorkIt->EE8_SLDATU := EE9->EE9_SLDINI

            WorkIt->WK_PREEMB  := EE9->EE9_PREEMB
            WorkIt->WK_SEQEMB  := EE9->EE9_SEQEMB
            WorkIt->EE8_RV     := EE9->EE9_RV
            WorkIt->EE8_DTRV   := EE9->EE9_DTRV

            WorkIt->(DbGoTo(nRec))
            WorkIt->EE8_SLDINI -= EE9->EE9_SLDINI

            EE9->(DbSkip())
         EndDo
         WorkIt->(DbGoTo(nRec))
         If WorkIt->EE8_SLDINI = 0
            WorkIt->(DbDelete())
         EndIf
      EndIf
      If !Empty(WorkIt->EE8_RV)
         WorkIt->EE8_SLDATU := 0
      EndIf
      WorkIt->(DbSkip())
   EndDo

End Sequence

Return Nil

/*
Funcao      : Ap102Grade()
Objetivos   : Realiza os tratamentos para exibição da grade de produtos.
Retorno     : lRet
Autor       : Eduardo Contessoto Romanini
Data/Hora   : 26/10/2009 - 11:20
Revisão     : WFS - 02/03/2010
              Passagem da quantidade de linhas durante a inclusão de um novo produto
*/
*---------------------------*
Function Ap102Grade(cCpoName)
*---------------------------*
Local lRet        := .T.
Local lReferencia := .F.

Local nLin

Local cCpoCont := ""

Default cCpoName := ReadVar()

Begin Sequence

   If Type("lGrade") == "U"
      lGrade := AvFlags("GRADE")
   EndIf

   If !lGrade
      Break
   EndIf

   If nOpcI == INC_DET
      nLin:= WorkIt->(EasyRecCount()) + 1
   Else
      nLin:= WorkIt->(RecNo())
   EndIf

   Do Case
      Case cCpoName == "EE8_COD_I"

           cCpoCont := M->EE8_COD_I

           If lGrade
              If MatGrdPrrf(@cCpoCont)
                 lReferencia := .T.
                 If nOpcI == INC_DET
                    oGrdExp:MontaGrade(nLin,cCpoCont,.T.,,lReferencia)
                 EndIf

                 SB4->(DbSetOrder(1))
                 If SB4->(DbSeek(xFilial("SB4")+AvKey(M->EE8_COD_I,"B4_COD")))

                    M->EE8_VM_DES := SB4->B4_DESC
                    M->EE8_PRECO  := SB4->B4_PRV1
                    M->EE8_PSLQUN := SB4->B4_PESO
                    M->EE8_UNIDAD := SB4->B4_UM
                 EndIf
              Else
                 If !ExistCpo("SB1",cCpoCont)
                    lRet := .F.
                    Break
                 Else
                    lReferencia := .F.
                    If nOpcI == INC_DET
                       oGrdExp:MontaGrade(nLin,cCpoCont,.T.,,lReferencia)
                    EndIf
                 EndIf
              EndIf

           Else
              If !ExistCpo("SB1",cCpoCont)
                 lRet := .F.
                 Break
              EndIf
           EndIf

      Case cCpoName == "EE8_SLDINI"

            cCpoCont := M->EE8_COD_I

            If lGrade
               If MatGrdPrrf(@cCpoCont)
                  oGrdExp:cProdRef := M->EE8_COD_I
                  oGrdExp:lShowGrd := .T.
                  oGrdExp:nPosLinO := nLin

                  If oGrdExp:Show(cCpoName)
                     If oGrdExp:lOk
                        M->EE8_SLDINI:= oGrdExp:nQtdInformada
                     Else
                        M->EE8_SLDINI:= WorkIt->EE8_SLDINI
                        lRet:= .F.
                     EndIf
                  EndIf
               EndIf
            EndIf
            EECPPE07("PESOS",, cCpoName)
   End Case

End Sequence

Return lRet

/*
Funcao      : Ap102GrdValid()
Objetivos   : Efetua a validacao dos campos digitados na grade
Retorno     : lRet
Autor       : Eduardo Contessoto Romanini
Data/Hora   : 26/10/2009 - 12:00
*/
*----------------------*
Function Ap102GrdValid()
*----------------------*
Local lRet := .T.

Local cProdGrd  := ""

Local nLinAcols := 0
Local nQtdDig   := 0
Local nColuna   := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(Substr(Readvar(),4))})

Begin Sequence

   nLinAcols := oGrdExp:oGetDados:oBrowse:nAt
   cProdGrd  := oGrdExp:GetNameProd(,nLinAcols,nColuna)
   nQtdDig   := &(ReadVar())

   If nQtdDig < 0
      EasyHelp(STR0105,STR0051) //STR0105 "Não é possível preencher quantidade negativa." //STR0051 "Atenção"
      lRet := .F.
      Break
   EndIf

   EE8->(DbSetOrder(1))
   If EE8->(DbSeek(xFilial("EE8")+M->EE8_PEDIDO+M->EE8_SEQUEN+AvKey(cProdGrd,"EE8_COD_I")))
      If EE8->EE8_SLDATU < EE8->EE8_SLDINI
         If nQtdDig < (EE8->EE8_SLDINI - EE8->EE8_SLDATU)
            EasyHelp(STR0106,STR0051) //STR0106 "Não há saldo disponível no pedido para essa alteração" //STR0051 "Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ap102GrdMonta()
Objetivos   : Efetua a montagem da grade de produtos
Retorno     : Nil
Autor       : Eduardo Contessoto Romanini
Data/Hora   : 29/10/2009 - 11:00
*/
*----------------------*
Function Ap102GrdMonta()
*----------------------*
Local cProdRef := ""
Local cLinha   := ""
Local cColuna  := ""
Local cMascara := EasyGParam("MV_MASCGRD")

Local nTamRef  := Val(Substr(cMascara,1,2))
Local nLinha   := 0
Local nColuna  := 0

Local nItGrade := 0

Begin Sequence

   EE8->(DbSetOrder(1))
   If EE8->(DbSeek(xFilial("EE8")+M->EE7_PEDIDO))
      While EE8->(!EOF()) .and. EE8->(EE8_FILIAL+EE8_PEDIDO) == xFilial("EE8")+M->EE7_PEDIDO

         cProdRef := SubStr(EE8->EE8_COD_I,1,nTamRef)
         If nItGrade <> Val(EE8->EE8_SEQUEN)
            nItGrade++
         EndIf

         If EE8->EE8_GRADE == "S"

            lReferencia := .T.

            &(MaReadGrd()):MontaGrade(nItGrade,@cProdRef)

            cLinha  := AllTrim(Substr(EE8->EE8_COD_I,&(MaReadGrd()):TamRef()+1,&(MaReadGrd()):TamLin()))
            cColuna := AllTrim(Substr(EE8->EE8_COD_I,(&(MaReadGrd()):TamRef()+&(MaReadGrd()):TamLin()+1),&(MaReadGrd()):TamCol()))

            nColuna := &(MaReadGrd()):RetPosCol(nItGrade,cColuna)

            nLinha  := &(MaReadGrd()):RetPosLin(nItGrade,cLinha)

            If ( nColuna<>0 .And. nLinha <> 0 )
               nColuna++
               &(MaReadGrd()):aColsGrade[nItGrade][nLinha][nColuna][&(MaReadGrd()):GetFieldGrdPos("EE8_SLDINI")]+= EE8->EE8_SLDINI
               &(MaReadGrd()):aHeadGrade[nItGrade][1]:= "R"
            EndIf
         Else
            lReferencia := .F.
            oGrdExp:MontaGrade(nItGrade,cProdRef,.T.,,lReferencia)
         EndIf
         EE8->(DbSkip())
      EndDo
   EndIf

End Sequence

Return

/*
Funcao      : Ap102GrdArray()
Objetivos   : Grava os itens da grade no array aGrdRec, evitando
              assim problemas no objeto oGrdExp após a integração
              com o SigaFAT.
Parâmetros  : nLinAcols
Retorno     : Nil
Autor       : Eduardo Contessoto Romanini
Data/Hora   : 16/12/2009 - 11:00
Revisão     : WFS 26/02/2010
              Tratamento de deleção de itens.
*/
*--------------------------------*
Function Ap102GrdArray(nLinAcols)
*--------------------------------*
Local cCpoCont := WorkIt->EE8_COD_I
Local cProdGrd := ""
Local nQuantDig  := 0
//Local nLinAcols := 1
Local nLinha    := 0
Local nColuna   := 0

Local aGrdAux := {}

Begin Sequence

   If Type("lGrade") == "U"
      lGrade := AvFlags("GRADE")
   EndIf

   If !lGrade
      Break
   EndIf

   If Type("aGrdRec") <> "A"
      Break
   EndIf

   oGrdExp:nPosLinO := nLinAcols

   If MatGrdPrrf(@cCpoCont)
      For nLinha:=1 to Len(oGrdExp:aColsGrade[nLinAcols])
         For nColuna:=2 to Len(oGrdExp:aHeadGrade[nLinAcols])

            nQuantDig := oGrdExp:aColsFieldByName("EE8_SLDINI",nLinAcols,nLinha,nColuna)
            cProdGrd  := oGrdExp:GetNameProd(cCpoCont,nLinha,nColuna)

            //Se é um item deletado da WorkIt, armazena o RecNo caso exista na base
            If WorkIt->(Deleted()) .And. WorkIt->EE8_RecNo <> 0
               If EE8->(DBGoTo(WorkIt->EE8_RecNo))
                  AAdd(aGrdAux, {nQuantDig, cProdGrd, EE8->(RecNo())})
               Else
                  AAdd(aGrdAux, {nQuantDig, cProdGrd, Nil})
               EndIf
            Else
               AAdd(aGrdAux, {nQuantDig, cProdGrd, Nil})
            EndIf

         Next
      Next
      aAdd(aGrdRec,{WorkIt->EE8_SEQUEN,aGrdAux})
   Else
      aAdd(aGrdRec,{WorkIt->EE8_SEQUEN,{}})
   EndIf
End Sequence

Return

/*
Funcao      : Ap102GrdGrava()
Objetivos   : Efetua a gravação dos itens da grade na tabela EE8
Retorno     : Nil
Autor       : Eduardo Contessoto Romanini
Revisão     : Wilsimar Fabrício da Silva
              Correção na gravação das descrições
              Correção na gravação dos pesos
              Correção na replicação de dados alterados (gravação de campos)
Data/Hora   : 28/10/2009 - 10:45
*/
*----------------------*
Function Ap102GrdGrava()
*----------------------*
Local aOrd := SaveOrd({"WorkIt","EE8"})

Local cField   := ""
Local cCpoCont := WorkIt->EE8_COD_I
Local cProdGrd := ""
Local cDescProd:= ""

Local nItemGrd   := 0
Local nQuantDig  := 0
Local nQuantBase := 0
Local nSaldo     := 0
Local nCont      := 1
Local nInc       := 0
Local nPos       := 0
Local nInc2      := 0
Local nPos2      := 0


Begin Sequence

   If Type("lGrade") == "U"
      lGrade := AvFlags("GRADE")
   EndIf

   If !lGrade
      Break
   EndIf

   If Type("aGrdRec") <> "A"
      Break
   EndIf

   If MatGrdPrrf(@cCpoCont)

      nPos:= aScan(aGrdRec,{|x| x[1] == WorkIt->EE8_SEQUEN})
      If nPos > 0
         For nInc:= 1 To Len(aGrdRec[nPos][2])

            nQuantDig := aGrdRec[nPos][2][nInc][1]
            cProdGrd  := aGrdRec[nPos][2][nInc][2]
            cDescProd := Posicione("SB1", 1, SB1->(xFilial()) + cProdGrd, "B1_DESC")

            ////////////////////////////////////////////////////
            //Verifica se já existe o registro gravado na base//
            ////////////////////////////////////////////////////
            EE8->(DbSetOrder(1)) ////EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN + EE8_COD_I
            If EE8->(DbSeek(xFilial("EE8")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN+AvKey(cProdGrd,"EE8_COD_I")))

               nQuantBase := EE8->EE8_SLDINI

               ////////////////////////////////////////////////////////
               //Verifica se foi digitada quantidade no item da grade//
               ////////////////////////////////////////////////////////
               If nQuantDig > 0

                  nItemGrd++

                  //Verifica a próxima sequência disponível para o item da grade
                  nItemGrd:= AP102GrdItem(M->EE7_PEDIDO, WorkIt->EE8_SEQUEN, nItemGrd, "EE8")

                  EE8->(RecLock("EE8", .F.))

                  //Gravação do item da grade na tabela EE8
                  GradeGrvItem(nItemGrd, cProdGrd, nQuantDig, cDescProd)

                  If nQuantDig > nQuantBase
                     nSaldo := nQuantDig - nQuantBase
                     EE8->EE8_SLDATU += nSaldo
                  ElseIf nQuantDig < nQuantBase
                     nSaldo := nQuantBase - nQuantDig
                     EE8->EE8_SLDATU -= nSaldo
                  EndIf

                  EE8->(MsUnlock())
               EndIf

            //////////////////////////////////////
            //Não foi enontrado registro na base//
            //////////////////////////////////////
            Else
               ////////////////////////////////////////////////////////
               //Verifica se foi digitada quantidade no item da grade//
               ////////////////////////////////////////////////////////
               If nQuantDig > 0

                  nItemGrd++

                  //////////////////////////////////////////////////////////////
                  //Verifica se é a primeira gravação de itens da grade       //
                  //WFS: a primeira gravação, realizada pelo padrão sem grade,//
                  //será excluído, sendo considerada apenas a gravação        //
                  //por este tratamento.                                      //
                  //////////////////////////////////////////////////////////////
                  EE8->(DbSetOrder(1)) //EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN + EE8_COD_I
                  If EE8->(DbSeek(xFilial("EE8") + M->EE7_PEDIDO + WorkIt->EE8_SEQUEN + AvKey(cCpoCont, "EE8_COD_I")))

                     EE8->(RecLock("EE8",.F.))

                     For nCont:= 1 To Len(aMemoItem)
                        If EE8->(FieldPos(aMemoItem[nCont][1])) > 0 .And.!Empty(EE8->&(aMemoItem[nCont][1]))
                            EasyMSMM(EE8->&(aMemoItem[nCont][1]),,,, EXCMEMO,,, "EE8", aMemoItem[nCont][1])
                        EndIf
                     Next

                     EE8->(DBDelete())
                     EE8->(MsUnlock())

                  EndIf

                  //Verifica a próxima sequência disponível para o item da grade
                  nItemGrd:= AP102GrdItem(M->EE7_PEDIDO, WorkIt->EE8_SEQUEN, nItemGrd, "EE8")

                  //Inclusão de um novo registro da grade de produtos
                  EE8->(RecLock("EE8",.T.))

                  GradeGrvItem(nItemGrd, cProdGrd, nQuantDig, cDescProd)

                  EE8->(MsUnlock())

               EndIf
            EndIf
         Next
      EndIf
   Else
      EE8->(RecLock("EE8", .F.))
      EE8->EE8_GRADE:= "N"
      EE8->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return Nil


/*
Função      : GradeGrvItem()
Objetivos   : Efetiva a gravação dos itens da grade na tabela EE8
Parâmetros  : nItemGrd, cProdGrd, nQuantDig, cDescProd
Retorno     : Nil
Autor       : Wilsimar Fabrício da Silva
Revisão     :
Data/Hora   : 18/02/2010
*/
Static Function GradeGrvItem(nItemGrd, cProdGrd, nQuantDig, cDescProd)
Local cField
Local nCont,;
      nPos,;
      nDecim:= EasyGParam("MV_AVG0110",, 2)

Begin Sequence

   For nCont:= 1 To EE8->(FCount())

      cField:= EE8->(FieldName(nCont))
      nPos  := WorkIt->(FieldPos(cField))

      If nPos > 0
         EE8->(FieldPut(nCont, WorkIt->(FieldGet(nPos))))
      Endif

   Next

   EE8->EE8_FILIAL := xFilial("EE8")
   EE8->EE8_PEDIDO := M->EE7_PEDIDO
   EE8->EE8_GRADE  := "S"
   EE8->EE8_ITEMGR := StrZero(nItemGrd, AVSX3("EE8_ITEMGR", AV_TAMANHO))

   //Quantidades
   EE8->EE8_COD_I  := cProdGrd
   EE8->EE8_SLDINI := nQuantDig
   EE8->EE8_SLDATU := nQuantDig

   //Valores
   EE8->EE8_PRCTOT:= Round((WorkIt->EE8_PRCTOT / WorkIt->EE8_SLDINI) * nQuantDig, nDecim)
   EE8->EE8_PRCINC:= Round((WorkIt->EE8_PRCINC / WorkIt->EE8_SLDINI) * nQuantDig, nDecim)

   //Recálculo dos pesos e quantidade de embalagens
   If (nQuantDig % WorkIt->EE8_QE) <> 0
      EE8->EE8_QTDEM1:= Int(nQuantDig / WorkIt->EE8_QE) + 1
   Else
      EE8->EE8_QTDEM1:= Int(nQuantDig / WorkIt->EE8_QE)
   EndIf

   EE5->(DBSetOrder(1)) //EE5_FILIAL + EE5_CODEMB
   EE5->(DBSeek(xFilial() + EE8->EE8_EMBAL1))

   EE8->EE8_PSLQTO:= nQuantDig * WorkIt->EE8_PSLQUN
   EE8->EE8_PSBRTO:= EE8->EE8_PSLQTO +;
                     (EE8->EE8_QTDEM1 * AvTransUnid("KG", EE8->EE8_UNPES, cProdGrd, EE5->EE5_PESO, .F.)) +;
                     MultiEmbal(EE8->EE8_QTDEM1, EE8->EE8_EMBAL1)

   //Descrição do produto
   For nCont:= 1 To Len(aMemoItem)
      If EE8->(FieldPos(aMemoItem[nCont][1])) > 0

         //Se a descrição já foi gravada alguma vez, exclui antes
         If !Empty(EE8->&(aMemoItem[nCont][1]))
            EasyMSMM(EE8->&(aMemoItem[nCont][1]),,,, EXCMEMO,,, "EE8", aMemoItem[nCont][1])
         EndIf

         EE8->(EasyMSMM(, AVSX3(aMemoItem[nCont][2], AV_TAMANHO),, cDescProd, INCMEMO,,, "EE8", aMemoItem[nCont][1]))
      EndIf
   Next

End Sequence

Return Nil

/*
Função      : AP102GrdItem()
Objetivos   : Retornar a próxima sequência do item da grade disponível.
Parâmetros  : cPedido  - pedido de exportação
              cItem    - item do pedido de exportação
              nItemGrd - item a ser verificado se encontra-se disponível
              cAlias   - indica se a chamada foi realizada do pedido de exportação ou do pedido de vendas
Retorno     : nItemGrd - item da grade disponível para uso
Autor       : Wilsimar Fabrício da Silva
Observação  : Nos tratamentos-padrão da grade, a sequência sempre é reordenada pela ordem como os itens são
              montados no objeto, sendo que a sequência dos itens excluídos na mesma operação não serão
              reaproveitados.


Revisão     :
Data/Hora   : 18/02/2010
*/

Function AP102GrdItem(cPedido, cItem, nItemGrd, cAlias)
Local aOrd:= SaveOrd(cAlias)

Local nRecNo:= (cAlias)->(RecNo()),;
      nPos  := 0

Local lContinua:= .T.

Default cPedido:= WorkIt->EE8_PEDIDO,;
        cItem  := WorkIt->EE8_SEQUEN


Begin Sequence

   If Empty(cPedido) .Or. Empty(cItem)
      cPedido:= WorkIt->EE8_PEDIDO
      cItem  := WorkIt->EE8_SEQUEN
   EndIf

   nPos:= AScan(aItGrdRest, {|x| x[1] == cPedido + cItem})

   Do Case

      Case cAlias == "EE8"

         /************
           Na tabela EE8, o campo EE8_ITEMGR faz parte da chave única do registro.
           Neste caso, após verificar a próxima sequência disponível será realizado um tratamento
           que verificará se esta sequência encontra-se em uso por outro registro. Caso a constatação
           seja positiva, a sequência será alterada para uma outra qualquer, sendo corrigida nos
           próximos loops
           ********************************************************************************************/

         //Não há restrições para o uso da sequência enviada
         If nPos == 0
            lContinua:= .F.
         EndIf

         //Verificando qual o próximo item disponível na sequência
         While lContinua

            If AScan(aItGrdRest[nPos][2], nItemGrd) > 0
               nItemGrd ++
            Else
               lContinua:= .F.
            EndIf

         EndDo

         EE8->(DBSetOrder(1)) //EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN

         If EE8->(DBSeek(xFilial() + cPedido + cItem))

            While EE8->(!Eof()) .And.;
                  EE8->(EE8_FILIAL + EE8_PEDIDO + EE8_SEQUEN) == xFilial("EE8") + cPedido + cItem

               If EE8->EE8_ITEMGR == StrZero(nItemGrd, AvSx3("EE8_ITEMGR", AV_TAMANHO))
                  EE8->(RecLock("EE8", .F.))
                  EE8->EE8_ITEMGR:= StrZero(1000 - nItemGrd, AvSx3("EE8_ITEMGR", AV_TAMANHO))
                  EE8->(MsUnlock())
                  Exit
               EndIf

               EE8->(DBSkip())
            EndDo
         EndIf

      Case cAlias == "SC6"

         /* **********
            Na tabela SC6, o campo C6_ITEMGRD não faz parte de chave única.
            Neste caso, quando não houver restrição do uso da sequência enviada para verificação,
            será retornada a mesma.
            *************************************************************************************/
      OtherWise
      //nada

   EndCase

End Sequence

RestOrd(aOrd)
(cAlias)->(DBGoTo(nRecNo))

Return nItemGrd

/*
Função      : AP102ViaTrans()
Objetivos   : Retornar Via de Transporte
Parâmetros  : cOrigem  - Origem da Via de Transporte
              cItem    - Destino da Via de Transporte
Retorno     : cVia - Via de Transporte
Autor       : Marcos Roberto Ramos Cavini Filho
Observação  : -
Revisão     :
Data/Hora   : 11/05/2015
*/

Function AP102ViaTrans(lValidacao)
Local cVia := ""
Local cOrigem := ""
Local cDestino := ""
Local xRet
Default lValidacao := .F.

Begin Sequence

   If lValidacao
      xRet := AvFlags("EEC_LOGIX") .And. !AvFlags("EEC_LOGIX_PREPED")
   Else

   EXJ->(dbSetOrder(1))
   EXJ->(dbSeek(xFilial("EXJ")+M->EE7_IMPORT+M->EE7_IMLOJA))
   Do Case
      Case !Empty(SA1->A1_DEST_1)
       cDestino := SA1->A1_DEST_1
          If (EXJ->(FieldPos("EXJ_ORI_1")) # 0 .And. !Empty(EXJ->EXJ_ORI_1)) //MCF - 11/05/2015                //NCF - 21/05/2015
             cOrigem := EXJ->EXJ_ORI_1
          EndIf
       Case !Empty(SA1->A1_DEST_2)
          cDestino := SA1->A1_DEST_2
             If (EXJ->(FieldPos("EXJ_ORI_2")) # 0 .And. !Empty(EXJ->EXJ_ORI_2))  //TRP - 14/05/2015 - FIELDPOS()
                cOrigem := EXJ->EXJ_ORI_2
              EndIf
       Case !Empty(SA1->A1_DEST_3)
          cDestino := SA1->A1_DEST_3
             If (EXJ->(FieldPos("EXJ_ORI_3")) # 0 .And. !Empty(EXJ->EXJ_ORI_3)) //TRP - 14/05/2015 - FIELDPOS()
                cOrigem := EXJ->EXJ_ORI_3
             EndIf
   End Case

   If Empty(cOrigem)
      SYR->(DbSetOrder(4))
	  SYR->(DbSeek(xFilial("SYR")+cDestino))
	  cVia := SYR->YR_VIA
   ElseIf Empty(cDestino)
	  SYR->(DbSetOrder(3))
	  SYR->(DbSeek(xFilial("SYR")+cOrigem))
	  cVia := SYR->YR_VIA
   Else
	  SYR->(DbSetOrder(5))
	  SYR->(DbSeek(xFilial("SYR")+cOrigem+cDestino))
	  cVia := SYR->YR_VIA
   Endif

   If !Empty(cVia) .And. Empty(M->EE7_VIA) //MCF - 11/05/2015
      M->EE7_VIA := AllTrim(cVia)
      lGatVia := .T.
      AP100Crit("EE7_VIA")
      lGatVia := .F.
   EndIf

   xRet := cVia

Endif
End Sequence
Return xRet
/*
Funcao     : AP102CboxAmo()
Parametros : EE7_AMOSTR ou EEC_AMOSTR
Retorno    : Opção para execução.
Objetivos  : Valida o combobox dos campos EE7_AMOSTR e EEC_AMOSTR.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 03/11/2015 - 10:38
*/
*-----------------------------*
Function AP102CboxAmo(cCampo)
*-----------------------------*
Local aOrd := SaveOrd("SX3")
Local cComboBox := ""
Local cRet := &(cCampo)

SX3->(DbSetOrder(2))
SX3->(DbSeek(cCampo))
cComboBox := AllTrim(X3CBOX())

If cRet == "2" .AND. !Empty(cComboBox)
   nAt := At("2=",cComboBox)
   If SubStr(cComboBox,nAt+2,1) == "S"
      cRet := "4"
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return cRet

/*
Funcao     : AP102IniBrw()
Parametros : Campo a ser verificado
Retorno    : Conteudo de campo
Objetivos  : Tratamento de exibição de browse dos campos EE7_AMOSTR e EEC_AMOSTR.
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 03/11/2015 - 13:48
*/
*---------------------------*
Function AP102IniBrw(cCampo)
*---------------------------*
Local cRet := ""
Local cTabela := SubStr(cCampo,1,3)

Do Case
   Case &(cTabela+"->"+cCampo) == "1"
      cRet := "1=Sim – Sem Faturamento"
   Case &(cTabela+"->"+cCampo) == "2"
      cRet := If(AP102CboxAmo(cTabela+"->"+cCampo) == "4","2=Sim – Com Faturamento","2=Não")
   Case &(cTabela+"->"+cCampo) == "3"
      cRet := "3=Não"
   Case &(cTabela+"->"+cCampo) == "4"
      cRet := "4=Sim – Com Faturamento"
End Case


Return cRet

/*
Funcao     : AP102CondGat()
Parametros : Nenhum
Retorno    : Condição de gatilho
Objetivos  : Condição do gatilho de sequencia 008 do campo EE7_IMPORT
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 03/11/2015 - 13:48
*/
*---------------------------*
Function AP102CondGat()
*---------------------------*
Return !Empty(SA1->A1_PAIS) .AND. !Empty(SYA->YA_IDIOMA)
/*
Funcao     : IniBrwAmostra()
Parametros : cAlias - nome da tabela a ser tratado o campo.
Retorno    : Texto do campo virtual de amostra do PE e Embarque
Objetivos  : Exibir a informação de acordo com o texto das opções definidas no X3
Autor      : Miguel Prado Gontijo
Data/Hora  : 16/09/2019
*/
Function IniBrwAmostra(cAlias)
Local cRet := ""

if cAlias == "EEC"
   cRet := iif(EEC->EEC_AMOSTR=="1","Sim – Sem Faturamento",iif(EEC->EEC_AMOSTR=="2","Nao","Sim – Com Faturamento"))
elseif cAlias == "EE7"
   cRet := iif(EE7->EE7_AMOSTR=="1","Sim – Sem Faturamento",iif(EE7->EE7_AMOSTR=="2","Nao","Sim – Com Faturamento"))
endif

Return cRet

*-----------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAP102.PRW                                                *
*-----------------------------------------------------------------------------*
