#INCLUDE "eecae107.ch"
#include "dbtree.ch"
#include "EEC.CH"

// Defines do array de itens do tratamento de carta de crédito por itens    
#Define LC_RECNO    1
#Define LC_FLAG     2
#Define LC_VAL_BASE 3
#Define LC_VAL_MEMO 4
#Define LC_QTD_BASE 5
#Define LC_QTD_MEMO 6
#Define LC_NUM_BASE 7
#Define LC_SEQ_BASE 8
#Define LC_NUM_MEMO 9
#Define LC_SEQ_MEMO 10
#Define LC_UNI_MEMO 11
#Define LC_UNI_BASE 12

//Define da Função Ae107AtuSld
#Define LC_SUBTRAIR 1
#Define LC_SOMAR    2

/*
Programa        : EECAE107.PRW
Objetivo        : Proc. Embarque - Rotinas novas 8.11
Autor           : Cristiano A. Ferreira
Data/Hora       : 10/12/04 11:00
Obs.            :                                                              	
*/

/*
Funcao      : Ae105FechaPrc()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Manutenção de Fechamento de Praça.
Autor       : Jeferson Barros Jr.
Data/Hora   : 18/09/2003 - 14:37.
Revisao     :
Obs.        :
*/
*----------------------*
Function Ae105FechaPrc()
*----------------------*
Local aFields, aOrd := SaveOrd({"EE6","EX3","EX4","EX8","SYQ"})
Local cFileFPE, cFileFPA, cAlias := Select() 
Local lGrvFim1 := .f., lGrvFim2 := .f., lRet := .f.
Private aCampos //Usado no E_CRIATRAB
Private aMarcados := {{1,0},{2,0}}

// ** Flag para indicar se a via de transporte é do tipo 'maritima'.
Private lIsMaritima := .f. 

Begin Sequence

   If !Empty(M->EEC_DTEMBA)
      MsgInfo(STR0015, STR0017) //"Embarque finalizado"###"Atenção"
      Break
   EndIf
   
   If Empty(M->EEC_PREEMB)
      MsgInfo(STR0016, STR0017) //"Não foi informado o No. do Processo."###"Atenção"
      Break
   EndIf
   
   If !Empty(M->EEC_VIA)
      SYQ->(DbSetOrder(1))
      If SYQ->(DbSeek(xFilial("SYQ")+M->EEC_VIA))
         lIsMaritima := (Left(SYQ->YQ_COD_DI,1)=="1") // Tipo da via (Maritimo).
      EndIf
   Else
      MsgInfo(STR0001+AllTrim(AvSx3("EEC_VIA",AV_TITULO))+STR0002,STR0017) //"O campo '"###"' deve ser informado."###"Atenção"
      Break
   EndIf

   If !lIsMaritima
      MsgStop(STR0028+; //"Os tratamentos de fechamento de praça são realizados apenas para processos que utilizam "
              STR0029,STR0030) //"via de transporte do tipo 'marítima'."###"Atenção"
      Break
   EndIf

   If Empty(M->EEC_ORIGEM) .Or. Empty(M->EEC_DEST)
      MsgInfo(STR0003+AllTrim(AvSx3("EEC_ORIGEM",AV_TITULO))+"' e '"+AllTrim(AvSx3("EEC_DEST",AV_TITULO))+; //"Os campos '"
              STR0004,STR0017) //"' devem ser informados."###"Atenção"
      Break
   EndIf

   If lIsMaritima
      aFields := {{"WKMARCA", "C", 02, 0},;
                  {"EE6_COD",    AvSx3("EE6_COD"   ,AV_TIPO),AvSx3("EE6_COD"   ,AV_TAMANHO),AvSx3("EE6_COD"   ,AV_DECIMAL)},;
                  {"EE6_VIAGEM", AvSx3("EE6_VIAGEM",AV_TIPO),AvSx3("EE6_VIAGEM",AV_TAMANHO),AvSx3("EE6_VIAGEM",AV_DECIMAL)},;
                  {"EE6_NOME",   AvSx3("EE6_NOME"  ,AV_TIPO),AvSx3("EE6_NOME"  ,AV_TAMANHO),AvSx3("EE6_NOME"  ,AV_DECIMAL)},;
                  {"EE6_DEADLI", AvSx3("EE6_DEADLI",AV_TIPO),AvSx3("EE6_DEADLI",AV_TAMANHO),AvSx3("EE6_DEADLI",AV_DECIMAL)},;
                  {"EE6_ETAORI", AvSx3("EE6_ETAORI",AV_TIPO),AvSx3("EE6_ETAORI",AV_TAMANHO),AvSx3("EE6_ETAORI",AV_DECIMAL)},;
                  {"EX8_ETADES", AvSx3("EX8_ETADES",AV_TIPO),AvSx3("EX8_ETADES",AV_TAMANHO),AvSx3("EX8_ETADES",AV_DECIMAL)}}
     
      cFileFPE := E_CriaTrab(,aFields,"WorkFPE")
      IndRegua("WorkFPE",cFileFPE+TEOrdBagExt(),"EE6_COD")

      MsAguarde({|| lRet := Ae105GrvEmb() },STR0005) //"Verificando embarcações ..."

      If lRet
         If !(lGrvFim1 := Ae105ViewWork(1,"WorkFPE")) 
            Break
         EndIf
      Else
         MsgInfo(STR0006+AllTrim(M->EEC_ORIGEM)+STR0007+; //"Não foram encontradas embarcações, para a origem ("###") e  o destino ("
                 AllTrim(M->EEC_DEST)+").",STR0017) //"Atenção"
         Break
      EndIf
   EndIf

   aFields := {{"WKMARCA","C",02,0},;
               {"EX3_AGENTE",AvSx3("EX3_AGENTE",AV_TIPO),AvSx3("EX3_AGENTE",AV_TAMANHO),AvSx3("EX3_AGENTE",AV_DECIMAL)},;
               {"EX3_DSCAGE",AvSx3("EX3_DSCAGE",AV_TIPO),AvSx3("EX3_DSCAGE",AV_TAMANHO),AvSx3("EX3_DSCAGE",AV_DECIMAL)},;
               {"EX3_TRATIM",AvSx3("EX3_TRATIM",AV_TIPO),AvSx3("EX3_TRATIM",AV_TAMANHO),AvSx3("EX3_TRATIM",AV_DECIMAL)},;          
               {"EX4_TIPO"  ,AvSx3("EX4_TIPO"  ,AV_TIPO),AvSx3("EX4_TIPO"  ,AV_TAMANHO),AvSx3("EX4_TIPO"  ,AV_DECIMAL)},;
               {"EX4_CON20" ,AvSx3("EX4_CON20" ,AV_TIPO),AvSx3("EX4_CON20" ,AV_TAMANHO),AvSx3("EX4_CON20" ,AV_DECIMAL)},;
               {"EX4_CON40" ,AvSx3("EX4_CON40" ,AV_TIPO),AvSx3("EX4_CON40" ,AV_TAMANHO),AvSx3("EX4_CON40" ,AV_DECIMAL)},;
               {"EX4_CON40H",AvSx3("EX4_CON40H",AV_TIPO),AvSx3("EX4_CON40H",AV_TAMANHO),AvSx3("EX4_CON40H",AV_DECIMAL)},;
               {"EX4_MOEDA" ,AvSx3("EX4_MOEDA" ,AV_TIPO),AvSx3("EX4_MOEDA" ,AV_TAMANHO),AvSx3("EX4_MOEDA" ,AV_DECIMAL)}}

   cFileFPA := E_CriaTrab(,aFields,"WorkFPA")
   IndRegua("WorkFPA",cFileFPA+TEOrdBagExt(),"EX3_AGENTE")

   MsAguarde({|| lRet := Ae105GrvAge() },STR0008) //"Verificando agentes ..."

   If lRet
      If !(lGrvFim2 := Ae105ViewWork(2,"WorkFPA"))
         Break
      EndIf
   Else
      MsgInfo(STR0009+AllTrim(M->EEC_ORIGEM)+STR0007+; //"Não foram encontrados agentes, para a origem ("###") e  o destino ("
              AllTrim(M->EEC_DEST)+").",STR0017) //"Atenção"
      Break
   EndIf

   If lGrvFim1 .Or. lGrvFim2
      If lIsMaritima
         If aMarcados[1][2] > 0
            WorkFPE->(dbGoTo(aMarcados[1][2]))
            M->EEC_ETA    := WorkFPE->EE6_ETAORI
            M->EEC_ETD    := WorkFPE->EE6_ETAORI
            M->EEC_ETADES := WorkFPE->EX8_ETADES
            M->EEC_VIAGEM := WorkFPE->EE6_VIAGEM
            M->EEC_EMBARC := WorkFPE->EE6_COD
            M->EEC_DSCNAV := WorkFPE->EE6_NOME
         EndIf
      EndIf

      If aMarcados[2][2] > 0
         WorkFPA->(dbGoTo(aMarcados[2][2]))
         nCon20  := Ae105TotContainer(M->EEC_PREEMB,"1")
         nCon40  := Ae105TotContainer(M->EEC_PREEMB,"2")
         nCon40H := Ae105TotContainer(M->EEC_PREEMB,"3")

         M->EEC_TRSTIM := WorkFPA->EX3_TRATIM
         M->EEC_DTFCPR := dDataBase

         If M->EEC_FRPPCC # "CC"         
            If nCon20+nCon40+nCon40H = 0
               M->EEC_FRPREV := AE105FreteKilo(M->EEC_VIA+M->EEC_ORIGEM+M->EEC_DEST+WorkFPA->EX3_AGENTE, M->EEC_PESLIQ, M->EEC_MOEDA)
            Else
               M->EEC_FRPREV := (nCon20 * WorkFPA->EX4_CON20) + (nCon40 * WorkFPA->EX4_CON40 ) + (nCon40H * WorkFPA->EX4_CON40H)
            EndIf            
         Endif   

         WorkAg->(dbSetOrder(1))
         If !WorkAg->(dbSeek(WorkFPA->EX3_AGENTE))
            WorkAg->(dbAppEnd())
            WorkAg->EEB_CODAGE  := WorkFPA->EX3_AGENTE
            WorkAg->EEB_NOME    := WorkFPA->EX3_DSCAGE
            WorkAg->EEB_TIPOAG  := CD_AGE + Tabela('YE',"1")
         EndIf
      EndIf
   EndIf

End Sequence

If Select("WorkFpe") > 0
   WorkFPE->(E_EraseArq(cFileFpe))
EndIf

If Select("WorkFpa") > 0
   WorkFpa->(E_EraseArq(cFileFpa))
EndIf

RestOrd(aOrd)

dbSelectarea(cAlias)

Return Nil

/*
Funcao      : Ae105GrvEmb().
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Selecionar as Embarcacoes de acordo com a origem e o destino.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/09/2003 13:40.
Obs.        :
*/
*---------------------------*
Static Function Ae105GrvEmb()
*---------------------------*
Local lRet := .f.
Local aOrd:=SaveOrd({"EE6","EX8"})
Local cOrigem//, cCodOrigens
#IFDEF TOP
   Local cQueryString
#ENDIF

Begin Sequence

   cOrigem := M->EEC_ORIGEM
   EE6->(DbSetOrder(1))
   EX8->(DbSetOrder(3))

   /*
   If EE6->(DbSeek(xFilial("EE6")+cOrigem))   

      Do While EE6->(!Eof()) .And. EE6->EE6_FILIAL == xFilial("EE6") .And.; 
                                   EE6->EE6_ORIGEM == cOrigem
                                   EE6->( EE6_ORIGEM + EE6_ )
         If EX8->(dbSeek(xFilial("EX8")+EE6->EE6_COD))

            While EX8->(!Eof()) .And. EX8->EX8_FILIAL == xFilial("EX8") .And.;
                                      EX8->EX8_NAVIO  == EE6->EE6_COD

               If EX8->EX8_DEST == M->EEC_DEST
                  WorkFPE->(dbAppend())
                  WorkFPE->EE6_COD    := EE6->EE6_COD
                  WorkFPE->EE6_NOME   := EE6->EE6_NOME
                  WorkFPE->EE6_DEADLI := EE6->EE6_DEADLI
                  WorkFPE->EE6_ETAORI := EE6->EE6_ETAORI
                  WorkFPE->EE6_VIAGEM := EE6->EE6_VIAGEM
                  WorkFPE->EX8_ETADES := EX8->EX8_ETADES
                  lRet := .t.
               EndIf

               EX8->(dbSkip())
            EndDo
         EndIf

         EE6->(dbSkip())
      EndDo
   Else
      EE6->(DbSeek(xFilial("EE6")))
      Do While EE6->(!Eof()) .And. EE6->EE6_FILIAL == xFilial("EE6")
         cCodOrigens := (EE6->EE6_ORIGEM+"/"+EE6->EE6_ORIG_2+"/"+EE6->EE6_ORIG_3+"/"+;
                         EE6->EE6_ORIG_4+"/"+EE6->EE6_ORIG_5)

         If cOrigem $ cCodOrigens
            If EX8->(dbSeek(xFilial("EX8")+EE6->EE6_COD))

               While !EX8->(Eof()) .And. EX8->EX8_FILIAL == xFilial("EX8") .And.; 
                                         EX8->EX8_NAVIO  == EE6->EE6_COD
            
                  If EX8->EX8_DEST == M->EEC_DEST
                     WorkFPE->(dbAppend())
                     WorkFPE->EE6_COD    := EE6->EE6_COD
                     WorkFPE->EE6_NOME   := EE6->EE6_NOME
                     WorkFPE->EE6_DEADLI := EE6->EE6_DEADLI
                     WorkFPE->EE6_ETAORI := EE6->EE6_ETAORI
                     WorkFPE->EE6_VIAGEM := EE6->EE6_VIAGEM
                     WorkFPE->EX8_ETADES := EX8->EX8_ETADES
                     lRet := .t.
                  EndIf

                  EX8->(dbSkip())
               EndDo
            EndIf
         EndIf

         EE6->(DbSkip())
      EndDo
   EndIf
   */
   
   /*
   Rotina para criação da WorkFPE.
   Data e Hora: 02/04/2004 às 15:33.
   Autor: Alexsander Martins dos Santos
   */

   #IFDEF TOP

      /*
      cQueryString := "SELECT "
      cQueryString += "EE6.EE6_COD, "
      cQueryString += "EE6.EE6_VIAGEM, "
      cQueryString += "EE6.EE6_NOME, "
      cQueryString += "EE6.EE6_DEADLI, "
      cQueryString += "EE6.EE6_ETAORI, "
      cQueryString += "EX8.EX8_ETADES "    
      cQueryString += "FROM "
      cQueryString += RetSQLName("EE6") + " EE6 "
      cQueryString += "INNER JOIN "
      cQueryString += RetSQLName("EX8") + " EX8 "
      cQueryString += "ON EE6.EE6_FILIAL+EE6.EE6_COD+EE6.EE6_VIAGEM = EX8.EX8_FILIAL+EX8.EX8_NAVIO+EX8.EX8_VIAGEM "      
      cQueryString += "WHERE "
      cQueryString += "EE6.D_E_L_E_T_ <> '*' AND "
      cQueryString += "EX8.D_E_L_E_T_ <> '*' AND "
      cQueryString += "EE6.EE6_FILIAL = '"+xFilial("EE6")+"' AND "
      cQueryString += "EE6.EE6_ORIGEM+EE6.EE6_ORIG_2+EE6.EE6_ORIG_3+EE6.EE6_ORIG_4+EE6.EE6_ORIG_5 LIKE '%"+cOrigem+"%' AND "
      cQueryString += "EX8.EX8_DEST = '"+M->EEC_DEST+"'"
      */

      cQueryString := "SELECT "
      cQueryString += "EE6.EE6_COD, "
      cQueryString += "EE6.EE6_VIAGEM, "
      cQueryString += "EE6.EE6_NOME,   "
      cQueryString += "EE6.EE6_DEADLI, "
      cQueryString += "EE6.EE6_ETAORI, "
      cQueryString += "EX8.EX8_ETADES  "
      cQueryString += "FROM " +RetSQLName("EE6")+" EE6, "+RetSQLName("EX8") + " EX8 "
      cQueryString += "WHERE "
      cQueryString += "EE6.D_E_L_E_T_ <> '*' AND "
      cQueryString += "EX8.D_E_L_E_T_ <> '*' AND "
      cQueryString += "EE6.EE6_FILIAL = '"+xFilial("EE6")+"' AND "
      cQueryString += "EX8.EX8_FILIAL = '"+xFilial("EX8")+"' AND "+;
                       " EE6.EE6_COD = EX8.EX8_NAVIO And EE6.EE6_VIAGEM = EX8.EX8_VIAGEM AND "+;
                       " EX8.EX8_DEST = '"+M->EEC_DEST+"' AND "+;
                       "(EE6.EE6_ORIGEM LIKE '%"+cOrigem+"%' OR "+;
                       " EE6.EE6_ORIG_2 LIKE '%"+cOrigem+"%' OR "+;
                       " EE6.EE6_ORIG_3 LIKE '%"+cOrigem+"%' OR "+;
                       " EE6.EE6_ORIG_4 LIKE '%"+cOrigem+"%' OR "+;
                       " EE6.EE6_ORIG_5 LIKE '%"+cOrigem+"%')"

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQueryString)), "QRY", .F., .T. )

      TCSetField("QRY", "EE6_DEADLI", "D")
      TCSetField("QRY", "EE6_ETAORI", "D")
      TCSetField("QRY", "EX8_ETADES", "D")

      While QRY->(!Eof())

         WorkFPE->(dbAppend())
         AVReplace("QRY", "WorkFPE")
         QRY->(dbSkip())

         lRet := .T.

      End

      QRY->(dbCloseArea())
      dbSelectArea("WORKFPE")

   #ELSE

      EE6->(dbSeek(xFilial("EE6")))

      While EE6->(!Eof() .and. EE6_FILIAL == xFilial("EE6"))

         If "'"+cOrigem+"'" $ EE6->("'"+EE6_ORIGEM+"'" + ;
                                    "'"+EE6_ORIG_2+"'" + ;
                                    "'"+EE6_ORIG_3+"'" + ;
                                    "'"+EE6_ORIG_4+"'" + ;
                                    "'"+EE6_ORIG_5+"'")

            If EX8->(dbSeek(xFilial("EX8")+EE6->EE6_COD+EE6->EE6_VIAGEM))

               While EX8->(!Eof() .and. EX8_FILIAL == xFilial("EX8") .and. EX8_NAVIO == EE6->EE6_COD .and. EX8_VIAGEM == EE6->EE6_VIAGEM)

                  If EX8->EX8_DEST == M->EEC_DEST
                     WorkFPE->(dbAppend())
                     WorkFPE->EE6_COD    := EE6->EE6_COD
                     WorkFPE->EE6_VIAGEM := EE6->EE6_VIAGEM
                     WorkFPE->EE6_NOME   := EE6->EE6_NOME
                     WorkFPE->EE6_DEADLI := EE6->EE6_DEADLI
                     WorkFPE->EE6_ETAORI := EE6->EE6_ETAORI
                     WorkFPE->EX8_ETADES := EX8->EX8_ETADES
                     lRet := .T.
                  EndIf

                  EX8->(dbSkip())

               End

            EndIf

         EndIf

         EE6->(dbSkip())

      End   
   
   #ENDIF

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ae105GrvAge().
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Selecionar os Agentes de acordo com a origem e o destino.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/09/2002 às 11:00
Revisão     : 02/04/2004 às 16:30, Alexsander Martins dos Santos.
Obs.        :
*/
*---------------------------*
Static Function Ae105GrvAge()
*---------------------------*
Local lRet := .f., aOrd:=SaveOrd({"EX3","EX4"})
Local cFilEX3 := xFilial("EX3"), cFilEX4 := xFilial("EX4")

