#INCLUDE "EDCBA400.ch"   
#INCLUDE "Protheus.ch"
#INCLUDE "AVERAGE.CH" 
#Include "APWizard.CH"  
#INCLUDE "TOPCONN.CH"

#DEFINE DE "1" //Devolução       
#DEFINE DT "2" //Destruição 
#DEFINE SI "3" //Sinistro
#DEFINE NA "4" //Nacionalização


/*
Programa   : EDCBA400 
Objetivo   : Manutenção da rotina de Devolução, sinistro, destruição e nacionalização de insumos  
Retorno    : lRet
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 14:40 
Obs.       : 
*/ 

/******************/
Function EDCBA400(aCabx,nOpcx)
/******************/
Local aOrd:=SaveOrd("EDH") 
Local lRet       := .T.
Local cAlias     := "EDH" 
Local cExpFilter := "" 
Local lTemFiltro := .F. 
Local lTop       := .F. 
Local lExpTop    := .T.

Private cCadastro

Private aRotina := MenuDef(ProcName(1))
//AOM - 05/11/2011 - ExecAuto 
Private aCabAuto := aCabx
Private nOpcAuto := nOpcx
Private lExecAuto:= Type("aCabAuto") == "A" .And. Type("nOpcAuto") == "N"

Default nOpcx := 3

Begin Sequence

If lExecAuto
   If (nPos := aScan(aCabAuto,{|X| AllTrim(X[1]) == "EDH_TPOCOR"})) > 0
      cTipoOpe := aCabAuto[nPos][2]
   Else
      lRet := .F.
      Break
   EndIf
EndIf

If cTipoOpe == DE
   cCadastro := STR0001 //"Manutenção de Ocorrência - Devolução"
ElseIf cTipoOpe == SI
   cCadastro := STR0002 //"Manutenção de Ocorrência - Sinistro" 
ElseIf cTipoOpe == NA
   cCadastro := STR0003 //"Manutenção de Ocorrência - Nacionalização" 
ElseIf cTipoOpe == DT
   cCadastro := STR0004 //"Manutenção de Ocorrência - Destruição"
EndIf

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF
   
   //Verifica se a tabela já possui filtro
   lTemFiltro := !Empty( (cAlias)->( DBFilter() ) )

   If !lTop  .Or.  lTemFiltro  // Caso a tabela ja esteja filtrada efetua o DBFilter() normalmente
         lExpTop := .F.
   EndIf

   If ValType(cTipoOpe) == "C"
      If lExpTop
         cExpFilter := cAlias+"_TPOCOR = '"+AvKey(cTipoOpe,cAlias+"_TPOCOR")+"' "
      Else
         cExpFilter := cAlias+"->"+cAlias + "_TPOCOR == '" + cTipoOpe + "' "
      EndIf
   EndIf
   
   //Adiciona um novo filtro junto com que já existia
   If lTemFiltro
      cExpFilter := "("+(cAlias)->(DbFilter())+") .And. ("+cExpFilter+")"  
      (cAlias)->(DbClearFilter())
   EndIf
   
   //Filtro
   If !Empty(cExpFilter)
      (cAlias)->(dbSetFilter(&("{|| " + cExpFilter + " }"), cExpFilter))
   EndIf  

//AOM - 05/11/2011 - ExecAuto    
If lExecAuto
  mBrowseAuto(nOpcAuto,aCabAuto,cAlias) 
Else
  MBrowse(,,,,cAlias)
EndIf

(cAlias)->( DBClearFilter() )

End Sequence

RestOrd(aOrd)

Return lRet 

/*
Funcao      : BA400MAN(cAlias,nReg,nOpc )
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : lRet
Objetivos   : Executar enchoice - Rotina Devolução, sinistro, destruição e nacionalização de insumos
Autor       : Allan Oliveira Monteiro
Data/Hora   : 10/09/10 - 10:38
Obs.        :
*/

/************************************/
Function BA400MAN(cAlias,nReg,nOpcao)
/************************************/

Local lRet := .T. 
Local nInc 
Local oEncCapa, oDlg
Local bOk := {|| BA400VldGrv()  .And. oDlg:End()}
Local bCancel:= {|| If(MsgYesNo(STR0021,STR0010),lRet := .F. , ), If(!lRet,oDlg:End(),) } //"Deseja Cancelar a Operação?","Aviso" 
Local aCampos := {} , aCmpApre := {}
Local cNotCampos := {}

Private nOpc := nOpcao 
Private aTela[0][0],aGets[0] 

Begin Sequence

   If nOpc == INCLUIR
   
      For nInc := 1 TO (cAlias)->(FCount())
         M->&((cAlias)->(FIELDNAME(nInc))) := CRIAVAR((cAlias)->(FIELDNAME(nInc)))
      Next nInc 
      
      M->EDH_TPOCOR:= cTipoOpe
      M->EDH_UMNCM := ""
      M->EDH_DESC_I:= ""
      M->EDH_DESNCM:= ""
      M->EDH_DESCUM:= ""

      //AOM - 05/11/2011 - ExecAuto 
      If lExecAuto
         If BA400PN1() .And. BA400Inclui("EDH",1,3)
            BA400Grava(nOpc)
         EndIf
      Else

         //Gravando Dados
         If BA400WZPainel(cAlias,nReg,nOpc) 
            BA400Grava(nOpc)
         EndIf
      EndIf   
      
   Else
     
     //EDH->(DbSetOrder(1)) - NOPADO POR - AOM - 05/11/2011  
     //If EDH->(DbSeek(xFilial("EDH")+EDH->EDH_TPOCOR+EDH->EDH_CODOCO)) 
        RegToMemory("EDH",.T.) // Para criar os virtuais 
        For nInc := 1 TO (cAlias)->(FCount())
           M->&((cAlias)->(FieldName(nInc))) := (cAlias)->(FieldGet(nInc))
        Next
        M->EDH_UMNCM := Posicione("SYD",1,xFilial("SYD")+M->EDH_NCM,"YD_UNID")
        M->EDH_DESC_I:= Posicione("SB1",1,xFilial("SB1")+M->EDH_COD_I,"B1_DESC")
        M->EDH_DESNCM:= Posicione("SYD",1,xFilial("SYD")+M->EDH_NCM,"YD_DESC_P")
        M->EDH_DESCUM:= Posicione("SAH",1,xFilial("SAH")+M->EDH_UMNCM,"AH_DESCPO")
     //EndIf 
     
     //AOM - 05/11/2011 - ExecAuto 
     If !lExecAuto
        If !Empty(M->EDH_DI_NUM)
           cNotCampos := "EDH_NF/EDH_SERIE/EDH_DTNF/EDH_SEQMI"  
        Else
           cNotCampos := "EDH_RE/EDH_DT_DI/EDH_DI_NUM/EDH_HAWB/EDH_INVOIC/EDH_PGI_NU/EDH_SEQPLI/EDH_LI/EDH_SEQSIS"
        EndIf
      
        If cTipoOpe <> NA
           cNotCampos += "/EDH_II/EDH_IPI/EDH_PIS/EDH_COFINS/EDH_AFRMM/EDH_ICMS
        EndIf
      
        If cTipoOpe <> DE
           cNotCampos += "/EDH_RE"
        EndIf
     
        //Adicionando os campos a serem apresentados na Enchoice, apenas campos da aba "Ocorrencia" 
        SX3->(DbSetOrder(1))
        SX3->(DbSeek("EDH"))
        While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EDH"
           If !(AllTrim(SX3->X3_CAMPO) $ cNotCampos) .And. X3Uso(SX3->X3_USADO)
              If SX3->X3_FOLDER == "3" .And. nOpc <> 5
                 Aadd(aCampos,SX3->X3_CAMPO)
              EndIf
              Aadd(aCmpApre,SX3->X3_CAMPO)
           EndIf 
        SX3->(DbSkip())
        EndDo

        DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

           oEncCapa := MsMGet():New(cAlias, nReg, nOpc,,,,aCmpApre,PosDlg(oDlg),aCampos)

        ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
        
     Else
        
        If !EnchAuto(cAlias,aCabAuto,{|| BA400VldGrv() },nOpcAuto,)
           lRet:= .F.  
        Endif
        
     EndIf
     
     If nOpc == 2 .Or. !lRet 
        Break
     EndIf
     
     //Gravando Dados 
     If !BA400Grava(nOpc)
        BA400MAN(cAlias,nReg,nOpcao)
     EndIf
        
   EndIf 
   
End Sequence

Return lRet 

/*
Funcao      : BA400Grava
Parametros  : nOpc:=opcao escolhida
Retorno     : lRet
Objetivos   : Gravação da rotina Devolução, sinistro, destruição e nacionalização de insumos
Autor       : Allan Oliveira Monteiro
Data/Hora   : 14/09/10 - 13:50
Obs.        :
*/
/*************************/
Function BA400Grava(nOpc)
/*************************/
Local lRet  := .T.
Local lSeek
Local aEst , aBxa 
Local nPos
Local cDataEDD
Local lCompNacion := AvFlags("SEQMI")
Local cSequencia := "" , cPGINum := "" 
Local cMsg := ""
Local aOrd := SaveOrd({"SW6","EDH"})
Local cHawb:= "", cAc := "", cSeqsis:= "" //RRC - 25/06/12 - Utilizadas na exclusão da ocorrência 
Local cFiltro := "" //RRC - 26/06/12 - Guarda, se houver,  o filtro da tabela EDH
Local nSaldoInsumo:= 0