Begin Sequence

   EX3->(dbSetOrder(1))
   EX4->(dbSetOrder(1))

   If EX3->(dbSeek(cFilEX3+M->EEC_VIA+M->EEC_ORIGEM+M->EEC_DEST))

      While EX3->(!Eof()) .And. EX3->EX3_FILIAL == cFilEX3 .And.; 
                                EX3->EX3_VIA    == M->EEC_VIA .And.;
                                EX3->EX3_ORIGEM == M->EEC_ORIGEM .And.;
                                EX3->EX3_DEST   == M->EEC_DEST

         EX4->(dbSeek(cFilEX4+EX3->(EX3_VIA+EX3_ORIGEM+EX3_DEST+EX3_AGENTE)))
         While EX4->(!Eof()) .And. EX4->EX4_FILIAL == cFilEX4 .And.; 
                                   EX4->EX4_VIA    == EX3->EX3_VIA .And.;
                                   EX4->EX4_ORIGEM == EX3->EX3_ORIGEM .And.;
                                   EX4->EX4_DEST   == EX3->EX3_DEST .And.;
                                   EX4->EX4_AGENTE == EX3->EX3_AGENTE

            WorkFPA->(DbAppend())
            WorkFPA->EX3_AGENTE := EX3->EX3_AGENTE
            WorkFPA->EX3_DSCAGE := Posicione("SY5",1,xFilial()+EX3->EX3_AGENTE,"Y5_NOME") //EX3->EX3_DSCAGE
            WorkFPA->EX3_TRATIM := EX3->EX3_TRATIM

            If M->EEC_MOEDA # EX4->EX4_MOEDA
               nTaxaA := BuscaTaxa(EX4->EX4_MOEDA,dDataBase)
               nTaxaB := BuscaTaxa(M->EEC_MOEDA,dDataBase)
            Else
               nTaxaA := 1
               nTaxaB := 1
            Endif
            
            WorkFPA->EX4_TIPO   := EX4->EX4_TIPO
            WorkFPA->EX4_CON20  += (EX4->EX4_CON20  * nTaxaA)/nTaxaB 
            WorkFPA->EX4_CON40  += (EX4->EX4_CON40  * nTaxaA)/nTaxaB
            WorkFPA->EX4_CON40H += (EX4->EX4_CON40H * nTaxaA)/nTaxaB

            EX4->(dbSkip())
         EndDo

         lRet := .t.      
         EX3->(dbSkip())         
      EndDo
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ae105ViewWork(nTipo,cAlias)
Parametros  : nTipo  : (1)Embarcacoes/(2)Agentes. 
              cAlias : Arquivo a ser aberto.
Retorno     : .f./.t.
Objetivos   : Mostra os Agentes ou Embarcacoes para a Selecao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/09/2003 10:44
Obs.        :

*/
*-----------------------------------------*
Static Function Ae105ViewWork(nTipo,cAlias)
*-----------------------------------------*
Local oDlg ,oMark
Local lRet := .f.
Local nOpc := 0
Local bOk     := {|| If(Ae105ValidSaida(1),(nOpc:=1,oDlg:End()),nil)}
Local bCancel := {|| If(Ae105ValidSaida(2),(nOpc:=0,oDlg:End()),nil)}
Local aCampos:={}, aButtons:={}
Local cTitulo

Private cMarca  := GetMark(), lInverte := .f.
Private nMarcados := 0

Begin Sequence

   If nTipo = 1
      Aadd(aCampos,{"WKMARCA"   ,," "})
      Aadd(aCampos,{"EE6_COD"   ,,AvSx3("EE6_COD"   ,AV_TITULO)})
      Aadd(aCampos,{"EE6_VIAGEM",,AvSx3("EE6_VIAGEM",AV_TITULO)})
      Aadd(aCampos,{"EE6_NOME"  ,,AvSx3("EE6_NOME"  ,AV_TITULO)})
      Aadd(aCampos,{"EE6_DEADLI",,AvSx3("EE6_DEADLI",AV_TITULO)})
      Aadd(aCampos,{"EE6_ETAORI",,AvSx3("EE6_ETAORI",AV_TITULO)})
      Aadd(aCampos,{"EX8_ETADES",,AvSx3("EX8_ETADES",AV_TITULO)})

      cTitulo := STR0010 //"Fechamento de Praça - Embarcações"
   Else

      Aadd(aCampos,{"WKMARCA"   ,," "})
      Aadd(aCampos,{"EX3_AGENTE",,AvSx3("EX3_AGENTE",AV_TITULO)})
      Aadd(aCampos,{"EX3_DSCAGE",,AvSx3("EX3_DSCAGE",AV_TITULO)})
      Aadd(aCampos,{"EX3_TRATIM",,AvSx3("EX3_TRATIM",AV_TITULO)})
      Aadd(aCampos,{"EX4_TIPO"  ,,AvSx3("EX4_TIPO"  ,AV_TITULO)})
      Aadd(aCampos,{{|| Trans(EX4_CON20, AvSx3('EX4_CON20' ,AV_PICTURE))} ,"",AvSx3("EX4_CON20" ,AV_TITULO)})
      Aadd(aCampos,{{|| Trans(EX4_CON40, AvSx3('EX4_CON40' ,AV_PICTURE))} ,"",AvSx3("EX4_CON40" ,AV_TITULO)})
      Aadd(aCampos,{{|| Trans(EX4_CON40H,AvSx3('EX4_CON40H',AV_PICTURE))} ,"",AvSx3("EX4_CON40H",AV_TITULO)})
      cTitulo := STR0011 //"Fechamento de Praça - Agentes"
   EndIf

   (cAlias)->(dbGoTop())

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 28,80 OF oMainWnd
      oMark := MsSelect():New(cAlias,"WKMARCA",,aCampos,@lInverte,@cMarca,PosDlg(oDlg))
      oMark:bAval := {|| Ae105ChkMarca(oMark,cMarca,cAlias,nTipo)}
   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)

   If nOpc = 1
      lRet := .t.   
   Else
      aMarcados[nTipo][2] := 0
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ae105ChkMarca(oMark,cMarca,cAlias,nTipo)
Parametros  : oMark,cMarca,cAlias.
Retorno     : Nil.
Objetivos   : Controle de marcacao.
Autor       : Jefeson Barros Jr.
Data/Hora   : 19/09/2003 14:55
Obs.        :

*/
*------------------------------------------------------*
Static Function Ae105ChkMarca(oMark,cMarca,cAlias,nTipo)
*------------------------------------------------------*
Begin Sequence

   If nMarcados = 0
      (cAlias)->WKMARCA := cMarca
      nMarcados = 1
      aMarcados[nTipo][2] := (cAlias)->(RecNo())
   Else
      If Empty((cAlias)->WKMARCA)
         MsgInfo(STR0012,STR0017) //"Somente um item deve ser marcado."###"Atenção"
      Else
         (cAlias)->WKMARCA := Space(2)
         nMarcados := 0
         aMarcados[nTipo][2] := 0
      EndIf
   EndIf

   oMark:oBrowse:Refresh()

End Sequence

Return Nil

/*
Funcao      : Ae105ValidSaida(nTipo)
Parametros  : nTipo : 1 = Ok
                      2 = Cancel
Retorno     : .T. , .F.
Objetivos   : Validação da saida da visualizacao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/09/2003 13:40
Revisao     :
Obs.        :
*/
*------------------------------------*
Static Function Ae105ValidSaida(nTipo)
*------------------------------------*
Local lRet := .t.

Begin Sequence

   If nTipo = 1
      If nMarcados = 0 
         If !MsgYesNo(STR0013,STR0017) //"Deseja sair sem marcar nenhum item ? "###"Atenção"
            lRet := .f.
            Break
         EndIf
      EndIf
   Else
      If nMarcados = 0
         If !MsgYesNo(STR0013,STR0017) //"Deseja sair sem marcar nenhum item ? "###"Atenção"
            lRet := .f.
            Break
         EndIf
      Else
         If !MsgYesNo(STR0014,STR0017) //"Se sair, o item selecionado não será gravado."###"Atenção"
            lRet := .f.
            Break
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ae105TotContainer(cProc,cTipo)
Parametros  : cProc, cTipo
Retorno     : .t. , .f.
Objetivos   : Validação da saida da visualizacao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 19/09/2003 13:40.
Revisao     :
Obs.        :
*/
*--------------------------------------------*
Static Function Ae105TotContainer(cProc,cTipo)
*--------------------------------------------*
Local nCont:=0, aOrd:=SaveOrd("EX9")

Begin Sequence

   cProc := AvKey(AllTrim(cProc),"EX9_PREEMB")
   cTipo := AllTrim(cTipo)

   EX9->(DbSetorder(1))
   EX9->(DbSeek(xFilial("EX9")+cProc))

   While EX9->(!Eof() .and. EX9_FILIAL == xFilial("EX9") .and. EX9_PREEMB == cProc)
      If Left(EX9->EX9_TIPCON,1) == cTipo
         nCont++
      Endif
      EX9->(DBSKIP())
   EndDo

End Sequence

RestOrd(aOrd)

Return (nCont)

/*
Funcao       AE105FreteKilo
Objetivo   : Calcular e retornar o valor de frete com base no peso, através da taxa de frete por kilo no agente.
Parametros : Agente -> Via + Origem + Destino + Agente.
             Peso   -> Peso.
             Moeda  -> Moeda em que deve retornar o valor.
Autor      : Alexsander Martins dos Santos
Data e Hora: 06/04/2004 às 18:30
*/
*----------------------------------------------------*
Static Function AE105FreteKilo(cAgente, nPeso, cMoeda)
*----------------------------------------------------*
Local nReturn    := 0
Local aSaveOrd   := SaveOrd("EX3")
Local aTaxaFrete := Array(6, 2)
Local nPos       := 0

Begin Sequence

   EX3->(dbSetOrder(1))
   EX3->(dbSeek(xFilial("EX3")+cAgente))
   
   For nPos := 1 To Len(aTaxaFrete)
      aTaxaFrete[nPos][1] := EX3->(&("EX3_KILO"  + Str(nPos, 1)))
      aTaxaFrete[nPos][2] := EX3->(&("EX3_VALOR" + Str(nPos, 1)))
   Next

   aSort(aTaxaFrete, 1, Len(aTaxaFrete), {|x, y| x < y})

   If (nPos := aScan(aTaxaFrete, {|x| x[1] >= nPeso})) > 0
      If EX3->EX3_MOEDA <> cMoeda
         If EX3->EX3_MOEDA <> "R$"
            aTaxaFrete[nPos][2] := aTaxaFrete[nPos][2] * BuscaTaxa(EX3->EX3_MOEDA, dDataBase)
         EndIf
         aTaxaFrete[nPos][2] := aTaxaFrete[nPos][2] / BuscaTaxa(cMoeda, dDataBase)
      EndIf
      nReturn := aTaxaFrete[nPos][2]
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(nReturn)

/*
Funcao       AE107AtuLC
Objetivo   : Atualizar os campos de saldo da carta de credito vinculada ao embarque
Parametros : 
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 13/01/2005 às 15:10
*/
*-------------------------------------*
Function AE107AtuLC(lInclui,lReplDados)
*-------------------------------------*
Local aOrd := SaveOrd({"EEC","EE9"})
Local nTxEEC_EEL, nTxM_EEL, nTx, nRec
Local lDtEmbaBase, lDtEmbaMemoria, i
Local nDecEEL := AvSx3("EEL_LCVL",AV_DECIMAL)
Local nAux
Local nRecEEL
Default lReplDados := .f.
EEL->(DbSetOrder(1))

If EECFlags("ITENS_LC")
   EXS->(DbSetOrder(1))
EndIf

nRec := EEC->(RecNo())

If !lInclui   
   EEC->(DbSetOrder(1))
   EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))
EndIf

If !lReplDados
   Private dDtEmba := EEC->EEC_DTEMBA
   Private cLc_Num := EEC->EEC_LC_NUM
   Private cMoeda  := EEC->EEC_MOEDA
   Private nTotPed := EEC->EEC_TOTPED
   If EECFlags("ITENS_LC")
      Private aItens := {}
      /*  _____________________________________________________________________________
         | aItens por posição                                       | Defines          |
         |__________________________________________________________|__________________|
         | [i][1] - Recno da Work                                   |  1 - LC_RECNO    |
         | [i][2] - Flag da Work (Marcado(.t.) ou desmarcado (.f.)) |  2 - LC_FLAG     |
         | [i][3] - Valor total do item na base                     |  3 - LC_VAL_BASE |
         | [i][4] - Valor total do item na memória (work)           |  4 - LC_VAL_MEMO |
         | [i][5] - Quantidade do item na base                      |  5 - LC_QTD_BASE |
         | [i][6] - Quantidade do item na memória (work)            |  6 - LC_QTD_MEMO |
         | [i][7] - Número da L/C na Base                           |  7 - LC_NUM_BASE |
         | [i][8] - Sequência da L/C na Base                        |  8 - LC_SEQ_BASE |
         | [i][9] - Número da L/C na Memória                        |  9 - LC_NUM_MEMO |
         | [i][10]- Sequência da L/C na Memória                     | 10 - LC_SEQ_MEMO |
         | [i][11]- Unidade de Medida na Memória                    | 11 - LC_UNI_MEMO |
         | [i][12]- Unidade de Medida na base                       | 12 - LC_UNI_BASE |
         |__________________________________________________________|__________________|
      */                  
      WorkIp->(DbGoTop())
      While WorkIp->(!Eof())
         If WorkIp->(WP_RECNO = 0 .And. Empty(WP_FLAG))
            WorkIp->(DbSkip())
            Loop
         EndIf
         AAdd(aItens,{WorkIp->WP_RECNO,If(Empty(WorkIp->WP_FLAG),.f.,.t.),0 ,Ae107CalcTot(.t.),;
                      0 ,WorkIp->EE9_SLDINI,"","",WorkIp->EE9_LC_NUM,WorkIp->EE9_SEQ_LC,WorkIp->EE9_UNIDAD,"" })
         If WorkIp->WP_RECNO <> 0
            EE9->(DbGoTo(WorkIp->WP_RECNO))
            aItens[Len(aItens)][LC_VAL_BASE] := Ae107CalcTot()
            aItens[Len(aItens)][LC_QTD_BASE] := EE9->EE9_SLDINI
            aItens[Len(aItens)][LC_NUM_BASE] := EE9->EE9_LC_NUM
            aItens[Len(aItens)][LC_SEQ_BASE] := EE9->EE9_SEQ_LC
            aItens[Len(aItens)][LC_UNI_BASE] := EE9->EE9_UNIDAD
         EndIf
         WorkIp->(DbSkip())
      EndDo
   EndIf
EndIf

lDtEmbaBase    := .f.
lDtEmbaMemoria := !Empty(M->EEC_DTEMBA)

nTotPed:= (nTotPed - AE102TotADiant())  //TRP-24/07/08
If !lInclui   
   lDtEmbaBase    := !Empty(dDtEmba)
   
   If !EECFlags("ITENS_LC") .And. !Empty(cLc_Num)
      EEL->(DbSeek(xFilial("EEL")+cLc_Num))  
      nTxEEC_EEL := EECCalcTaxa(cMoeda,EEL->EEL_MOEDA)
   EndIf
EndIf

If EECFlags("ITENS_LC") // Tratamento de Itens por L/C

   nRecEE9 := EE9->(RecNo())
   nRecEEC := EEC->(RecNo())
   EE9->(DbSetOrder(3))
   For i := 1 to Len(aItensDesv)
      
      EE9->(DbSeek(aItensDesv[i][1]+aItensDesv[i][2]+aItensDesv[i][3]))
      EEC->(DbSeek(aItensDesv[i][1]+aItensDesv[i][2]))
      If Empty(EE9->EE9_LC_NUM)
         Loop
      EndIf
      EEL->(DbSeek(aItensDesv[i][1]+EE9->EE9_LC_NUM))
      If EEL->EEL_CTPROD $ cSim
         If Empty(EE9->EE9_SEQ_LC)
            Loop
         EndIf

         nAux := Ae107AtuSld("EXS_SLDVNC",Ae107CalcTot(),EEC->EEC_MOEDA,LC_SOMAR) // Restaura Sld. a Vinc. do Item
         Ae107AtuSld("EEL_SLDVNC",nAux,Nil,LC_SOMAR)                              // Restaura Sld. a Vinc. da L/C
               
         If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, restaura a quantidade a vincular
            Ae107AtuSld("EXS_QTDVNC",EE9->EE9_SLDINI,Nil,LC_SOMAR,EE9->EE9_UNIDAD)
         EndIf
               
         If !Empty(EEC->EEC_DTEMBA) // Se o processo está com a data de embarque preenchida

            nAux := Ae107AtuSld("EXS_SLDEMB",Ae107CalcTot(),EEC->EEC_MOEDA,LC_SOMAR)// Restaura Sld. a Emb. do Item
            Ae107AtuSld("EEL_SLDEMB",nAux,Nil,LC_SOMAR)                             // Restaura Sld. a Emb. da L/C
                  
            If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, restaura a quantidade a Embarcar
               Ae107AtuSld("EXS_QTDEMB",EE9->EE9_SLDINI,Nil,LC_SOMAR,EE9->EE9_UNIDAD)
            EndIf
         EndIf
         
      Else
         
         Ae107AtuSld("EEL_SLDVNC",Ae107CalcTot(),EEC->EEC_MOEDA,LC_SOMAR) //Restaura Saldo a Vincular da L/C
         If !Empty(EEC->EEC_DTEMBA)  // Se o processo está com a data de embarque preenchida
            Ae107AtuSld("EEL_SLDEMB",Ae107CalcTot(),EEC->EEC_MOEDA,LC_SOMAR)
         EndIf
         
      EndIf
      
   Next
   EE9->(DbGoTo(nRecEE9))
   EEC->(DbGoTo(nRecEEC))
   aItensDesv := {}
   
   For i := 1 to Len(aItens)
      
      If aItens[i][LC_RECNO] > 0 //Retira as vinculações de acordo com o que está na base
         
         If !Empty(aItens[i][LC_NUM_BASE]) // Se a L/C para este item na base estava preenchida
         
            EEL->(DbSeek(xFilial()+aItens[i][LC_NUM_BASE] ))
            If EEL->EEL_CTPROD $ cSim // Se a carta de Crédito controla produtos
               If !Empty(aItens[i][LC_SEQ_BASE]) // e a sequência está preenchida
                  EXS->(DbSeek(xFilial()+aItens[i][LC_NUM_BASE]+aItens[i][LC_SEQ_BASE]))
               
                  nAux := Ae107AtuSld("EXS_SLDVNC",aItens[i][LC_VAL_BASE],cMoeda,LC_SOMAR) // Restaura Sld. a Vinc. do Item
                  Ae107AtuSld("EEL_SLDVNC",nAux,Nil,LC_SOMAR)                              // Restaura Sld. a Vinc. da L/C
                  
                  If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, restaura a quantidade a vincular
                     Ae107AtuSld("EXS_QTDVNC",aItens[i][LC_QTD_BASE],Nil,LC_SOMAR,aItens[i][LC_UNI_BASE])
                  EndIf
                  
                  If lDtEmbaBase // Se o processo já havia sido gravado com data de embarque
                     nAux := Ae107AtuSld("EXS_SLDEMB",aItens[i][LC_VAL_BASE],cMoeda,LC_SOMAR)// Restaura Sld. a Emb. do Item
                     Ae107AtuSld("EEL_SLDEMB",nAux,Nil,LC_SOMAR)                             // Restaura Sld. a Emb. da L/C
                     
                     If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, restaura a quantidade a Embarcar
                        Ae107AtuSld("EXS_QTDEMB",aItens[i][LC_QTD_BASE],Nil,LC_SOMAR,aItens[i][LC_UNI_BASE])
                     EndIf
                  EndIf
               EndIf
               
            Else //Se a carta de crédito não controla produtos
      
               Ae107AtuSld("EEL_SLDVNC",aItens[i][LC_VAL_BASE],cMoeda,LC_SOMAR) //Restaura Saldo a Vincular da L/C
               If lDtEmbaBase // Se o processo já havia sido gravado com data de embarque, restaura Saldo a Embarcar
                  Ae107AtuSld("EEL_SLDEMB",aItens[i][LC_VAL_BASE],cMoeda,LC_SOMAR)
               EndIf
      
            EndIf
         
         EndIf
         
      EndIf
      
      If aItens[i][LC_FLAG] // Atualiza as vinculações de acordo com o que está na memória
         
         If !Empty(aItens[i][LC_NUM_MEMO]) // Se a L/C do item na work  estiver preenchida
            EEL->(DbSeek(xFilial()+aItens[i][LC_NUM_MEMO] ))
            If EEL->EEL_CTPROD $ cSim// Se a carta de Crédito controla produtos
               If !Empty(aItens[i][LC_SEQ_MEMO]) // e a sequência está preenchida
                  EXS->(DbSeek(xFilial()+aItens[i][LC_NUM_MEMO]+aItens[i][LC_SEQ_MEMO]))
                  
                  nAux := Ae107AtuSld("EXS_SLDVNC",aItens[i][LC_VAL_MEMO],M->EEC_MOEDA,LC_SUBTRAIR) // Atualiza Sld. a Vinc. do Item
                  Ae107AtuSld("EEL_SLDVNC",nAux,Nil,LC_SUBTRAIR)                              // Atualiza Sld. a Vinc. da L/C
                  
                  If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, atualiza a quantidade a vincular
                     Ae107AtuSld("EXS_QTDVNC",aItens[i][LC_QTD_MEMO],Nil,LC_SUBTRAIR,aItens[i][LC_UNI_MEMO]) 
                  EndIf
                  
                  If lDtEmbaMemoria // Se o processo já havia sido gravado com data de embarque
                     nAux := Ae107AtuSld("EXS_SLDEMB",aItens[i][LC_VAL_MEMO],M->EEC_MOEDA,LC_SUBTRAIR)// Atualiza Sld. a Emb. do Item
                     Ae107AtuSld("EEL_SLDEMB",nAux,Nil,LC_SUBTRAIR)                             // Atualiza Sld. a Vinc. da L/C
                     
                     If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, atualiza a quantidade a Embarcar
                        Ae107AtuSld("EXS_QTDEMB",aItens[i][LC_QTD_MEMO],Nil,LC_SUBTRAIR,aItens[i][LC_UNI_MEMO])
                     EndIf
                  EndIf
               EndIf
            
            Else //Se a carta de crédito não controla produtos
      
               Ae107AtuSld("EEL_SLDVNC",aItens[i][LC_VAL_MEMO],M->EEC_MOEDA,LC_SUBTRAIR) //Atualiza Saldo a Vincular da L/C
               If lDtEmbaMemoria // Se o processo já havia sido gravado com data de embarque, atualiza Saldo a Embarcar
                  Ae107AtuSld("EEL_SLDEMB",aItens[i][LC_VAL_MEMO],M->EEC_MOEDA,LC_SUBTRAIR)
               EndIf
      
            EndIf
            
            If EEL->EEL_RENOVA $ cNao //Se não for renovável...
               If EEL->(EEL_SLDVNC <= 0 .And. EEL_SLDEMB <= 0) //Se o saldo ficou zerado após a atualização, então a L/C fica finalizada
                  If !(EEL->EEL_FINALI $ cSim)
                     EEL->(RecLock("EEL",.f.),EEL_FINALI := "1",MsUnlock())
                  EndIf
               EndIf
            EndIf

         EndIf

      EndIf

   Next

Else

   If Empty(M->EEC_LC_NUM)    // se o campo de carta de crédito está vazio
      If !lInclui
         If !Empty(cLc_Num)   // mas anteriormente estava preenchido(alteração)
            RecLock("EEL",.f.)
            EEL->EEL_SLDVNC += Round(nTotPed * nTxEEC_EEL,nDecEEL) //retorna os saldos da L/C
            EEL->(MsUnlock())
         Endif
      EndIf
   Else
      EEL->(DbSetOrder(1))
      EEL->(DbSeek(xFilial("EEL")+M->EEC_LC_NUM))
      nTxM_EEL := EECCalcTaxa(M->EEC_MOEDA,EEL->EEL_MOEDA)

      EEC->(DbSetOrder(1))
      For i := 1 to Len(aDesvinculados) //desvincula da L/C os processos selecionados para tal
         EEC->(DbSeek(aDesvinculados[i][1]+aDesvinculados[i][2]))
         nRecEEL := EEL->(RecNo())
         If EEC->EEC_LC_NUM <> EEL->EEL_LC_NUM
            EEL->(DbSeek(EEC->(EEC_FILIAL+EEC_LC_NUM)))
         EndIf
         nTx := EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA)

         RecLock("EEL",.f.)
         EEL->EEL_SLDVNC += Round((EEC->EEC_TOTPED - AE102TotADiant(EEC->EEC_PREEMB)) * nTx,nDecEEL) //Retorna os saldos da L/C    //TRP-24/07/08  
         If !Empty(EEC->EEC_DTEMBA)
            EEL->EEL_SLDEMB += Round((EEC->EEC_TOTPED - AE102TotADiant(EEC->EEC_PREEMB)) * nTx,nDecEEL)    //TRP-24/07/08
         EndIf
         EEL->(MsUnlock())

         RecLock("EEC",.f.)
         EEC->EEC_LC_NUM := Space(AvSx3("EEC_LC_NUM",AV_TAMANHO)) // limpa o campo de L/C do pedido
         EEC->(MsUnlock())
         EEL->(DbGoTo(nRecEEL))
      Next

      RecLock("EEL", .F.)
      EEL->EEL_SLDVNC -= Round((M->EEC_TOTPED - AE102TotADiant()) * nTxM_EEL,nDecEEL)  //TRP-24/07/08
      /*
      If lDtEmbaMemoria
         EEL->EEL_SLDEMB -= Round(M->EEC_TOTPED * nTxM_EEL,nDecEEL)
      Endif
      */
      If lInclui
         If !Empty(M->EEC_DTEMBA)
            EEL->EEL_SLDEMB -= Round((M->EEC_TOTPED - AE102TotADiant())*nTxM_EEL, nDecEEL)  //TRP-24/07/08
         EndIf
      Else
         Do Case
            Case !Empty(M->EEC_DTEMBA) .and. Empty(EEC->EEC_DTEMBA)
               EEL->EEL_SLDEMB -= Round((M->EEC_TOTPED - AE102TotADiant())*nTxM_EEL, nDecEEL)  //TRP-24/07/08

            Case Empty(M->EEC_DTEMBA) .and. !Empty(EEC->EEC_DTEMBA)
               EEL->EEL_SLDEMB += Round((M->EEC_TOTPED - AE102TotADiant())*nTxM_EEL, nDecEEL)  //TRP-24/07/08
         End Case
      EndIf

      EEL->(MsUnlock())

      If !lInclui 
         //EEC->(DbSetOrder(1))
         //EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB))
         If !Empty(cLc_Num) // se for alteração de embarque já vinculado a uma L/C
            EEL->(DbSeek(xFilial("EEL")+cLc_Num))
            RecLock("EEL",.f.)
            EEL->EEL_SLDVNC += Round(nTotPed * nTxEEC_EEL,nDecEEL)
            /*
            If lDtEmbaBase
               EEL->EEL_SLDEMB += Round(nTotPed * nTxEEC_EEL,nDecEEL)
            EndIf
            */
            EEL->(MsUnlock())
         Endif
      EndIf
      
      //ER - 05/12/2007 - Finaliza a Carta de Credito quando não houver Saldo e não for do tipo Renova.
      If EECFlags("ITENS_LC")
         If !Empty(cLc_Num)
            If EEL->EEL_SLDVNC == 0 .and. EEL->EEL_RENOVA == "2"

               EEL->(RecLock("EEL",.F.))
               
               EEL->EEL_FINALI := "1"
          
               EEL->(MsUnlock())
      
            EndIf
         EndIf
      EndIf

   EndIf
   EEC->(DbGoTo(nRec))

EndIf

RestOrd(aOrd,.t.)

Return Nil

/*
Funcao     : Ae107AtuSld
Objetivo   : Atualizar saldo da L/C, tratando os campos de Saldo Negativo, por causa da tolerância
Parametros : 1 - Char - Campo da L/C a ser atualizado
             2 - Núm. - Valor a ser somado ou subtraído do parâmetro 1
             3 - Char - Moeda do Item, que será convertida para a moeda da L/C (se Nil, assume que já está convertido)
             4 - Núm. - operação (LC_SOMAR ou LC_SUBTRAIR)
             5 - Char - Unidade de Medida do Item, caso seja campo de quantidade
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 14/07/2005 às 11:40
*/
*-----------------------------------------------------------------------*
Function Ae107AtuSld(cCampo,nValor,cMoedaOrigem,nOperacao,cUnidadeOrigem)
*-----------------------------------------------------------------------*
                 //  Positivo     Negativo    Finalizado
Local aCampos := {{"EEL_SLDVNC","EEL_VNCNEG","EEL_SVFINA"},;
                  {"EEL_SLDEMB","EEL_EMBNEG","EEL_SEFINA"},;
                  {"EXS_SLDVNC","EXS_VLVING","EXS_SVFINA"},;
                  {"EXS_SLDEMB","EXS_VLEMNG","EXS_SEFINA"},;
                  {"EXS_QTDVNC","EXS_QTVING","EXS_QVFINA"},;
                  {"EXS_QTDEMB","EXS_QTEMNG","EXS_QEFINA"} }

Local nPos, cAlias, nVal, n