Begin Transaction

   ED0->(DbSetOrder(2))    
   ED0->(DbSeek(xFilial("ED0")+ AvKey(M->EDH_AC,"ED0_AC")))
   
   //Inclusão ou Alteração
   If nOpc == 3 .OR. nOpc == 4 
   
 
      Begin Sequence
      
         If nOpc == 4 
            EDH->(DbSetOrder(1))
            If EDH->(DbSeek(xFilial("EDH") + AvKey(M->EDH_TPOCOR,"EDH_TPOCOR") + AvKey(M->EDH_CODOCO,"EDH_CODOCO")))
            
               If M->EDH_QTDOCO == EDH->EDH_QTDOCO
                  break
               EndIf
         
               If (lCompNacion := lCompNacion .And. Empty(EDH->EDH_SEQSIS) .And. !Empty(EDH->EDH_SEQMI))
                  cSequencia := EDH->EDH_SEQMI
               Else
                  cSequencia := EDH->EDH_SEQSIS
               EndIf
         
               If EDH->(FieldPos("EDH_DTNF")) > 0 .And. !Empty(EDH->EDH_DTNF)  .And. Empty(EDH->EDH_DT_DI)
                  cDataEDD := EDH->EDH_DTNF 
               Else                   
                  cDataEDD := EDH->EDH_DT_DI
               EndIf
         
               cPGINum := EDH->EDH_PGI_NU
               If Empty(cPGINum)
                  cPGINum := EDH->EDH_LI
               EndIf
         
               aBxa := AC400BxSld(EDH->EDH_QTDOCO, EDH->EDH_UMPROC, EDH->EDH_PESO , EDH->EDH_VALOCO, EDH->EDH_MOEDA, EDH->EDH_AC, cSequencia, .T.,,,,,,lCompNacion,If(EDH->(FieldPos("EDH_ESTSLD")) > 0,EDH->EDH_ESTSLD,))//RRC - 25/06/12 - Último parâmetro: Verifica se deve abater saldo do item da ocorrência
               If ValType(aBxa) <> "U" 
                  DIGrvAnt(5,EDH->EDH_HAWB,EDH->EDH_PO_NUM,EDH->EDH_INVOIC,EDH->EDH_COD_I,EDH->EDH_POSICA,cPGINum,EDH->EDH_QTDOCO,cDataEDD,EDH->EDH_AC,cSequencia,ED0->ED0_PD,EDH->EDH_CODOCO)//AOM 25/06/2012
               Else
                  If lExecAuto//AOM - 05/11/2011 - ExecAuto 
                     EasyHelp(STR0019)//"O estorno da Ocorrência não foi concluida com Sucesso. Verifique os dados da Ocorrência."
                  Else
                     MsgInfo(STR0019,STR0010)//"O estorno da Ocorrência não foi concluida com Sucesso. Verifique os dados da Ocorrência."
                  EndIf
                  lRet := .F.
                  Break                      	
               EndIf
            EndIf
         EndIf
      
         
         If (lCompNacion := lCompNacion .And. Empty(M->EDH_SEQSIS) .And. !Empty(M->EDH_SEQMI))
            cSequencia := M->EDH_SEQMI
         Else
            cSequencia := M->EDH_SEQSIS
         EndIf
         
     
         cPGINum := M->EDH_PGI_NU
         If Empty(cPGINum)
           cPGINum := M->EDH_LI
         EndIf
         
         IF AvFlags("SEQMI") .AND. Empty(M->EDH_HAWB)
            EDD->(DbSetOrder(4))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+ EDD_SEQMI+EDD_PREEMB
         ELSE
            EDD->(DbSetOrder(2))  //EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU+EDD_AC+EDD_SEQSII+EDD_PREEMB
         ENDIF
         
         If EDD->( DBSeek(xFilial("EDD")+AvKey(M->EDH_HAWB,"EDD_HAWB")+AvKey(M->EDH_INVOIC ,"EDD_INVOIC")+AvKey(M->EDH_PO_NUM  ,"EDD_PO_NUM")+AvKey(M->EDH_POSICA ,"EDD_POSICA")+AvKey(cPGINum ,"EDD_PGI_NU")+AvKey(M->EDH_AC     ,"EDD_AC")+cSequencia + AvKey("","EDD_PREEMB")))
            nSaldoInsumo:= EDD->EDD_QTD
            cMsg += STR0023+ AllTrim(Str(M->EDH_QTDOCO)) +STR0024+ AllTrim(Str(EDD->EDD_QTD)) + ")" + ENTER //"A Quantidade da Ocorrência("//") é maior que a quantidade de saldo a exportar("
         Else
            nSaldoInsumo:= 0
            cMsg += STR0023+ AllTrim(Str(M->EDH_QTDOCO)) +STR0024+ AllTrim(Str(0)) + ")" + ENTER //"A Quantidade da Ocorrência("//") é maior que a quantidade de saldo a exportar("
         EndIf

         //cMsg += STR0023+ AllTrim(Str(M->EDH_QTDOCO)) +STR0024+ AllTrim(Str(EDD->EDD_QTD)) + ")" + ENTER //"A Quantidade da Ocorrência("//") é maior que a quantidade de saldo a exportar("
         
         //AOM - 21/11/2011
         If !EasyGParam("MV_EDC0009",,.F.) 
            cMsg += STR0048 //"disponivel para comprovação, o valor de importação a comprovar não pode ficar negativo portanto nao será feita a baixa."  
         Else           
            cMsg += STR0025//"disponivel para comprovação, devido ao conteudo .T. do Parametro MV_EDC0009 que permite efetuar a baixa dos valores ja comprovados o valor de importação a comprovar ficará negativo. " 
         EndIf


         If nSaldoInsumo < M->EDH_QTDOCO 
            EasyHelp(cMsg,"QTDOCO")
            If !EasyGParam("MV_EDC0009",,.F.)
               lRet := .F.
               RollBackDelTran("")
               Break
            EndIf
         EndIf

         If lRet 
      
            If (lCompNacion := lCompNacion .And. Empty(M->EDH_SEQSIS) .And. !Empty(M->EDH_SEQMI))
               cSequencia := M->EDH_SEQMI
            Else
               cSequencia := M->EDH_SEQSIS
            EndIf
      
            aEst:= AC400EstSld(M->EDH_QTDOCO, M->EDH_UMPROC, M->EDH_PESO , M->EDH_VALOCO, M->EDH_MOEDA, M->EDH_AC, cSequencia, .T.,,,,,,lCompNacion,If(EDH->(FieldPos("EDH_ESTSLD")) > 0,M->EDH_ESTSLD,))//RRC - 25/06/12 - Último parâmetro: Verifica se deve estornar saldo do item da ocorrência
   
            If ValType(aEst) <> "U"
               If (nPos := aScan(aEst,{|x| x[1]== "QTDEST"})) > 0
                  M->EDH_QTDEST := aEst[nPos][2]
               EndIf
            
               If (nPos := aScan(aEst,{|x| x[1]== "QTDNCM"})) > 0 
                  M->EDH_QTDNCM := aEst[nPos][2]
               EndIf
               
               //AOM - 30/11/11 - Gravacao da Unid. de mediada do Item
               If (nPos := aScan(aEst,{|x| x[1]== "UMITEM"})) > 0 
                  M->EDH_UMITEM := aEst[nPos][2]
               EndIf
         
               /*DESCONSIDERAR - NOPADO POR AOM - O valor do processo FOB em US$ já esta sendo adicionado
                                  pois o valor está vindo do campo W8_VL_AC*/
                                                 
               //CORRETO - AOM - 30/11/11                    
               If (Empty(M->EDH_HAWB) .Or. Empty(M->EDH_DI_NUM) .Or. Empty(M->EDH_VLPROC)) .And. (nPos := aScan(aEst,{|x| x[1]== "VALDOL"})) > 0 
                 M->EDH_VLPROC := aEst[nPos][2]
               EndIf
               
               //AOM - 07/03/2012
               If Empty(M->EDH_VALDOL)
                  M->EDH_VALDOL := (M->EDH_QTDOCO * M->EDH_VLPROC) / M->EDH_QTDIMP 
               EndIf
         
               cPGINum := M->EDH_PGI_NU
               If Empty(cPGINum)
                 cPGINum := M->EDH_LI
               EndIf
            
               DIGrvAnt(4,M->EDH_HAWB,M->EDH_PO_NUM,M->EDH_INVOIC,M->EDH_COD_I,M->EDH_POSICA,cPGINum,M->EDH_QTDOCO,/*Data*/,M->EDH_AC,cSequencia,,M->EDH_CODOCO)//AOM - 25/06/2012
            
               //RRC - 22/06/2012 - Mantem o nº da DI no campo "W6_DI_HIS" e altera caractere no campo "W6_DI_NUM"
               //Essa alteração permite que um novo processo seja feito utilizando-se a mesma DI, ou seja, a que ficou gravada em "W6_DI_HIS"
               DbSelectArea("SW6")
               SW6->(DbSetOrder(1))        
               If SW6->(DbSeek(xFilial("SW6")+AvKey(M->EDH_HAWB,"EDH_HAWB"))) .And. SW6->(FieldPos("W6_DI_HIS"))>0 .And. Empty(SW6->W6_DI_HIS) .And. EasyGParam("MV_DI_HIS",,.F.)
                  SW6->(RecLock("SW6"),.F.)    
                  SW6->W6_DI_HIS := M->EDH_DI_NUM
                  SW6->W6_DI_NUM := Stuff(M->EDH_DI_NUM,Len(M->EDH_DI_NUM),1,"*")
                  SW6->(MsUnLock())
               EndIf
            Else
               If lExecAuto//AOM - 05/11/2011 - ExecAuto 
                  EasyHelp(STR0018)//"A Baixa da Ocorrência não foi concluida com Sucesso. Verifique os dados da Ocorrência."
               Else
                  MsgInfo(STR0018,STR0010)//"A Baixa da Ocorrência não foi concluida com Sucesso. Verifique os dados da Ocorrência.","Aviso"
               EndIf
               lRet := .F.
               Break
            EndIf
      
         EndIf

     End Sequence
  
     If lRet    
        EDH->(DbSetOrder(1))
        lSeek:= EDH->(DbSeek(xFilial("EDH")+ AvKey(M->EDH_TPOCOR,"EDH_TPOCOR")+ AvKey(M->EDH_CODOCO,"EDH_CODOCO"))) 
        If EDH->(RecLock("EDH",!lSeek))
           AVReplace("M","EDH")
           EDH->(MSUNLOCK())
        EndIf
    
     EndIf  
    
   //Exclusão   
   ElseIf nOpc == 5 
  
      EDH->(DbSetOrder(1))
      If EDH->(DbSeek(xFilial("EDH") + AvKey(M->EDH_TPOCOR,"EDH_TPOCOR") + AvKey(M->EDH_CODOCO,"EDH_CODOCO")))
         If (lCompNacion := lCompNacion .And. Empty(EDH->EDH_SEQSIS) .And. !Empty(EDH->EDH_SEQMI))
            cSequencia := EDH->EDH_SEQMI
         Else
            cSequencia := EDH->EDH_SEQSIS
         EndIf
      
         aBxa := AC400BxSld(EDH->EDH_QTDOCO, EDH->EDH_UMPROC, EDH->EDH_PESO , EDH->EDH_VALOCO, EDH->EDH_MOEDA, EDH->EDH_AC, cSequencia, .T.,,,,,,lCompNacion,If(EDH->(FieldPos("EDH_ESTSLD")) > 0,EDH->EDH_ESTSLD,))//RRC - 25/06/12 - Último parâmetro: Verifica se deve abater saldo do item da ocorrência
      
         cPGINum := EDH->EDH_PGI_NU
         If Empty(cPGINum)
            cPGINum := EDH->EDH_LI
         EndIf
      
         If EDH->(FieldPos("EDH_DTNF")) > 0 .And. !Empty(EDH->EDH_DTNF)  .And. Empty(EDH->EDH_DT_DI)
            cDataEDD := EDH->EDH_DTNF 
         Else                    
            cDataEDD := EDH->EDH_DT_DI
         EndIf
      
         If ValType(aBxa) <> "U" 
            DIGrvAnt(5,EDH->EDH_HAWB,EDH->EDH_PO_NUM,EDH->EDH_INVOIC,EDH->EDH_COD_I,EDH->EDH_POSICA,cPGINum,EDH->EDH_QTDOCO,cDataEDD,EDH->EDH_AC,cSequencia,ED0->ED0_PD,EDH->EDH_CODOCO)//AOM 25/06/2012
         Else
            lRet := .F.
            If lExecAuto//AOM - 05/11/2011 - ExecAuto 
               EasyHelp(STR0019)//"O estorno da Ocorrência não foi concluida com Sucesso. Verifique os dados da Ocorrência."
            Else
               MsgInfo(STR0019,STR0010)//"O estorno da Ocorrência não foi concluida com Sucesso. Verifique os dados da Ocorrência."
            EndIf
         EndIf
      EndIf
   
      If lRet
         cHawb   := EDH->EDH_HAWB
         cAc     := EDH->EDH_AC      
         cSeqsis := EDH->EDH_SEQSIS
         If EDH->(RecLock("EDH",.F.))
            EDH->(DbDelete())
            EDH->(MSUNLOCK())
         EndIf  
         
         //RRC - 26/06/2012 - Verifica se existe filtro na EDH
         /*Para esta operação, a EDH não pode estar filtrada pelo tipo da ocorrência, pois serão considerados todos os tipos.     
           O objetivo é verificar se após a exclusão, ainda existe qualquer ocorrência relacionada ao Ato e Sequência.
         */
         If !Empty(cFiltro:= EDH->(DBFilter()))
            EDH->(DBCLEARFILTER())   
         EndIf
         
         //RRC - 22/06/2012 - Volta o conteúdo natural do campo "W6_DI_NUM" caso não haja mais registro deste pedido na EDH (busca por Ato e Sequência)
         SW6->(DbSetOrder(1)) 
         EDH->(DbSetOrder(2))
         If !EDH->(DbSeek(xFilial("EDH") + cAc + cSeqsis)) .And. SW6->(DbSeek(xFilial("SW6")+cHawb)) .And. SW6->(FieldPos("W6_DI_HIS"))>0 .And. !Empty(SW6->W6_DI_HIS)
            If SW6->(RecLock("SW6",.F.))    
               SW6->W6_DI_NUM := SW6->W6_DI_HIS
               SW6->W6_DI_HIS := ""
               SW6->(MsUnLock())
            EndIf
         EndIf        
         
         //RRC - 26/06/12 - Retorna o conteúdo do fitro anteriormente apagado.
         If Empty(EDH->(DBFilter()))
            EDH->(DBSetFilter({|| &cFiltro}, cFiltro ))
         EndIF
         
      EndIf
   EndIf
   