Begin Sequence

   If EEL->EEL_FINALI $ cSim
      n := 3
   Else
      n := 1
   EndIf
   
   If nOperacao == LC_SUBTRAIR
      nValor := -nValor
   EndIf
   /*
   (cAlias)->&(aCampos[nPos][1]) -> Campo de Saldo
   (cAlias)->&(aCampos[nPos][2]) -> Campo de Saldo Negativo
   */
   nPos := AScan(aCampos,{|x| x[1] = cCampo })
   cAlias := Left(cCampo,3)
   (cAlias)->(RecLock(cAlias,.f.))
   If !Empty(cMoedaOrigem)
      nValor := EECCalcTaxa(cMoedaOrigem,EEL->EEL_MOEDA,nValor,AvSx3(cCampo,AV_DECIMAL))
   ElseIf !Empty(cUnidadeOrigem) .And. Left(cCampo,3) == "EXS"
      nValor := Round(AvTransUnid(cUnidadeOrigem, EXS->EXS_UNIDAD, EXS->EXS_COD_I,nValor,.f.),AvSx3(cCampo,AV_DECIMAL))
   EndIf
   
   nVal   := (cAlias)->&(aCampos[nPos][n]) + nValor
   If nVal < 0
      (cAlias)->&(aCampos[nPos][n]) := 0
      (cAlias)->&(aCampos[nPos][2]) -= nVal
   Else
      If nVal > (cAlias)->&(aCampos[nPos][2])
         (cAlias)->&(aCampos[nPos][n]) := nVal - (cAlias)->&(aCampos[nPos][2])
         (cAlias)->&(aCampos[nPos][2]) := 0
      Else
         (cAlias)->&(aCampos[nPos][2]) -= nVal
         (cAlias)->&(aCampos[nPos][n]) := 0
      EndIf
   EndIf
   (cAlias)->(MsUnlock())
   
End Sequence

If nOperacao == LC_SUBTRAIR
   nValor := -nValor
EndIf

Return nValor

/*
Funcao       AE107DesLC
Objetivo   : Tela de desvinculação de carta de crédito de outros processos
Parametros :
Retorno    : lRet = .t. or .f. 
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 13/01/2005 às 15:20
*/
*-------------------*
Function AE107DesLC()
*-------------------*
//JPM - 23/12/04 - Variáveis da MsSelect de Desvinculação de Processos à Carta de Crédito
Local   aCamposLC := {}, lInverte := .f., cMarca := GetMark(), oDlgLC, lSeek, lRet := .t.,;
        bOk , bCancel , cNomArq := "", oMark, nSoma, nTxEELEEC, lOk := .f., aPosLC, oSaldo, cCarta 
//Local   cTitulo := STR0145//"Desvinculação de Processos"
Local   cTitulo := STR0018//"Desvinculação de Processos"

Local nDecEEL := AvSx3("EEL_LCVL",AV_DECIMAL)
Local nTotLCsEmb := 0, nLinBrw       
Private nSldEmb,; //Saldo a Embarcar
        nSldVnc,; //Saldo a Vincular
        nTotPed,; //Total do Pedido
        nTotPedAnt,;//Total do Pedido (vinculado à mesma LC) gravado anteriormente
        nSaldo
        
Private aCampos[0], aHeader[0],aCpos 

// JPM - 26/04/05
If Type("lReplicacao") <> "L"
   lReplicacao := .f.
EndIf

Begin Sequence

   EEL->(DbSetOrder(1))
   EEL->(DbSeek(xFilial("EEL")+M->EEC_LC_NUM))  
         
   nTotPed := (M->EEC_TOTPED - AE102TotADiant())  //TRP-24/07/08
   nTxEELEEC := EECCalcTaxa(EEL->EEL_MOEDA,M->EEC_MOEDA)
        
   nSldVnc   := Round(EEL->EEL_SLDVNC * nTxEELEEC,nDecEEL)
   nSldEmb   := Round(EEL->EEL_SLDEMB * nTxEELEEC,nDecEEL)
   EEC->(DbSetOrder(1))
   nTotPedAnt := 0
   lSeek := (EEC->(DbSeek(xFilial("EEC")+M->EEC_PREEMB)) .and. EEC->EEC_LC_NUM == M->EEC_LC_NUM)
   If lSeek
      nTotPedAnt := EECCalcTaxa(EEC->EEC_MOEDA,M->EEC_MOEDA,EEC->EEC_TOTPED,AvSx3("EEC_TOTPED",AV_DECIMAL))
      nTotPedAnt := (nTotPedAnt - AE102TotADiant())  //TRP-24/07/08
   Endif
   
   /* Qdo for replicação de embarque, deve-se considerar que a carta de crédito do processo anterior será 
      retirada do mesmo e utilizada no novo processo. */
   nReplicacao := 0
   lReplDtEmba := .f.
   If lReplicacao
      nRec := EEC->(RecNo())
      EEC->(DbSetOrder(1))
      If EEC->(DbSeek(cFilEx+M->EEC_PEDREF)) .And. M->EEC_LC_NUM == EEC->EEC_LC_NUM
         lReplDtEmba := !Empty(EEC->EEC_DTEMBA)
         nReplicacao := EECCalcTaxa(EEC->EEC_MOEDA,M->EEC_MOEDA,EEC->EEC_TOTPED,AvSx3("EEC_TOTPED",AV_DECIMAL))
      EndIf
      EEC->(DbGoTo(nRec)) 
   EndIf
   
   If nTotPed > nSldVnc + nTotPedAnt + nReplicacao .And. If(!Empty(M->EEC_DTEMBA),lValLC,.T.) //!@lValLC .AND. !Empty(M->EEC_DTEMBA)//LGS-04/07/2014
     
   /* If nTotPed > nSldEmb + If(lSeek,nTotPedAnt,0) + If(lReplDtEmba,nReplicacao,0)
         MsgInfo(STR0019,STR0025)//"A Carta de Crédito não possui saldo suficiente para este Embarque.","Aviso"
         lRet := .f.
         Break
      EndIf */ 
      
      If !MsgYesNo(STR0020,STR0025) //"O saldo da Carta de Crédito é insuficiente, porém você poderá desvinculá-la de outros Embarques na tela seguinte. Deseja prosseguir?","Aviso"
         lRet := .f.
         Break
      EndIf 
               
      aCamposLC := { {"WK_OK"    ,"C",2,0},;
                     {"WK_PEDIDO","C",AvSx3("EEC_PREEMB",AV_TAMANHO),0},;
                     {"WK_TOTPED","N",AvSx3("EEC_TOTPED",AV_TAMANHO),AvSx3("EEC_TOTPED",AV_DECIMAL) } }
                  
      cNomArq := E_CriaTrab(,aCamposLC,"WKLC")
      
      nRec := EEC->(RecNo())
      EEC->(DbSetOrder(3))
      EEC->(DbSeek(xFilial("EEC")+M->EEC_LC_NUM))
      While EEC->(!EoF()) .And. xFilial("EEC") == EEC->EEC_FILIAL .And. M->EEC_LC_NUM == EEC->EEC_LC_NUM
         If M->EEC_PREEMB <> EEC->EEC_PREEMB .And. Empty(EEC->EEC_DTEMBA)
            WKLC->(DbAppend())
            WKLC->WK_OK     := ""
            WKLC->WK_PEDIDO := EEC->EEC_PREEMB
            WKLC->WK_TOTPED := EECCalcTaxa(EEC->EEC_MOEDA,M->EEC_MOEDA,EEC->EEC_TOTPED,nDecEEL) - AE102TotADiant(EEC->EEC_PREEMB)
            nTotLCsEmb += WKLC->WK_TOTPED
         EndIf 
         EEC->(DbSkip())
      EndDo     
      WKLC->(DbGoTop())
      
      nSaldo  := nSldVnc + nTotPedAnt

      If nTotPed > ( nSaldo + nTotLCsEmb )
         MsgInfo(STR0019,STR0025)//"A Carta de Crédito não possui saldo suficiente para este Embarque.","Aviso"
         lRet := .f.
         Break
      Else  

         bOk     := { || If(AE107ValLC(),(oDlgLC:End(),lOk := .t.,lRet := .t.) , ) } 
         bCancel := { || lRet := .f., oDlgLC:End(), lOk := .f. }
         //nSaldo  := nSldVnc + nTotPedAnt
           
         aCpos   := {  { "WK_OK","",""},;          
                       { {||WKLC->WK_PEDIDO},"",STR0026},;//"Embarque"
                       { {||AllTrim(Transf(WKLC->WK_TOTPED,AvSx3("EEC_TOTPED",AV_PICTURE) ) ) },"",STR0021 + M->EEC_MOEDA} }//"Total do Embarque "
         lRet := .f. 
         cCarta := M->EEC_LC_NUM
         nLinBrw := 2
         DEFINE MSDIALOG oDlgLC TITLE cTitulo FROM 1,1 To /*300,415*/ 500,900 OF oMainWnd Pixel

            oPanel:= TPanel():New(0, 0, "", oDlgLC ,, .F., .F.,,,1,1)
            oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

            @ nLinBrw,2 to nLinBrw+32,206 PIXEL of oPanel//oDlgLC
        
            @ nLinBrw+7,007 Say AvSx3("EEL_LC_NUM",AV_TITULO) Size 80,07 Pixel Of oPanel//oDlgLC 
            @ nLinBrw+5,35  MsGet cCarta PICTURE AVSX3("EEL_LC_NUM",AV_PICTURE) Size 080,07 Pixel Of oPanel/*oDlgLC*/ When .f.

            @ nLinBrw+20,007 Say STR0022+AllTrim(M->EEC_MOEDA) Size 80,07 Pixel Of oPanel//oDlgLC
            @ nLinBrw+20,93  Say STR0023+AllTrim(M->EEC_MOEDA) Size 80,07 Pixel Of oPanel//oDlgLC

            @ nLinBrw+18,35  MsGet oSaldo Var nSaldo Picture AvSx3("EEC_TOTPED",AV_PICTURE) Size 050,07  Pixel Of oPanel/*oDlgLC*/ When .f.
            @ nLinBrw+18,150 MsGet nTotPed Picture AvSx3("EEC_TOTPED",AV_PICTURE) Size 050,07  Pixel Of oPanel/*oDlgLC*/ When .f.
               
            @ nLinBrw+36,007 Say STR0024 + AllTrim(cCarta) Size 160,07 Pixel Of oPanel//oDlg//"Processos vinculados à L/C No. "
            @ nLinBrw+32,2 to nLinBrw+45,206 Pixel of oPanel//oDlg
         
            aPosLC := PosDlgDown(oPanel/*oDlgLC*/)
            aPosLC[1] := nLinBrw+77
            aPosLC[2] += 1 
            aPosLC[3] += 1
            oMark := MsSelect():New("WKLC","WK_OK",,aCpos,@lInverte,@cMarca,aPosLC)

            oMark:bAval := {|| AE107Marca(cMarca), oMark:oBrowse:Refresh(), oSaldo:Refresh() }   
               
         Activate MsDialog oDlgLC ON INIT EnchoiceBar(oDlgLC,bOk,bCancel,,) Centered   

         aDesvinculados := {}
         If lOk 
            WKLC->(DbGoTop())
            
            While WKLC->(!EoF())
               If !Empty(WKLC->WK_OK)
                  AAdd(aDesvinculados,{xFilial("EEC"),WKLC->WK_PEDIDO})
               Endif
               WKLC->(DbSkip())
            EndDo
         EndIf
      EndIf

      WKLC->(E_EraseArq(cNomArq))

      If !lOk
         Break
      Endif
            
      EEC->(DbGoTo(nRec))
   EndIf
   
End Sequence

Return lRet        

/*
Funcao      : AE107ValLC()
Parametros  : 
Retorno     : .T./.F.
Objetivos   : Validar se os Embarques desvinculados foram suficientes para conseguir o saldo necessario 
              para vinculação do embarque atual
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 23/12/04 10:47
Revisao     : 
Obs.        :
*/
*--------------------------*
Static Function AE107ValLC()
*--------------------------*
   Local lRet := .t.    
   Begin Sequence
      
      If nTotPed > nSaldo
         MsgStop(STR0027,STR0025)//"Faça a desvinculacao de mais processos. O saldo ainda é insuficiente.","Aviso"
         lRet := .f.
      EndIf
      
   End Sequence
Return lRet    

/*
Funcao      : AE107Marca()
Parametros  : 
Retorno     : Nil
Objetivos   : atualizacao do saldo quando marca/desmarca um embarque para desvinculação
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 23/12/04 10:47
Revisao     : 
Obs.        :
*/
*--------------------------------*
Static Function AE107Marca(cMarca)
*--------------------------------*

   Begin Sequence
      
      If !Empty(WKLC->WK_OK)
         nSaldo -= WKLC->WK_TOTPED
         WKLC->WK_OK := ""
      Else
         nSaldo += WKLC->WK_TOTPED
         WKLC->WK_OK := cMarca
      EndIf
      
   End Sequence
Return Nil

/*
Funcao     : AE107DelLC
Objetivo   : Atualização do saldo da L/C no Cancelamento / Eliminação do embarque
Parametros : Nenhum
Retorno    : Nil 
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 14/01/2005 às 10:46
*/
*-------------------*
Function AE107DelLC()
*-------------------*
Local aOrd := SaveOrd({"EEC","EE9"})
Local nDecEEL := AvSx3("EEL_LCVL",AV_DECIMAL)
Local nTxEEC_EEL
Local cMoeda := EEC->EEC_MOEDA

Begin Sequence

   EEL->(DbSetOrder(1))
   
   If EECFlags("ITENS_LC")
      EE9->(DbSetOrder(2))
      EE9->(DbSeek(xFilial()+EEC->EEC_PREEMB))

      While EE9->(!EoF()) .And. EE9->(EE9_FILIAL+EE9_PREEMB) == (xFilial("EE9")+EEC->EEC_PREEMB)
      
         If !Empty(EE9->EE9_LC_NUM) // Se a L/C para este item estava preenchida
         
            EEL->(DbSeek(xFilial()+EE9->EE9_LC_NUM ))
            If EEL->EEL_CTPROD $ cSim  .And. !Empty(EE9->EE9_SEQ_LC)// Se a carta de Crédito controla produtos e a sequência está preenchida
               EXS->(DbSeek(xFilial() + EE9->( EE9_LC_NUM+EE9_SEQ_LC ) ) )
               
               nAux := Ae107AtuSld("EXS_SLDVNC",Ae107CalcTot(),cMoeda,LC_SOMAR) // Restaura Sld. a Vinc. do Item
               Ae107AtuSld("EEL_SLDVNC",nAux,Nil,LC_SOMAR)                      // Restaura Sld. a Vinc. da L/C
               
               If EXS->EXS_CTRQTD $ cSim // se o item controla quantidade, restaura a quantidade a vincular
                  Ae107AtuSld("EXS_QTDVNC",EE9->EE9_SLDINI,Nil,LC_SOMAR,EE9->EE9_UNIDAD) 
               EndIf  
               RecLock("EE9",.f.) // By JPP - 08/09/2005 -10:30 - Limpar os dados da carta de crédito dos itens.
               EE9->EE9_LC_NUM := "" 
               EE9->EE9_SEQ_LC := ""
               EE9->(MsUnlock())
            Else //Se a carta de crédito não controla produtos
      
               Ae107AtuSld("EEL_SLDVNC",Ae107CalcTot(),cMoeda,LC_SOMAR) //Restaura Saldo a Vincular da L/C
               RecLock("EE9",.f.) // By JPP - 08/09/2005 -10:30 - Limpar os dados da carta de crédito dos itens.
               EE9->EE9_LC_NUM := "" 
               EE9->(MsUnlock())
            EndIf
   
         EndIf
         
         EE9->(DbSkip())
         
      EndDo

   Else
   
      If EEL->(DbSeek(xFilial("EEL")+EEC->EEC_LC_NUM))
         nTxEEC_EEL := EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA)
         RecLock("EEL",.f.)
         EEL->EEL_SLDVNC += Round((EEC->EEC_TOTPED - AE102TotADiant()) * nTxEEC_EEL,nDecEEL)  //TRP-24/07/08
         EEL->(MsUnlock())
         EEC->EEC_LC_NUM := Space(AvSx3("EEC_LC_NUM",AV_TAMANHO))
      EndIf

   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return Nil

/*
Funcao     : Ae107AtuProcs()
Objetivo   : Executar tratamentos específicos na Replicação de Dados, para a Carta de Crédito
Parametros : nTipo : 1 - 1ª parte - gravar em um array os dados gravados antes das replicação, especificamente 
                                    aqueles que são utilizados na atualização da Carta de Crédito
                     2 - 2ª parte - preparar variáveis para chamada da função Ae107AtuLC que atualizará a carta de 
                                    crédito.
Retorno    : Nil 
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 27/04/2005 às 13:45
*/
*---------------------------*
Function Ae107AtuProcs(nTipo)
*---------------------------*