End Transaction
RestOrd(aOrd,.T.)
Return lRet





/*
Funcao      : EDCBA401()
Parametros  : Nenhum.
Retorno     : 
Objetivos   : Chama a manutenção de Devolução.
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:23 
*/

/*******************/
Function EDCBA401()
/*******************/
Private cTipoOpe := DE
Return EDCBA400()

/*
Funcao      : EDCBA402()
Parametros  : Nenhum.
Retorno     : 
Objetivos   : Chama a manutenção de Sinistro.
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:23 
*/

/*******************/
Function EDCBA402()
/*******************/
Private cTipoOpe := SI
Return EDCBA400() 		


/*
Funcao      : EDCBA403()
Parametros  : Nenhum.
Retorno     : 
Objetivos   : Chama a manutenção de Nacionalização.
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:23 
*/

/*******************/
Function EDCBA403()
/*******************/
Private cTipoOpe := NA
Return EDCBA400() 


/*
Funcao      : EDCBA404()
Parametros  : Nenhum.
Retorno     : 
Objetivos   : Chama a manutenção de Nacionalização.
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:23 
*/

/*******************/
Function EDCBA404()
/*******************/
Private cTipoOpe := DT
Return EDCBA400()


/*
Funcao     : MenuDef()
Parametros : cOrigem, lMBrowse
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:10
*/
/********************************/
Static Function MenuDef(cOrigem)
/********************************/         
Local aRotina  := { { STR0005, "AxPesqui" , 0 , 1},;  //"Pesquisar "
                    { STR0006, "BA400MAN" , 0 , 2},;  //"Visualizar"
                    { STR0007, "BA400MAN" , 0 , 3},;  //"Incluir   "
                    { STR0008, "BA400MAN" , 0 , 4},;  //"Alterar   " 
                    { STR0009, "BA400MAN" , 0 , 5}} // { STR0009, "BA400MAN" , 0 , 4,3}} //"Cancelar  "  
Default cOrigem  := AvMnuFnc()
                    
                    	
Return aRotina 

/*
Funcao     : BA400Valid()
Parametros : cCampo - Campo do SX3
Retorno    : lRet
Objetivos  : Efetuar as validações necessarias dos campos antes da gravação
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:10
*/
/********************/
Function BA400Valid()
/********************/
Local lRet   := .T. 
Local cCampo := AllTrim(Substr(ReadVar(),4))  
Local DtVenc , cDtCompr

Do Case 
    
   Case cCampo == "EDH_LI"
      Transf(M->EDH_LI , AVSX3("WP_REGIST" , 06))
  
   Case cCampo == "EDH_DI_NUM"
      Transf(M->EDH_DI_NUM , AVSX3("W6_DI_NUM" , 06))
     
   Case cCampo == "EDH_CODOCO"
      EDH->(DbSetOrder(1))
      If EDH->(DbSeek(xFilial("EDH")+AvKey(M->EDH_TPOCOR,"EDH_TPOCOR")+AvKey(M->EDH_CODOCO,"EDH_CODOCO")))
         If Type("lExecAuto") == "L" .And. lExecAuto
            EasyHelp(STR0011)
         Else
            MsgInfo(STR0011,STR0010)//"Codigo da Ocorrência já existe, informe outro código.","Aviso"
         EndIf
         lRet := .F.
      EndIf
      
   Case cCampo == "EDH_DTOCOR"
      
      If Empty(WKDI->EDH_DI_NUM) .And. EDH->(FieldPos("EDH_DTNF")) > 0 
         cDtCompr := M->EDH_DTNF
      Else
         cDtCompr := M->EDH_DT_DI
      EndIf                                          
   
      If !Empty(cDtCompr) .And. !Empty(M->EDH_AC)
         DbSelectArea("ED0")
         ED0->(DbSetOrder(2))    
         ED0->(DbSeek(xFilial("ED0")+ AvKey(M->EDH_AC,"ED0_AC")))
         If cDtCompr < M->EDH_DTOCOR 
            DtVenc := AC400ApDtValid(.F.,"ED0","BAIXA")
            If DtVenc < M->EDH_DTOCOR 
               If Type("lExecAuto") == "L" .And. lExecAuto
                  EasyHelp(STR0014)
               Else
                  MsgInfo(STR0014 + SUBSTR(DTOS(DtVenc),7,2)+"/"+SUBSTR(DTOS(DtVenc),5,2)+"/"+SUBSTR(DTOS(DtVenc),1,4) ,STR0010)//"A Data da Ocorrência deve ser menor que a Data de vencimento prorrogada a quantidade de dias para baixa de insumos ","Aviso" 
               EndIf
               lRet := .F.
            EndIf
         ElseIf !Empty(M->EDH_DTOCOR)
            If Type("lExecAuto") == "L" .And. lExecAuto
               EasyHelp(STR0026)//"A Data da Ocorrência deve ser maior que a Data da (DI - Importação ou NF - Compra Nacional)."
            Else
               MsgInfo(STR0026,STR0010)//"A Data da Ocorrência deve ser maior que a Data da (DI - Importação ou NF - Compra Nacional).","Aviso" 
            EndIf
            lRet := .F.
         EndIf

      //Else
         //MsgInfo("Os campos Data da (DI - Importação ou NF - Compra Nacional) e Ato Concessório devem estar informados para liberar o preenchimento da Data da Ocorrência."/*STR0012*/,STR0010)//"Os campos Data da (DI - Importação ou NF - Compra Nacional) e Ato Concessório devem estar informados para liberar o preenchimento da Data da Ocorrência.","Aviso"
      EndIf  
      
   Case cCampo == "EDH_QTDOCO"
      If !Empty(M->EDH_QTDIMP)
         If M->EDH_QTDOCO > M->EDH_QTDIMP
            If Type("lExecAuto") == "L" .And. lExecAuto
               EasyHelp(STR0016)
            Else
               MsgInfo(STR0016,STR0010)//"Quantidade da Ocorrência não pode ser maior que a Quantidade de compra.","Aviso"
            EndIf
            M->EDH_QTDOCO:= 0
            lRet := .F.
         Else
            M->EDH_VALOCO := (M->EDH_VALIMP/M->EDH_QTDIMP) * M->EDH_QTDOCO
            M->EDH_VALDOL := (M->EDH_QTDOCO * M->EDH_VLPROC) / M->EDH_QTDIMP        
         EndIf
      Else
         If Type("lExecAuto") == "L" .And. lExecAuto
            EasyHelp(STR0015)
         Else
            MsgInfo(STR0015,STR0010)//" "O campo quantidade de Compra deve ser informada para preencher a Quantidade da Ocorrência.","Aviso"
         EndIf
         M->EDH_QTDOCO:= 0
         lRet := .F.
      EndIf
      
End Case

Return lRet

/*
Funcao     : BA400VldGrv()
Parametros : cCampo - Campo do SX3
Retorno    : lRet
Objetivos  : Efetuar as validações necessarias dos campos antes da gravação
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 09/09/10 - 16:10
*/
/********************/
Function BA400VldGrv()
/********************/
Local lRet := .T.

Begin Sequence

   If nOpc == 5 
      If Type("lExecAuto") == "L" .And. lExecAuto
         lRet := .T.
      Else
         lRet := MsgYesNo(STR0027,STR0010)//"Deseja realmente excluir a ocorrência?"
      EndIf
      //RRC - 22/06/2012 - Verifica se após a ocorrência, foi efetuada uma nova importação utilizando o campo "W6_DI_HIS"    
      If lRet == .T. 
         DbSelectArea("SW6")
         SW6->(DbSetOrder(1)) 
         If SW6->(DbSeek(xFilial("SW6")+AvKey(EDH->EDH_HAWB,"EDH_HAWB")))
            If SW6->(FieldPos("W6_DI_HIS"))>0 .And. !Empty(SW6->W6_DI_HIS)
               SW6->(DbSetOrder(11))
               If SW6->(DbSeek(xFilial("SW6")+AvKey(SW6->W6_DI_HIS,"W6_DI_HIS")))
                  lRet := .F.
                  If Type("lExecAuto") == "L" .And. lExecAuto
                     EasyHelp(STR0049 + SW6->W6_DI_NUM)//"O estorno não foi concluído com sucesso pois existe uma nova importação realizada com esta DI:"
                  Else
                     MsgInfo(STR0049 + SW6->W6_DI_NUM,STR0010)//"O estorno não foi concluído com sucesso pois existe uma nova importação realizada com esta DI:"
                  EndIf
               EndIf
            EndIf
         EndIf  
      EndIf
   EndIf   
   
   If nOpc == 4 .Or. nOpc == 3
      lRet := Obrigatorio(aGets,aTela)
   EndIf

End Sequence

Return lRet

/*
Funcao     : BA400WZPainel()
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 15/09/10 - 16:10
*/
/***********************/
Function BA400WZPainel(cAlias,nReg,nOpc)
/***********************/
Local lRet := .F.
Local lInverte := .F.
Local npan := 0

Private oEnchoice
Private cLastPanel  := ""
Private oFont := TFont():New("Arial", 07, 15)
Private oCombo,oGet,oSelect1,oSelect2,oFolder,oFldImp, oFldComp, oPanel, oWizard 
Private aPos := {}, aTab := {STR0028,STR0029,STR0030}//"Código Item","Ato Concessório","Processo de Importação"
Private cCombo := aTab[1], cChave:= Space(20), cBotao := STR0031//"Pesquisar" 

DEFINE WIZARD oWizard TITLE STR0032; //"Wizard de Inclusão do Tipo de Ocorrência"
                      HEADER STR0033;//"Início"
                      MESSAGE STR0034;//"Apresentação"
                      TEXT STR0035 + cCadastro + STR0036+ cCadastro + STR0037 ;//"Bem vindo ao assistente de inclusão de "//". Essa rotina é utilizada para auxiliá-lo na inclusão de uma "//" para baixa em Ato Concessório."
                      PANEL ;
                      NEXT {|| PanelNext(oWizard,cAlias,nReg,nOpc)};
                      FINISH {|| .T.}
                      oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                      oPanel:cName := "USER_PN0"

      CREATE PANEL oWizard HEADER STR0038 ;//"Lista de DI`s de Insumos a comprovar no Ato Concessório"
      															    	MESSAGE STR0039;//"Lista de DI`s"
																		PANEL;
																		BACK	{|| PanelBack(oWizard,cAlias,nReg,nOpc) };
																		NEXT	{|| PanelNext(oWizard,cAlias,nReg,nOpc) };
																		FINISH	{|| .T. };
																		EXEC	{|| .T. }
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "USER_PN1"
         
      //MsSelect Listagem das DI`s
      //Processa({||BA400PN1(oPanel)},STR0020,STR0020,.F.)// "Carregando Insumos..."
      
        
         
      CREATE PANEL oWizard HEADER STR0040 MESSAGE STR0041 ;//"Cadastro do Tipo da Ocorrência"//"Tipo da Ocorrência"
																		PANEL;
																	   	BACK	{|| PanelBack(oWizard,cAlias,nReg,nOpc) };
																		NEXT	{|| PanelNext(oWizard,cAlias,nReg,nOpc) };
																		FINISH	{|| .T. };
																		EXEC	{|| .T. }
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "USER_PN2"

      
      
      //BA400Inclui("EDH",1,3,oPanel)

         
         
      CREATE PANEL oWizard HEADER STR0042 + cCadastro MESSAGE cCadastro;//"Gravação "
																		PANEL;
																		BACK	{|| PanelBack(oWizard,cAlias,nReg,nOpc) };
																	   	NEXT	{|| PanelNext(oWizard,cAlias,nReg,nOpc) };
																		FINISH	{||  lRet := (MsgYesNo(STR0043,STR0042) .And. BA400VldGrv()) };//"Deseja prosseguir com a gravação da Ocorrência?","Gravação"
																		EXEC	{||  .T.}
                                                                        oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
                                                                        oPanel:cName := "USER_PN3"
      
     // BA400Inclui("EDH",1,2,oPanel)
         

ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }
     
Return lRet