Local i, nRec := EEC->(RecNo()), nOrd := EEC->(IndexOrd())

Begin Sequence
   
   EEC->(DbSetOrder(1))
   If nTipo == 1 // Antes das Replicações
      WK_MAIN->(DbGoTop())
      While WK_MAIN->(!EoF())
         // ** Carta de Crédito
         If WK_MAIN->(WK_FASE == OC_EM .And. !Empty(WK_MARCA))
            If WK_MAIN->WK_CAMPO == "EE7_LC_NUM"
               EEC->(DbSeek(WK_MAIN->(WK_FILIAL+WK_PROC)))
               AAdd(aAtuLC,{WK_MAIN->WK_FILIAL,;
                            WK_MAIN->WK_PROC,;
                            EEC->EEC_DTEMBA,; //     \
                            EEC->EEC_LC_NUM,; // _ _ _\ Dados antes da gravação
                            EEC->EEC_MOEDA,;  //      / das replicações 
                            EEC->EEC_TOTPED}) //     /
         
            EndIf
            //If WK_MAIN->WK_CAMPO == "EE7_LC_NUM"...
            
            
         EndIf
         
         // ** Porto de Destino
         If !Empty(WK_MAIN->WK_MARCA)
            If WK_MAIN->(SubStr(WK_CAMPO,1,8) == "EE7_DEST" .And. WK_FASE == OC_EM)
               EEC->(DbSeek(WK_MAIN->(WK_FILIAL+WK_PROC)))
               AAdd(aAtuManual,{"EE7_DEST",;
                                WK_MAIN->WK_FILIAL,;
                                WK_MAIN->WK_PROC,;
                                EEC->EEC_DEST  })
            EndIf
         
         EndIf
         WK_MAIN->(DbSkip())
      EndDo
   
   ElseIf nTipo == 2 // Após as Replicações
      // ** Carta de Crédito
      For i := 1 to Len(aAtuLC)
         EEC->(DbSeek(aAtuLC[i][1]+aAtuLC[i][2]))
         // Prepara as variáveis para chamar a função que atualiza os saldos da L/C
         Private dDtEmba := aAtuLC[i][3]
         Private cLc_Num := aAtuLC[i][4]
         Private cMoeda  := aAtuLC[i][5]
         Private nTotPed := aAtuLC[i][6]
         
         nTotPed:= (nTotPed - AE102TotADiant())  //TRP-24/07/08 
         M->EEC_DTEMBA := EEC->EEC_DTEMBA
         M->EEC_PREEMB := EEC->EEC_PREEMB
         M->EEC_LC_NUM := EEC->EEC_LC_NUM
         M->EEC_MOEDA  := EEC->EEC_MOEDA
         M->EEC_TOTPED := EEC->EEC_TOTPED
         
         If !Ae107ValAtu()
            //Se não passar pelas validações de saldo, retorna o nº anterior da carta de crédito.
            EEC->(RecLock("EEC",.f.))
            EEC->EEC_LC_NUM := aAtuLC[i][4]
            EEC->(MsUnlock())
         Else
            //Se tiver saldo suficiente, então o saldo da L/C é atualizado.
            Ae107AtuLC(.f.,.t.)
         EndIf
         
      Next
      EEC->(DbSetOrder(1))
      SYR->(DbSetOrder(1))
      
      // ** Atualizações Genéricas
      For i := 1 to Len(aAtuManual)
         EEC->(DbSeek(aAtuManual[i][2]+aAtuManual[i][3]))
         If aAtuManual[i][1] == "EE7_DEST"
            If aAtuManual[i][4] <> EEC->EEC_DEST
               SYR->(DbSeek(xFilial("SYR")+EEC->(EEC_VIA+EEC_ORIGEM+EEC_DEST+EEC_TIPTRA)))
               EE1->(DbSetOrder(1))
               If !EE1->(DbSeek(xFilial("EE1")+"I"+SYR->YR_PAIS_DE+AvKey(EEC->EEC_INSCOD,"EE1_DOCUM")))
                  If EE1->(DbSeek(xFilial("EE1")+"I"+SYR->YR_PAIS_DE))
                     EEC->(RecLock("EEC",.f.))
                     EEC->EEC_INSCOD := EE1->EE1_DOCUM
                     EEC->(MsUnlock())
                  EndIf
               EndIf
            EndIf
         EndIf
      Next
      
   EndIf
   
End Sequence

EEC->(DbSetOrder(nOrd))
EEC->(DbGoTo(nRec))

Return Nil
         
/*
Funcao     : Ae107ValAtu()
Objetivo   : Valida a replicação da carta de crédito, verificando se esta possui saldo suficiente para comportar
             o Total do embarque de destino, mesmo após as replicações.
Parametros : Nenhum
Retorno    : Nil 
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 28/04/2005 às 11:27
*/
*--------------------*
Function Ae107ValAtu()
*--------------------*
Local lRet := .t.

Begin Sequence

   If !Empty(M->EEC_LC_NUM) .and. lNRotinaLC
               
      nTotPedAnt := 0
      If cLc_Num == M->EEC_LC_NUM .And. !Empty(dDtEmba)
         nTotPedAnt := nTotPed
      EndIf
                  
      EEL->(DbSetOrder(1))   
      EEL->(DbSeek(xFilial("EEL")+M->EEC_LC_NUM))
               
      nTaxa1 := 1 
      nTaxa2 := 1            
               
      nSldLC := EEL->EEL_SLDVNC 
      If nTotPedAnt <> 0
         nSldLC += nTotPedAnt * If(cMoeda <> "R$ ",BuscaTaxa(cMoeda,dDataBase),1) ;
                                / ;
                                If(EEL->EEL_MOEDA <> "R$ ",BuscaTaxa(EEL->EEL_MOEDA,dDataBase),1)
      EndIf
      
      nTotPed := (M->EEC_TOTPED - AE102TotADiant())  //TRP-24/07/08
               
      If EEL->EEL_MOEDA <> M->EEC_MOEDA
         If EEL->EEL_MOEDA <> "R$ " 
            nTaxa1 := BuscaTaxa(EEL->EEL_MOEDA,dDataBase)
         Endif
         If M->EEC_MOEDA <> "R$ " 
            nTaxa2 := BuscaTaxa(M->EEC_MOEDA,dDataBase)
         Endif
         If cMoeda <> "R$ " .And. nTotPedAnt <> 0
            nTotPedAnt := Round(nTotPedAnt * BuscaTaxa(cMoeda,dDataBase),2)
         EndIf
         nSldLCReais := Round(EEL->EEL_SLDVNC * nTaxa1,2) + nTotPedAnt
         nTotPedReais := Round((M->EEC_TOTPED - AE102TotADiant()) * nTaxa2,2)  //TRP-24/07/08
      EndIf
               
      If EEL->EEL_MOEDA <> M->EEC_MOEDA
         lRet := (nSldLCReais >= nTotPedReais)
      Else
         lRet := (nSldLC >= nTotPed)
      EndIf 
      
      If !lRet
         cMsg := STR0031 + AllTrim(M->EEC_LC_NUM) + STR0032 + AllTrim(M->EEC_PREEMB)
                 //"A L/C " ## " nao sera atualizada no embarque "
         
         cMsg += STR0033 +AllTrim(M->EEC_MOEDA)+" "
                 //", pois o saldo da mesma nao é suficiente. Saldo Necessário: " ##
         
         cMsg += AllTrim(Transf(nTotPed,AvSx3("EEC_TOTPED",AV_PICTURE)))
         If M->EEC_MOEDA <> "R$ " .And. EEL->EEL_MOEDA <> M->EEC_MOEDA
            cMsg += " (R$ "+ AllTrim(Transf(nTotPedReais,AvSx3("EEC_TOTPED",AV_PICTURE)))+")"
         EndIf
         cMsg += STR0034 + AllTrim(EEL->EEL_MOEDA)+" "
                 //". Saldo da L/C: " ##
         
         cMsg += AllTrim(Transf(nSldLC,AvSx3("EEL_SLDVNC",AV_PICTURE)))
         If EEL->EEL_MOEDA <> "R$ " .And. EEL->EEL_MOEDA <> M->EEC_MOEDA
            cMsg += " (R$ " + AllTrim(Transf(nSldLCReais,AvSx3("EEL_SLDVNC",AV_PICTURE)))+")"
         EndIf
         cMsg += "."
                                    
         MsgStop(cMsg,STR0017)//"Atencao"
         
      EndIf
               
   EndIf
               
End Sequence
              
Return lRet

/*
Funcao     : Ae107AtuIt()
Objetivo   : Atualiza WorkIt quando preenchido o Nro. da carta de crédito no pedido
Parametros : Nenhum
Retorno    : Nil 
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 08/07/2005 às 12:09
*/
*-------------------*
Function Ae107AtuIt()
*-------------------*
Local lRet := .t.
Local nSaldoAEmb, nTotalAEmb

Private aItens := {}, aItensLC := {}, aVinculados := {}, lTemContQtd

Begin Sequence

   If EEL->EEL_CTPROD $ cNao .Or. Empty(M->EE7_LC_NUM)// só vincula aos itens
      WorkIt->(DbGoTop())
      While WorkIt->(!EoF())
         WorkIt->EE8_LC_NUM := EEL->EEL_LC_NUM
         WorkIt->EE8_SEQ_LC := CriaVar("EE8_SEQ_LC")
         WorkIt->(DbSkip())
      EndDo
      Break
   EndIf
   
   EE9->(DbSetOrder(1))
   EXS->(DbSetOrder(1))   
   WorkIt->(DbGoTop())
   While WorkIt->(!Eof())
      nSaldoAEmb := 0
      nTotalAEmb := 0

      CalculaSaldos(,@nSaldoAEmb,@nTotalAEmb)
   
      // converte o valor dos itens para a moeda da carta de crédito.
      nTotalAEmb := EECCalcTaxa(M->EE7_MOEDA,EEL->EEL_MOEDA,nTotalAEmb,AvSx3("EXS_SLDEMB",AV_DECIMAL))
   
      AAdd(aItens, { WorkIt->(RecNo()), nTotalAEmb, nSaldoAEmb , .f., WorkIt->EE8_COD_I, WorkIt->EE8_PRECO,WorkIt->EE8_UNIDAD} )
      /* aItens por posição - [i][1] - RecNo na WorkIt
                              [i][2] - Preço total do item
                              [i][3] - Quantidade total do item
                              [i][4] - Define se já foi vinculado (.t. = vinculado)
                              [i][5] - Código do Produto
                              [i][6] - Preço do Item
                              [i][7] - Unidade de Medida da Quantidade
      */
      WorkIt->(DbSkip())
   EndDo
   
   lTemContQtd := .f. //Define se algum item possui controle de quantidade.
   EXS->(DbSeek(xFilial("EXS")+M->EE7_LC_NUM))
   While EXS->(!EoF()) .And. EXS->(EXS_FILIAL+EXS_LC_NUM) == xFilial("EXS")+M->EE7_LC_NUM
      EXS->(AAdd(aItensLC,{EXS_SEQUEN,ValTolera(.t.,.f.),ValTolera(.f.,.f.),;
                           If(EXS_CTRQTD $ cSim, .t., .f.), EXS_COD_I, EXS_PRECO, EXS_UNIDAD } ) )
      /* aItensLC por posição - [j][1] - Sequência do Item da L/C
                                [j][2] - Saldo a Embarcar do Valor
                                [j][3] - Saldo a Embarcar da quantidade
                                [j][4] - Define se controla quantidade
                                [j][5] - Código do Produto
                                [j][6] - Preço do Item
                                [j][7] - Unidade de Medida da Quantidade
                                
      */
      If !lTemContQtd .And. EXS->EXS_CTRQTD $ cSim
         lTemContQtd := .t.
      EndIf
      EXS->(DbSkip())
   EndDo

   Processa( {|| lRet := AlocaItens() })

   If !lRet .And. Len(aVinculados) > 0
      nTot := Len(aItens) - Len(aVinculados)
      nOp := 3
      While nOp == 3
         nOp := Aviso( STR0061, AllTrim(Str(nTot)) + STR0062, {STR0063,STR0064,STR0065}, 2 ) //"Vinculação Inteligente" # " itens não puderam ser vinculados. Deseja que os itens vinculados com sucesso permaneçam desta maneira? Para maiores detalhes, clique em 'Itens'." # "Sim" # "Não" # "Itens"
         If nOp == 3
            VinculaItens(.f.,OC_PE)
         EndIf
      EndDo
      If nOp == 1
         lRet := .t.
      ElseIf nOp == 2
         Break
      EndIf
   EndIf

   VinculaItens(lRet,OC_PE)
   
End Sequence

Return lRet

/*
Função     : TransfHora()
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 04/08/05 - 15:35
Objetivo   : Transformar os segundos em formato hh:mm:ss
Parâmetro  : nSec - Segundos
Retorno    : Tempo no formato hh:mm:ss
*/
*------------------------------*
Static Function TransfHora(nSec)
*------------------------------*
Local cRet := "", nMin := 0, nHour := 0

Begin Sequence
   
   If nSec >= 60 
      nMin := (nSec - (nSec % 60)) / 60 
      nSec -= nMin * 60
   Else
      Break
   EndIf
        
   If nMin >= 60 
      nHour := (nMin - (nMin % 60)) / 60
      nMin -= nHour * 60
   EndIf
   
End Sequence

cRet += AllTrim(Str(nHour,,0)) + ":"
cRet += AllTrim(StrZero(nMin,2)) + ":"
cRet += AllTrim(StrZero(nSec,2))

Return cRet

/*
Funcao     : AlocaItens()
Objetivo   : Alocar Itens do Pedido/Embarque com Itens da L/C da melhor forma
Parametros : Nenhum
Retorno    : lRet := define se a alocação foi efetuada com sucesso
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 13/07/2005 às 14:26
*/
*--------------------------*
Static Function AlocaItens()
*--------------------------*
Local lRet := .t., nPesoMaior, i, j, lExit, nQtd := 0
Local n := 1
Local nTot := Len(aItens)
Local nSec, nSecTot := 0, nLen, nEstim := 0
Local nDec
Private aIdeal, aIdeais := {0,0,{}}

Begin Sequence
   
   nDec := Eval( {|x,y| If(x < y,x,y) } , AvSx3("EXS_PRECO",AV_DECIMAL),AvSx3("EE8_PRECO",AV_DECIMAL) )
   
   nLen := Len(aItens)
   ProcRegua(nLen)

   nSec := Seconds()

   While n <= nLen
      n++
      
      nSecTot := Seconds() - nSec
      nEstim  := ((nSecTot*(nLen))/(n-1))
      
      IncProc(AllTrim(Str((n/nTot)*100,,0))+STR0066 + TransfHora(nEstim-nSecTot) + "." )//"% Concluído. Tempo Estimado: "

      aIdeal := {0,0,.f.}
      nPesoMaior := 0
      lExit := .f.
      For i := 1 To Len(aItens)

         If aItens[i][4] //Se já foi vinculado, não trata mais.
            Loop
         EndIf
         
         For j := 1 To Len(aItensLC)
            
            // Se o código do item da L/C for diferente do código do item do pedido
            If aItens[i][5] <> aItensLC[j][5]
               Loop
            EndIf
            
            // Só vincula se tiver preços iguais
            
            If Round(aItens[i][6],nDec) <> Round(aItensLC[j][6],nDec)
               Loop
            EndIf
            
            If aItensLC[j][4] //Se controla quantidade...
               nQtd := Round(AvTransUnid(aItens[i][7], aItensLC[j][7], aItensLC[j][5],aItens[i][3],.f.),AvSx3("EXS_QTDEMB",AV_DECIMAL))
            EndIf
            
            // Se o valor ou quantidade do item do pedido for maior que o valor ou quantidade do item da L/C, é desconsiderado
            If aItens[i][2] > aItensLC[j][2] .Or. (aItensLC[j][4] .And. nQtd > aItensLC[j][3])
               Loop
            EndIf
            
            // Os pares (item ped. - item L/C) de maior peso tem mais chance de serem vinculados
            If aItensLC[j][4] //Se controla quantidade, a quantidade é considerada no peso
               nPeso := (aItens[i][2] / aItensLC[j][2]) + (nQtd / aItensLC[j][3])
            Else // se não controla quantidade, somente o valor total é considerado
               nPeso := 2 * (aItens[i][2] / aItensLC[j][2])
            EndIf
            
            /* se o peso atual for maior que o já calculado de outro par ou se for igual, e o atual controlar qtde., 
               e o já calculado não controlar, então este passa a ser o par ideal */
            If nPeso > nPesoMaior .Or. (nPeso = nPesoMaior .And. aItensLC[j][4] .And. !aIdeal[3])
               nPesoMaior := nPeso
               aIdeal := {i,j,aItensLc[j][4]}
            EndIf
            
            //Se o peso for o máximo e controlar quantidade, a busca foi finalizada
            If nPeso == 2 .And. (!lTemContQtd .Or. aItensLC[j][4])
               lExit := .t.
               Exit
            EndIf
         Next
         
         If lExit
            Exit
         EndIf
      Next
      
      If aIdeal[1] > 0
         i := aIdeal[1]
         j := aIdeal[2]
         AAdd(aVinculados, {i,j} )
         // Abate o saldo de valor
         aItensLC[j][2] -= aItens[i][2]
         // Abate o saldo de quantidade
         If aItensLC[j][4]
            aItensLC[j][3] -= Round(AvTransUnid(aItens[i][7], aItensLC[j][7], aItensLC[j][5],aItens[i][3],.f.),;
                                    AvSx3("EXS_QTDEMB",AV_DECIMAL))
         EndIf
         aItens[i][4] := .t. // Seta flag de "vinculado"
      Else
         lRet := .f. //Se não conseguiu vincular, já retorna false pra dar mensagem.
         Exit
      EndIf
      
   EndDo
   
End Sequence

Return lRet

/*
Funcao     : VinculaItens()
Objetivo   : Vincular itens aos itens da carta de crédito ou dar mensagem de que não foi possível vincular
Parametros : cFase (pedido ou embarque
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 13/07/2005 às 14:41
*/
*--------------------------------------*
Static Function VinculaItens(lRet,cFase)
*--------------------------------------*

Local k, i, j, cMsg := ""
Local cAliasIt := If(cFase == OC_PE, "WorkIt", "WorkIp")
Local cAlias   := If(cFase == OC_PE, "EE8", "EE9")
Local cSequen  := If(cFase == OC_PE, "EE8_SEQUEN", "EE9_SEQEMB")
Local bTot, lDesc := EasyGParam('MV_AVG0085',,.f.)
//ER - 06/09/2007 - Define se o Desconto será subtraído(.T.) ou somado(.F.) no Valor Fob, quando o preço for fechado.
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.) 

Begin Sequence

   If lRet
      // Faz efetivamente a vinculação dos itens
      For k := 1 to Len(aVinculados)
         i := aVinculados[k][1]
         j := aVinculados[k][2]
         (cAliasIt)->(DbGoTo(aItens[i][1]))
         (cAliasIt)->&(cAlias+"_LC_NUM") := If(cFase == OC_PE, M->EE7_LC_NUM, M->EEC_LC_NUM)
         (cAliasIt)->&(cAlias+"_SEQ_LC") := aItensLC[j][1]
      Next
   Else   
      //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
      If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. EEC->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc  
         bTot := {|| If(cFase == OC_PE,WorkIt->(EE8_SLDATU*(EE8_PRCUN-If(lDesc,(EE8_VLDESC/EE8_SLDINI),0)) ) ,;
                                       WorkIp->(EE9_PRCTOT-If(lDesc,(EE9_VLDESC/EE9_SLDINI),0) ) )}
      Else
         bTot := {|| If(cFase == OC_PE,WorkIt->(EE8_SLDATU*(EE8_PRCUN+If(lDesc,(EE8_VLDESC/EE8_SLDINI),0)) ) ,;
                                       WorkIp->(EE9_PRCTOT+If(lDesc,(EE9_VLDESC/EE9_SLDINI),0) ) )}
      EndIf
      
      cMsg += STR0035 + ENTER //"Os seguintes itens do processo não puderam ser vinculados:"
      cMsg += IncSpace(STR0036,11,.f.) +; //"Sequência"
              IncSpace(STR0038,AvSx3(cAlias+"_COD_I" ,AV_TAMANHO)+2,.f.) +; //"Código"
              IncSpace(STR0037,22,.f.) + ;//"Descrição"
              IncSpace(AvSx3(cAlias+"_SLDINI",AV_TITULO),Int(AvSx3(cAlias+"_SLDINI",AV_TAMANHO)*(1.3)+2),.t.) + ;
              IncSpace(AvSx3(cAlias+"_PRECO" ,AV_TITULO),Int(AvSx3(cAlias+"_PRECO" ,AV_TAMANHO)*(1.3)+2),.t.) + ;
              IncSpace(AvSx3(cAlias+"_PRCTOT",AV_TITULO),Int(AvSx3(cAlias+"_PRCTOT",AV_TAMANHO)*(1.3)+2),.t.) + ENTER
              
               
      cMsg += Repl("-",9) + Space(2) +;
              Repl("-",AvSx3(cAlias+"_COD_I" ,AV_TAMANHO)) + Space(2) +;
              Repl("-",20) + Space(4) + ;
              Repl("-",Int(AvSx3(cAlias+"_SLDINI",AV_TAMANHO)*(1.3))) + Space(2) + ;
              Repl("-",Int(AvSx3(cAlias+"_PRECO" ,AV_TAMANHO)*(1.3))) + Space(2) + ;
              Repl("-",Int(AvSx3(cAlias+"_PRCTOT",AV_TAMANHO)*(1.3))) + ENTER
              
      For k := 1 to Len(aItens)
         
         If (AScan(aVinculados,{|x| x[1] == k }) = 0) // Se o item não foi vinculado, adiciona na String de msg
            (cAliasIt)->(DbGoTo(aItens[k][1]))
            cMsg += (cAliasIt)->(IncSpace(&(cSequen),9,.t.) + Space(2) + ;
                                 &(cAlias+"_COD_I") + Space(2) + ;
                                 MemoLine(&(cAlias+"_VM_DES"),20,1) + Space(2) + ;
                                 IncSpace(Transf(&(cAlias+"_SLDINI"), AvSx3(cAlias+"_SLDINI",AV_PICTURE)),Int(AvSx3(cAlias+"_SLDINI",AV_TAMANHO)*(1.3)+2),.t.) + ;
                                 IncSpace(Transf(&(cAlias+"_PRECO" ), AvSx3(cAlias+"_PRECO" ,AV_PICTURE)),Int(AvSx3(cAlias+"_PRECO" ,AV_TAMANHO)*(1.3)+2),.t.) + ;
                                 IncSpace(Transf(Eval(bTot)         , AvSx3(cAlias+"_PRCTOT",AV_PICTURE)),Int(AvSx3(cAlias+"_PRCTOT",AV_TAMANHO)*(1.3)+2),.t.) + ;
                                 ENTER)
         EndIf
         
      Next
      
      cMsg += ENTER + STR0039 //"Motivo: Os itens não puderam ser alocados nos itens da Carta de Crédito, por falta de saldo e/ou de itens correspondentes."
      EECView(cMsg,STR0025) //##, "Aviso"
      
   EndIf

End Sequence

Return Nil

/*
Funcao     : CalculaSaldos()
Objetivo   : Calcular saldo a embarcar do item posicionado (WorkIt) (Pedido)
Parametros : 1 - Alias do item do pedido (Memória, work ou tabela)
             2 - variável que armazenará a quantidade 
             3 - variável que armazenará o valor total
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 14/07/2005 às 16:51
Obs.       : Os parâmetros 2 e 3 devem ser passados por referência, para poderem ser editados pela função.(Ex: CalculaSaldos("WorkIt",@Saldo,@Valor) )
*/
*--------------------------------------------------------*
Static Function CalculaSaldos(cWork,nSaldoAEmb,nTotalAEmb)
*--------------------------------------------------------*
Local nVlDesc
Local aOrd := SaveOrd({"EE7"})

Default cWork := "WorkIt"
Private lDesc := EasyGParam('MV_AVG0085',,.f.)

Begin Sequence

   If cWork = "EE8"
      EE7->(DbSetOrder(1))
      EE7->(DbSeek(EE8->(EE8_FILIAL+EE8_PEDIDO)))
   EndIf
   
   nSaldoAEmb  := &(cWork+"->EE8_SLDATU")

   //Se o MV_AVG0085 está ligado, o desconto não está sendo incluído no preço do item
   If cWork = "EE8" .And. EE8->(FieldPos("EE8_PRCUN")) = 0 .And. EE8->(FieldPos("EE8_VLDESC")) = 0
      
      If lDesc
         //FJH 07/02/06 - Desconto por itens
         If EasyGParam("MV_AVG0119",,.F.) .and. EE8->(FieldPos("EE8_DESCON")) > 0
            nVlDesc := WorkIt->EE8_DESCON
         Else
            nVlDesc := (EE8->EE8_PRCTOT / EE7->(EE7_TOTPED+EE7_DESCON)) * EE7->EE7_DESCON
            nVlDesc := nVlDesc/EE8_SLDINI
         Endif
      Else
         nVlDesc := 0
      EndIf
                                                                         
      //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
      If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. EEC->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc      
         nTotalAEmb := nSaldoAEmb * EE8->((EE8_PRCTOT/EE8_SLDINI)+nVlDesc )
      Else
         nTotalAEmb := nSaldoAEmb * EE8->((EE8_PRCTOT/EE8_SLDINI)-nVlDesc )
      EndIf
   Else
      nTotalAEmb := nSaldoAEmb * &(cWork+"->(EE8_PRCUN-If(lDesc,EE8_VLDESC/EE8_SLDINI,0) )")
   EndIf
   
End Sequence

RestOrd(aOrd)

Return Nil
      
/*
Funcao     : ValTolera()
Objetivo   : Retornar valor do saldo com a tolerância do EEL ou EXS já posicionado
Parametros : 1 - lógico - se .t. pega o valor, se .f. pega a quantidade
             2 - lógico - se .t. pega o saldo a vincular, senão pega o a embarcar
             3 - lógico - se .t. pega o valor do EEL, senão pega do EXS
Retorno    : Valor do saldo especificado + tolerância
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 13/07/2005 às 11:25
*/
*-----------------------------------------------*
Static Function ValTolera(lValor,lAVincular,lEEL)
*-----------------------------------------------*
Local cCpoSaldo, cCpoSaldoNeg, cCpoValor, cAlias, cCpo, cCpoTolera
Local aCampos := {{"EEL_SLDVNC","EEL_VNCNEG"},;
                  {"EEL_SLDEMB","EEL_EMBNEG"},;
                  {"EXS_SLDVNC","EXS_VLVING"},;
                  {"EXS_SLDEMB","EXS_VLEMNG"},;
                  {"EXS_QTDVNC","EXS_QTVING"},;
                  {"EXS_QTDEMB","EXS_QTEMNG"}}
Default lEEL := .f.

Begin Sequence

   If lEEL // no EEL só tem campos de valor, e não de quantidade
      lValor := .t.
      cAlias := "EEL"
      cCpo  := "LCVL"
      cCpoTolera := "EEL_TOLERA"
   Else
      cAlias := "EXS"
      cCpo  := "VALOR"
      cCpoTolera := If(lValor,"EXS_TOLEVL","EXS_TOLEQT")
   EndIf

   cCpoSaldo    := cAlias + "_" + If(lValor,"SLD","QTD") + If(lAVincular,"VNC","EMB")
   cCpoSaldoNeg := aCampos[ AScan(aCampos,{|x| x[1] = cCpoSaldo }) ][2]
   cCpoValor    := cAlias + "_" + If(lValor,cCpo,"QTD")
   
End Sequence

Return Round( (cAlias)->( ( &(cCpoSaldo) - &(cCpoSaldoNeg) ) + ( &(cCpoTolera)/100 ) * &(cCpoValor) ),AvSx3(cCpoSaldo,AV_DECIMAL) )

/*
Funcao     : Ae107CalcTot()
Objetivo   : Calcular o valor total do item posicionado da Work ou do EE9(com desconto)
Parametros : 1 - lógico - pegar dados da work (.t.) ou da base (.f.)
             2 - lógico - pegar dados da memória (.t.) ou da work (.f.)
Retorno    : Valor total do item
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 14/07/2005 às 10:23
*/
*-----------------------------------*
Function Ae107CalcTot(lWork,lMemoria)
*-----------------------------------*
Local nRet := 0, cWork, cAlias
Local nVlDesc
//ER - 06/09/2007 - Define se o Desconto será subtraído(.T.) ou somado(.F.) no Valor Fob, quando o preço for fechado.
Local lSubDesc := EasyGParam("MV_AVG0139",,.T.) 

Default lWork    := .f.
Default lMemoria := .f.

If lMemoria
   cWork  := "M"
   cAlias := "M"
ElseIf lWork
   cWork := "WorkIp"
   cAlias := "M"
Else
   cWork := "EE9"
   cAlias := "EEC"
EndIf

nRet := &(cWork+"->EE9_PRCTOT")
If EasyGParam("MV_AVG0085",,.f.)
   //FJH 07/02/06 - Desconto por itens
   If EasyGParam("MV_AVG0119",,.F.) .and. EE9->(FieldPos("EE9_DESCON")) > 0
      nVlDesc := &(cWork+"->EE9_DESCON")
   //If lWork .Or. lMemoria .Or. EE9->(FieldPos("EE9_VLDESC")) > 0
   ElseIf lWork .Or. lMemoria .Or. EE9->(FieldPos("EE9_VLDESC")) > 0 
      nVlDesc := &(cWork+"->EE9_VLDESC")
   Else
      nVlDesc := Round((&(cWork+"->EE9_PRCTOT") / &(cAlias+"->(EEC_TOTPED+EEC_DESCON)")) * &(cAlias+"->EEC_DESCON"),2)
   EndIf
                                                                      
   //DFS - 22/03/13 - Inclusão de verificação para o campo EEC_TPDESC na rotina de Embarque
   If (EEC->(FieldPos("EEC_TPDESC")) > 0 .AND. EEC->EEC_TPDESC $ CSIM) .OR. EEC->(FieldPos("EEC_TPDESC")) == 0 .AND. lSubDesc
      nRet -= nVlDesc
   Else
      nRet += nVlDesc
   EndIf
EndIf

Return nRet

/*
Funcao     : Ae107ValIt()
Objetivo   : Validação dos itens da Carta de Crédito no Ok final ou na manutenção de itens do Pedido / Embarque
Parametros : cFase (pedido OC_PE ou embarque OC_EM)
Retorno    : .t./.f.
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 14/07/2005 às 16:26
*/
*--------------------------------*
Function Ae107ValIt(cFase, nRecNo)
*--------------------------------*

Local lRet := .t., lPedido := (cFase == OC_PE), i, j
Local cAlias   := If(lPedido, "EE7", "EEC")
Local cAliasIt := If(lPedido, "EE8", "EE9")
Local cWork    := If(lPedido, "WorkIt", "WorkIp")
Local aItensLC := {}, nPos
Local bCond, lOk, cOldWork, nRec, l2Saldos := .f.
Local aOrd := SaveOrd({cWork,cAlias,cAliasIt})
Local lRecNo := ValType(nRecNo) = "N"
Local lIncluir := If(lRecNo,If(nRecNo == 0,.t.,.f.),.f.)
Local bWhile := If(!lReplicacao, {|| (cWork)->(!EoF())},;
                   {|| EE9->(!EoF()) .And. EE9->(EE9_FILIAL+EE9_PREEMB) == cFilEx+EEC->EEC_PREEMB})
Local bLoop  := If(!lReplicacao, {|| (cWork)->(DbSkip()) }, {|| EE9->(DbSkip()) } )
Local cMsg, lFirst
Local lValidaAtual := .f.
Local lDesvincular := .f.
Local aItensPed := {} //itens vinculados a outros pedidos

Local nTotalAEmb, nTotalMoeda
Local nSaldoAEmb, nSaldoUnid, lCtProd

Private nSaldo1 := 0, nTotal1 := 0
Private nSaldo2 := 0, nTotal2 := 0