/*
Funcao     : BA400PN1()
Parametros : oPanel 
Retorno    : lRet
Objetivos  : Selecionar as Invoices com que possui saldo no Ato Concessório.
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 15/09/10 - 16:10
*/
/******************/
Function BA400PN1(oPanel)
/******************/
Local lRet     := .T.
Local cMsg     := STR0044//"Selecione uma das DI's para efetuar a ocorrência e clique em 'Avançar': " 
Local aEstruWork := {} , aNomeFolders := {} , aAbrevFolders := {}
Local lInverte := .F.
Local nOpcFolder
Local nOrderAuto := 0 
Local nPosSEQMI := 0
Local nPosSEQSIS := 0
Private aSelImp := {} , aSelComp := {}
Private cMarca   := GetMark()
Private cFileWork, cFileWork1, cFileWork2,cFileWork3 
//Private aTela[0][0],aGets[0]

   aAdd(aEsTruWork,{"EDH_COD_I"  ,"C",AVSX3("W8_COD_I"  ,AV_TAMANHO),0,AVSX3("W8_COD_I"  ,6)})//Codigo do Item
   aAdd(aEsTruWork,{"EDH_DESC_I" ,"C",AVSX3("B1_DESC"   ,AV_TAMANHO),0,AVSX3("B1_DESC"   ,6)})//Descrição Resumida do Item
   aAdd(aEsTruWork,{"EDH_NCM"    ,"C",AVSX3("B1_POSIPI" ,AV_TAMANHO),0,AVSX3("B1_POSIPI" ,6)})//POS NCM 
   aAdd(aEsTruWork,{"EDH_UMNCM"  ,"C",AVSX3("B1_UM"     ,AV_TAMANHO),0,AVSX3("B1_UM"     ,6)})//Unidade de Medida do Item NCM
   aAdd(aEsTruWork,{"EDH_DESCUM" ,"C",AVSX3("AH_DESCPO" ,AV_TAMANHO),0,AVSX3("AH_DESCPO" ,6)})//Descrição da unidade de medida do Item
   aAdd(aEsTruWork,{"EDH_DESNCM" ,"C",AVSX3("YD_DESC_P" ,AV_TAMANHO),0,AVSX3("YD_DESC_P" ,6)})//Descrição da NCM
   aAdd(aEsTruWork,{"EDH_AC"     ,"C",AVSX3("W8_AC"     ,AV_TAMANHO),0,AVSX3("W8_AC"     ,6)})//Ato Concessório
   aAdd(aEsTruWork,{"EDH_SEQSIS" ,"C",AVSX3("W8_SEQSIS" ,AV_TAMANHO),0,AVSX3("W8_SEQSIS" ,6)})//Sequencia do Saldo de Importação
   //AOM - 27/10/2011
   If ED8->(FieldPos("ED8_SEQMI")) > 0
      aAdd(aEsTruWork,{"EDH_SEQMI" ,"C",AVSX3("ED8_SEQMI",AV_TAMANHO),0,AVSX3("ED8_SEQMI",6)})//Seq. Sis MI   
   EndIf 
   aAdd(aEsTruWork,{"EDH_HAWB"     ,"C",AVSX3("W8_HAWB"   ,AV_TAMANHO),0,AVSX3("W8_HAWB"   ,6)})//Numero do Processo Importação
   aAdd(aEsTruWork,{"EDH_DT_DI"  ,"D",AVSX3("W6_DTREG_D",AV_TAMANHO),0,AVSX3("W6_DTREG_D",6)})//Data DI
   aAdd(aEsTruWork,{"EDH_DI_NUM" ,"C",AVSX3("W6_DI_NUM" ,AV_TAMANHO),0,AVSX3("W6_DI_NUM" ,6)})//Numero DI
   //RRC - 21/06/2012
   If SW6->(FieldPos("W6_DI_HIS")) > 0 .And. EasyGParam("MV_DI_HIS",,.F.)
      aAdd(aEsTruWork,{"W6_DI_HIS" ,"C",AVSX3("W6_DI_HIS",AV_TAMANHO),0,AVSX3("W6_DI_HIS" ,6)})//No. Hist. DI
   EndIf
   aAdd(aEsTruWork,{"EDH_PGI_NU" ,"C",AVSX3("W8_PGI_NUM",AV_TAMANHO),0,AVSX3("W8_PGI_NUM",6)})//Numero PLI
   aAdd(aEsTruWork,{"EDH_SEQPLI" ,"C",AVSX3("W8_SEQ_LI" ,AV_TAMANHO),0,AVSX3("W8_SEQ_LI" ,6)})//Sequencia da PLI
   aAdd(aEsTruWork,{"EDH_LI"     ,"C",AVSX3("WP_REGIST" ,AV_TAMANHO),0,AVSX3("WP_REGIST" ,6)})//Numero LI 
   aAdd(aEsTruWork,{"EDH_INVOIC" ,"C",AVSX3("W8_INVOICE",AV_TAMANHO),0,AVSX3("W8_INVOICE",6)})//Invoice
   aAdd(aEsTruWork,{"EDH_PO_NUM" ,"C",AVSX3("W8_PO_NUM" ,AV_TAMANHO),0,AVSX3("W8_PO_NUM" ,6)})//Numero do Pedido 
   aAdd(aEsTruWork,{"EDH_POSICA" ,"C",AVSX3("W8_POSICAO",AV_TAMANHO),0,AVSX3("W8_POSICAO",6)})//Posição do Item no Pedido 
   aAdd(aEsTruWork,{"EDH_QTDIMP" ,"N",AVSX3("W8_QTDE"   ,AV_TAMANHO),3,AVSX3("W8_QTDE"   ,6)})//Quantidade Comprada
   aAdd(aEsTruWork,{"EDH_VALIMP" ,"N",AVSX3("W8_PRECO"  ,AV_TAMANHO),5,AVSX3("W8_PRECO"  ,6)})//Valor Compra
   aAdd(aEsTruWork,{"EDH_PESO"   ,"N",AVSX3("W7_PESO"   ,AV_TAMANHO),6,AVSX3("W7_PESO"   ,6)})//Peso Unit. do Item                         
   aAdd(aEsTruWork,{"EDH_UMPROC" ,"C",AVSX3("W8_UNID"   ,AV_TAMANHO),0,AVSX3("W8_UNID"   ,6)})//Unidade de Medida do Processo
   aAdd(aEsTruWork,{"EDH_MOEDA"  ,"C",AVSX3("W9_MOE_FOB",AV_TAMANHO),0,AVSX3("W9_MOE_FOB",6)})//Moeda do Processo
   aAdd(aEsTruWork,{"EDH_VLPROC" ,"N",AVSX3("EDH_VLPROC",AV_TAMANHO),0,AVSX3("EDH_VLPROC",6)})//Valor FOB US$ 
   If EDH->(FieldPos("EDH_NF")) > 0  .And. EDH->(FieldPos("EDH_SERIE")) > 0  .And. EDH->(FieldPos("EDH_DTNF")) > 0 
      aAdd(aEsTruWork,{"EDH_NF"    ,"C",AVSX3("EDH_NF"    ,AV_TAMANHO),0,AVSX3("EDH_NF"    ,6)})//Unidade de Medida do Processo
      aAdd(aEsTruWork,{"EDH_SERIE" ,"C",AVSX3("EDH_SERIE" ,AV_TAMANHO),0,AVSX3("EDH_SERIE" ,6)})//Moeda do Processo
      aAdd(aEsTruWork,{"EDH_DTNF" ,"D",AVSX3("EDH_DTNF"  ,AV_TAMANHO),0,AVSX3("EDH_DTNF"  ,6)})//Valor FOB US$ 
   EndIf
   
   If !(Select("WKDI") <> 0)
      cFileWork:=E_CriaTrab(,aEstruWork,"WKDI")

      //Indice 1
      IndRegua("WKDI",cFileWork+TEOrdBagExt(),"EDH_COD_I")
      
      //Indice 2
      cFileWork1:= E_Create(,.F.) 
      IndRegua("WKDI",cFileWork1+TEOrdBagExt(),"EDH_AC+EDH_SEQSIS")
      
      //Indice 3
       cFileWork2:= E_Create(,.F.)
      IndRegua("WKDI",cFileWork2+TEOrdBagExt(),"EDH_HAWB")
      
      If ED8->(FieldPos("ED8_SEQMI")) > 0
         cFileWork3:= E_Create(,.F.) 
         IndRegua("WKDI",cFileWork3+TEOrdBagExt(),"EDH_AC+EDH_SEQMI")
         Set Index To (cFileWork+TEOrdBagExt()),(cFileWork1+TEOrdBagExt()),(cFileWork2+TEOrdBagExt()),(cFileWork3+TEOrdBagExt())
      Else
         Set Index To (cFileWork+TEOrdBagExt()),(cFileWork1+TEOrdBagExt()),(cFileWork2+TEOrdBagExt())
      EndIf
      
   Else
      WKDI->(avzap())
   EndIf
   
   //Importações
   aAdd(aSelImp,{"EDH_COD_I"  ,"",AVSX3("EDH_COD_I",AV_TITULO)      })//Codigo do Item
   aAdd(aSelImp,{"EDH_DESC_I" ,"",AVSX3("EDH_DESC_I",AV_TITULO)     })//Descrição Resumida do Item
   aAdd(aSelImp,{"EDH_NCM"    ,"",AVSX3("EDH_NCM",AV_TITULO)        })//NCM do Item
   aAdd(aSelImp,{"EDH_UMNCM"  ,"",AVSX3("EDH_UMNCM",AV_TITULO)      })//Unidade de Medida do Item
   aAdd(aSelImp,{"EDH_DESCUM" ,"",AVSX3("EDH_DESCUM",AV_TITULO)     })//Descrição da unidade de medida do Item 
   aAdd(aSelImp,{"EDH_AC"     ,"",AVSX3("EDH_AC",AV_TITULO)         })//Ato Concessório
   aAdd(aSelImp,{"EDH_SEQSIS" ,"",AVSX3("EDH_SEQSIS",AV_TITULO)     })//Sequencia do Saldo de Importação
   aAdd(aSelImp,{"EDH_HAWB"   ,"",AVSX3("EDH_HAWB",AV_TITULO)       })//Numero do Processo Importação
   aAdd(aSelImp,{"EDH_DT_DI"  ,"",AVSX3("EDH_DT_DI",AV_TITULO)      })//Data DI
   aAdd(aSelImp,{"EDH_DI_NUM" ,"",AVSX3("EDH_DI_NUM",AV_TITULO)     })//Numero DI
   //RRC - 21/06/2012
   If SW6->(FieldPos("W6_DI_HIS")) > 0 .And. EasyGParam("MV_DI_HIS",,.F.)
      aAdd(aSelImp,{"W6_DI_HIS" ,"",AVSX3("W6_DI_HIS",AV_TITULO)  })//No. Hist. DI
   EndIf
   aAdd(aSelImp,{"EDH_PGI_NU" ,"",AVSX3("EDH_PGI_NU",AV_TITULO)     })//Numero PLI
   aAdd(aSelImp,{"EDH_SEQPLI" ,"",AVSX3("EDH_SEQPLI",AV_TITULO)     })//Sequencia da PLI
   aAdd(aSelImp,{"EDH_LI"     ,"",AVSX3("EDH_LI",AV_TITULO)         })//Numero LI 
   aAdd(aSelImp,{"EDH_INVOIC" ,"",AVSX3("EDH_INVOIC",AV_TITULO)     })//Invoice
   aAdd(aSelImp,{"EDH_PO_NUM" ,"",AVSX3("EDH_PO_NUM",AV_TITULO)     })//Numero do Pedido 
   aAdd(aSelImp,{"EDH_POSICA" ,"",AVSX3("EDH_POSICA",AV_TITULO)     })//Posição do Item no Pedido 
   aAdd(aSelImp,{"EDH_QTDIMP" ,"",AVSX3("EDH_QTDIMP",AV_TITULO)     })//Quantidade Comprada
   aAdd(aSelImp,{"EDH_VALIMP" ,"",AVSX3("EDH_VALIMP",AV_TITULO)     })//Valor Compra
   aAdd(aSelImp,{"EDH_PESO"   ,"",AVSX3("EDH_PESO",AV_TITULO)       })//Peso Unit. do Item
   aAdd(aSelImp,{"EDH_UMPROC" ,"",AVSX3("EDH_UMPROC",AV_TITULO)     })//Unidade de Medida do Processo 
   aAdd(aSelImp,{"EDH_MOEDA"  ,"",AVSX3("EDH_MOEDA",AV_TITULO)      })//Moeda Processo
   //aAdd(aSelImp,{"EDH_VLPROC"  ,"","Valor FOB US$"                   })//Valor FOB US$  
   
   //Compras Nacionais
   aAdd(aSelComp,{"EDH_COD_I"  ,"",AVSX3("EDH_COD_I",AV_TITULO)     })//Codigo do Item
   aAdd(aSelComp,{"EDH_DESC_I" ,"",AVSX3("EDH_DESC_I",AV_TITULO)    })//Descrição Resumida do Item
   aAdd(aSelComp,{"EDH_NCM"    ,"",AVSX3("EDH_NCM" ,AV_TITULO)      })//NCM do Item
   aAdd(aSelComp,{"EDH_UMNCM"  ,"",AVSX3("EDH_UMNCM",AV_TITULO)     })//Unidade de Medida do Item
   aAdd(aSelComp,{"EDH_DESCUM" ,"",AVSX3("EDH_DESCUM",AV_TITULO)    })//Descrição da unidade de medida do Item 
   aAdd(aSelComp,{"EDH_AC"     ,"",AVSX3("EDH_AC" ,AV_TITULO)       })//Ato Concessório
   If ED8->(FieldPos("ED8_SEQMI")) > 0
      aAdd(aSelComp,{"EDH_SEQMI"  ,"",AVSX3("EDH_SEQMI",AV_TITULO)  })//Sequencia Siscomex Mercado Interno/Compra Nacional
   Else
      aAdd(aSelComp,{"EDH_SEQSIS","",AVSX3("EDH_SEQSIS",AV_TITULO)  })//Sequencia do Saldo de Importação  
   EndIf
   aAdd(aSelComp,{"EDH_PO_NUM" ,"",AVSX3("EDH_SEQSIS",AV_TITULO)                })//Numero do Pedido 
   aAdd(aSelComp,{"EDH_POSICA" ,"",AVSX3("EDH_SEQSIS",AV_TITULO)       })//Posição do Item no Pedido
   If EDH->(FieldPos("EDH_NF")) > 0  .And. EDH->(FieldPos("EDH_SERIE")) > 0  .And. EDH->(FieldPos("EDH_DTNF")) > 0 
      aAdd(aSelComp,{"EDH_NF"    ,"",AVSX3("EDH_NF",AV_TITULO)      })//Nota Fiscal
      aAdd(aSelComp,{{|| Transform(EDH_SERIE,AvSX3("EDH_SERIE",AV_PICTURE)) },"",AVSX3("EDH_SERIE",AV_TITULO)   })//Serie
      aAdd(aSelComp,{"EDH_DTNF" ,"",AVSX3("EDH_DTNF",AV_TITULO)     })//Data Nota Fiscal
   EndIf
   aAdd(aSelComp,{"EDH_QTDIMP" ,"",AVSX3("EDH_QTDIMP",AV_TITULO)    })//Quantidade Comprada
   aAdd(aSelComp,{"EDH_VALIMP" ,"",AVSX3("EDH_VALIMP",AV_TITULO)    })//Valor Compra
   aAdd(aSelComp,{"EDH_PESO"   ,"",AVSX3("EDH_PESO",AV_TITULO)      })//Peso Unit. do Item
   aAdd(aSelComp,{"EDH_UMPROC" ,"",AVSX3("EDH_UMPROC",AV_TITULO)    })//Unidade de Medida do Processo 
   aAdd(aSelComp,{"EDH_MOEDA"  ,"",AVSX3("EDH_MOEDA",AV_TITULO)     })//Moeda Processo
   
   
   #IFDEF TOP
      //Query com os dados filtrado
      Qryinsumos()
      
      ProcRegua(QRY->(EasyRecCount()))
      QRY->(DbGoTop())
      While QRY->(!EOF())
         WKDI->(DbAppend())
         WKDI->EDH_COD_I   := QRY->W8_COD_I
         
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(xFilial("SB1")+AvKey(QRY->W8_COD_I,"B1_COD")))
            WKDI->EDH_DESC_I:= SB1->B1_DESC
            WKDI->EDH_NCM   := SB1->B1_POSIPI
            WKDI->EDH_UMNCM := SB1->B1_UM
         EndIf
         
         SYD->(DbSetOrder(1))
         If SYD->(DbSeek(xFilial("SYD")+AvKey(SB1->B1_POSIPI,"YD_TEC")))
            WKDI->EDH_DESNCM := SYD->YD_DESC_P
         EndIf
         
         WKDI->EDH_AC    := QRY->W8_AC
         WKDI->EDH_SEQSIS:= QRY->W8_SEQSIS
         WKDI->EDH_HAWB  := QRY->W8_HAWB
         WKDI->EDH_DT_DI := QRY->W6_DTREG_D
         WKDI->EDH_DI_NUM:= QRY->W6_DI_NUM       
         //RRC - 22/06/2012
         If SW6->(FieldPos("W6_DI_HIS")) > 0 .And. EasyGParam("MV_DI_HIS",,.F.)
            WKDI->W6_DI_HIS := QRY->W6_DI_HIS
         EndIf
         WKDI->EDH_PGI_NU:= QRY->W8_PGI_NUM
         WKDI->EDH_SEQPLI:= QRY->W8_SEQ_LI
         WKDI->EDH_LI    := if(Empty(QRY->WP_NR_ALI),QRY->WP_REGIST,QRY->WP_NR_ALI)
         WKDI->EDH_INVOIC:= QRY->W8_INVOICE 
         WKDI->EDH_PO_NUM:= QRY->W8_PO_NUM
         WKDI->EDH_POSICA:= QRY->W8_POSICAO
         WKDI->EDH_QTDIMP:= QRY->W8_QTDE
         WKDI->EDH_VALIMP:= QRY->W8_PRECO * QRY->W8_QTDE
         WKDI->EDH_PESO  := QRY->W7_PESO
         WKDI->EDH_UMPROC:= QRY->W8_UNID 
         WKDI->EDH_MOEDA := QRY->W9_MOE_FOB
         WKDI->EDH_VLPROC := QRY->W8_VL_AC
         
         SAH->(DbSetOrder(1))
         If SAH->(DbSeek(xFilial("SAH")+ AvKey(SB1->B1_UM,"AH_UNIMED")))
            WKDI->EDH_DESCUM := SAH->AH_DESCPO 
         EndIf 
       
      IncProc()   
      QRY->(DbSkip())  
      EndDo
      
      ProcRegua(QRY2->(EasyRecCount()))
      QRY2->(DbGoTop())
      While QRY2->(!EOF())
         WKDI->(DbAppend())
         WKDI->EDH_COD_I   := QRY2->ED8_COD_I
         
         SB1->(DbSetOrder(1))
         If SB1->(DbSeek(xFilial("SB1")+AvKey(QRY2->ED8_COD_I,"B1_COD")))
            WKDI->EDH_DESC_I:= SB1->B1_DESC
            WKDI->EDH_NCM   := SB1->B1_POSIPI
            WKDI->EDH_UMNCM := SB1->B1_UM
         EndIf
         
         SYD->(DbSetOrder(1))
         If SYD->(DbSeek(xFilial("SYD")+AvKey(SB1->B1_POSIPI,"YD_TEC")))
            WKDI->EDH_DESNCM := SYD->YD_DESC_P
         EndIf
         
         WKDI->EDH_AC    := QRY2->ED8_AC
         //AOM - 28/10/2011
         If ED8->(FieldPos("ED8_SEQMI")) > 0
            WKDI->EDH_SEQMI := QRY2->ED8_SEQMI
         EndIf
         WKDI->EDH_HAWB  := QRY2->ED8_DI_NUM + QRY2->ED8_ADICAO
         WKDI->EDH_POSICA:= QRY2->ED8_POSDI
         WKDI->EDH_SEQSIS:= QRY2->ED8_SEQSIS
         WKDI->EDH_DT_DI := QRY2->ED8_DTREG
         WKDI->EDH_DI_NUM:= QRY2->ED8_DI_NUM
         WKDI->EDH_PO_NUM:= QRY2->ED8_PEDIDO   
         WKDI->EDH_LI    := QRY2->ED8_LI_NUM
         WKDI->EDH_INVOIC:= QRY2->ED8_INVOIC 
         WKDI->EDH_QTDIMP:= QRY2->ED8_QTD
         WKDI->EDH_VALIMP:= QRY2->ED8_VALORI
         WKDI->EDH_PESO  := QRY2->ED8_PESO
         WKDI->EDH_UMPROC:= QRY2->ED8_UM 
         WKDI->EDH_MOEDA := QRY2->ED8_MOEDA 
         If EDH->(FieldPos("EDH_NF")) > 0  .And. EDH->(FieldPos("EDH_SERIE")) > 0  .And. EDH->(FieldPos("EDH_DTNF")) > 0 
            WKDI->EDH_NF   := QRY2->ED8_NF
            WKDI->EDH_SERIE:= QRY2->ED8_SERIE
            WKDI->EDH_DTNF  := QRY2->ED8_EMISSA
         EndIf
         
         SAH->(DbSetOrder(1))
         If SAH->(DbSeek(xFilial("SAH")+ AvKey(SB1->B1_UM ,"AH_UNIMED")))
            WKDI->EDH_DESCUM := SAH->AH_DESCPO 
         EndIf 
       
      IncProc()   
      QRY2->(DbSkip())  
      EndDo
      
      QRY2->(DbCloseArea())
      QRY->(DbCloseArea())
      
   #ELSE
    
      //Carregando o arquivo de trabalho
      DbSelectArea("SW8")
      ProcRegua(SW8->(EasyRecCount()))
      SW8->(DbGoTop())
      While SW8->(!EOF()) 
         If !Empty(SW8->W8_AC)
            WKDI->(DbAppend())
            WKDI->EDH_COD_I   := SW8->W8_COD_I
         
            SB1->(DbSetOrder(1))
            If SB1->(DbSeek(xFilial("SB1")+AvKey(SW8->W8_COD_I,"B1_COD")))
               WKDI->EDH_DESC_I:= SB1->B1_DESC
               WKDI->EDH_NCM   := SB1->B1_POSIPI
               WKDI->EDH_UMNCM := SB1->B1_UM
            EndIf
         
            SYD->(DbSetOrder(1))
            If SYD->(DbSeek(xFilial("SYD")+AvKey(SB1->B1_POSIPI,"YD_TEC")))
               WKDI->EDH_DESNCM := SYD->YD_DESC_P
            EndIf
         
            WKDI->EDH_AC    := SW8->W8_AC
            WKDI->EDH_SEQSIS:= SW8->W8_SEQSIS
            WKDI->EDH_HAWB  := SW8->W8_HAWB
         
            SW6->(DbSetOrder(1))
            If SW6->(DbSeek(xFilial("SW6")+ AvKey(SW8->W8_HAWB,"W6_HAWB")))
               WKDI->EDH_DT_DI := SW6->W6_DTREG_D
               WKDI->EDH_DI_NUM:= SW6->W6_DI_NUM
               //RRC - 22/06/2012
               If SW6->(FieldPos("W6_DI_HIS")) > 0 .And. EasyGParam("MV_DI_HIS",,.F.)
                  WKDI->W6_DI_HIS := QRY->W6_DI_HIS
               EndIf
               WKDI->W6MOEDA   := SW6->W6_FOBMOE
            EndIf
         
            WKDI->EDH_PGI_NU:= SW8->W8_PGI_NUM
            WKDI->EDH_SEQPLI:= SW8->W8_SEQ_LI 
         
            SWP->(DbSetOrder(1))
            If SWP->(DbSeek(xFilial("SWP")+ AvKey(SW8->W8_PGI_NUM,"WP_PGI_NUM")+ AvKey(SW8->W8_SEQ_LI,"WP_SEQ_LI")))
               WKDI->EDH_LI := If(Empty(SWP->WP_NR_ALI),SWP->WP_REGIST,SWP->WP_NR_ALI)
            EndIf
         
            WKDI->EDH_INVOIC:= SW8->W8_INVOICE 
            WKDI->EDH_PO_NUM:= SW8->W8_PO_NUM
            WKDI->EDH_POSICA:= SW8->W8_POSICAO
            WKDI->EDH_QTDIMP:= SW8->W8_QTDE
            WKDI->EDH_VALIMP:= SW8->W8_PRECO * SW8->W8_QTDE
            WKDI->EDH_UMPROC  := SW8->W8_UNID
            
            SW7->(DbSetOrder(4)) 
            If SW7->(DbSeek(xFilial("SW7") + AvKey(SW8->W8_HAWB,"W8_HAWB") + AvKey(SW8->W8_PO_NUM,"W7_PO_NUM");
               + AvKey(SW8->W8_POSICAO,"W7_POSICAO") + AvKey(SW8->W8_PGI_NUM,"W7_PGI_NUM")))
               WKDI->EDH_PESO := SW7->W7_PESO
                        
            EndIf
            
            SAH->(DbSetOrder(1))
            If SAH->(DbSeek(xFilial("SAH")+ AvKey(SW8->W8_UNID,"AH_UNIMED")))
               WKDI->EDH_DESCUM := SAH->AH_DESCPO 
            EndIf
         EndIf
         IncProc()
         SW8->(DbSkip())   
      EndDo
      
   #ENDIF   
   
   //AOM - 05/11/2011 - ExecAuto 
   If !lExecAuto
      
      WKDI->(DbGoTop()) 
   
      @ 01,05 COMBOBOX oCombo VAR cCombo ITEMS aTab VALID OrdMsSelect(cCombo) SIZE 200, 07   PIXEL OF oPanel 
   
      @ 13,05 MSGET oGet VAR cChave SIZE 200, 07  PIXEL Of oPanel
         
      @ 30,05 Say cMsg Size 200,07  Pixel Of oPanel  
   
      @ 13,210 Button cBotao Size 60,11 Pixel Action PesqChave(cCombo,cChave) Of oPanel
   

   
      AADD(aNomeFolders,STR0045) //"Importações"
      AADD(aNomeFolders,STR0046) //"Compras Nacional"
   
      AADD(aAbrevFolders,"IMP")
      AADD(aAbrevFolders,"COM")
     
      oFolder := TFolder():New(1,1,aNomeFolders,aAbrevFolders,oPanel,,,,.T.,.F.,,) 
      aEval(oFolder:aControls,{|x| x:SetFont(oPanel:oFont) })
      oFolder:Align := CONTROL_ALIGN_BOTTOM
      oFldImp := oFolder:aDialogs[1]
      oFldComp:= oFolder:aDialogs[2]  
   
      aPos := PosDlg(oFolder)
      aPos[1] := 40
     
      oFolder:bSetOption:= {|nOpcFolder| AtuaFolder(nOpcFolder)}  
   
      oSelect1 := MsSelect():New("WKDI","",, aSelImp, @lInverte, @cMarca, aPos,,,oFldImp)
      oSelect1:oBrowse:Hide()
      oSelect1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oSelect1:oBrowse:Refresh()
      oSelect1:oBrowse:Show() 

      oSelect2 := MsSelect():New("WKDI","",, aSelComp, @lInverte, @cMarca, aPos,,,oFldComp) 
      oSelect2:oBrowse:Hide()
      oSelect2:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      oSelect2:oBrowse:Refresh()
      oSelect2:oBrowse:Show() 

      Eval(oFolder:bSetOption)
   Else
   
       nOrderAuto := 2
       If (nPosSEQMI := aScan(aCabAuto,{ |X| AllTrim(X[1]) == "EDH_SEQMI" })) > 0 .And. !Empty(aCabAuto[nPosSEQMI][2])
          nOrderAuto := 4
       EndIf 
       
       If !EasySeekAuto("WKDI", aCabAuto, nOrderAuto )
          EasyHelp(STR0047)//"Ato Concessório e Sequência informada não cadastrado."
          lRet := .F.
       EndIf
   
   EndIf 
   
  