Begin Sequence
   
   EEL->(DbSetOrder(1))
   EEC->(DbSetOrder(1))
   EXS->(DbSetOrder(1))
   
   If !lPedido
      nRec := EEC->(RecNo())
      If lReplicacao // Se for replicação, as cartas de crédito são tiradas do embarque de origem e colocadas no novo.
      
         If EEC->(!DbSeek(cFilEx+M->EEC_PEDREF))
            EE9->(DbGoBottom(),DbSkip())
         Else
            EE9->(DbSetOrder(2))
            EE9->(DbSeek(cFilEx+EEC->EEC_PREEMB))
         EndIf
      Else
         If !(EEC->(DbSeek(M->(EEC_FILIAL+EEC_PREEMB))))
            (cWork)->(DbGoBottom(),DbSkip())
         Else
            (cWork)->(DbGoTop())
         EndIf
         
      EndIf
      
      // Primeiro, verifica os itens que serão desvinculados (no caso de replicação ) ou que já estão na base
      While Eval(bWhile)
         
         If !lReplicacao
            // Se não houver nada deste item na base...
            If WorkIP->WP_RECNO = 0
               (cWork)->(DbSkip())
               Loop
            EndIf
            (cAliasIt)->(DbGoTo(WorkIP->WP_RECNO))
            EEC->(DbSeek( EE9->(EE9_FILIAL+EE9_PREEMB) ))
         EndIf
         
         // se não há carta de crédito para este item
         If Empty((cAliasIt)->&(cAliasIt+"_LC_NUM"))
            Eval(bLoop)
            Loop
         EndIf
         
         EEL->(DbSeek(xFilial()+(cAliasIt)->&(cAliasIt+"_LC_NUM")))
         
         If EEL->EEL_CTPROD $ cSim 
            // Se não está preenchida a Sequência do Item da carta de crédito...
            If Empty((cAliasIt)->&(cAliasIt+"_SEQ_LC"))
               Eval(bLoop)
               Loop
            EndIf
         EndIf
         
         nSaldoAEmb := EE9->EE9_SLDINI
         nTotalAEmb := Ae107CalcTot()
         
         // Se controla produto...
         If EEL->EEL_CTPROD $ cSim 
         
            EXS->(DbSeek(xFilial()+(cAliasIt)->&(cAliasIt+"_LC_NUM+"+cAliasIt+"_SEQ_LC")))
            /* aItensLC por posição - [i][1] - Nro. L/C
                                      [i][2] - Seq. L/C
                                      [i][3] - Valor a Embarcar
                                      [i][4] - Moeda da L/C
                                      [i][5] - Quantidade a embarcar
                                      [i][6] - Unidade de medida do item da L/C
                                      [i][7] - Valor a Vincular
                                      [i][8] - Quantidade a Vincular
            
            */

            // se a sequência da L/C ainda não existir no array, adiciona.
            If (nPos := AScan(aItensLC,{|x| x[1]+x[2] == (cAliasIt)->&(cAliasIt+"_LC_NUM+"+cAliasIt+"_SEQ_LC") })) == 0
               AAdd(aItensLC,{(cAliasIt)->&(cAliasIt+"_LC_NUM"),(cAliasIt)->&(cAliasIt+"_SEQ_LC"),;
                              ValTolera(.t.,.f.),EEL->EEL_MOEDA,ValTolera(.f.,.f.),EXS->EXS_UNIDAD,;
                              ValTolera(.t.,.t.),ValTolera(.f.,.t.)  })
               nPos := Len(aItensLC) //posição do item que acabou de ser adicionado no array
            EndIf
            
            // Valor...
            nAux := EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA,nTotalAEmb,AvSx3("EXS_SLDEMB",AV_DECIMAL))
            
            aItensLC[nPos][7] += nAux //valor a vincular
            If !Empty(EEC->EEC_DTEMBA)
               aItensLC[nPos][3] += nAux //valor a embarcar
            EndIf
            
            // Se o item da L/C controla quantidade...
            If EXS->EXS_CTRQTD $ cSim 
               // Quantidade...
               nAux := Round(AvTransUnid(EE9->EE9_UNIDAD, EXS->EXS_UNIDAD, EXS->EXS_COD_I ,nSaldoAEmb,;
                                         .f.),AvSx3("EXS_QTDEMB",AV_DECIMAL))
               
               aItensLC[nPos][8] += nAux //quantidade a vincular
               If !Empty(EEC->EEC_DTEMBA)
                  aItensLC[nPos][5] += nAux //quantidade a embarcar
               EndIf
               
            EndIf
            
         Else // se não controla produto..
         
            // se a L/C ainda não existir no array, adiciona.
            If (nPos := AScan(aItensLC,{|x| x[1] == (cAliasIt)->&(cAliasIt+"_LC_NUM") } ) ) == 0
               AAdd(aItensLC,{(cAliasIt)->&(cAliasIt+"_LC_NUM"),"",;
                              ValTolera(.t.,.f.,.t.),EEL->EEL_MOEDA,0,"",ValTolera(.t.,.t.,.t.),0  })
               nPos := Len(aItensLC) //posição do item que acabou de ser adicionado no array
            EndIf
            // Valor...
            nAux := EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA,nTotalAEmb,AvSx3("EXS_SLDEMB",AV_DECIMAL))
            
            aItensLC[nPos][7] += nAux //valor a vincular
            If !Empty(EEC->EEC_DTEMBA)
               aItensLC[nPos][3] += nAux //valor a embarcar
            EndIf
               
         EndIf
      
         Eval(bLoop)
      EndDo
      
      EEC->(DbGoTo(nRec))
      
   EndIf
   
   // simula o abatimento de saldo para verificar se o mesmo é suficiente.
   (cWork)->(DbGoTop())
   While .t. // este laço será executada no máximo 2 vezes.
      If (cWork)->(EoF()) .And. lRecNo
         lValidaAtual := .t.
         (cWork)->(DbGoTo(nRecNo))
      Else
         lValidaAtual := .f.
      EndIf
      
      While (cWork)->(!EoF()) .Or. lValidaAtual
         
         If !Empty((cWork)->&(cAliasIt+"_LC_NUM"))
            
            If !lValidaAtual
               If lRecNo .And. !lIncluir .And. (nRecNo == (cWork)->(RecNo()))
                  (cWork)->(DbSkip())
                  Loop
               
               ElseIf !lPedido
                  If Empty(WorkIp->WP_FLAG)
                     WorkIp->(DbSkip())
                     Loop
                  EndIf
               EndIf
            EndIf
            
            If lValidaAtual
               cOldWork := cWork
               cWork := "M"
            EndIf
           
            lOk := .t.
            lCtProd := .f.
            
            If EEL->(DbSeek(xFilial()+&(cWork+"->"+cAliasIt+"_LC_NUM")))
               If EEL->EEL_CTPROD $ cSim
                  lCtProd := .t.
                  If Empty(&(cWork+"->"+cAliasIt+"_SEQ_LC"))
                     lOk := .f.
                  Else
                     EXS->(DbSeek(xFilial()+&(cWork+"->("+cAliasIt+"_LC_NUM+"+cAliasIt+"_SEQ_LC)")))
                  EndIf
               EndIf
            EndIf
         
            If lOk
               nSaldoAEmb := 0
               nTotalAEmb := 0
            
               If lPedido
                  CalculaSaldos(cWork,@nSaldoAEmb,@nTotalAEmb)
               Else
                  nSaldoAEmb := &(cWork+"->EE9_SLDINI")
                  nTotalAEmb := Ae107CalcTot(.t.,If(cWork == "M",.t.,)) // parâmetro 1 - .t. - pega da Work (ou da memória)
               EndIf
               
               If lCtProd
                  nSaldoUnid  := AvTransUnid( &(cWork+"->"+cAliasIt+"_UNIDAD"),EXS->EXS_UNIDAD,EXS->EXS_COD_I,nSaldoAEmb,.f.)
               EndIf
               nTotalMoeda := EECCalcTaxa(M->&(cAlias+"_MOEDA"),EEL->EEL_MOEDA,nTotalAEmb,AvSx3(If(lCtProd,"EXS_SLDEMB","EEL_SLDEMB"),AV_DECIMAL ) )
               
               bCond := &("{|x| x[1] == EEL->EEL_LC_NUM" + If(lCtProd," .And. x[2] == EXS->EXS_SEQUEN","") + " }")
               
               If (nPos := AScan(aItensLC,bCond)) = 0
                  If lCtProd
                     AAdd(aItensLC,{EEL->EEL_LC_NUM,EXS->EXS_SEQUEN,ValTolera(.t.,.f.),EEL->EEL_MOEDA,;
                                    ValTolera(.f.,.f.),EXS->EXS_UNIDAD,ValTolera(.t.,.t.),ValTolera(.f.,.t.) })
                  Else
                     AAdd(aItensLC,{EEL->EEL_LC_NUM,"",ValTolera(.t.,.f.,.t.),EEL->EEL_MOEDA,;
                                    0,"",ValTolera(.t.,.t.,.t.),0})
                  EndIf
                  nPos := Len(aItensLC)
               
               EndIf
               
               // Valor...
               aItensLC[nPos][3] -= nTotalMoeda
               aItensLC[nPos][7] -= nTotalMoeda
               
               // Se o item da L/C controla quantidade...
               If lCtProd
                  // Quantidade...
                  aItensLC[nPos][5] -= nSaldoUnid
                  aItensLC[nPos][8] -= nSaldoUnid
               EndIf
            
            EndIf
            
            If cWork == "M"
               If lOk
                  For i := 1 to 2
                     If lPedido .And. i == 2 //só considera outros pedidos se passar pela primeira validação.
                     
                        //considerar itens vinculados a outros pedidos
                        nSaldo1 := 0
                        nTotal1 := 0
   
                        EE8->(DbSetOrder(5))
                        cChave := xFilial("EE8")+aItensLC[nPos][1]+If(lCtProd,aItensLC[nPos][2],"")
                        
                        EE8->(DbSeek(cChave))
                        While EE8->(EE8_FILIAL+EE8_LC_NUM+If(lCtProd,EE8_SEQ_LC,"")) == cChave
                           If EE8->(EE8_FILIAL+EE8_PEDIDO) == M->(EE7_FILIAL+EE7_PEDIDO) //só considera de outros pedidos.
                              EE8->(DbSkip())
                              Loop
                           EndIf
                           nSaldo1 := 0
                           nTotal1 := 0
                           CalculaSaldos("EE8",@nSaldo1,@nTotal1)
                           If lCtProd
                              nSaldo2 += AvTransUnid(EE8->EE8_UNIDAD,EXS->EXS_UNIDAD,EXS->EXS_COD_I,nSaldo1,.f.)
                           EndIf
                           nTotal2 += EECCalcTaxa(EE7->EE7_MOEDA,EEL->EEL_MOEDA,nTotal1,AvSx3(If(lCtProd,"EXS_SLDEMB","EEL_SLDEMB"),AV_DECIMAL ) )
                           
                           EE8->(DbSkip())
                        EndDo
                        
                        aItensLC[nPos][3] -= nTotal2
                        aItensLC[nPos][7] -= nTotal2
                        
                        If lCtProd
                           aItensLC[nPos][5] -= nSaldo2
                           aItensLC[nPos][8] -= nSaldo2
                        EndIf
                        
                     EndIf

                     // Valor                  ou  Quantidade menor que zero, dá a mensagem.
                     If aItensLC[nPos][7] < 0 .Or. aItensLC[nPos][8] < 0
                        
                        If lCtProd // Se controla produto...
                           cMsg := STR0041 //"A Sequência de L/C informada não possui "
                        Else
                           cMsg := STR0042 //"A Carta de Crédito informada não possui "
                        EndIf
                        l2Saldos := .f.
                        If aItensLC[nPos][7] < 0 .And. aItensLC[nPos][8] >= 0
                           cMsg += STR0043 //"saldo de valor suficiente para comportar este item."
                        ElseIf aItensLC[nPos][7] >= 0 .And. aItensLC[nPos][8] < 0
                           cMsg += STR0044 //"saldo de quantidade suficiente para comportar este item."
                        Else
                           cMsg += STR0045 //"saldos de valor e quantidade suficientes para comportar este item."
                           l2Saldos := .t.
                        EndIf
                     
                        cMsg += Repl(ENTER,2)
                  
                        If aItensLC[nPos][7] < 0
                           If l2Saldos
                              cMsg += STR0046 + Repl(ENTER,2) //"Valor:" 
                           EndIf
                           cMsg += STR0048 //"Saldo Disponível: "
                           xAux := aItensLC[nPos][7] + nTotalMoeda
                           xAux := AllTrim(Transform(xAux,AvSx3(If(lCtProd,"EXS_SLDEMB","EEL_SLDEMB"),AV_PICTURE)))
                           cMsg += AllTrim(EEL->EEL_MOEDA) + " " + xAux + ". "
                           
                           cMsg += STR0049 //"Saldo Necessário: "
                           xAux := AllTrim(Transform(nTotalAEmb,AvSx3(If(lCtProd,"EXS_SLDEMB","EEL_SLDEMB"),AV_PICTURE)))
                           cMsg += AllTrim(M->&(cAlias+"_MOEDA")) + " " + xAux
                           xAux := AllTrim(Transform(nTotalMoeda,AvSx3(If(lCtProd,"EXS_SLDEMB","EEL_SLDEMB"),AV_PICTURE)))
                           If EEL->EEL_MOEDA <> M->&(cAlias+"_MOEDA")
                              cMsg += "(" + AllTrim(EEL->EEL_MOEDA) + " " + xAux + ")"
                           EndIf
                           cMsg += ". " + Repl(ENTER,2)
                        EndIf
                        
                        If aItensLC[nPos][8] < 0
                           If l2Saldos
                              cMsg += STR0047 + Repl(ENTER,2) //"Quantidade:"
                           EndIf
                           cMsg += STR0048 //"Saldo Disponível: "
                           xAux := aItensLC[nPos][8] + nSaldoUnid
                           xAux := AllTrim(Transform(xAux,AvSx3("EXS_QTDEMB",AV_PICTURE)))
                           cMsg += xAux + " " + AllTrim(EXS->EXS_UNIDAD) + ". "
                           
                           cMsg += STR0049 //"Saldo Necessário: "
                           xAux := AllTrim(Transform(nSaldoAEmb,AvSx3("EXS_QTDEMB",AV_PICTURE)))
                           cMsg += xAux + " " + AllTrim(M->&(cAliasIt+"_UNIDAD"))
                           xAux := AllTrim(Transform(nSaldoUnid,AvSx3("EXS_QTDEMB",AV_PICTURE)))
                           If EXS->EXS_UNIDAD <> M->&(cAliasIt+"_UNIDAD")
                              cMsg += "(" + xAux + " " + AllTrim(EXS->EXS_UNIDAD) + ")"
                           EndIf
                           cMsg += ". " + Repl(ENTER,2)
                        EndIf
                        
                        If i == 1 // da primeira vez, bloqueia, pois é considerado o saldo da carta (que é abatido em fase de processo)
                           MsgInfo(cMsg,STR0025) //##,"Aviso" 
                           lRet := .f.
                           Break
                        ElseIf i == 2 // da segunda vez, pergunta, pois é considerado o saldo utilizado em outros pedidos 
                           If !MsgYesNo(STR0068 + Lower(Left(cMsg,1)) + SubStr(cMsg,2) + STR0067) //"Considerando o uso em outros pedidos, " ## "Deseja continuar?"
                              lRet := .f.
                              Break
                           EndIf
                        EndIf
                     EndIf
                  
                  Next
                  
               EndIf
               cWork := cOldWork
               
            EndIf
         EndIf
         
         If lValidaAtual
            Exit
         Else
            (cWork)->(DbSkip())
         EndIf
      EndDo

      If !lRecNo .Or. lValidaAtual
         Exit
      EndIf

   EndDo
   
   If !lRecNo
      
      // Array de espaços da mensagem
      aSpace := {AvSx3("EEL_LC_NUM",AV_TAMANHO),; // Nro. L/C
                 10,;                             // Seq. L/C 
                 AvSx3("EEL_MOEDA",AV_TAMANHO) + 5,;  // Moeda
                 Eval({|x,y| Int(If(x > y, x, y) * 1.5) },AvSx3("EEL_SLDEMB",AV_TAMANHO),AvSx3("EXS_SLDEMB",AV_TAMANHO) ),; // Saldo Disponível
                 0,;                              // Saldo Necessário
                 Int(AvSx3("EXS_QTDEMB",AV_TAMANHO) * 1.5),; // Quantidade disponível
                 0 }                              // Quantidade Necessária
      aSpace[5] := aSpace[4]
      aSpace[7] := aSpace[6]
      
      For j := 1 to 2
         cMsg := ""
         
         For i := 1 to Len(aItensLC) //Preenche as colunas da Mensagem
   
            If lPedido .And. j == 2//Considerar os itens vinculados a outros pedidos...
            
               EEL->(DbSeek(xFilial()+aItensLC[i][1]))
               If (lCtProd := (EEL->EEL_CTPROD $ cSim))
                  EXS->(DbSeek(xFilial()+aItensLC[i][1]+aItensLC[i][2]))
               EndIf
               
               If (AScan(aItensPed,{|x| x[1]+x[2] == EEL->EEL_LC_NUM+If(lCtProd,EXS->EXS_SEQUEN,"") } ) = 0)
   
                  AAdd(aItensPed, { EEL->EEL_LC_NUM , If(lCtProd,EXS->EXS_SEQUEN,"") } )
   
                  nSaldo1 := 0
                  nTotal1 := 0
      
                  EE8->(DbSetOrder(5))
                  cChave := xFilial("EE8")+aItensLC[i][1]+If(lCtProd,aItensLC[i][2],"")
                          
                  EE8->(DbSeek(cChave))
                  While EE8->(EE8_FILIAL+EE8_LC_NUM+If(lCtProd,EE8_SEQ_LC,"")) == cChave
                     If EE8->(EE8_FILIAL+EE8_PEDIDO) == M->(EE7_FILIAL+EE7_PEDIDO) //só considera de outros pedidos, não do atual
                        EE8->(DbSkip())
                        Loop
                     EndIf
                     nSaldo1 := 0
                     nTotal1 := 0
                     CalculaSaldos("EE8",@nSaldo1,@nTotal1)
                     If lCtProd
                        nSaldo2 += AvTransUnid(EE8->EE8_UNIDAD,EXS->EXS_UNIDAD,EXS->EXS_COD_I,nSaldo1,.f.)
                     EndIf
                     nTotal2 += EECCalcTaxa(EE7->EE7_MOEDA,EEL->EEL_MOEDA,nTotal1,AvSx3(If(lCtProd,"EXS_SLDEMB","EEL_SLDEMB"),AV_DECIMAL ) )
                          
                     EE8->(DbSkip())
                  EndDo
                  
                  aItensLC[i][3] -= nTotal2
                  aItensLC[i][7] -= nTotal2
                           
                  If lCtProd
                     aItensLC[i][5] -= nSaldo2
                     aItensLC[i][8] -= nSaldo2
                  EndIf
               
               EndIf
                        
            EndIf
            
            If aItensLC[i][7] < 0 .Or. aItensLC[i][8] < 0
               If Empty(aItensLC[i][2]) // se não controla produtos...
                  EEL->(DbSeek(xFilial()+aItensLC[i][1]))
                  cSeq    := "-"
                  cSldEmb := AllTrim(Transform(EEL->EEL_SLDVNC,AvSx3("EEL_SLDVNC",AV_PICTURE)))
                  cQtdEmb := "-"
                  cSldNec := AllTrim(Transform(EEL->EEL_SLDVNC - aItensLC[i][7],AvSx3("EEL_SLDVNC",AV_PICTURE)))
                  cQtdNec := "-"
                   
               Else
                  EXS->(DbSeek(xFilial()+aItensLC[i][1]+aItensLC[i][2]))
                  cSeq    := aItensLC[i][2]
                  If aItensLC[i][7] < 0
                     cSldEmb := AllTrim(Transform(EXS->EXS_SLDVNC,AvSx3("EXS_SLDVNC",AV_PICTURE)))
                     cSldNec := AllTrim(Transform(EXS->EXS_SLDVNC - aItensLC[i][7],AvSx3("EEL_SLDVNC",AV_PICTURE)))
                  Else
                     cSldEmb := "-"
                     cSldNec := "-"
                  EndIf
                  
                  If EXS->EXS_CTRQTD $ cSim .And. aItensLC[i][8] < 0
                     cQtdEmb := AllTrim(Transform(EXS->EXS_QTDVNC,AvSx3("EXS_SLDVNC",AV_PICTURE)))
                     cQtdNec := AllTrim(Transform(EXS->EXS_QTDVNC - aItensLC[i][8],AvSx3("EXS_SLDVNC",AV_PICTURE)))
                  Else
                     cQtdEmb := "-"
                     cQtdNec := "-"
                  EndIf
                  
               EndIf
               
               cMsg += aItensLC[i][1]                         + Space(2) +;
                       IncSpace(cSeq,aSpace[2],.f.)           + Space(2) +;
                       IncSpace(aItensLC[i][4],aSpace[3],.f.) + Space(2) +;
                       IncSpace(cSldEmb,aSpace[4],.t.)        + Space(2) +;
                       IncSpace(cSldNec,aSpace[5],.t.)        + Space(2) +;
                       IncSpace(cQtdEmb,aSpace[6],.t.)        + Space(2) +;
                       IncSpace(cQtdNec,aSpace[7],.t.)        + ENTER
               
            EndIf
         Next
         
         If Len(cMsg) > 0
            // Preenche o "header" da mensagem
            cMsg := STR0050 + Repl(ENTER,2) +; //"As seguintes Cartas de Crédito/Itens de Carta de Crédito utilizados não possuem saldo suficiente. Detalhes: "
                    IncSpace(STR0051,aSpace[1],.f.) + Space(2) +;  //"Nro. L/C"
                    IncSpace(STR0052,aSpace[2],.f.) + Space(2) +;  //"Seq. L/C"
                    IncSpace(STR0053,aSpace[3],.f.) + Space(2) +;  //"Moeda"
                    IncSpace(STR0054,aSpace[4],.t.) + Space(2) +;  //"Valor Disponível"
                    IncSpace(STR0055,aSpace[5],.t.) + Space(2) +;  //"Valor Necessário"
                    IncSpace(STR0056,aSpace[6],.t.) + Space(2) +;  //"Qtde. Disponível"
                    IncSpace(STR0057,aSpace[7],.t.) + ENTER    +;  //"Qtde. Necessária"
                    Repl("-",aSpace[1]) + Space(2) +;  //"Nro. L/C" - Traços...
                    Repl("-",aSpace[2]) + Space(2) +;  //"Seq. L/C" - Traços...
                    Repl("-",aSpace[3]) + Space(2) +;  //"Moeda" - Traços...
                    Repl("-",aSpace[4]) + Space(2) +;  //"Valor Disponível" - Traços...
                    Repl("-",aSpace[5]) + Space(2) +;  //"Valor Necessário" - Traços...
                    Repl("-",aSpace[6]) + Space(2) +;  //"Qtde. Disponível" - Traços...
                    Repl("-",aSpace[7]) + ENTER + cMsg //"Qtde. Necessária" - Traços...
                    
            If j == 1
               EECView(cMsg,STR0025) //##,"Aviso"
               lRet := .f.
               Break
            ElseIf j == 2
               If !EECView(STR0068 + Lower(Left(cMsg,1)) + SubStr(cMsg,2) + ENTER + STR0067,STR0025) //"Considerando o uso em outros pedidos, " ## "Deseja continuar?","Aviso"
                  lRet := .f.
                  Break
               EndIf
            EndIf
         EndIf
      
         /*
         If !lPedido .And. lDesvincular //por enquanto, não está sendo utilizada.
            If !Ae107DesIt(aItensLC) 
               lRet := .f.
               Break
            EndIf
         EndIf
         */
      
      Next
      
   EndIf
   
End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao     : Ae107DesIt()
Objetivo   : Tela de desvinculação de itens da L/C de itens de outros processos.
Parametros : Array de itens da L/C, com os saldos já tratados pela função Ae107ValIt
Retorno    : .t. / .f.
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 19/07/2005 às 14:16
*/
*---------------------------*
Function Ae107DesIt(aItensLC)
*---------------------------*

Local lRet := .t., lOk  := .f.
Local bOk     := {|| If(Ae107ValDes(),(lOk := .t.,oDlg:End()),) }
Local bCancel := {|| oDlg:End() }
Local i

Begin Sequence
   
   If !MsgYesNo(STR0058,STR0025) //"O saldo da(s) carta(s) de crédito vinculada(s) a este processo não é(são)
                                 // suficiente(s), porém você poderá desvincular a(s) mesma(s) de outros processos
                                 // que ainda não estão embarcados, na tela seguinte. Deseja Continuar?","Aviso"
      lRet := .f.
      Break
   EndIf
   
   For i := 1 to Len(aItensLC)
      If aItensLC[i][7] < 0 .Or. aItensLC[i][8] < 0
         
      EndIf
   Next
   
   If !lOk
      lRet := .f.
      Break
   EndIf
   
End Sequence

Return lRet

/*
Funcao     : Ae107ValDes()
Objetivo   : Validar Tela de desvinculação de itens da L/C
Parametros : Nenhum
Retorno    : .t. / .f.
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 19/07/2005 às 15:42
*/
*--------------------*
Function Ae107ValDes()
*--------------------*
Local lRet := .t.

Begin Sequence

End Sequence

Return lRet

/*
Funcao      : Ae107AtuIp()
Objetivo    : Atualiza WorkIp quando preenchido o Nro. da carta de crédito no Embarque
Parametros  : Nenhum
Retorno     : Nil 
Autor       : João Pedro Macimiano Trabbold
Data e Hora : 08/07/2005 às 12:09
Obs.        : Considera que o EEL já está posicionado na L/C que foi preenchida
*/
*-------------------*
Function Ae107AtuIp()
*-------------------*

Local lRet := .t.
Local nSaldoAEmb, nTotalAEmb

Private aItens := {}, aItensLC := {}, aVinculados := {}, lTemContQtd := .f. // define se algum item tem controle de saldo por quantidade

Begin Sequence
   
   If EEL->EEL_CTPROD $ cNao .Or. Empty(M->EEC_LC_NUM)// só vincula aos itens
      WorkIp->(DbGoTop())
      While WorkIp->(!EoF())
         If !Empty(WorkIp->WP_FLAG)
            WorkIp->EE9_LC_NUM := EEL->EEL_LC_NUM
            WorkIp->EE9_SEQ_LC := CriaVar("EE9_SEQ_LC")
            WorkIp->(DbSkip())
         EndIf
      EndDo
      
      Break
   EndIf
   
   EE9->(DbSetOrder(1))
   EEC->(DbSetOrder(1))
   EXS->(DbSetOrder(1))   
   WorkIp->(DbGoTop())
   While WorkIp->(!Eof())

      If WorkIp->WP_RECNO <> 0 // Se o item já existia na base
         EE9->(DbGoTo(WorkIp->WP_RECNO))
         EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB ))
         If EE9->EE9_LC_NUM == M->EEC_LC_NUM .And. !Empty(EE9->EE9_SEQ_LC) //verifica se o mesmo estava vinculado a alguma sequencia da mesma L/C
            
            EXS->(DbSeek(xFilial("EXS")+EE9->(EE9_LC_NUM+EE9_SEQ_LC) ))
         
            If (nPos := AScan(aItensLC,{|x| x[1] == EXS->EXS_SEQUEN} ) ) = 0
               EXS->(AAdd(aItensLC,{EXS_SEQUEN,ValTolera(.t.,.f.),ValTolera(.f.,.f.),;
                                    If(EXS_CTRQTD $ cSim, .t., .f.), EXS_COD_I, EXS_PRECO, EXS_UNIDAD } ) )
               nPos := Len(aItensLC)
               /* aItensLC por posição - [j][1] - Sequência do Item da L/C
                                         [j][2] - Saldo a Embarcar do Valor
                                         [j][3] - Saldo a Embarcar da quantidade
                                         [j][4] - Define se controla quantidade
                                         [j][5] - Código do Produto
                                         [j][6] - Preço do Item
                                         [j][7] - Unidade de Medida da Quantidade
               */
               If !lTemContQtd .And. EXS->EXS_CTRQTD $ cSim
                  lTemContQtd := .t.
               EndIf    
            EndIf
            
            aItensLC[nPos][2] += EECCalcTaxa(EEC->EEC_MOEDA,EEL->EEL_MOEDA,Ae107CalcTot(),AvSx3("EXS_SLDVNC",AV_DECIMAL))
            aItensLC[nPos][3] += AvTransUnid(EE9->EE9_UNIDAD,EXS->EXS_UNIDAD,EXS->EXS_COD_I,EE9->EE9_SLDINI,.f.)
            
         EndIf
      EndIf
      
      If Empty(WorkIp->WP_FLAG) // considera apenas itens marcados
         WorkIp->(DbSkip())
         Loop
      EndIf
      
      nSaldoAEmb := WorkIp->EE9_SLDINI
      nTotalAEmb := Ae107CalcTot(.t.)
      
      AAdd(aItens, { WorkIp->(RecNo()), nTotalAEmb, nSaldoAEmb , .f., WorkIp->EE9_COD_I, WorkIp->EE9_PRECO,WorkIp->EE9_UNIDAD} )
      /* aItens por posição - [i][1] - RecNo na WorkIp
                              [i][2] - Preço total do item
                              [i][3] - Quantidade total do item
                              [i][4] - Define se já foi vinculado (.t. = vinculado)
                              [i][5] - Código do Produto
                              [i][6] - Preço do Item
                              [i][7] - Unidade de Medida da Quantidade
      */
      WorkIp->(DbSkip())
   EndDo
   
   EXS->(DbSeek(xFilial("EXS")+M->EEC_LC_NUM))
   While EXS->(!EoF()) .And. EXS->(EXS_FILIAL+EXS_LC_NUM) == xFilial("EXS")+M->EEC_LC_NUM
      If (nPos := AScan(aItensLC,{|x| x[1] == EXS->EXS_SEQUEN} ) ) = 0
         EXS->(AAdd(aItensLC,{EXS_SEQUEN,ValTolera(.t.,.f.),ValTolera(.f.,.f.),;
                              If(EXS_CTRQTD $ cSim, .t., .f.), EXS_COD_I, EXS_PRECO, EXS_UNIDAD } ) )
         nPos := Len(aItensLC)
         /* aItensLC por posição - [j][1] - Sequência do Item da L/C
                                   [j][2] - Saldo a Embarcar do Valor
                                   [j][3] - Saldo a Embarcar da quantidade
                                   [j][4] - Define se controla quantidade
                                   [j][5] - Código do Produto
                                   [j][6] - Preço do Item
                                   [j][7] - Unidade de Medida da Quantidade
         */
         If !lTemContQtd .And. EXS->EXS_CTRQTD $ cSim
            lTemContQtd := .t.
         EndIf    
      EndIf

      EXS->(DbSkip())
   EndDo

   Processa( {|| lRet := AlocaItens() },,.f.)
   
   If !lRet .And. Len(aVinculados) > 0
      nTot := Len(aItens) - Len(aVinculados)
      nOp := 3
      While nOp == 3
         nOp := Aviso( STR0061, AllTrim(Str(nTot)) + STR0062, {STR0063,STR0064,STR0065}, 2 ) //"Vinculação Inteligente" # " não puderam ser vinculados. Deseja que os itens vinculados com sucesso permaneçam desta maneira? Para maiores detalhes, clique em 'Itens'." # "Sim" # "Não" # "Itens"
         If nOp == 3
            VinculaItens(.f.,OC_EM)
         EndIf
      EndDo
      If nOp == 1
         lRet := .t.
      ElseIf nOp == 2
         Break
      EndIf
   EndIf
   
   VinculaItens(lRet,OC_EM)
   
End Sequence

Return lRet

/*
Funcao     : Ae107ValInv()
Objetivo   : Validar se existem invoices para as L/Cs
Parametros : Nenhum
Retorno    : .t. / .f.
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 02/08/2005 às 15:00
*/
*--------------------*
Function Ae107ValInv()
*--------------------*
Local lRet := .t.

Begin Sequence

   If !Empty(M->EEC_LC_NUM) // quer dizer que só há uma L/C para os itens, então não é necessário que se cadastrem invoices.
      Break
   EndIf
   
   If IsVazio("WorkInv")
      WorkIp->(DbGoTop())
      While WorkIp->(!Eof())
         If !Empty(WorkIp->WP_FLAG) .And. !Empty(WorkIp->EE9_LC_NUM)
            MsgInfo(STR0059,STR0025) //"Para duas ou mais L/Cs diferentes em um mesmo processo, devem ser cadastradas as respectivas invoices.","Aviso" 
            lRet := .f.
            Break
         EndIf
         WorkIp->(DbSkip())
      EndDo
   EndIf
   
End Sequence

Return lRet

/*
Funcao     : Ae107VldProd()
Objetivo   : Validar L/C nos itens do pedido ou embarque
Parametros : Ocorrência - Pedido ou Embarque
Retorno    : .t. / .f.
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 03/08/2005 às 10:52
*/
*--------------------------*
Function Ae107VldProd(cFase)
*--------------------------*
Local cAlias
Local lRet := .t.

Default cFase := OC_PE

Begin Sequence

   cAlias := If(cFase == OC_PE,"EE8","EE9")

   If !Empty(M->&(cAlias + "_LC_NUM"))
      
      EEL->(DbSetOrder(1))
      EEL->(DbSeek(xFilial()+M->&(cAlias + "_LC_NUM")))
      If EEL->EEL_CTPROD $ cSim .And. Empty(M->&(cAlias + "_SEQ_LC"))
         MsgInfo(STR0060,STR0025) // "A Carta de Crédito informada controla produtos. Informe a Sequência do Item da L/C.","Aviso"
         lRet := .f.
         Break
      EndIf

   EndIf

End Sequence

Return lRet