Return lRet

Static Function AtuaFolder(nOpcFolder)

Default nOpcFolder := 1

If nOpcFolder == 1
    If !Empty(WKDI->(DBFilter()))
       WKDI->(DBCLEARFILTER())   
    EndIf
    
    WKDI->(DBSetFilter({|| !Empty(WKDI->EDH_DI_NUM)}, "!Empty(WKDI->EDH_DI_NUM)")) 
    
    oSelect2:oBrowse:Hide()
    Eval(oSelect1:oBrowse:bGoTop)
    oSelect1:oBrowse:Refresh()
    oSelect1:oBrowse:Show()
   

ElseIf nOpcFolder == 2

   If !Empty(WKDI->(DBFilter()))
      WKDI->(DBCLEARFILTER())   
   EndIf
    
   WKDI->(DBSetFilter({|| Empty(WKDI->EDH_DI_NUM)}, "Empty(WKDI->EDH_DI_NUM)")) 
   
   oSelect1:oBrowse:Hide() 
   Eval(oSelect2:oBrowse:bGoTop)
   oSelect2:oBrowse:Refresh()
   oSelect2:oBrowse:Show()

EndIf

Return


/*
Funcao     : PesqChave()
Parametros : cCombo  - "Código Item","Ato Concessório","Processo de Importação"
             cChave  - objeto de pesquisa
Retorno    : lRet
Objetivos  : Posicionar no item desejado de acordo com a chave informada
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 16/09/10 - 15:10
*/
/***************************************/ 
Static Function PesqChave(cCombo,cChave)
/***************************************/ 
Local lRet  := .T. 
Local cCampo:= "" 

Begin Sequence

   If Empty(cChave)
      MsgInfo(STR0017,STR0010)// "A chave de pesquisa não está preenchida, informe primeiramente para pesquisar.","Aviso"
      lRet := .F.
      Break
   EndIf
    

   If cCombo == STR0028//"Código Item"
      WKDI->(DbSetOrder(1))
      cCampo:= "W8_COD_I" 
   ElseIf cCombo == STR0029//"Ato Concessório"
      WKDI->(DbSetOrder(2))
      cCampo:= "W8_AC" 
   ElseIf cCombo == STR0030//"Processo de Importação"
      WKDI->(DbSetOrder(3))
      cCampo:= "W8_HAWB" 
   EndIf
   
   WKDI->(DbGoTop())
   WKDI->(DbSeek(AvKey(cChave,cCampo),.T.))

End Sequence

Return lRet

/*
Funcao     : OrdMsSelect()
Parametros : oSelect - objeto
             cCombo  - "Código Item","Ato Concessório","Processo de Importação"
Retorno    : lRet
Objetivos  : Colocar na ordem os itens do objeto MsSelect de acordo com a opção selecionada
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 17/09/10 - 9:30
*/
/******************************************/
Static Function OrdMsSelect(cCombo) 
/******************************************/
Local lRet := .T. 

Begin Sequence

   If cCombo == STR0028//"Código Item"
      WKDI->(DbSetOrder(1))
      oSelect1:oBrowse:Refresh()
      oSelect2:oBrowse:Refresh()
   ElseIf cCombo == STR0029//"Ato Concessório"
      WKDI->(DbSetOrder(2))
      oSelect1:oBrowse:Refresh()
      oSelect2:oBrowse:Refresh()
   ElseIf cCombo == STR0030//"Processo de Importação"
      WKDI->(DbSetOrder(3))
      oSelect1:oBrowse:Refresh()
      oSelect2:oBrowse:Refresh() 
   EndIf
   

End Sequence

Return lRet



/*
Funcao     : BA400Inclui()
Parametros : cAlias   - Tabela utilizada
             nReg     - Posição do registro
             nOpc     - Tipo de operação (1 - Pesquisar , 2 - Visualizar, 3 - Incluir, 4 - Alterar, 5 - Excluir)
             oPanel   - objeto
             lRefresh - Indica se carregará a enchoice ou apenas os campos de memória
             
Retorno    : lRet
Objetivos  : Apresentar a Enchoice com os dados preenchidos de acordo com o tipo de operação 
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 17/09/10 - 9:30
*/
/******************************************************/
Function BA400Inclui(cAlias,nReg,nOpc,oPanel, lRefresh)
/******************************************************/
Local lRet := .T.
Local cNotCampos := ""  
Local aPos := {} , aCmpApre := {} 
Local nInc
//Private aTela[0][0],aGets[0]
Private aCamposEDH := {}
Default lRefresh := .F.   

Begin Sequence 

      //Carregando arquivos da Work para Memoria 
      //AOM - 30/11/2011
      For nInc := 1 To EDH->(FCount())
         M->&(EDH->(FieldName(nInc))) := WKDI->&(EDH->(FieldName(nInc)))
      Next
      M->EDH_DESC_I:= WKDI->EDH_DESC_I
      M->EDH_UMNCM := WKDI->EDH_UMNCM
      M->EDH_DESNCM:= WKDI->EDH_DESNCM 
         
   If !lRefresh 
   
      If !Empty(M->EDH_DI_NUM)
         cNotCampos := "EDH_NF/EDH_SERIE/EDH_DTNF/EDH_SEQMI"
         //Liberando os Campos para Alteração
         Aadd(aCamposEDH,"EDH_DI_NUM") 
         Aadd(aCamposEDH,"EDH_DT_DI")
         Aadd(aCamposEDH,"EDH_LI") 
      Else
         cNotCampos := "EDH_RE/EDH_DT_DI/EDH_DI_NUM/EDH_HAWB/EDH_INVOIC/EDH_PGI_NU/EDH_SEQPLI/EDH_LI/EDH_SEQSIS"
      EndIf
      
      //RRC - 25/06/2012 - Permite alteração de campo que verifica se deve ou não abater saldo do item no Ato tanto para Itens Importados como para Compras Nacionais
      If EDH->(FieldPos("EDH_ESTSLD")) > 0
         Aadd(aCamposEDH,"EDH_ESTSLD")
      EndIf  
      
      If cTipoOpe <> NA
         cNotCampos += "/EDH_II/EDH_IPI/EDH_PIS/EDH_COFINS/EDH_AFRMM/EDH_ICMS
      EndIf
      
      If cTipoOpe <> DE
         cNotCampos += "/EDH_RE"
      EndIf
   
      //Adicionando os campos a serem apresentados na Enchoice, apenas campos da aba "Ocorrencia" 
      SX3->(DbSetOrder(1))
      SX3->(DbSeek("EDH"))
      While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "EDH"
         If !(AllTrim(SX3->X3_CAMPO) $ cNotCampos) .And. X3Uso(SX3->X3_USADO)
            If SX3->X3_FOLDER == "3" 
               Aadd(aCamposEDH,SX3->X3_CAMPO)
            EndIf
            Aadd(aCmpApre,SX3->X3_CAMPO)
         EndIf
      SX3->(DbSkip())
      EndDo
      
      //AOM - 05/11/2011 - ExecAuto 
      If lExecAuto
         
         If !EnchAuto(cAlias,aCabAuto,{|| BA400VldGrv()},nOpcAuto,aCmpApre)
            lRet:= .F.  
         Endif
      
      Else
 
         aPos := PosDlg(oPanel)
         aPos[1] := 01
         aPos[2] := 01
         aPos[3] := 140
         aPos[4] := 290
         If nOpc == 2
            oEnchoice := MsMGet():New(cAlias, , nOpc,,,,aCmpApre,aPos,,,,,,oPanel,,.T.,,,.F.,.T.)
         Else
               DbSelectArea(cAlias)
               if valtype(oEnchoice) <> "O"
                                       //([cAlias],,nOpc,,,, aAcho  ,aPos,aCpos                    ,nModelo,,,,oWnd],lF3,lMemoria,lColumn,caTela,lNoFolder,lProperty,aField,aFolder,lCreate,lNoMDIStretch,) 
                  oEnchoice := MsMGet():New(cAlias,,nOpc,,,,aCmpApre,aPos,If(nOpc == 3,aCamposEDH,),,,,,      oPanel,   ,.T.     ,  .F.  ,      ,.F.      ,         ,      ,       ,.F.    ,.F.,,) 
               EndIf
         EndIf
      EndIf

   EndIf
        
End Sequence

Return lRet 

/*
Funcao     : Qryinsumos()
Parametros : -
Retorno    : lRet
Objetivos  : Efetuar a Query nas tabelas (SW8,SW6 e SWP) para apresentar os insumos com Ato concessório
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 17/09/10 - 9:30
*/

/***************************/     
Static Function Qryinsumos()
/***************************/  
Local lRet
Local cQuery := "", cQuery2 := "" , cCond := "", cCond2 := ""

cQuery := "SELECT DISTINCT SW8.W8_COD_I, SW8.W8_AC, SW8.W8_SEQSIS, SW8.W8_HAWB, SW8.W8_PGI_NUM, SW8.W8_SEQ_LI, SW8.W8_INVOICE, SW7.W7_PESO, SW8.W8_VL_AC, " +;
          "SW8.W8_PO_NUM, SW8.W8_POSICAO, SW8.W8_QTDE, SW8.W8_PRECO, SW8.W8_UNID, SW6.W6_DTREG_D, SW6.W6_DI_NUM, " + If(SW6->(FieldPos("W6_DI_HIS"))>0,"SW6.W6_DI_HIS, ","")+; //RRC - 22/06/12 - Acrescentado campo "W6_DI_HIS"
          "SWP.WP_NR_ALI, SWP.WP_REGIST, SW9.W9_MOE_FOB "+;
          "FROM "+RetSqlName("SW8")+" SW8 INNER JOIN " + RetSqlName("SW6")+ " SW6 ON SW8.W8_HAWB = SW6.W6_HAWB INNER JOIN "+;
          RetSqlName("SWP") + " SWP ON SW8.W8_PGI_NUM = SWP.WP_PGI_NUM AND SW8.W8_SEQ_LI = SWP.WP_SEQ_LI INNER JOIN "+RetSqlName("SW9")+" SW9 ON SW8.W8_HAWB = SW9.W9_HAWB "+; //RRC - 10/07/12 - Acrescentado relação entre as sequências da LI para SW8 e SWP, pois pode existir mais de uma sequência
          "AND SW8.W8_FORN = SW9.W9_FORN AND " +  If(EICLoja("SW8","W8_FORLOJ"),"SW8.W8_FORLOJ = SW9.W9_FORLOJ AND ","")+ "SW8.W8_INVOICE = SW9.W9_INVOICE "+;
          "INNER JOIN " + RetSqlName("SW7") + " SW7 ON SW8.W8_HAWB = SW7.W7_HAWB AND SW8.W8_PO_NUM = SW7.W7_PO_NUM AND SW8.W8_SI_NUM = SW7.W7_SI_NUM "+;
          "AND SW8.W8_COD_I = SW7.W7_COD_I "  
          
cCond  := "WHERE SW8.W8_AC <> ''  AND  SW8.D_E_L_E_T_ <> '*' AND SW6.D_E_L_E_T_ <> '*' AND SWP.D_E_L_E_T_ <> '*' AND SW9.D_E_L_E_T_ <> '*' AND SW7.D_E_L_E_T_ <> '*' " 

cQuery:=ChangeQuery(cQuery+cCond) 


cQuery2 := "SELECT DISTINCT ED8.ED8_COD_I, ED8.ED8_AC, ED8.ED8_SEQSIS, ED8.ED8_INVOIC, ED8.ED8_PESO, ED8.ED8_QTD, ED8.ED8_VALORI, ED8.ED8_UM, ED8.ED8_DTREG, "+;
           "ED8.ED8_DI_NUM, ED8.ED8_LI_NUM, ED8.ED8_MOEDA, ED8.ED8_NCM, ED8.ED8_PEDIDO, ED8.ED8_EMISSA, ED8.ED8_NF, ED8.ED8_SERIE, ED8.ED8_ADICAO, ED8.ED8_POSDI "

//AOM - 28/10/2011
If ED8->(FieldPos("ED8_SEQMI")) > 0           
   cQuery2 += ", ED8_SEQMI"
EndIf
           
cQuery2 += " FROM " + RetSqlName("ED8") + " ED8 " 
           
cCond2  := "WHERE ED8.ED8_AC <> '' AND ED8.D_E_L_E_T_ <> '*'" 

cQuery2:=ChangeQuery(cQuery2+cCond2)


TcQuery cQuery ALIAS "QRY" NEW

TcQuery cQuery2 ALIAS "QRY2" NEW

TcSetField("QRY","W8_QTDE"   ,"N", AVSX3("W8_QTDE",3)   , AVSX3("W8_QTDE",4)   ) //Quantidade de Compra
TcSetField("QRY","W8_PRECO"  ,"N", AVSX3("W8_PRECO",3)  , AVSX3("W8_PRECO",4)  ) //Valor de Compra
TcSetField("QRY","W6_DTREG_D","D", AVSX3("W6_DTREG_D",3), AVSX3("W6_DTREG_D",4)) //Data DI 
TcSetField("QRY","W7_PESO"   ,"N", AVSX3("W7_PESO",3)   , AVSX3("W7_PESO",4)   ) //Peso

TcSetField("QRY2","ED8_QTD"   ,"N", AVSX3("ED8_QTD",3)   , AVSX3("ED8_QTD",4)   ) //Quantidade de Compra
TcSetField("QRY2","ED8_VALORI","N", AVSX3("ED8_VALORI",3), AVSX3("ED8_VALORI",4)) //Valor de Compra
TcSetField("QRY2","ED8_DTREG" ,"D", AVSX3("ED8_DTREG",3) , AVSX3("ED8_DTREG" ,4)) //Data DI 
TcSetField("QRY2","ED8_PESO"  ,"N", AVSX3("ED8_PESO",3)  , AVSX3("ED8_PESO",4)  ) //Peso    
TcSetField("QRY2","ED8_EMISSA","D", AVSX3("ED8_EMISSA",3), AVSX3("ED8_EMISSA",4)) //Data Nota Fiscal



Return lRet


/*
Função      : PanelBack(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : lRet - Verdadeiro - Recua ao painel anterior, Falso - Continua no mesmo painel.
Objetivos   : Efetuar validações ao clicar no botão 'Voltar' dos painéis do Wizard.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 13:20
*/
Static Function PanelBack(oWizard)
Local cPanel := PanelName(oWizard)
Local lRet := .T.

   Do Case
      Case cPanel == "USER_PN1"
         // oPanel := oWizard:oMPanel[ascan( oWizard:oMPanel , { |x| x:cName == "USER_PN0" } )]
         lRet := .F.
      Case cPanel == "USER_PN2"
         oPanel := oWizard:oMPanel[ascan( oWizard:oMPanel , { |x| x:cName == "USER_PN1" } )]
         // lRet := .F.
      Case cPanel == "USER_PN3"
         oPanel := oWizard:oMPanel[ascan( oWizard:oMPanel , { |x| x:cName == "USER_PN2" } )]
   EndCase

   // If lRet
   //    oWizard:nPanel := PanelPos(cLastPanel, oWizard, .T.)
   // EndIf

Return lRet

/*
Função      : PanelNext(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : lRet - Verdadeiro - Avança ao próximo painel, Falso - Continua no mesmo painel.
Objetivos   : Efetuar validações ao clicar no botão 'Avançar' dos painéis do Wizard.
Autor       : Allan Oliveira Monteiro
Data/Hora   : 13:40
*/
Static Function PanelNext(oWizard,cAlias,nReg,nOpc)
Local cPanel := PanelName(oWizard)
Local lRet := .T.
// Local nPanel := oWizard:nPanel

   Do Case
      
      Case cPanel == "USER_PN0"
   
         Processa({||BA400PN1(oWizard:OMPANEL[2])},STR0020,STR0020,.F.)
   
      Case cPanel == "USER_PN1"
         If (Select("WKDI") == 0) .or. (WKDI->(eof()) .and. WKDI->(bof()))
            MsgInfo(STR0022,STR0010)//"Não existe insumos relacionados a nenhum Ato Concessório","Aviso"
            lRet:= .F.
         else
            BA400Inclui(cAlias,nReg,nOpc,oWizard:OMPANEL[3],.F.)
         EndIf

      Case cPanel == "USER_PN2"

         BA400Inclui(cAlias,nReg,2,oWizard:OMPANEL[4],.F.)
         If !BA400VldGrv()
            lRet:= .F.
         EndIf

   EndCase
   
   // If !lRet
   //    oWizard:nPanel := nPanel
   // Else
   //    SetLastPanel(oWizard)
   // EndIf

Return lRet   

/*
Função      : PanelName(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : Propridade cName do painel atual - Nome do painel definido na declaração do Wizard.
Objetivos   : Retornar o nome do painel atual (Propriedade cName)
Autor       : Allan Oliveira Monteiro
Data/Hora   : 13:20
*/
Static Function PanelName(oWizard)
Return oWizard:oMPanel[oWizard:nPanel]:cName

/*
Função      : SetLastPanel(oWizard)
Parametros  : oWizard - Objeto da interface Wizard.
Retorno     : .T.
Objetivos   : Marcar o painel atual como o último painel exibido, guardando seu nome na variável private cLastPanel. 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 11/09/08
*/
Static Function SetLastPanel(oWizard)
   cLastPanel := PanelName(oWizard)
Return .T.
