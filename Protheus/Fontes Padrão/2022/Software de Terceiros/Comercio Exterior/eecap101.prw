#INCLUDE "EECAP101.ch"
/*
Programa        : EECAP101.PRW
Objetivo        : Continuacao do EECAP100
Autor           : Heder M Oliveira
Data/Hora       : 28/12/98 17:51
Obs.            :
*/
#include "EEC.CH"
#define PC_CF "8" //Processo de exportação de café
#define PC_CM "9" //Processo de exportação de commodites
/*
Funcao      : AP100DESP().
Parametros  : cOcorrencia := P - PEDIDO.
                             E - EMBARQUE.
              nOpc := Inclusao/Alt./Excl./Vis.
Retorno     : .T./.F.
Objetivos   : Executa rotina externa de lancamento de despesas.
Autor       : Heder M Oliveira.
Data/Hora   : 28/12/98 14:20.
Revisao     : Jeferson Barros Jr.
Data/Hora   : 15/05/03 11:10.
Objetivo    : Diponibilizar a edição dos dados via wmultiline de acordo com o MV_AVG0045.
Obs.        :
*/
Function AP100DESP(cOcorrencia,nOPC)

Local lRet:=.T.,cOldArea:=Select()//,nOpcA:=0
Local cFileBackup := CriaTrab(,.F.)
//Local bOk := {|| nOpcA := 1, oDlg:End() }
//Local bCancel := {|| oDlg:End() }
Local oMark, aDelBak
Local nX, j:=0, i:=0

Private bOkDesp     := {|| nOpcADesp := 1, oDlg:End() },;
        bCancelDesp := {|| oDlg:End() },;
        nOpcADesp   := 0

Private aAuxDesp := {} //Para uso em ponto de entrada
Private aButtons:={}
Private MSeguro:=0,MImpostos:=0,MAdiant:=0,MOutras:=0,MSaldos:=0,MTot_Ger:=0,nPos:=0
Private oOutras, oImpostos, oAdiant, oTot_Ger, oSaldos, oDlg
Private cPCDESP:=cOcorrencia
Private lEdit := EasyGParam("MV_AVG0045",,.f.)
Private aHeader:={}, nUsado := Len(aHeader), aCols:={}

Begin Sequence

   cOcorrencia := Upper(cOcorrencia)

   IF ! (cOcorrencia $ OC_PE+"/"+OC_EM)
      HELP(" ",1,"AVG0000648") //MsgStop("Erro no parametro da função AP100Desp","Aviso")
      lRet := .F.
      Break
   Endif

   dbSelectArea("WorkDe")
   WorkDe->(dbGoTop())
   TETempBackup(cFileBackup)
   aDelBak := aClone(aDeDeletados)
   WorkDe->(dbGoTop())

   aAdd(aButtons,{"BMPVISUAL" /*"ANALITICO"*/,{|| AP100DSMAN(VIS_DET,cOcorrencia,oMark)},STR0116}) //"Visualizar"

   If !lEdit .And. nOpc <> VISUALIZAR
      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/ ,{|| AP100DSMAN(INC_DET,cOcorrencia,oMark)},STR0056}) //"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/    ,{|| AP100DSMAN(ALT_DET,cOcorrencia,oMark)},STR0057}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{|| AP100DSMAN(EXC_DET,cOcorrencia,oMark)},STR0058}) //"Excluir"
   EndIf

   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,{"ANTES_TELA"})
   Endif

   DEFINE MSDIALOG oDlg TITLE STR0001+M->cPESQDESP FROM 9,0 TO 28,70 OF oMainWnd //"Despesas do P.E. n."

      AP100DSDTELA(.T., oDlg)

      If !lEdit
         oMark := MSSELECT():New("WorkDe",,,aDeBrowse,,,aDePos)
         oMark:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AP100DSMAN(VIS_DET,cOcorrencia,oMark),AP100DSMAN(ALT_DET,cOcorrencia,oMark)) }
      Else
         aP100DSEdit(oDlg,nOpc)
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOkDesp,bCancelDesp,,aButtons) CENTERED

   IF nOpcADesp == 0 //Cancelar
      AvZap("WorkDe")

      dbSelectArea("WorkDe")
      TERestBackup(cFileBackup)
      aDeDeletados := aClone(aDelBak)
   Else
      If lEdit // Tela de edição dos dados.
         WorkDe->(DbGoTop())

         // ** Limpa a work.
         Do While WorkDe->(!Eof())
            If WorkDe->EET_RECNO # 0
               aAdd(aDeDeletados,WorkDe->EET_RECNO)
            EndIf
            WorkDe->(DbSkip())
         EndDo
         AvZap("WorkDe")//WorkDe->(AvZap())

         // ** Grava as informações de acordo com o aCols.
         For i:=1 To Len(aCols)
            If !aCols[i][Len(aHeader)+1] // Verifica se a despesa estah ativa ou deletada ...

               // ** Inclui as despesas na work.
               WorkDe->(RecLock("WorkDe", .T.))
               For j:=1 To WorkDe->(FCount())
                  nX := aScan(aHeader,{|z| z[2] = WorkDe->(FieldName(j))})
                  If nX > 0
                     WorkDe->&(FieldName(j)) := aCols[i][nX]
                  EndIf
               Next
               WorkDe->(MsUnlock()) 
            EndIf
         Next

      EndIf
   EndIf

   E_EraseArq(cFileBackup)

End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : aP100DSEdit(oDlg,nOpc)
Parametros  : oDlg, nOpc
Retorno     : .t.
Objetivos   : Possibilitar e inclusao,alteracao e exclusao das despesas via wmultiline.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/05/03 - 11:31.
Revisao     :
Obs.        :
*/
*------------------------------------*
Static Function aP100DSEdit(oDlg,nOpc)
*------------------------------------*
Local lRet := .t., i:=0, j:=0, aOrd:=SaveOrd("SX3")
Local oGetDb, cCampo, cAux:="", nZ:=0
Local aCamposCalc:={"EET_DESPES","EET_VALORR","EET_PAGOPO"}

Begin Sequence

   Sx3->(DbSetOrder(2))

   For j:=1 To Len(aCamposCalc)
      cAux+=aCamposCalc[j]+"/"
   Next

   For i:=1 To WorkDe->(FCount())
      cCampo := WorkDe->(FieldName(i))

      If !(cCampo $ "EET_PEDIDO/EET_OCORRE/EET_RECNO/DBDELETE")
         If SX3->(DbSeek(cCampo))

            If cCampo $ cAux
               cValid := AllTrim(Sx3->X3_VALID)+" .And. aP100DsCalc()"
            Else
               cValid := Sx3->X3_VALID
            EndIf

            aAdd(aHeader,{Sx3->X3_TITULO ,;
                          Sx3->X3_CAMPO  ,;
                          Sx3->X3_PICTURE,;
                          Sx3->X3_TAMANHO,;
                          Sx3->X3_DECIMAL,;
                          cValid         ,;
                          Sx3->X3_USADO  ,;
                          Sx3->X3_TIPO   ,;
                          "WorkDe"       ,;
                          Sx3->X3_CONTEXT})
         EndIf
      EndIf
   Next

   // Carrega as informações no aCols.
   WorkDe->(DbGoTop())
   Do While WorkDe->(!Eof())

      SYB->(DbSetOrder(1))
      If SYB->(DbSeek(xFilial("SYB")+WorkDe->EET_DESPES))
         WorkDe->EET_DESCDE := SYB->YB_DESCR
      EndIf

      Aadd(aCols,Array(Len(aHeader)+1))

      For i:=1 To Len(aHeader)
         aCols[Len(aCols),i] := WorkDe->&(aHeader[i][2])
      Next

      aCols[Len(aCols),Len(aCols[1])] := .f. // Flag (.t. - Deletado, .f. - Ativo).

      WorkDe->(DbSkip())
   EndDo

   oGetDb := IW_MultiLine(aDePos[1],aDePos[2],aDePos[3],aDePos[4],If(nOpc=VISUALIZAR,.f.,.t.),If(nOpc=VISUALIZAR,.f.,.t.),"AP100DsLinOk()")

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : aP100DsCalc()
Parametros  : Nenhum.
Retorno     : .t.
Objetivos   : Calcular e atualizar os totais exibidos na tela.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/05/03 - 11:31.
Revisao     :
Obs.        :
*/
*--------------------*
Function aP100DsCalc()
*--------------------*
Local aCamposCalc:={"EET_DESPES","EET_VALORR","EET_PAGOPO"}
Local cDespes, cPagoPo, nValor, nPagoDesp:=0
Local lRet:=.t., i:=0 , j:=0
Local aAux:={}

Begin Sequence

   If Len(aCamposCalc) = 0
      Break
   EndIf

   MSeguro:=0;MImpostos:=0;MAdiant:=0;MOutras:=0;MSaldos:=0;MTot_Ger:=0

   For j:=1 To Len(aCols)
      aAux := {}

     If !aCols[j][Len(aHeader)+1] // Verifica se a grade estah ativa ...

         For i:=1 To Len(aCamposCalc)
             nPos := aScan(aHeader,{|z| z[2] = aCamposCalc[i]})
             aAdd(aAux,{aCamposCalc[i],aCols[j][nPos]})
         Next

         For i:=1 To Len(aAux)
            If aAux[i][1] = "EET_DESPES"
               cDespes := aAux[i][2]
            ElseIf aAux[i][1] = "EET_VALORR"
               nValor  := aAux[i][2]
            ElseIf aAux[i][1] = "EET_PAGOPO"
               cPagoPo := aAux[i][2]
            EndIf
         Next

         // ** Para a grade ativa, considera os valores da memória.
         If j = n
            cDesPes := M->EET_DESPES

            nValor := M->EET_VALORR

            cPagoPo := M->EET_PAGOPO
         EndIf

         If SubStr(cDespes,1,1) == '2'
            MImpostos += nValor
            MTot_Ger  += nValor
         ElseIf cDespes == "903"
            MAdiant -= nValor
         ElseIf SubStr(cDespes,1,1) == '9'
            MAdiant += nValor
         Else
            MOutras  += nValor
            MTot_Ger += nValor
         EndIf

         IF !(cDespes == "903" .Or. SubStr(cDespes,1,1) == '9') .And. cPagoPo == "1"
            nPagoDesp += nValor
         Endif
      EndIf
   Next

   MSaldos  := if(MAdiant>0,MAdiant-nPagoDesp,0)

   oOutras:Refresh()
   oImpostos:Refresh()
   oAdiant:Refresh()
   oTot_Ger:Refresh()
   oSaldos:Refresh()

End Sequence

Return lRet

/*
Funcao      : AP100DsLinOk()
Parametros  : Nenhum.
Retorno     : lRet
Objetivos   : Consistencia do lançamento das despesas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 15/05/2003 15:59.
Revisao     :
Obs.        :
*/
*---------------------*
Function AP100DsLinOk()
*---------------------*
Local lRet := .t., nPos, i:=0
Local aCpObrigat:={"EET_DESPES","EET_DESADI","EET_VALORR",;
                   "EET_BASEAD","EET_PAGOPO"}
Begin Sequence

   For i:=1 To Len(aCpObrigat)
      nPos := aScan(aHeader,{|z| z[2] = aCpObrigat[i]})

      If Empty(aCols[n][nPos])
         Help(" ",1,"OBRIGAT")
         lRet:=.f.
         Break
      EndIf
   Next

   // ** Recalcula os totais em caso de deleçao/não deleção de linha.
   aP100DsCalc()

End Sequence

Return lRet

/*
Funcao      : AP100DSGRAVA()
Parametros  : lGRVs  -> .T. ->GERA WORK
                        .F. ->GRAVA "EET"
              cOcorrencia -> Pedido/Embarque.
              lIntegracao -> Chamada a partir de rotina de integração.
Retorno     :
9Objetivos  : Grava arquivo de trabalho ou EET
Autor       : Heder M Oliveira
Data/Hora   :
Revisao     :
Obs.        :
*/
Function AP100DSGrava(lGRV,cOcorrencia,lIntegracao)

Local lRet    := .T.
Local lGerTit := .F.
Local i                             //NCF - 07/08/2014
Local nInc

Local aCposInt := {"EET_DESADI","EET_VALORR","EET_PAGOPO","EET_FORNEC","EET_LOJAF","EET_DTVENC","EET_NATURE"}

Private cFinForn := ""
Private cFinLoja := ""
Private cAliasInt:= "WorkDe"
Private cTipoTit := "NF"
Static aDadosEET:= {}               //NCF - 07/08/2014
Default lIntegracao := .f.

cOcorrencia := Upper(cOcorrencia)

If Type("lEE7Auto") <> "L"
   lEE7Auto:= .F.
EndIf

Begin Sequence

   If !lIntegracao
      IF ! (cOcorrencia $ OC_PE+OC_EM)
         EECHelp(" ",1,"AVG0000649") //MsgStop("Erro no parametro da função AP100DSGRAVA","Aviso")
         lRet := .F.
         Break
      Endif
   EndIf

   IF !lGRV
      For nInc:=1 to LEN(aDeDeletados)
         
         EET->(DBGOTO(aDeDeletados[nInc]))
         
         if ( nPos := aScan(aDadosEET,{|x|x[2] == EET->(Recno())}) ) == 0
            //para o backup em caso de erro de integração com o logix
            aAdd(aDadosEET,{"DEL", EET->(recno()) })
         endif

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         If EasyEntryPoint("EECAP101") // By JPP - 28/09/2006 - 16:00
            ExecBlock("EECAP101",.F.,.F.,"PE_DEL_EET")
         EndIf

         RecLock("EET",.F.)

         ///////////////////////////////////////////////////////////
         //Exclusão do título no financeiro para a despesa nacional//
         ///////////////////////////////////////////////////////////
         If cOcorrencia == OC_EM
            //RMD - 22/01/15 - Tratamento para geração de pedidos de compra para despesas nacionais
            If (EET->(FieldPos("EET_FINNUM")) > 0 .And. !Empty(EET->EET_FINNUM)) .Or.; //Gera Título no Financeiro
               (EET->(FieldPos("EET_PEDCOM")) > 0 .And. !Empty(EET->EET_PEDCOM))      //Gera Pedido de Compras
                  If !(lRet := AvStAction("016"))
                     Break
                  EndIf
            EndIf
         EndIf

         EET->(DBDELETE())
         EET->(MsUnlock())
      Next nInc

      WorkDe->(DBGOTOP())

      While ! WorkDe->(EOF())

         lGerTit := .F.

         If WorkDe->EET_RECNO # 0
            EET->(DBGOTO(WorkDe->EET_RECNO))
            //para o backup em caso de erro de integração com o logix
            if ( nPos := aScan(aDadosEET,{|x|x[2] == EET->(Recno())}) ) == 0
               aAdd(aDadosEET,{"ALT", EET->(Recno()) })
            endif
            RecLock("EET",.F.)

            ///////////////////////////////////////////////////////////
            //Exclusão do título no financeiro para a despesa nacional//
            ///////////////////////////////////////////////////////////
            If cOcorrencia == OC_EM
               If IsIntEnable("001") .And. EET->(FieldPos("EET_FINNUM")) > 0 .Or. EET->(FieldPos("EET_PEDCOM")) > 0 //RMD - 22/01/15 - Considera criação de pedidos de compra para a despesa
                  If AvGeraTit("WorkDe","EET",aCposInt) //.Or. empty(EET->EET_FINNUM) 
                     //WFS
                     //Com a disponibilização da integração na rotina de numerários, os campos vencimento e
                     //natureza passaram a ser não obrigatórios, porém são necessários para a realização da
                     //integração. Desta forma, quando a despesa for alterada, as condições para recriar o
                     //título será excluir o existente, desde que este já tenha sido enviado ao Financeiro.

                     //RMD - 22/01/15 - Também exclui o pedido de compras (se tiver sido criado)

                     //If !AvFlags("EEC_LOGIX")
                        If !Empty(EET->EET_FINNUM) .Or. AP101ChkI("WorkDe","EET_PEDCOM",.T.)/*(EET->(FieldPos("EET_PEDCOM")) > 0 .And. !Empty(WorkDe->EET_PEDCOM))*/
                           If (lRet := AvStAction("016"))
                              If !AvFlags("EEC_LOGIX")
                                 WorkDe->EET_FINNUM:= ""
                                 If EET->(FieldPos("EET_PEDCOM")) > 0
                                    WorkDe->EET_PEDCOM:= ""
                                 EndIf
                              EndIf
                           EndIf
                        EndIf
                     //EndIf

                     If !lRet
                        Break
                     EndIf

                     lGerTit := .T.

                  EndIf
               Else
                  If EET->(FieldPos("EET_FINNUM")) > 0 .Or. EET->(FieldPos("EET_PEDCOM")) > 0//RMD - 22/01/15 - Considera o pedido de compras.
                     If Empty(EET->EET_FINNUM) .Or. AP101ChkI("EET","EET_PEDCOM",.T.)/*(EET->(FieldPos("EET_PEDCOM")) > 0 .And. !Empty(EET->EET_PEDCOM))*/ // BAK - 13/03/2012 - ALTERAÇÃO da Despesa
                        lGerTit := .T.
                     ElseIf IsIntEnable("001") .And. AvGeraTit("WorkDe","EET",aCposInt) .OR.;
                        !IsIntEnable("001") .And. (WorkDe->EET_DTVENC <> EET->EET_DTVENC .OR. ;
                        WorkDe->EET_DESADI <> EET->EET_DESADI .OR. WorkDe->EET_VALORR <> EET->EET_VALORR)
                           If !(lRet := AvStAction("019"))
                              Break
                           EndIf
                     EndIf
                  EndIf
               EndIf
            EndIf

         Else

            RecLock("EET",.T.)  // bloquear e incluir registro vazio
            If lIntCont
               If lOkEstor .And. lContEst  // Estorno da Contabilizacao
                  AAdd(aIncluiECF, {WorkDe->EET_PEDIDO, WorkDe->EET_DESPES, WorkDe->EET_VALORR} )
               Endif
            Endif
            lGerTit := .T.

            //para o backup em caso de erro de integração com o logix
            if ( nPos := aScan(aDadosEET,{|x|x[2] == EET->(Recno())}) ) == 0
               //para o backup em caso de erro de integração com o logix
               aAdd(aDadosEET,{"INC", EET->(recno())})
            endif


         EndIf

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         //NCF - 07/08/2014 - Backup de dados da tabela EET para reversão
         If ( nPos := aScan(aDadosEET,{|x|x[2] == EET->(Recno())}) ) > 0
            aAux := {}
            For i:=1 To EET->(FCount())
               aAdd( aAux , EET->&(FieldName(i)) )
            Next i
            if len(aDadosEET[nPos]) < 3
               aadd(aDadosEET[nPos], aClone(aAux))
            elseif len(aDadosEET[nPos]) == 3
               aDadosEET[nPos][3] := aClone(aAux)
            endIf
         EndIf

         AVReplace("WorkDe","EET")

         If EasyEntryPoint("EECAP101") // By JPP - 28/09/2006 - 16:00
            ExecBlock("EECAP101",.F.,.F.,{"PE_GRV_EET",WorkDe->EET_RECNO})
         EndIf

         EET->EET_PEDIDO := AvKey(IF(cOcorrencia==OC_PE,M->EE7_PEDIDO,M->EEC_PREEMB),"EET_PEDIDO")
         EET->EET_FILIAL := xFilial("EET")
         EET->EET_OCORRE := cOcorrencia

         ///////////////////////////////////////////////////////////
         //Geração do título no financeiro para a despesa nacional//
         ///////////////////////////////////////////////////////////
         If cOcorrencia == OC_EM
            If IsIntEnable("001") .And. EET->(FieldPos("EET_FINNUM")) > 0
               //If lGerTit nopado por WFS em 05/02/2010
               //Os campos EET_DTVENC e EET_NATURE foram alterados no dicionário para não obrigatórios.
               //Desta forma, os títulos serão gerados quando esses campos forem preenchidos.
               If lGerTit .And. (!Empty(WorkDe->EET_DTVENC) .And. (!Empty(WorkDe->EET_NATURE) .Or. EasyGParam("MV_EEC0043",,.F.)))//RMD - 22/01/15 - Considera o pedido de compras
                  cFinForn := WorkDe->EET_FORNEC
                  cFinLoja := WorkDe->EET_LOJAF

                  If !(lRet := AvStAction("015"))
                     Break
                  EndIf
               EndIf
            ElseIf EET->(FieldPos("EET_FINNUM")) > 0 .And. lGerTit  // BAK - 13/03/2012 - Envio da INCLUSÃO/ALTERAÇÃO da despesa
               If !(lRet := AvStAction("015") )
                  Break
               EndIf
            EndIf
         EndIf

         EET->(MsUnlock())
         WorkDe->(DBSKIP())
      Enddo

      If lIntCont
         If lOkEstor .And. lContEst // Estorno da Contabilizacao
            AP101EstCtb(aEstornaECF, aIncluiECF)
         Endif
      Endif
   Else //WorkDe
      AVReplace("EET","WorkDe")
      WorkDe->EET_RECNO := EET->(RECNO())
      If EasyEntryPoint("EECAP101") // By JPP - 28/09/2006 - 16:00
         ExecBlock("EECAP101",.F.,.F.,"PE_ATU_WORKDE")
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AP100DSDTELA(lInit)
Parametros  : lInit:= .T. = inicilizar valores
                      .F. = envia mensagem de atualizacao
Retorno     : .T.
Objetivos   : apresentar header de despesas
Autor       : Heder M Oliveira
Data/Hora   : 29/12/98 10:24
Revisao     :
Obs.        :
*/
Static Function  AP100DSDTELA(lInit,oDlg)
   Local lRet:=.T.,cOldArea:=select()
   Local MRecno := WorkDe->(RECNO()), nL1, nL2, nL3, nC1, nC2, nC3, nC4
   Local nPagoDesp := 0 // by CAF 11/04/2003 Pago pelo despachante para controle do saldo

   Begin Sequence
      nL1:=1.4 ; nL2:=2.2 ; nL3:=3.0 ; nC1:=0.8 ; nC2:=15 ; nC3:=08 ; nC4:=20

      MSeguro:=0;MImpostos:=0;MAdiant:=0;MOutras:=0;MSaldos:=0;MTot_Ger:=0
      WorkDe->(DBGOTOP())

      While ! WorkDe->(EOF())

         Do Case
            Case SUBST(WorkDe->EET_DESPES,1,1) == '2'
                 MImpostos += WorkDe->EET_VALORR ; MTot_Ger += WorkDe->EET_VALORR
            Case WorkDe->EET_DESPES == "903"
                 MAdiant -= WorkDe->EET_VALORR
            Case SUBST(WorkDe->EET_DESPES,1,1) == '9'
                 MAdiant += WorkDe->EET_VALORR
            OtherWise
                 MOutras   += WorkDe->EET_VALORR ; MTot_Ger += WorkDe->EET_VALORR
         End Case

         IF ! (WorkDe->EET_DESPES == "903" .Or. SUBST(WorkDe->EET_DESPES,1,1) == '9') .And.;
            WorkDE->EET_PAGOPO == "1"

            nPagoDesp += WorkDe->EET_VALORR
         Endif

         WorkDe->(DBSKIP())
      Enddo

      // by CAF 11/04/2003 MSaldos  := if(MAdiant>0,MAdiant - MTot_Ger,0)
      MSaldos  := if(MAdiant>0,MAdiant - nPagoDesp,0)
      WorkDe->(DBGOTO(MRecno))

      If lInit
         @nL1,nC1 SAY STR0002 OF oDlg //"Outras Despesas"
         @nL1,nC2 SAY STR0003 OF oDlg //"Impostos"
         @nL2,nC1 SAY STR0004 OF oDlg //"Adiantamentos"
         @nL2,nC2 SAY STR0005 OF oDlg //"Saldo Adianta/o"
         @nL3,nC1 SAY STR0006 OF oDlg //"Total Geral"

         @nL1,nC3 MSGET oOutras   VAR MOutras   PICTURE AVSX3("EET_VALORR",AV_PICTURE) WHEN .F. SIZE 50,7 RIGHT OF oDlg
         @nL1,nC4 MSGET oImpostos VAR MImpostos PICTURE AVSX3("EET_VALORR",AV_PICTURE) WHEN .F. SIZE 50,7 RIGHT OF oDlg
         @nL2,nC3 MSGET oAdiant   VAR MAdiant   PICTURE AVSX3("EET_VALORR",AV_PICTURE) WHEN .F. SIZE 50,7 RIGHT OF oDlg
         @nL2,nC4 MSGET oSaldos   VAR MSaldos   PICTURE AVSX3("EET_VALORR",AV_PICTURE) WHEN .F. SIZE 50,7 RIGHT OF oDlg
         @nL3,nC3 MSGET oTot_Ger  VAR MTot_Ger  PICTURE AVSX3("EET_VALORR",AV_PICTURE) WHEN .F. SIZE 50,7 RIGHT OF oDlg
      Else
         oOutras:Refresh()
         oImpostos:Refresh()
         oAdiant:Refresh()
         oTot_Ger:Refresh()
         oSaldos:Refresh()
      EndIf
   End Sequence

   dbselectarea(cOldArea)
Return lRet

/*
Funcao      : AP100DSMAN(nTipoDS,cOcorrencia,oMark)
Parametros  : nTipoDS := INC_DET/VIS_DET/ALT_DET/EXC_DET
              cOcorrencia := P (default) pedido
                             E (embarque) pedido
Retorno     : .T.
Objetivos   : Permitir manutencao de outras descricoes da moeda
Autor       : Heder M Oliveira
Data/Hora   : 29/12/98 15:16
Revisao     :
Obs.        :
*/
Static Function AP100DSMAN(nTipoDS,cOcorrencia, oMark)

Local lRet:=.T.,cOldArea:=select(),oDlg,nInc,nOpcA:=0,cNewtit,nRECNO
Local nRecOld := WorkDe->(RecNo()), aDeCampos:={}, j:=0, aCmpNotEdit:={}, nPos:=0

Private aTela[0][0],aGets[0],aHeader[0]
Private lNaoAltera := .t.

Begin Sequence

   IF nTipoDS <> INC_DET
      IF WorkDe->(Eof() .And. Bof())
         HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      Endif
   Endif

   IF nTipoDS == INC_DET
      WorkDe->(dbGoBottom())
      WorkDe->(dbSkip())
   Endif

   // ** Tratamentos para impedir a edição do campos de código do notify na opção de alteração.
   aDeCampos := aClone(aDeEnchoice)
   If nTipoDS == ALT_DET
      aCmpNotEdit := {"EET_DESPES"}
      For j:=1 To Len(aCmpNotEdit)
         nPos := aScan(aDeCampos,aCmpNotEdit[j])
         If nPos > 0
            aDel(aDeCampos,nPos)
            aSize(aDeCampos, Len(aDeCampos)-1)
         EndIf
      Next
   EndIf

   nRECNO:=WorkDe->(RECNO())

   For nInc := 1 TO WorkDe->(FCount())
      M->&(WorkDe->(FIELDNAME(nInc))) := WorkDe->(FIELDGET(nInc))
   Next nInc

   M->EET_PEDIDO := If(cOcorrencia==OC_PE,M->EE7_PEDIDO,M->EEC_PREEMB)
   M->EET_OCORRE := cOcorrencia

   If lIntCont
      If cOcorrencia = "Q"  // Embarque
         Aadd(aDeEnchoice, "EET_NR_CON") //Nro da Contabiliação
      Endif

      If nTipoDS == ALT_DET
         If !Empty(M->EET_NR_CON)
            EasyHelp(STR0070, STR0071) //"A Despesa não pode ser alterado pois já possui Contabilizações!"###"Aviso"
            Break
         Endif
      Endif
   Endif

   If lIntCont
      If lOkEstor .And. lContEst
         If cOcorrencia = "Q"  // Embarque
            Aadd(aDeEnchoice, "EET_DTDEMB")   // Exibe o campo Dt.Desembaraço caso seja despesa de embarque
         Endif
      Endif
   Endif

   cNewTit:=STR0007 //"Definição de Despesa"

   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      EnChoice("EET", , 3, , , ,aDeEnchoice , PosDlg(oDlg),IF(STR(nTipoDS,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aDeCampos) , 3 )
      // Botão para funcionar a exclusão
      DEFINE SBUTTON FROM 10025,187 TYPE 2 ACTION (.T.) ENABLE OF oDlg PIXEL

      If EasyEntryPoint("EECAP101")  // By JPP - 28/09/2006 - 16:00
         ExecBlock("EECAP101",.F.,.F.,"PE_GRV_MEM_TELA")
      EndIf

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpcA:=1,If(AP100VALDP(nTipoDS,nRECNO),oDlg:End(),nOpcA:=0)},{||oDlg:End()})

   If lIntCont
      If lOkEstor .And. lContEst
         nPos := Ascan(aDeEnchoice, "EET_DTDEMB")
         If nPos > 0
            ADel(aDeEnchoice, nPos)   // Exclui o campo Dt.Desembaraço para que possa ser utilizado em outras rotinas
            aSize(aDeEnchoice,LEN(aDeEnchoice)-1)
         Endif
      Endif
   Endif

   If nOpcA != 0
      If nTipoDS == INC_DET
         WorkDe->(RecLock("WorkDe", .T.))
      Else
         WorkDe->(RecLock("WorkDe", .F.))  
      EndIf

      If ! (Str(nTipoDS,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
         AVReplace("M","WorkDe")
      EndIf
      WorkDe->(MsUnlock())  
      oMark:oBrowse:Refresh()
      AP100DSDTELA(.F.)
   Else
      IF nTipoDS == INC_DET
         WorkDe->(dbGoto(nRecOld))
      Endif
   EndIf

End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AP100VALDP()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Deletar despesas
Autor       : Heder M Oliveira
Data/Hora   : 05/01/99 13:30
Revisao     :
Obs.        :
*/
Static Function AP100VALDP(nTipo,nRecno)
   Local lRet:=.T.

   Begin Sequence

      If EasyEntryPoint("EECAP101")
         lRet := ExecBlock("EECAP101",.F.,.F.,{"VALDP",nTipo,nRecno})
         If ValType(lRet) <> "L"
            lRet := .T.
         EndIf
         If !lRet
            Break
         EndIf
      EndIf

      If nTipo == INC_DET .OR. nTipo = ALT_DET
         lRet:=Obrigatorio(aGets,aTela)
      ElseIf nTIPO==EXC_DET .AND. MsgNoYes(STR0008,STR0009) //'Confirma Exclusao ? '###'Excluir'
         WorkDe->(DBGOTO(nRECNO))
         If WorkDe->EET_RECNO # 0
            AADD(aDeDeletados,WorkDe->EET_RECNO)
            If lIntCont
               If lOkEstor .And. lContEst // Estorno da Contabilidade
                  If !Empty(WorkDe->EET_NR_CON)
                     AAdd(aEstornaECF, {WorkDe->EET_PEDIDO, WorkDe->EET_DESPES, WorkDe->EET_DTDEMB, WorkDe->EET_NR_CON} )
                  Endif
               Endif
            Endif
         EndIf
         WorkDe->(DBDELETE())
         WorkDe->(dbSkip(-1))
         IF WorkDe->(Bof())
            WorkDe->(dbGoTop())
         Endif
      EndIf
   End Sequence

Return lRet

/*
Funcao      : AP100AGEN()
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Executa rotina externa de lancamento de agentes/representantes
Autor       : Heder M Oliveira
Data/Hora   : 28/12/98 14:20
Revisao     : By JBJ - 05/06/03 - Novos tratamentos para lançamentos de comissão nos agentes.
Obs.        :
*/
Function AP100AGEN(cOcorrencia,nOPC,aAuto)

Local lRet:=.T.,cOldArea:=Select(),nOpcA:=0,oDlg,oMPEDIDO, oTipo, oTotComItem
Local nL1:=1.4, nL2:=2.2, nL3:=3.0, nC1:=0.8, nC2:=15, nC3:=08, nC4:=20
Local cFileBackup := CriaTrab(,.f.), bTotal
Local cPedido, cTipo
Local bOk := {|| Ap100ValCom(cOcorrencia), nOpcA := 1, If(lEEBAuto, Nil, oDlg:End())}
Local bCancel := {|| oDlg:End() }
Local nTotComItem := 0
Local cAlias, nCom_Old, aDelBak, lComisItem := .f., nResCom_Old
Local nRec, aItensBackup, i
Local oPanel

Private onAGENTES,onAGERCOM,onAGETCOM,nMAGENTES:=0,nMAGERCOM:=0,nMAGETCOM:=0
Private lOk := .F.
Private cAliasIt, cWorkIt
Private lEEBAuto := ValType(aAuto) == "A"
/*
AMS - 01/11/2004 às 19:42. Flag que identifica para função EEBTrigger se retorno deve ser
                           Agente Recebedor de Comissão.
*/
Private lRecebCom := .T.

cOcorrencia := Upper(cOcorrencia)

// JPM - Variável inicializada apenas em fase de embarque, e que no pedido deve ser constante
If Type("lDtEmba") == "U" .Or. cOcorrencia == OC_PE
   Private lDtEmba := .f.
EndIf

Begin Sequence

   IF ! (cOcorrencia $ OC_PE+"/"+OC_EM)
      HELP(" ",1,"AVG0000650") //MsgStop("Erro no parametro da função AP100AGEN","Aviso")
      lRet := .F.
      Break
   Endif

   cAlias := IF(cOcorrencia==OC_PE,"EE7","EEC")

   nCom_Old    := MemField("VALCOM",cALIAS)
   nResCom_Old := MemField("DSCCOM",cAlias)

   If !EECFlags("COMISSAO")
      If Len(ComboX3Box(cAlias+"_TIPCVL")) <= 3 // Nro de Opcoes de comissao
         If &("M->"+cAlias+"_TIPCVL") == "3" // Comissao por item
            SetComissao(cOcorrencia)

            nTotComItem := &("M->"+cAlias+"_VALCOM")
            lComisItem := .t.
         EndIf
      EndIf
   EndIf

   IF cAlias == "EE7"
      cPedido := MemField("PEDIDO",cALIAS)
   Else
      cPedido := MemField("PREEMB",cALIAS)
   Endif

   nMAGENTES := 0
   nMAGERCOM := 0
   cTipo     := BscXBox(cAlias+"_TIPCVL",&("M->"+cAlias+"_TIPCVL"))

   If !EECFlags("COMISSAO")
      bTotal := {|| nMAGENTES++,IF(SUBSTR(WorkAg->EEB_TIPOAG,1,1)==CD_AGC,(nMAGERCOM++,nMAGETCOM+=WorkAg->EEB_TXCOMI),)}
   Else
      bTotal := {|| nMAGENTES++,If(SubStr(WorkAg->EEB_TIPOAG,1,1)==CD_AGC,(nMAGERCOM++,nMAGETCOM+=WorkAg->EEB_VALCOM),)}
   EndIf

   dbSelectArea("WorkAg")
   WorkAg->(dbGoTop())
   TETempBackup(cFileBackup)
   aDelBak := aClone(aAgDeletados)
   WorkAg->(dbGoTop())
   WorkAg->(dbEval(bTotal))

   nOpcA := 0
   // ** JPM - 31/01/05 - Backup de dados de itens referentes a comissao
   cWorkIt := If(cAlias == "EE7","WorkIt","WorkIp")
   cAliasIt := If(cAlias == "EE7","EE8","EE9")
   nRec := (cWorkIt)->(RecNo())
   (cWorkIt)->(DbGoTop())
   aItensBackup := {}
   While (cWorkIt)->(!EoF())
      AAdd(aItensBackup,{ (cWorkIt)->(RecNo()),;
                         &(cWorkIt+"->"+cAliasIt+"_CODAGE"),;
                         &(cWorkIt+"->"+cAliasIt+"_PERCOM"),;
                         &(cWorkIt+"->"+cAliasIt+"_VLCOM" ) } )

      If (cAliasIt)->(FieldPos(cAliasIt+"_TIPCOM")) > 0
         AAdd(aItensBackup[Len(aItensBackup)], &(cWorkIt+"->"+cAliasIt+"_TIPCOM") )
      EndIf

      (cWorkIt)->(DbSkip())
   EndDo
   (cWorkIt)->(DbGoTo(nRec))

   // **

   /*
   AMS - 30/10/2004 às 19:09. Filtro para WorkAge, quando for tratamento de Frete, Seguro e Comissão, para não
                              visualizar os  agentes do tipo Recebedor de Comissão.
   */
   If EECFlags("FRESEGCOM")
      //AOM - 04/08/2011
      WorkAg->(DBEVAL({|| If(Left(EEB_TIPOAG, 1) = "3", WorkAg->WK_FILTRO := "S", WorkAg->WK_FILTRO := "") }))
      WorkAg->(dbSetFilter({|| WorkAg->WK_FILTRO == "S" }, "WorkAg->WK_FILTRO == 'S'"))
   EndIf

   WorkAg->(dbGoTop())

   If !lEEBAuto

      DEFINE MSDIALOG oDlg TITLE STR0010 + " " + Alltrim(Transform(cPedido, AVSX3(If(cAlias == "EE7", "EE7_PEDIDO", "EEC_PREEMB") , AV_PICTURE))) FROM 9,0 TO 32,70 OF oMainWnd //"Empresas P.E. n."

         oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.15)

         // ** By JBJ - 25/03/03
         @ nL1,nC1 SAY STR0011 Of oPanel //"Pedido Export."
         @ nL1,nC2 SAY STR0012 Of oPanel//"Total Empresas"

         @ nL1,nC3 MSGET oMPEDIDO  VAR cPedido   WHEN .F. SIZE 50,7 RIGHT Of oPanel
         @ nL1,nC4 MSGET onAGENTES VAR nMAGENTES WHEN .F. SIZE 50,7 RIGHT Of oPanel
  
         If EECFlags("COMISSAO")
            @ nL2,nC1 SAY STR0117 Of oPanel//"Total Comissão" //"Comissão"
            @ nL2,nC3 MSGET M->&(cAlias+"_DSCCOM") WHEN .F. SIZE 198,7 Of oPanel
         Else
            @ nL2,nC1 SAY STR0014 //"Total Comissão"
            @ nL2,nC3 MSGET onAGETCOM VAR nMAGETCOM WHEN .F. SIZE 50,7 RIGHT PICT AVSX3(cAlias+"_VALCOM",AV_PICTURE) Of oPanel

            @ nL2,nC2 SAY STR0070 Of oPanel//"Tipo Comissão"
            @ nL2,nC4 MSGET oTipo     VAR cTipo     WHEN .F. SIZE 100,7 Of oPanel

            // ** By JBJ - 26/03/03 - 11:39.
            If lComisItem
               @ nL3,nC1 SAY STR0071 Of oPanel//"Total Comissão Item"
               @ nL3,nC3 MSGET oTotComItem  VAR nTotComItem WHEN .F. SIZE 50,7 RIGHT PICT AVSX3(cAlias+"_VALCOM",AV_PICTURE) Of oPanel
            EndIf
         EndIf

         //wfs - alinhamento
         oPanel:Align:= CONTROL_ALIGN_TOP

         oMark := MSSELECT():New("WorkAg",,,aAgBrowse,,,aAgPos)
         //wfs - alinhamento
         oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
         // JPM - Alteração de dados após o embarque
         oMark:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AP100AGMAN(VIS_DET,cOcorrencia,oMark),;
                         AP100AGMAN(If(lDtEmba,VIS_DET,ALT_DET),cOcorrencia,oMark)) }

      ACTIVATE MSDIALOG oDlg ON INIT AVBar(If(lDtEmba,VISUALIZAR,nOpc),;
                                     oDlg,bOk,bCancel,ENCH_ADD,{|opc| AP100AGMAN(opc,cOcorrencia,oMark)}) CENTERED
   Else
      If aScan(aAuto, {|x| AllTrim(Upper(x[1])) == "EEB_TIPOAG" }) == 0
         aAdd(aAuto, {"EEB_TIPOAG", AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG"), Nil})//Sempre é agente recebedor de comissão, caso o campo não tenha sido informado inclui automaticamente pois faz parte da chave
      EndIf
      If EasySeekAuto("WorkAg",aAuto,1)
         If nOpc == INCLUIR//Upsert
            nOpc := ALT_DET
         ElseIf nOpc == ALTERAR
            nOpc := ALT_DET
         ElseIf nOpc == EXCLUIR
            nOpc := EXC_DET
         EndIf
      ElseIf nOpc == INCLUIR//Upsert
         nOpc := INC_DET
      ElseIf (nOpc == ALTERAR) .Or. (nOpc == EXCLUIR)
         EasyHelp(STR0130, STR0049) //"Falha de Integração: Registro não localizado na tabela de Agentes."###"Aviso"
         lRet := .F.
      EndIf
      If lRet
         If (lRet := AP100AGMAN(nOpc,cOcorrencia,Nil,aAuto))
            Eval(bOk)
         EndIf
      EndIf
   EndIf


   /*
   AMS - 30/10/2004 às 19:17. Retirada do filtro imposto acima, quando for tratamento de Frete, Seguro e Comissão.
   */
   IF(EasyEntryPoint("EECAP101"),EXECBLOCK("EECAP101",.F.,.F.,"ALT_TITULO_FIN"),)  //LRS - 09/05/2014 Ponto entrada para alterar titulos gerados na comissões de agente.

   If EECFlags("FRESEGCOM")
      WorkAg->(dbClearFilter())
   EndIf

   If nOpcA == 1 //OK
      EECTotCom(cOcorrencia,, .T.)      // Totaliza a comissão para o agente.
   ElseIf nOpcA == 0 //Cancelar
      cWorkIt := If(cAlias == "EE7","WorkIt","WorkIp")
      cAliasIt := If(cAlias == "EE7","EE8","EE9")

      dbSelectArea("WorkAg")
      AvZap()
      TERestBackup(cFileBackup)
      aAgDeletados := aClone(aDelBak)
      // ** JPM - 31/01/05 - restauração de dados de itens referentes a comissão
      For i := 1 to Len(aItensBackup)
         (cWorkIt)->(DbGoTo(aItensBackup[i][1]))
         &(cWorkIt+"->"+cAliasIt+"_CODAGE") := aItensBackup[i][2]
         &(cWorkIt+"->"+cAliasIt+"_PERCOM") := aItensBackup[i][3]
         &(cWorkIt+"->"+cAliasIt+"_VLCOM" ) := aItensBackup[i][4]
         If (cAliasIt)->(FieldPos(cAliasIt+"_TIPCOM")) > 0
            &(cWorkIt+"->"+cAliasIt+"_TIPCOM" ) := aItensBackup[i][5]
         EndIf
      Next
      (cWorkIt)->(DbGoTop())
      // **
      Eval(MemVarBlock(cAlias+"_VALCOM"),nCom_Old)
      Eval(MemVarBlock(cAlias+"_DSCCOM"),nResCom_Old)
   Endif

   (cWorkIt)->(DbGoTo(nRec))
   FErase(cFileBackup+GetDBExtension())

End Sequence

dbselectarea(cOldArea)

// ** JPM - 06/06/06 - pto entrada ao fechar tela de agentes.
lOk := (nOpcA == 1)
If EasyEntryPoint("EECAP101")
   ExecBlock("EECAP101",.F.,.F.,"FIM_BROWSE_AG")
Endif

Return lRet

/*
Funcao      : Ap100ValCom()
Parametros  : cOcorrencia = Fase (Pedido/Embarque).
              lSetCom = .t. - Atualiza a capa do processo/Mostra aviso em caso de diferenças.
                        .f. - Não atualiza a capa do processo/Mostra aviso em caso de diferenças.
Retorno     : .T./.F.
Objetivos   : Validação do valor da(s) comissão(ões) do(s) agente(s)
Autor       : Jeferson Barros Jr.
Data/Hora   : 26/03/03 08:50
Revisao     :
Obs.        :
*/
*---------------------------------------*
Function Ap100ValCom(cOcorrencia,lSetCom)
*---------------------------------------*
Local lRet:=.t.,  nTotComAg :=0
Local cAlias := If(cOcorrencia==OC_PE,"EE7","EEC")

Default lSetCom := .t.

Begin Sequence

   // ** By JBJ - 10/06/03 - 11:01
   If EECFlags("COMISSAO")
      Break
   EndIf

   If Len(ComboX3Box(cAlias+"_TIPCVL")) > 3
      Break
   EndIf

   If &("M->"+(cAlias)+"_TIPCVL") == "3" // Comissão por item.

      bTotal := {|| If(SubStr(WorkAg->EEB_TIPOAG,1,1)==CD_AGC, nTotComAg += WorkAg->EEB_TXCOMI, nil)}
      WorkAg->(dbGoTop())
      WorkAg->(dbEval(bTotal))

      // ** Faz os calculos do percentual por item e atualiza o campo valor da comissao na capa.
      If lSetCom
         SetComissao(cOcorrencia)
      EndIf

      If nTotComAg <> &("M->"+(cAlias)+"_VALCOM")
         If IsMemVar("lEEBAuto") .AND. lEEBAuto
            EasyHelp(STR0072+; //"O total de comissão do processo ("
                     AllTrim(Transf(&("M->"+(cAlias)+"_VALCOM"),Avsx3(cAlias+"_VALCOM",AV_PICTURE)))+STR0073 +ENTER+; //") não "
                     STR0074+; //" confere com o total de comisão do(s) agente(s) ("
                     AllTrim(Transf(nTotComAg,Avsx3(cAlias+"_VALCOM",AV_PICTURE)))+") ",STR0049)
         Else
            EECMsg(STR0072+; //"O total de comissão do processo ("
                     AllTrim(Transf(&("M->"+(cAlias)+"_VALCOM"),Avsx3(cAlias+"_VALCOM",AV_PICTURE)))+STR0073 +ENTER+; //") não "
                     STR0074+; //" confere com o total de comisão do(s) agente(s) ("
                     AllTrim(Transf(nTotComAg,Avsx3(cAlias+"_VALCOM",AV_PICTURE)))+") ",STR0049) //"Aviso"
         EndIf
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : AP100AGGRAVA()
Parametros  : lGRVs  -> .T. ->GERA WORK
                        .F. ->GRAVA "EEB"
              cOcorrencia -> Pedido/Embarque.
              lIntegracao -> Chamada a partir de rotina de integração.
Retorno     :
9Objetivos  : Grava arquivo de trabalho ou EEB
Autor       : Heder M Oliveira
Data/Hora   : 13/01/99 19:56
Revisao     :
Obs.        :
*/
Function AP100AGGrava(lGRV,cOcorrencia,lIntegracao)

Local lRet:=.T., nInc
Local cAlias, cPedido, x

Default lIntegracao := .f.

cOcorrencia := Upper(cOcorrencia)

If Type("lEE7Auto") <> "L"
   lEE7Auto:= .F.
EndIf

Begin Sequence

   If !lIntegracao
      IF ! (cOcorrencia $ OC_PE+"/"+OC_EM)
         EECHelp(" ",1,"AVG0000651") //MsgStop("Erro no parametro da função AP100AGGRAVA","Aviso")
         lRet := .F.
         Break
      Endif
   EndIf

   cAlias := IF(cOcorrencia==OC_PE,"EE7","EEC")

   IF cAlias == "EE7"
      cPedido := MemField("PEDIDO",cALIAS)
   Else
      cPedido := MemField("PREEMB",cALIAS)
   Endif

   IF !lGRV
      For nInc:=1 to LEN(aAgDeletados)
         EEB->(DBGOTO(aAgDeletados[nInc]))

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         RecLock("EEB",.F.)
         EEB->(DBDELETE())
         EEB->(MsUnlock())
      Next nInc

      /* Se a rotina de tipo de comissão por item estiver ativa, então o campo EEB_TIPCOM entra na chave única
         do EEB, mas o sistema permite alterações neste campo. Sendo assim, deve-se evitar que sejam gravados,
         mesmo que temporariamente, registros com mesma chave, para não dar erro de Unique Constraint. JPM - 06/06/05  */

      If If(cOcorrencia == OC_PE,EE8->(FieldPos("EE8_TIPCOM")) > 0,EE9->(FieldPos("EE9_TIPCOM")) > 0)
         WorkAg->(DBGOTOP())
         x := 0
         While ! WorkAg->(EOF())
            If WorkAg->WK_RECNO = 0
               WorkAg->(DBSKIP())
               Loop
            EndIf
            x++
            EEB->(DBGOTO(WorkAg->WK_RECNO))
            RecLock("EEB",.F.)
            EEB->EEB_TIPCOM := Chr(x) //apenas para não dar erro de chave única. A gravação efetiva apagará este chr.
            EEB->(MsUnlock())
            WorkAg->(DBSKIP())
         Enddo
      EndIf

      // ** OBSERVAÇÃO IMPORTANTE. Não podem haver desvios entre o tratamento de chave única acima e a gravação
      // efetiva abaixo, ou seja, SEMPRE que o tratamento acima for executado, a gravação abaixo DEVERÁ ser feita.

      WorkAg->(DBGOTOP())
      While ! WorkAg->(EOF())
         If WorkAg->WK_RECNO # 0
            EEB->(DBGOTO(WorkAg->WK_RECNO))
            RecLock("EEB",.F.)
         Else
            RecLock("EEB",.T.)  // bloquear e incluir registro vazio
         EndIf

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         AVReplace("WorkAg","EEB")
         EEB->EEB_PEDIDO := cPedido
         EEB->EEB_FILIAL := xFilial("EEB")
         // Alterado por Heder M Oliveira - 8/30/1999
         EEB->EEB_OCORRE := cOcorrencia
         EEB->(MsUnlock())
         WorkAg->WK_RECNO := EEB->(Recno()) //NCF - 19/11/2014 - Reversão da integração LOGIX
         WorkAg->(DBSKIP())
      Enddo
   Else
      AVReplace("EEB", "WorkAg")
      WorkAg->WK_RECNO := EEB->(RECNO())
   EndIf

End Sequence

Return Nil

/*
Funcao      : AP100AGMAN(nTipoAG)
Parametros  : nTipoAG := INC_DET/ALT_DET/EXC_DET/VIS_DET
Retorno     : .T.
Objetivos   : Manutenção de Agentes
Autor       : Heder M Oliveira
Data/Hora   : 14/01/99 11:32
Revisao     :
Obs.        :
*/
Static Function AP100AGMAN(nTipoAG,cOcorrencia,oMark,aAuto)

Local lRet:=.T.,cOldArea:=Select()
Local oDlg,nInc,nOpcA:=0,nRECNO
Local cAlias, cPedido
Local nRecOld := WorkAg->(RecNo())
Local nCom_Old, bVlCom, aAgCampos:={}
Local cNewTit := ""
Local cOpcoes := STR0118 //"3-Visualização 4-Inclusão     5-Alteração    6-Exclusão     "
Local nPos:=0, j:=0, aCmpNotEdit:={}

Private aTela[0][0],aGets[0],aHeader[0]
Private oDlgAgente
Private cTipComAnt := If(nTipoAg == ALT_DET,WorkAg->EEB_TIPCOM,"")
Private lNoUser := .F.

Begin Sequence

   IF nTipoAG <> INC_DET
      IF WorkAg->(Eof() .And. Bof())
         HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      Endif
   Endif

   cAlias := if(cOcorrencia==OC_PE,"EE7","EEC")

   IF cAlias == "EE7"
      cPedido := MemField("PEDIDO",cALIAS)
      bVlCom  := MemVarBlock("EE7_VALCOM")
   Else
      cPedido := MemField("PREEMB",cALIAS)
      bVlCom  := MemVarBlock("EEC_VALCOM")
   Endif

   cNewTit := If(EECFlags("FRESEGCOM"), STR0078, STR0015+Alltrim(cPedido)) //"Agente Recebedor de Comissão"

   /*
   Substituido a rotina original para tratar a array aAGCampos para Despesas Nacionais.
   Autor: Alexsander Martins dos Santos
   Data e Hora: 09/09/2004 às 09:55

   If nTipoAG==INC_DET

      WorkAg->(dbGoBottom())
      WorkAg->(dbSkip())

   ElseIf nTipoAg == ALT_DET

      If EECFlags("COMISSAO")
         aAgCampos:={"EEB_CODAGE","EEB_NOME"}
      EndIf

   EndIf
   */

   If Str(nTipoAG, 1) $ Str(INC_DET, 1)+Str(ALT_DET, 1)

      aAgCampos := aClone(aAgEnchoice)

      If EECFlags("FRESEGCOM")
         If (nInc := aScan(aAgCampos, "EEB_TIPOAG")) > 0
            aDel(aAgCampos, nInc)
            aSize(aAgCampos, Len(aAgCampos)-1)
         EndIf
      EndIf

      If nTipoAG = INC_DET
         WorkAg->(dbGoBottom())
         WorkAg->(dbSkip())
      Else
         If EECFlags("COMISSAO")
            aAgCampos := {"EEB_CODAGE", "EEB_NOME"}
         EndIf
      EndIf

   EndIf

   If nTipoAg == ALT_DET
      // ** Tratamentos para impedir a edição do campos de código do agente na opção de alteração.
      aCmpNotEdit := {"EEB_CODAGE"}
      For j:=1 To Len(aCmpNotEdit)
         nPos := aScan(aAgCampos,aCmpNotEdit[j])
         If nPos > 0
            aDel(aAgCampos,nPos)
            aSize(aAgCampos, Len(aAgCampos)-1)
         EndIf
      Next
   EndIf

   nRECNO:=WorkAg->(RECNO())

   //TRP-22/10/07
   If nTipoAG == INC_DET
      For nInc := 1 TO EEB->(FCount())
         M->&(EEB->(FIELDNAME(nInc))) := CRIAVAR(EEB->(FIELDNAME(nInc)))
      Next nInc
   Else
      For nInc := 1 TO WorkAg->(FCount())
         M->&(WorkAg->(FIELDNAME(nInc))) := WorkAg->(FIELDGET(nInc))
      Next nInc
   Endif

   If nTipoAG == ALT_DET .Or. nTipoAG == EXC_DET
      nCom_Old := If(!EECFlags("COMISSAO"),M->EEB_TXCOMI,M->EEB_VALCOM)
   Endif

   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"AG_DIALOG")
   EndIf

   If (SubStr(M->EEB_TIPOAG,1,1)==CD_AGC .And. EECFlags("COMISSAO"))
      If nTipoAG <> INC_DET
         If EECAgComs(cOcorrencia,nTipoAG,aAuto)
            nOpcA := 1
         EndIf
         If IsMemVar("lEEBAuto") .AND. !lEEBAuto
            oMark:oBrowse:Refresh()
         EndIf
      EndIf
   Else
      M->EEB_PEDIDO := cPedido
      M->EEB_OCORRE := cOcorrencia

      cNewTit += " - " + AllTrim(SubStr(cOpcoes, AT(Str(nTipoAG, 1), cOpcoes)+2, 13))

      If IsMemVar("lEEBAuto").AND. !lEEBAuto

         DEFINE MSDIALOG oDlgAgente TITLE cNewTit FROM 9,0 TO 35,80 OF oMainWnd

            If lNoUser
               AAdd(aAgEnchoice,"NOUSER")
            EndIf

            EnChoice("EEB",, 3,,,, aAgEnchoice, PosDlg(oDlgAgente), aAgCampos, 3)

            If lNoUser
               ADel(aAgEnchoice,Len(aAgEnchoice))
               ASize(aAgEnchoice,Len(aAgEnchoice)-1)
            EndIf

            // Botão para funcionar a exclusão
            DEFINE SBUTTON FROM 10025,187 TYPE 2 ACTION (.T.) ENABLE OF oDlgAgente PIXEL

         ACTIVATE MSDIALOG oDlgAgente ON INIT ;
            EnchoiceBar(oDlgAgente,{||nOpcA:=1,If(AP100DEAG(nTipoAG,nRECNO,,cOcorrencia),oDlgAgente:End(),nOpcA:=0)},{||oDlgAgente:End()}) CENTERED
      Else
         EnchAuto("EEB",ValidaEnch(aAuto, aAgCampos),{|| Obrigatorio(aGets,aTela)},3, aAgEnchoice)
         If !lMsErroAuto .And. AP100DEAG(nTipoAG,nRECNO,,cOcorrencia)
            nOpcA := 1
         EndIf
      EndIf
   EndIf

   IF nOpcA == 1 // Ok
      // ** By JBJ - 09/06/03 - Direcionar para tela específica de agente recebedor de comissao.
      If EECFlags("COMISSAO")
         If SubStr(M->EEB_TIPOAG,1,1)==CD_AGC
            If nTipoAG == INC_DET
               If !EECAgComs(cOcorrencia,nTipoAG,aAuto)
                  If IsMemVar("lEEBAuto") .AND. !lEEBAuto
                     oMark:oBrowse:Refresh()
                  EndIf
                  Break
               EndIf
               If IsMemVar("lEEBAuto") .AND. !lEEBAuto
                  oMark:oBrowse:Refresh()
               EndIf
            EndIf
         EndIf
      EndIf

      IF nTipoAG == INC_DET
         WorkAg->(RecLock("WorkAg", .T.))
         WorkAg->EEB_PEDIDO := cPedido
         //AOM - 08/08/2011
         IF WorkAg->(FieldPos("WK_FILTRO")) > 0
            WorkAg->WK_FILTRO  := "S"
         ENDIF
         nMAGENTES++
         IF SUBSTR(M->EEB_TIPOAG,1,1)==CD_AGC //AGENTE COMISSAO
            nMAGERCOM++
            nMAGETCOM+=If(!EECFlags("COMISSAO"),M->EEB_TXCOMI,M->EEB_VALCOM)
         EndIf
      Else
         WorkAg->(RecLock("WorkAg", .F.))
      EndIf        
      If ! (Str(nTipoAg,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
         AVReplace("M","WorkAg")

         If nTipoAG == ALT_DET
            nMAGETCOM -= nCom_Old
            If SUBSTR(M->EEB_TIPOAG,1,1)==CD_AGC //AGENTE COMISSAO
               nMAGETCOM+=If(!EECFlags("COMISSAO"),M->EEB_TXCOMI,M->EEB_VALCOM)
            ELSE
               WorkAg->EEB_TXCOMI:=0
            EndIf
         EndIf
      Elseif nTipoAg == EXC_DET
         nMAGETCOM -= nCom_Old
         nMAGENTES --
         If SUBSTR(M->EEB_TIPOAG,1,1)==CD_AGC //AGENTE COMISSAO
            nMAGERCOM--
         Endif
      EndIf

      // ** By JBJ 26/03/03 - 09:45.
      If !EECFlags("COMISSAO")
         If Len(ComboX3Box(cAlias+"_TIPCVL")) <= 3 // Nro de Opcoes de comissao
            If &("M->"+(cAlias)+"_TIPCVL") <> "3"  // Tipo de comissao
               Eval(bVlCom,nMagetCom)
            EndIf
         Else
            Eval(bVlCom,nMagetCom)
         EndIf
      EndIf

      If IsMemVar("lEEBAuto") .AND. !lEEBAuto
         oMark:oBrowse:Refresh()
         onAGENTES:Refresh()
      EndIf

      If !EECFlags("COMISSAO")
         If IsMemVar("lEEBAuto") .AND. !lEEBAuto
            onAGETCOM:Refresh()
         EndIf
      Else
         // ** Atualiza o total da comissão para o agente.
         If nTipoAg <> EXC_DET

            If cAlias == "EE7"
               Ap100PrecoI(.t.)
            Else
               Ae100PrecoI(.t.)
            EndIf

            If nTipoAg = ALT_DET .And. !AvFlags("COMISSAO_VARIOS_AGENTES")
               EECAtuIt(cOcorrencia) // Atualiza os itens para o agente alterado.
            EndIf

            EECTrataIt(.f.,cOcorrencia) // Verifica se existe algum item não agenciado.
            EECTotCom(cOcorrencia, .f., .T.)  // Totaliza a comissão para o agente.
            If IsMemVar("lEEBAuto") .AND. !lEEBAuto
               oMark:oBrowse:Refresh()
            EndIf
         EndIf
      EndIf
      WorkAg->(MsUnlock())
   Else
      If nTipoAG == INC_DET
         WorkAg->(dbGoTo(nRecOld))
      Endif
   EndIf
End sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AP100DEAG()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Validações e Tratamentos para deletar AGENTES
Autor       : Heder M Oliveira
Data/Hora   : 05/01/99 13:30
Revisao     :
Obs.        :
*/
Static Function AP100DEAG(nTipo,nRecno,lValidCom,cOcorrencia)
   Local lRet:=.T., lRetPto
   // JPM - 02/06/05
   Local lTipComChave := (Type("M->EE7_PEDIDO") <> "U" .And. EE8->(FieldPos("EE8_TIPCOM")) > 0) .Or.;
                         (Type("M->EEC_PREEMB") <> "U" .And. EE9->(FieldPos("EE9_TIPCOM")) > 0)
   Local cAlias
   Local cAliasIt

   Default lValidCom := .f.

   Private nTipoDet := nTipo

   WorkAg->(DbGoTo(nRecNo))

   Begin Sequence

      // ** JPM - 06/06/06 - Pto de entrada para validação do agente
      If EasyEntryPoint("EECAP101")
         If ValType((lRetPto := ExecBlock("EECAP101",.F.,.F.,"VALID_AG_COM"))) = "L" .And. !lRetPto
            lRet := .F.
            Break
         EndIf
      Endif

      If nTipo == INC_DET .OR. nTipo = ALT_DET
         lRet:=Obrigatorio(aGets,aTela)
         If !lRet
            Break
         EndIf

         If EECFlags("COMISSAO")
            If M->EEB_TIPCVL <> "3" .And. M->EEB_VALCOM = 0 .And. lValidCom
               EasyHelp(STR0075+AllTrim(AvSx3("EEB_VALCOM",AV_TITULO))+STR0076,STR0027) //"O campo '"###"' deve ser informado."###"Atenção"
               lRet:=.f.
               Break
            EndIf

            //JPM - 29/01/05 - validação que não era executada no OK em certas situações
            If !(lRet := If(lValidCom,Ap100Crit("EEB_VALCOM"),.t.))
               Break
            EndIf

            //JPM - 01/06/05
            If lValidCom .And. lTipComChave
               If (nTipo == INC_DET .Or. (nTipo == ALT_DET .And. WorkAg->EEB_TIPCOM <> M->EEB_TIPCOM)) .And.;
                  WorkAg->(dbSeek(M->EEB_CODAGE+M->EEB_TIPOAG+M->EEB_TIPCOM))

                  EasyHelp(STR0124 + AllTrim(M->EEB_CODAGE) + STR0125 + "'" +;
                          AllTrim(BscxBox("EEB_TIPCOM",M->EEB_TIPCOM)) + "'" + STR0126,STR0027)
                          //"O agente "##" com o tipo de comissão "##" ja se encontra cadastrado.","Atencao"
                  lRet := .f.
                  Break
               EndIf
            EndIf

         EndIf

         If !lTipComChave .Or. M->EEB_TIPOAG <> CD_AGC // JPM - 01/06/05
            If nTipo == INC_DET .and. WorkAg->(dbSeek(M->EEB_CODAGE+M->EEB_TIPOAG))
               EasyHelp(STR0119, STR0027) //"O agente com a classificação informada já se encontra cadastrado."###"Atenção"
               lRet := .F.
               Break
            EndIf
         EndIf

         If EECFlags("FRESEGCOM")

            If Left(M->EEB_TIPOAG, 1) <> CD_AGC //3 = Agente Recebedor de Comissão.
               EasyHelp(STR0120, STR0027) //"O agente informado não é do tipo Agente Recebedor de Comissão."###"Atenção"
               lRet := .F.
               Break
            EndIf

            If Empty(M->EEB_FORNEC) .AND. (EasyGParam("MV_EEC_ECO",,.f.) .Or. IsIntEnable("001") .Or. AvFlags("EEC_LOGIX")) // NCF - 11/11/2009 - Adicionada a verificação de integração com financeiro
               EasyHelp(STR0121, STR0027) //"Agente não permitido por não haver vinculo com o Fornecedor/Loja."###"Atenção"
               lRet := .F.
               Break
            EndIf

         EndIf

      ElseIf nTIPO==EXC_DET

         If !EECFlags("COMISSAO")
            If !MsgNoYes(STR0008,STR0009) //'Confirma Exclusao ? '###'Excluir'
               Break
            EndIf
         Else
            // ** Tratamento para os itens agenciados pelo agente a ser excluído.
            If cOcorrencia == OC_PE
               cAlias   := "EE8"
               cAliasIt := "WorkIt"
            Else
               cAlias:= "EE9"
               cAliasIt := "WorkIp"
            EndIf

            // ** Verifica se o agente possui algum item associado.
            (cAliasIt)->(DbGoTop())
            Do While (cAliasIt)->(!Eof())
               // ** Desconsidera os itens não marcados para embarque.
               If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
                  WorkIp->(DbSkip())
                  Loop
               EndIf

               //If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE - JPM - 02/06/05
               If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE .And.;
                  If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") == WorkAg->EEB_TIPCOM,.t.)

                  EasyHelp(STR0077,STR0049) //"Este agente está vinculado à itens do processo."###"Aviso"
                  Exit
               EndIf

               (cAliasIt)->(dbSkip())
            EndDo

            If IsMemVar("lEEBAuto") .AND. !lEEBAuto .And. !MsgNoYes(STR0008,STR0009) //'Confirma Exclusao ? '###'Excluir'
               Break
            EndIf

            (cAliasIt)->(DbGoTop())
            Do While (cAliasIt)->(!Eof())
               // ** Desconsidera os itens não marcados para embarque.
               If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
                  WorkIp->(DbSkip())
                  Loop
               EndIf

               //If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE - JPM - 02/05/06
               If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE .And.;
                  If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") == WorkAg->EEB_TIPCOM,.t.)//JPM - 30/05/05

                  If lTipComChave //JPM - 02/06/05
                     (cAliasIt)->&(cAlias+"_TIPCOM") := ""
                  EndIf

                  (cAliasIt)->&(cAlias+"_CODAGE") := ""
                  (cAliasIt)->&(cAlias+"_DSCAGE") := ""
                  (cAliasIt)->&(cAlias+"_PERCOM") := 0
                  (cAliasIt)->&(cAlias+"_VLCOM")  := 0
               EndIf
               (cAliasIt)->(DbSkip())
            EndDo
            (cAliasIt)->(DbGoTop())
         EndIf

         WorkAg->(dbGoTo(nRECNO))
         If WorkAg->WK_RECNO # 0
            aAdd(aAgDeletados,WorkAg->WK_RECNO)
         EndIf
         WorkAg->(dbDelete())
         WorkAg->(dbSkip(-1))
         IF WorkAg->(Bof())
            WorkAg->(dbGoTop())
         Endif

         // ** Tratamento para acerto do campo resumo da comissão.
         If EECFlags("COMISSAO")
            If cAlias ="EE8"
               M->EE7_DSCCOM := EECResCom()
            Else
               M->EEC_DSCCOM := EECResCom()
            EndIf
         EndIf
      EndIf
      nRodTotCom := WorkAg->EEB_TOTCOM  // GFP - 11/04/2014
   End Sequence

   WorkAg->(DbGoTo(nRecNo))

Return lRet

/*
Funcao      : EECAgComs(cOcorrencia, nOpcAg)
Parametros  : cOcorrencia = Pedido/Embarque.
              nOpcAg = INC_DET/ALT_DET/EXC_DET.
Retorno     : .t./.f.
Objetivos   : Tela específica para agentes recebedores de comissao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/06/03 08:35.
Revisao     :
Obs.        :
*/
*-------------------------------------------*
Static Function EECAgComs(cOcorrencia,nOpcAg,aAuto)
*-------------------------------------------*
Local lRet:=.f., oDlg
Local cOldArea:=Select(), cAlias, cPedido, cTitulo, cMoeda
Local nInc, nRecNo, nOpcA:=0, nRecOld := WorkAg->(RecNo())
Local aPos:={}

Private aTela[0][0],aGets[0],aHeader[0]
Private aCmpToEdit:={} // utilizado no ponto de entrada
Private aNewCmpAg:={}
Private lOkAg := .F.

Private bOk := {|| lOkAg := .t., If(AP100DEAG(nOpcAg,nRecNo,.t.,cOcorrencia),(If(IF(IsMemVar("lEEBAuto"),lEEBAuto,.F.),Nil,oDlg:End()),lRet:=.t.),lRet:=.f.)}

Private bCancel := {||oDlg:End()}

Begin Sequence

   cAlias := if(cOcorrencia==OC_PE,"EE7","EEC")
   nRecNo:=WorkAg->(Recno())

   If cAlias == "EE7"
      M->EEB_PEDIDO := MemField("PEDIDO",cAlias)
   Else
      M->EEB_PEDIDO := MemField("PREEMB",cAlias)
   Endif

   cMoeda := MemField("MOEDA" ,cAlias)

   M->EEB_OCORRE := cOcorrencia

   cTitulo := STR0078 //"Agente Recebedor de Comissão"

   // ** Campos específicos.
   aNewCmpAg := aClone(aAgEnchoice)
   aAdd(aNewCmpAg,"EEB_TIPCOM")
   aAdd(aNewCmpAg,"EEB_TIPCVL")
   aAdd(aNewCmpAg,"EEB_VALCOM")
   aAdd(aNewCmpAg,"EEB_REFAGE")

   aCmpToEdit :=  {"EEB_NOME", "EEB_TIPCOM", "EEB_TIPCVL", "EEB_VALCOM", "EEB_REFAGE"}

   aCmpToEdit:= AddCpoUser(aCmpToEdit,"EEB","1")

   IF EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"COM_DIALOG")
   Endif

   If EasyGParam("MV_AVG0077",,.F.)
      nRec := WorkAg->(RecNo())
      WorkAg->(DbGoTop())
      Do While WorkAg->(!EoF())
         If WorkAg->EEB_TIPCVL == "3"
            M->EEB_TIPCVL := "3"  //"2"  // GFP - 11/11/2015
            Exit
         EndIf
         WorkAg->(DbSkip())
      EndDo
      WorkAg->(DbGoto(nRec))
   EndIf

   If IsMemVar("lEEBAuto") .AND. !lEEBAuto

      DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 35,80 OF oMainWnd
         aPos := PosDlg(oDlg)

         aPos[3] -= 35
         EnChoice( "EEB",,3,,,,aNewCmpAg ,aPos,IF(STR(nOpcAg,1)$Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aCmpToEdit),3)

         @ 160,1.5 To 195.5,315 Of oDlg Pixel
         @ 175,10 Say STR0079+cMoeda+") " Size 60,7 Of oDlg Pixel  //"Total Comissão ("
         @ 175,70 MsGet M->EEB_TOTCOM When .f. Size 50,6 Right Pixel Picture AvSx3("EEB_TOTCOM",AV_PICTURE) Of oDlg

         // Botão para funcionar a exclusão
         DEFINE SBUTTON FROM 10025,187 TYPE 2 ACTION (.T.) ENABLE OF oDlg PIXEL

      ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,bOK,bCancel) CENTERED

   Else
      EnchAuto("EEB",ValidaEnch(aAuto, IF(STR(nOpcAg,1)$Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aCmpToEdit)),{|| Obrigatorio(aGets,aTela)},nOpcAg, aNewCmpAg)
      If !lMsErroAuto
         Eval(bOk)
      EndIf
   EndIf

End Sequence

DbSelectArea(cOldArea)

Return lRet

/*
    Funcao   : AP100W(cCAMPOWHEN)
    Autor    : Heder M Oliveira
    Data     : 01/07/99 11:57
    Revisao  : 01/07/99 11:57
    Uso      : Regras para inicializar campos
    Recebe   : cCAMPOWHEN := identificador do campo
    Retorna  :

*/
FUNCTION AP100W(cCAMPOWHEN)

LOCAL LRET:=.T., aOrd := {}
Local cOldProc:=""
Local lEE8_CODAGE, lEE9_CODAGE
Local cRelease

Begin Sequence

    DO CASE
        CASE cCAMPOWHEN="EE7_DTSLCR"
            lRet := lAltera .And. Empty(M->EE7_DTAPCR)
        CASE cCAMPOWHEN="EE7_ORIGEM"
            IF ( lALTERA )
                cWHENOD:="O"
                cVIA:=M->EE7_VIA
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_DEST"
            IF ( lALTERA )
                cWHENOD:="D"
                cVIA:=M->EE7_VIA
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_IMPORT"
            IF ( lALTERA )
               cWHENSA1:="EE7_IMPORT"
               cCODIMPORT := M->EE7_IMPORT+M->EE7_IMLOJA
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_CLIENT"
            IF ( lALTERA )
               cWHENSA1:="EE7_CLIENT"
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_CONSIG"
            IF ( lALTERA )
               cWHENSA1:="EE7_CONSIG"
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_FORN"
            IF ( lALTERA )
               cWHENSA2:="EE7_FORN"
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_RESPON"
           IF (lALTERA .AND. EMPTY(M->EE7_FORN))
          //    MSGSTOP("Necessário informar Fornecedor","Atenção")
              lRET:=.F.
           ENDIF

        CASE cCAMPOWHEN="EE7_EXPORT"
            IF ( lALTERA )
               cWHENSA2:="EE7_EXPORT"
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_BENEF"
            IF ( lALTERA )
               cWHENSA2:="EE7_BENEF"
            ELSE
               lRET:=.F.
            ENDIF
        CASE cCAMPOWHEN="EE7_TIPTRA"
           IF ( lALTERA )
              IF Empty(M->EE7_VIA)
            //     MsgStop("Necessario informar a VIA !","Aviso")
                 lRet:=.F.
              ELSE
                 IF EMPTY(M->EE7_ORIGEM)
              //      MsgStop("Necessario informar a Origem !","Aviso")
                    lRet:=.F.
                 Else
                    IF EMPTY(M->EE7_DEST)
                //       MsgStop("Necessario informar o Destino !","Aviso")
                       lRet:=.F.
                    Endif
                 Endif
              Endif
           ENDIF

        CASE cCAMPOWHEN == "EEN_IMPORT"
             cWHENSA1 := "EEN_IMPORT"

        CASE cCampoWhen=="EE7_VALCOM"  // ** By JBJ - 03/04/02 - 11:44
           lRet := .f. // lRet:=If(M->EE7_TIPCVL="3",.f.,.t.)

        Case cCampoWhen =="EE8_SLDINI"

           If lCommodity
              If !Empty(M->EE8_DTFIX)
                 lRet:=.f.
                 Break
              EndIf
           EndIf

           If lIntermed .And. AvGetM0Fil() == cFilEx
              aOrd:=SaveOrd({"EE7"})
              EE7->(DbSetOrder(1))
              If EE7->(DbSeek(cFilBr+M->EE7_PEDIDO))
                 lRet:=.f.
                 Break
              EndIf
           EndIf

           aOrd := SaveOrd({"EE8","EE9","EEC"})

           EE8->(DbSetOrder(1))
           If EE8->(DbSeek(xFilial("EE8")+M->(EE8_PEDIDO+EE8_SEQUEN)))
              If EE8->EE8_SLDATU = 0
                 lRet := .f.
                 EE9->(DbSetOrder(1))
                 EEC->(DbSetOrder(1))

                 cOldProc := ""
                 If EE9->(DbSeek(xFilial("EE9")+EE8->EE8_PEDIDO+EE8->EE8_SEQUEN))
                    Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9")  .And.;
                                                 EE9->EE9_PEDIDO == EE8->EE8_PEDIDO .And.;
                                                 EE9->EE9_SEQUEN == EE8->EE8_SEQUEN

                       If cOldProc <> EE9->EE9_PREEMB
                          If EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))
                             If Empty(EEC->EEC_DTEMBA)
                                lRet:=.t.
                                Break
                             EndIf
                          EndIf
                          cOldProc := EE9->EE9_PREEMB
                       EndIf

                       EE9->(DbSkip())
                    EndDo
                 Else
                    lRet:=.t.
                 EndIf
              EndIf
           EndIf

        Case cCampoWhen =="EE8_PRECO"
           If lCommodity
              If !Empty(M->EE8_DTFIX)
                 lRet:=.f.
              EndIf
           EndIf
        Case cCampoWhen=="EE8_DTCOTA"
           lRet:=If(Empty(M->EE8_DTFIX),.f.,.t.)
        Case cCampoWhen=="EE8_DTFIX"
           lRet:=If(Empty(M->EE8_DTFIX),.f.,.t.)
        Case cCampoWhen=="EE8_PRCFIX"
           lRet:=If(Empty(M->EE8_DTFIX),.f.,.t.)
        Case cCampoWhen=="EE8_QTDFIX"
           lRet:=If(Empty(M->EE8_DTFIX),.f.,.t.)
        Case cCampoWhen=="EE8_QTDLOT"
           lRet:=If(Empty(M->EE8_DTFIX),.f.,.t.)
        Case cCampoWhen=="EEB_VALCOM"
           If M->EEB_TIPCVL = "3" // Percentual por item.
              lRet:=.f.
           EndIf
        Case cCampoWhen $ "EE8_PERCOM/EE8_VLCOM" //LRS - 27/11/2014 - colocado na validação o campo EE8_VLCOM
           If EECFlags("COMISSAO")
              If !Empty(M->EE8_CODAGE)
                 //If WorkAg->(DbSeek(M->EE8_CODAGE+CD_AGC)) - JPM - 02/06/05
                 If WorkAg->(DbSeek(M->EE8_CODAGE+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+;
                                    If(EE8->(FieldPos("EE8_TIPCOM")) > 0,M->EE8_TIPCOM,"")))

                    If WorkAg->EEB_TIPCVL = "1" // Percentual.
                       lRet := .f.
                    ElseIf WorkAg->EEB_TIPCVL = "2" // Valor Fixo.
                       lRet := .f.
                    EndIf
                 EndIf
              Else
                 lRet:=.f.
              EndIf
           Else
              lRet:= M->EE7_TIPCVL == "3"
           EndIf
           IF cCampoWhen == "EE8_VLCOM" //LRS - 16/10/2018
              lRet := .F.
           EndIF
        Case cCampoWhen=="EE8_CODAGE"
           If EECFlags("COMISSAO") .And. AvFlags("COMISSAO_VARIOS_AGENTES")
              WorkAg->(DbGoTop())
              lEE8_CODAGE:= Type("M->EE8_CODAGE") = "C"
              lEE9_CODAGE:= Type("M->EE9_CODAGE") = "C"
              While WorkAg->(!EoF())
                 If Left(WorkAg->EEB_TIPOAG,1) == CD_AGC
                    If WorkAg->EEB_TIPCVL <> "3"
                       lRet := .f.
                       If lEE8_CODAGE
                          M->EE8_CODAGE := Space(AvSx3("EE8_CODAGE",AV_TAMANHO))
                          M->EE8_DSCAGE := Space(AvSx3("EE8_DSCAGE",AV_TAMANHO))
                       ElseIf lEE9_CODAGE
                          M->EE9_CODAGE := Space(AvSx3("EE9_CODAGE",AV_TAMANHO))
                          M->EE9_DSCAGE := Space(AvSx3("EE9_DSCAGE",AV_TAMANHO))
                       EndIf
                    EndIf
                    Exit
                 EndIf
                 WorkAg->(DbSkip())
              EndDo
           EndIf

        Case cCampoWhen == "EE8_PRENEG"
             If ALTERA .And. !(EE7->EE7_INTERM $ cNao) .And. M->EE7_INTERM $ cNao
                lRet:=.f.
             Else
                If M->EE7_INTERM $ cNao
                   lRet := .f.
                EndIf
             EndIf

        Case cCampoWhen $ "EE8_EMBAL1/EE8_QE/EE8_QTDEM1"

             If lIntermed .And. AvGetM0Fil() == cFilEx
                aOrd:=SaveOrd({"EE7"})
                EE7->(DbSetOrder(1))
                If EE7->(DbSeek(cFilBr+M->EE7_PEDIDO))
                   lRet:=.f.
                   Break
                EndIf
             EndIf

        Case cCampoWhen == "EE7_INTERM"

             /* by jbj - 16/06/05 - Caso o pedido na filial de off-shore possuir embarque o campo não poderá ser
                                    editado.*/

             If M->EE7_INTERM $ cSim
                aOrd:=SaveOrd({"EE7","EE8"})

                EE7->(DbSetOrder(1))
                If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))
                   EE8->(DbSetOrder(1))
                   If EE8->(DbSeek(cFilEx+M->EE7_PEDIDO))
                      Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL  == cFilEx .And.;
                                                   EE8->EE8_PEDIDO == M->EE7_PEDIDO

                         If EE8->EE8_SLDINI <> EE8->EE8_SLDATU // neste caso o pedido no exterior já possui embarque.
                            lRet := .f.
                            Break
                         EndIf
                         EE8->(DbSkip())
                      EndDo
                   EndIf
                EndIf
             EndIf

        Case cCampoWhen == "EE8_SEQ_LC"

             If Empty(M->EE8_LC_NUM)
                lRet := .f.
             ElseIf Posicione("EEL",1,xFilial("EE7")+M->EE8_LC_NUM,"EEL_CTPROD") $ cNao //Se não controla produto
                lRet := .f.
             EndIf

             If !lRet
                M->EE8_SEQ_LC := CriaVar("EE8_SEQ_LC")
             EndIf

        Case cCampoWhen == "EE7_SEGURO"
            If EE7->(FieldPos("EE7_TIPSEG")) > 0
               lRet := (M->EE7_TIPSEG == "1") // O seguro é calculado a partir do percentual digitado ("1")
            Else
               lRet := .T.
            EndIf
        Case cCampoWhen == "EE7_SEGPRE"
             If EE7->(FieldPos("EE7_TIPSEG")) > 0
                lRet := (M->EE7_TIPSEG == "2") // O valor do seguro é digitado diretamente pelo usuário (Valor Fixo)
             Else
                lRet := .T.
             EndIf
        Case cCampoWhen == "EE7_SEGPRE"
             lRet := (M->EE7_TIPSEG == "2") // O valor do seguro é digitado diretamente pelo usuário (Valor Fixo)

        CASE cCAMPOWHEN="EE7_DTSLAP"
            lRet := lAltera /*.And. !Empty(M->EE7_DTAPCR)*/ .And. Empty(M->EE7_DTAPPE)

        //LRS - 02/02/2016 - When para o campo de ato concessario
        CASE cCAMPOWHEN == "EE8_ATOCON"
            IF EasyGParam("MV_EEC_EDC",,.F.)
            	lRet := .F.
            EndIF
        CASE cCampoWhen == "EE9_VLCOM"  
            //OSSME-5553 MFR 29/01/2021
            cRelease := GetRPORelease() 
            cRelease := SubSTR(cRelease,Rat(".",cRelease)+1)
            Return !cRelease >= '027' //SE for release >= 027 nao permite a alteração
    ENDCASE

End Sequence

RestOrd(aOrd,.t.)

RETURN lRET

/*
Funcao      : VIAODF3(cWHENOD,cVIA)
Parametros  : cWHENOD:="O"  - ORIGEM
                       "D"  - DESTINO
              cPRC := OC_PE - PROCESSO
                      OC_EM - EMBARQUE
Retorno     : Codigo Origem / Destino
Objetivos   : Consulta padrao com filtro
Autor       : Heder M Oliveira
Data/Hora   : 01/07/99 10:57
Revisao     : Jeferson Barros Jr. - 14/05/01 - 11:00
Obs.        :
*/
FUNCTION VIAODF3(cWHENOD,cVIA,cPRC)

Local lRet := .f.
Local OldArea:=SELECT(), aOrd := SaveOrd({"SYR"})
Local oDlg, Tb_Campos:={}
Local cCampo,cTit1,bReturn,bSetF3 := SetKey(VK_F3)
Local oSeek,cSeek,oOrdem,cOrd,nOrdem,aOrdem:={}
Local cCpo, nRec, cKey, bKey, cKeyInd, cSigla
Local cArqTemp, cArqTemp1
Local oMark

Local aWork:={{'WK_RECNO' ,'N',07,0},;  // Numero do Registro
              {'WK_DESC1','C',25,0},;   // Descricao Origem ou Destino
              {'WK_DESC2','C',25,0}}  // Descricao Origem ou Destino


//**JBJ - 09/08/2001 - 14:08 - Versao 609
Local lVisualizar
Local lExcluir
//**

Private aHeader[0],aCampos:=Array(SYR->(FCount()))
Private cFwhenod:=cWhenod,cFvia:=cVia
Private lInverte := .F., cMarca := GetMark()

Private cMacro := "Empty(SYR->YR_PAIS_DE)"

Default cWhenOD := ReadVar()
Default cPrc := IF(Left(cWhenOD,3)=="EEC",OC_EM,OC_PE)

//RegToMemory("EE7") //Nopado por MCF - 30/10/2015
//RegToMemory("EEC") //Nopado por MCF - 16/12/2015

IF Empty(cVia)
   IF cPrc == OC_PE
      IF Empty(M->EE7_VIA)
         cVia := EE7->EE7_VIA
      Else
         cVia := M->EE7_VIA
      Endif
   Else
      IF Empty(M->EEC_VIA)
         cVia := EEC->EEC_VIA
      Else
         cVia := M->EEC_VIA
      Endif
   Endif
EndIf

SYR->(dbSetOrder(1)) // FILIAL+VIA+ORIGEM+DESTINO+TIPTRAN

// *** CAF 24/04/2000 11:00 - Versao Protheus
cCpo := AllTrim(Substr(ReadVar(),4))

cWhenod := Upper(cWhenod)

IF Substr(cCpo,5) == "ORIGEM"
   cWhenOD := "O"
Else
   cWhenOD := "D"
Endif

IF Left(cCpo,3) == "EEC"
   cPRC := OC_EM
Else
   cPRC := OC_PE
Endif
// ***

//**JBJ - 09/08/2001 - 14:10 - Versao 609

//**

Begin Sequence
   //LRS - 21/08/2015 - Cria a validação caso a variavel nSelecao não for carregada pela Function AP100MAN
   If Type("nSelecao") <> "U"
      lVisualizar:=If(nSelecao = VISUALIZAR,.T.,.F.)
      lExcluir   :=If(nSelecao = EXCLUIR,.T.,.F.)
      If lVisualizar .or. lExcluir
		   ConPad1(,,,"SY9",,)
		   Return .F.
      Endif
   Else
	   Return ConPad1(,,,"EY9",,)
   EndIF

   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"F3_VIA")
   EndIf

   //evitar recursividade
   Set Key VK_F3 TO
   If ( Empty(cVia) )
       HELP(" ",1,"AVG000652") //MsgStop("Necessário informar Via.","Atenção")
       Break
   ElseIf cWhenod=="D" .AND. Empty(MemField("ORIGEM",IF(cPRC==OC_PE,"EE7","EEC")))
       HELP(" ",1,"AVG0000653") //MsgStop("Necessário informar Origem.","Atenção")
       Break
   Endif

   cArqTemp:= E_CriaTrab("SYR",aWork,"WKORGDST")

   //Criando os índices
   If cWhenod=="O"
      cKeyInd := "YR_ORIGEM"
   Else
      cKeyInd := "YR_DESTINO"
   EndIf

   IndRegua("WKORGDST",cArqTemp+TEOrdBagExt(),cKeyInd)
   cArqTemp1 := CriaTrab(,.F.)
   IndRegua("WKORGDST",cArqTemp1+TEOrdBagExt(),"WK_DESC1")  // GFP - 27/05/2014

   Set Index To (cArqTemp+TEOrdBagExt()),(cArqTemp1+TEOrdBagExt())

   //Gravando os Dados
   If cWhenod=="O"
      cKey := AvKey(cVia,"YR_VIA")
      bKey := {|| SYR->YR_VIA }
   Else
      cKey := AvKey(cVia,"YR_VIA")+MemField("ORIGEM",IF(cPRC==OC_PE,"EE7","EEC"))
      bKey := {|| SYR->YR_VIA+SYR->YR_ORIGEM }
   Endif

   SYR->(Dbseek(XFILIAL("SYR")+cKey))

   Do While SYR->(!EOF().AND. YR_FILIAL==xFilial("SYR")) .And. Eval(bKey) == cKey

      /*
      Nopado por ER - 05/09/2008
      If !Empty(SYR->YR_PAIS_OR) //ASK 14/08/2007 - Filtro para trazer apenas as rotas incluídas na Exportação
        SYR->(DbSkip())
        LOOP
      EndIf
      */

      ////////////////////////////////////////////////////////////////////////////////////////////
      //ER - 05/09/2008.                                                                        //
      //Essa alteração permite que o valor da variavel cMacro seja alterada via ponto de entrada//
      //e assim possam ser customizadas novas validações ou retirada as validações padrão.      //
      //Ponto de Entrada: "F3_VIA"                                                              //
      ////////////////////////////////////////////////////////////////////////////////////////////
      If !Empty(cMacro)
         If &(cMacro)
            SYR->(DbSkip())
            Loop
         EndIf
      EndIf

      WKORGDST->(RecLock("WKORGDST", .T.))
      AVReplace("SYR","WKORGDST")

      WKORGDST->WK_RECNO := SYR->(Recno())

      IF cWhenod=="O"
         cSigla1 := WKORGDST->YR_ORIGEM
         cSigla2 := WKORGDST->YR_DESTINO
      Else
         cSigla1 := WKORGDST->YR_DESTINO
         cSigla2 := WKORGDST->YR_ORIGEM
      Endif

      WKORGDST->WK_DESC1 :=Posicione("SY9",2,xFilial("SY9")+cSigla1,"Y9_DESCR") //Descrição da Origem e Destino
      WKORGDST->WK_DESC2 :=Posicione("SY9",2,xFilial("SY9")+cSigla2,"Y9_DESCR") //Descrição da Origem e Destino

      WKORGDST->(MsUnlock())  
      SYR->(dbSkip())

   EndDo

   WKORGDST->(Dbgotop())

   If ( Upper(cWhenod)=="O") //Consulta pela Origem
      If cPRC=OC_PE
         //Processo
         bReturn:={||M->EE7_ORIGEM := WKORGDST->YR_ORIGEM ,;
                     M->EE7_DEST   := WKORGDST->YR_DESTINO,;
                     M->EE7_TIPTRA := WKORGDST->YR_TIPTRAN,;
                     M->EE7_DSCORI := WKORGDST->WK_DESC1,;
                     M->EE7_DSCDES := Posicione("SY9",2,xFilial("SY9")+M->EE7_DEST,"Y9_DESCR"),;
                     M->EE7_PAISET := WKORGDST->YR_PAIS_DE,; // AST - 28/07/08 - Atualizar o país de entrega
                     oDlg:End()}

      Else
         //Embarque
         bReturn:={||M->EEC_ORIGEM := WKORGDST->YR_ORIGEM ,;
                     M->EEC_DEST   := WKORGDST->YR_DESTINO,;
                     M->EEC_TIPTRA := WKORGDST->YR_TIPTRAN,;
                     M->EEC_DSCORI := WKORGDST->WK_DESC1,;
                     M->EEC_DSCDES := Posicione("SY9",2,xFilial("SY9")+M->EEC_DEST,"Y9_DESCR"),;
                     M->EEC_PAISDT := WKORGDST->YR_PAIS_DE,;
                     oDlg:End()}
      EndIf

      cTIT1 := STR0016+cVia //"Origens da Via "

      //Opcoes de consulta
      AADD(aORDEM,STR0017) //"Origem"
      AADD(aORDEM,STR0018)  //"Descrição"

      //Colunas no Browse
      AADD(Tb_Campos,{{||WKORGDST->YR_ORIGEM+" - "+WKORGDST->WK_DESC1},,STR0017}) //"Origem"
      AADD(Tb_Campos,{{||WKORGDST->YR_DESTINO+" - "+WKORGDST->WK_DESC2},,STR0019})//"Destino"  // GFP - 27/05/2014
      //AADD(Tb_Campos,{"YR_DESTINO" ,,STR0019})                       //"Destino"
   Else
      //Consulta pelo Destino
      If cPRC=OC_PE
         bReturn:={||M->EE7_DEST   := WKORGDST->YR_DESTINO,;
                     M->EE7_TIPTRA := WKORGDST->YR_TIPTRAN,;
                     M->EE7_DSCDES := WKORGDST->WK_DESC1,;
                     oDlg:End()}
      Else
         bReturn:={||M->EEC_DEST   := WKORGDST->YR_DESTINO,;
                     M->EEC_TIPTRA := WKORGDST->YR_TIPTRAN,;
                     M->EEC_DSCDES := WKORGDST->WK_DESC1,;
                     oDlg:End()}
      EndIf

      cTIT1:=STR0020+cVia //"Destinos da Via "

      //Opcoes de consulta
      AADD(aORDEM,STR0019) //"Destino"
      AADD(aORDEM,STR0018) //"Descrição"

      //Colunas do browse
      AADD(Tb_Campos,{{||WKORGDST->YR_DESTINO+" - "+WKORGDST->WK_DESC1},,STR0019}) //"Destino"
      AADD(Tb_Campos,{{||WKORGDST->YR_ORIGEM+" - "+WKORGDST->WK_DESC2},,STR0017})//"Destino"  // GFP - 27/05/2017
      //AADD(Tb_Campos,{"YR_ORIGEM",,STR0017})         //"Origem"
   EndIf

   AADD(TB_CAMPOS,{{||BSCTRAN(YR_TIPTRAN)},,STR0021})    //"Tipo Tranporte"

   WKORGDST->(dbSetOrder(1))
   cSeek:=Space(AVSX3("Y9_DESCR")[AV_TAMANHO])

   //RMD - 14/11/12 - Posiciona na origem/destino atual
   If !Empty(M->&(cCpo))
	   WKORGDST->(DbSeek(M->&(cCpo)))
   EndIf

   DEFINE MSDIALOG oDlg TITLE cTIT1 FROM 62,15 TO 310,460 OF oMainWnd PIXEL

      oMark:= MsSelect():New("WKORGDST",,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
      oMark:baval:= {|| nRec := WKORGDST->WK_RECNO, lRet:=.t.,Eval(bReturn) }

      @ 091, 14 Say STR0022 Size 42,7 OF oDLG PIXEL //"Pesquisar por:"
      @ 090, 59 Combobox oOrdem Var cOrd Items aOrdem Size 119, 42 OF oDlg PIXEL ON CHANGE ViaChgOrd(cWhenod,cOrd,@cSeek,oMark)

      @ 104, 14 Say STR0023 Size 32, 7 OF oDlg PIXEL //"Localizar"
      @ 104, 58 Msget oSeek Var cSeek Size 120, 10 OF oDlg PIXEL

      oSeek:bChange := {|x| VIASEEK(oMark,oSeek) }

      DEFINE SBUTTON FROM 10,187 TYPE 1  ACTION (Eval(oMark:baval)) ENABLE OF oDlg PIXEL
      DEFINE SBUTTON FROM 25,187 TYPE 2  ACTION (oDlg:End()) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg

   WKORGDST->(E_EraseArq(cArqTemp,cArqTemp1))

   IF !Empty(nRec)
      SYR->(dbGoTo(nRec))
   Endif

End Sequence

SetKey(VK_F3,bSetF3)

RestOrd(aOrd)

DbSelectArea(OldArea)

//RMD - 14/11/12 - Atualiza a enchoice da manutenção de pedido/embarque
Do Case
	Case cPRC == OC_EM
		If ValType(oEncCapa) == "O"
			oEncCapa:Refresh()
		EndIf

	Case cPRC == OC_PE
		If ValType(oEnc) == "O"
			oEnc:Refresh()
		EndIf

EndCase

Return .F. // lRet

/*
Funcao      : ViaChgOrd(cWhenod,cOrd,cSeek,oMark)
Parametros  : cWHENOD := "O"  - ORIGEM
                         "D"  - DESTINO
              cOrd    := "Origem"
                      := "Destino"
                      := "Descri4ção"
              cSeek   := Item a ser consultado
              oMark   := Objeto p/ refresh do browse
Retorno     : .T.
Objetivos   : Alterar o Indice do Arquivo Temporário
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/05/2001 - 11:00
Revisao     :
Obs.        :
*/
Static Function ViaChgOrd(cWhenod,cOrd,cSeek,oMark)
Local nOrd := 1

IF cWhenod == "O"
   IF Upper(cOrd) == "ORIGEM"
      cSeek:=Space(Len(WKORGDST->YR_ORIGEM))
      nOrd := 1
   Else
      cSeek:=Space(Len(WKORGDST->WK_DESC1))
      nOrd := 2
   Endif
Else
   IF Upper(cOrd) == "DESTINO"
      cSeek:=Space(Len(WKORGDST->YR_DESTINO))
      nOrd := 1
   Else
      cSeek:=Space(Len(WKORGDST->WK_DESC1))
      nOrd := 2
   Endif
Endif

WKORGDST->(dbSetOrder(nOrd))
oMark:oBrowse:Refresh()

Return .t.

/*
Funcao      : VIASEEK(oMark,oSeek)
Parametros  : oMark := Objeto p/ refresh do browse
              oSeek := Objeto p/ executar oGet:Buffer
Retorno     : .t.
Objetivos   : Efetuar pesquisa no momento da digitação
Autor       : Jeferson Barros Jr.
Data/Hora   : 16/05/2001 - 11:30
Revisao     :
Obs.        :
*/
Static Function VIASEEK(oMark,oSeek)

WKORGDST->(dbSeek(RTrim(oSeek:oGet:Buffer)))
oMark:oBrowse:Refresh()

Return .t.

/*
Funcao      : AP100INST()
Parametros  : Nenhum
Retorno     : .T./.F.
Objetivos   : Executa rotina externa de lancamento de agentes/representantes
Autor       : Heder M Oliveira
Data/Hora   : 02/07/99 10:01
Revisao     :
Obs.        :
*/
Function AP100INST(cOcorrencia,nOpc)

Local lRet:=.T.,cOldArea:=Select(),nOpcA:=0,oDlg,oMPEDIDO
Local nL1:=1.4, nL2:=2.2, nL3:=3.0, nC1:=0.8, nC2:=15, nC3:=08, nC4:=20
Local cFileBackup := CriaTrab(,.f.)
Local cAlias, cPedido

Local bOk := {|| nOpcA := 1, If(IF(IsMemVar("lEEBAuto"),lEEBAuto,.F.), Nil, oDlg:End()) }
Local bCancel := {|| oDlg:End() }, aDelBak
Local oPanel

Private onINST,nMINS:=0

cOcorrencia := Upper(cOcorrencia)

Begin Sequence

   IF ! (cOcorrencia $ OC_PE+"/"+OC_EM)
      HELP(" ",1,"AVG0000654") //MsgStop("Erro no parametro da função AP100INST","Aviso")
      lRet := .F.
      Break
   Endif

   cAlias  := if(cOcorrencia==OC_PE,"EE7","EEC")
   cPedido := if(cOcorrencia==OC_PE,MemField("PEDIDO",cALIAS),MemField("PREEMB",cALIAS))

   dbSelectArea("WorkIn")
   WorkIn->(dbGoTop())
   TETempBackup(cFileBackup)
   aDelBak := aClone(aInDeletados)
   nMINS := ContaInst()
   dbGoTop()

   nOpcA := 0

   DEFINE MSDIALOG oDlg TITLE STR0024 FROM 9,0 TO 28,70 OF oMainWnd //"Instituições Bancárias"

      oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.15)

      @ nL1,nC1 SAY If(cOcorrencia == "P",STR0011,STR0129) Of oPanel //"Pedido Export." ### "Embarque"  // GFP - 01/10/2012
      @ nL1,nC2 SAY STR0025 Of oPanel //"Total Instit."

      @ nL1,nC3 MSGET oMPEDIDO VAR cPedido WHEN .F. SIZE 50,7 RIGHT Of oPanel
      @ nL1,nC4 MSGET onINS    VAR nMINS   WHEN .F. SIZE 50,7 RIGHT Of oPanel

      //wfs alinhamento
      oPanel:Align:= CONTROL_ALIGN_TOP

      oMark:= MSSELECT():New("WorkIn",,,aInBrowse,,,aInPos)
      oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //wfs
      oMark:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AP100INSMAN(VIS_DET,cOcorrencia,oMark),AP100INSMAN(ALT_DET,cOcorrencia,oMark)) }

   ACTIVATE MSDIALOG oDlg ON INIT ;
        AVBar(nOpc,oDlg,bOk,bCancel,ENCH_ADD,{|opc| AP100INSMAN(opc,cOcorrencia,oMark)}) CENTERED

   If nOpcA == 0 //Cancelar
      dbSelectArea("WorkIn")
      AvZap()
      TERestBackup(cFileBackup)
      aInDeletados := aClone(aDelBak)
   EndIf

   FErase(cFileBackup+GetDBExtension())

End Sequence

dbselectarea(cOldArea)

Return lRet



/*
Funcao      : ValidarGrv(nTipoINS, cPedido, cOcorrencia, cAlias)
Parametros  : nTipoINS = tipo de opção,
              cPedido  = número do pedido,
              cOcorrencia= número de ocorrência,
              cAlias = alias do pedido
Retorno     : .T.
Objetivos   : Não permitir o usuário incluir Banco, Agência e conta iguais
            : para o mesmo número de pedido.
Autor       : HFD
Data/Hora   : 19.mai.2009
Revisao     : 30/08/10 - ISS
Obs.        :
*/
Static Function ValidarGrv(nTipoINS, cPedido, cOcorrencia, cAlias)
   Local lRet := .T.
   Local aOrd := SaveOrd({"WorkIn"})

   WorkIn->(dbSetOrder(2)) //MCF - 09/09/2015 - Realizado validação para gravação no arquivo temporário.
   WorkIn->(dbSeek(cPedido+cOcorrencia))
   While WorkIn->EEJ_PEDIDO == cPedido
   //ISS - 30/08 - Alterada a validação, assim incluindo um tratamento para inclusão e outro para alteração.
      if M->EEJ_CODIGO == WorkIn->EEJ_CODIGO ;
                   .AND. M->EEJ_AGENCI == WorkIn->EEJ_AGENCI;
                   .AND. M->EEJ_NUMCON == WorkIn->EEJ_NUMCON;
                   .AND. M->EEJ_TIPOBC == Alltrim(WorkIn->EEJ_TIPOBC)
                   //.AND. nTipoINS == INC_DET .AND. nTipoINS <> EXC_DET

         lRet := .F.
         EasyHelp(STR0127, STR0049) //STR0127	"Banco, Agência e conta já estão cadastrados." //STR0049 "Aviso"
         exit
      ElseIf M->EEJ_AGENCI == WorkIn->EEJ_AGENCI;
             .AND. M->EEJ_NUMCON == WorkIn->EEJ_NUMCON;
             .AND. M->EEJ_TIPOBC == WorkIn->EEJ_TIPOBC;
             .AND. nTipoINS <> EXC_DET
         lRet := .F.
         EasyHelp(STR0128 + WorkIn->EEJ_CODIGO + ".", STR0049) //STR0128	"Agência, nº da conta e classificação já cadastradas para o banco de código " //STR0049	 "Aviso"
         exit
      EndIf
      WorkIn->(dbSkip())
   EndDo

   /*EEJ->(dbSetOrder(1))
   EEJ->(dbSeek(xFilial(cAlias)+cPedido+cOcorrencia))
   while EEJ_PEDIDO == cPedido
   //ISS - 30/08 - Alterada a validação, assim incluindo um tratamento para inclusão e outro para alteração.
      if M->EEJ_CODIGO == EEJ->EEJ_CODIGO ;
                   .AND. M->EEJ_AGENCI == EEJ->EEJ_AGENCI;
                   .AND. M->EEJ_NUMCON == EEJ->EEJ_NUMCON;
                   .AND. nTipoINS == INC_DET //.AND. nTipoINS <> EXC_DET

         lRet := .F.
         MsgInfo(STR0127, STR0049) //STR0127	"Banco, Agência e conta já estão cadastrados." //STR0049 "Aviso"
         exit
      ElseIf M->EEJ_AGENCI == EEJ->EEJ_AGENCI;
             .AND. M->EEJ_NUMCON == EEJ->EEJ_NUMCON;
             .AND. M->EEJ_TIPOBC == EEJ->EEJ_TIPOBC;
             .AND. nTipoINS == ALT_DET
         lRet := .F.
         MsgInfo(STR0128 + EEJ->EEJ_CODIGO + ".", STR0049) //STR0128	"Agência, nº da conta e classificação já cadastradas para o banco de código " //STR0049	 "Aviso"
         exit
      EndIf
      EEJ->(dbSkip())
   EndDo*/

   RestOrd(aOrd, .T.)

Return lRet

/*
Funcao      : AP100INSMAN(nTipoINS)
Parametros  : nTipoAG := INC_DET/VIS_DET/ALT_DET/EXC_DET
Retorno     : .T.
Objetivos   : Permitir manutencao de instituicoes bancarias
Autor       : Heder M Oliveira
Data/Hora   : 02/07/99 16:04
Revisao     :
Obs.        :
*/
Static Function AP100INSMAN(nTipoINS,cOcorrencia,oMark)

Local lRet:=.T.,cOldArea:=Select(),oDlg,nInc,nOpcA:=0,cNewtit,nRECNO
Local cAlias := if(cOcorrencia==OC_PE,"EE7","EEC")
Local cPedido := if(cOcorrencia==OC_PE,MemField("PEDIDO",cALIAS),MemField("PREEMB",cALIAS))
Local nRecOld := WorkIn->(RecNo())
Local aCmpNotEdit:={}, j:=1

Private aTela[0][0],aGets[0],aHeader[0]

Begin Sequence

   IF nTipoINS <> INC_DET
      IF WorkIn->(Eof() .And. Bof())
         HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      Endif
   Endif

   // ** Tratamentos para impedir a edição do campos de código do notify na opção de alteração.
   aInCampos := aClone(aInEnchoice)
   If nTipoINS == ALT_DET
      aCmpNotEdit := {"EEJ_CODIGO"}
      For j:=1 To Len(aCmpNotEdit)
         nPos := aScan(aInCampos,aCmpNotEdit[j])
         If nPos > 0
            aDel(aInCampos,nPos)
            aSize(aInCampos, Len(aInCampos)-1)
         EndIf
      Next
   EndIf

   IF nTipoINS==INC_DET
      WorkIn->(DBGOBOTTOM())
      WorkIn->(DBSKIP())
   EndIf

   nRECNO:=WorkIn->(RECNO())

   For nInc := 1 TO WorkIn->(FCount())
      M->&(WorkIn->(FIELDNAME(nInc))) := WorkIn->(FIELDGET(nInc))
   Next nInc

   cNewTit:=STR0024 //"Instituições Bancárias"

   M->EEJ_PEDIDO := cPedido
   M->EEJ_OCORRE := cOcorrencia

   DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

      EnChoice( "EEJ",, 3, , , ,aInEnchoice , PosDlg(oDlg),IF(STR(nTipoIns,1)$Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aInCampos),3)
      // Botão para funcionar a exclusão
      DEFINE SBUTTON FROM 10025,187 TYPE 2 ACTION (.T.) ENABLE OF oDlg PIXEL

   ACTIVATE MSDIALOG oDlg ON INIT ;
                     EnchoiceBar(oDlg,{|| Iif(ValidarGrv(nTipoINS, cPedido, cOcorrencia, cAlias);
                                          ,(nOpcA:=1,;
                                          ,Iif(AP100DEINS(nTipoINS,nRECNO),oDlg:End(),nOpcA:=0)); //Condição Verdadeira
                                          , .F. )}; //Condição Falsa
                                          ,{||oDlg:End()})
   // 19.mai.2009 - 719214 - ValidarGrv() Tratamento para validar gravação. - HFD

   IF nOpcA == 1 // ok
      IF nTipoINS == INC_DET
         WorkIn->(RecLock("WorkIn", .T.))
         nMINS++
      Else
         WorkIn->(RecLock("WorkIn", .F.))
      EndIf

      IF ! (STR(nTipoIns,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1))
         AVReplace("M","WorkIn")
      Elseif nTipoINS == EXC_DET
         nMINS --
      EndIf
      WorkIn->(MsUnlock())
      oMark:oBrowse:Refresh()
      onINS:Refresh()
   Else
      IF nTipoINS == INC_DET
         WorkIn->(dbGoTo(nRecOld))
      Endif
   EndIf

End Sequence

dbselectarea(cOldArea)

Return lRet

/*
Funcao      : AP100DEINS()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Deletar AGENTES
Autor       : Heder M Oliveira
Data/Hora   : 05/01/99 13:30
Revisao     :
Obs.        :
*/
Static Function  AP100DEINS(nTipo,nRecno)
    Local lRet:=.T.

    Begin Sequence
       If nTipo == INC_DET .OR. nTipo = ALT_DET
          lRet:=Obrigatorio(aGets,aTela)
       ElseIf nTIPO==EXC_DET .AND. MSGNOYES(STR0026,STR0027) //'Confirma Exclusão ?'###"Atenção"
          WorkIn->(DBGOTO(nRECNO))
          If WorkIn->WK_RECNO # 0
             AADD(aInDeletados,WorkIn->WK_RECNO)
          EndIf
          WorkIn->(DBDELETE())
          WorkIn->(dbSkip(-1))
          IF WorkIn->(Bof())
             WorkIn->(dbGoTop())
          Endif
       EndIf
    End Sequence

Return lRet

/*
Funcao      : AP100INSGRAVA()
Parametros  : lGRVs  -> .T. ->GERA WORK
                        .F. ->GRAVA "EEJ"
              cOcorrencia -> Pedido/Embarque.
              lIntegracao -> Chamada a partir de rotina de integração.
Retorno     :
9Objetivos  : Grava arquivo de trabalho ou EEJ
Autor       : Heder M Oliveira
Data/Hora   : 02/07/99 16:23
Revisao     :
Obs.        :
*/
Function AP100INSGrava(lGRV,cOcorrencia,lIntegracao)

Local lRet:=.T., nInc:=0
Local cAlias := if(cOcorrencia==OC_PE,"EE7","EEC")
Local cPedido := if(cOcorrencia==OC_PE,MemField("PEDIDO",cALIAS),MemField("PREEMB",cALIAS))

Default lIntegracao := .f.

cOcorrencia := Upper(cOcorrencia)

If Type("lEE7Auto") <> "L"
   lEE7Auto:= .F.
EndIf

Begin Sequence

   If !lIntegracao
      IF ! (cOcorrencia $ OC_PE+OC_EM)
         EECHelp(" ",1,"AVG0000655") //MsgStop("Erro no parametro da função AP100INSGRAVA","Aviso")
         lRet:= .F.
         Break
      Endif
   EndIf

   cAlias  := if(cOcorrencia==OC_PE,"EE7","EEC")
   cPedido := if(cOcorrencia==OC_PE,MemField("PEDIDO",cALIAS),MemField("PREEMB",cALIAS))
   IF !lGRV
      For nInc:=1 to LEN(aInDeletados)
         EEJ->(DBGOTO(aInDeletados[nInc]))

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         RecLock("EEJ",.F.)
         EEJ->(DBDELETE())
         EEJ->(MsUnlock())
      Next nInc

      WorkIn->(DBGOTOP())
      While ! WorkIn->(EOF())

         IF WorkIn->WK_RECNO # 0
            EEJ->(DBGOTO(WorkIn->WK_RECNO))
            RecLock("EEJ",.F.)
         Else
            RecLock("EEJ",.T.)  // bloquear e incluir registro vazio
         EndIf

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         AVReplace("WorkIn","EEJ")

         EEJ->EEJ_FILIAL := xFilial("EEJ")
         EEJ->EEJ_PEDIDO := cPEDIDO
         EEJ->EEJ_OCORRE := cOcorrencia

         EEJ->(MsUnlock())
         WorkIn->(DBSKIP())
      Enddo

   Else //WorkIn

      AVReplace("EEJ","WorkIn")
      WorkIn->WK_RECNO := EEJ->(RECNO())
   EndIf

End Sequence

Return Nil

/*
Funcao      : AP100DocGrava()
Parametros  : lGRVs  -> .T. ->Gera Work
                        .F. ->Grava "EXB"
              cOcorrencia -> Pedido/Embarque.
              cFilEx      -> Filial Exterior.
              lIntegracao -> Chamada a partir de rotina de integração.
Retorno     : .t.
Objetivos   : Grava arquivo de trabalho ou EXB.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/08/02 10:59.
Revisao     :
Obs.        :
*/
*---------------------------------------------------------*
Function AP100DocGrava(lGrv,cOcorrencia,cFil,lIntegracao)
*---------------------------------------------------------*
Local nInc:=0
Local lPedido := if(Upper(cOcorrencia)==OC_PE,.t.,.f.)
Local cAlias  := if(lPedido,"EE7","EEC")
Local cPedido := if(lPedido,MemField("PEDIDO",cALIAS),MemField("PREEMB",cALIAS))

Default lIntegracao :=.f.
Default cFil := xFilial("EXB")

If Type("lEE7Auto") <> "L"
   lEE7Auto:= .F.
EndIf

Begin Sequence

   If !lGrv
      For nInc:=1 to Len(aDocDeletados)
         EXB->(DbGoto(aDocDeletados[nInc]))

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         RecLock("EXB",.F.)
         EXB->(DBDELETE())
         EXB->(MsUnlock())
      Next

      WorkDoc->(DbGoTop())
      While ! WorkDoc->(Eof())
         IF WorkDoc->WK_RECNO # 0
            EXB->(DbGoTo(WorkDoc->WK_RECNO))
            RecLock("EXB",.F.)
         Else
            RecLock("EXB",.T.)  // bloquear e incluir registro vazio
         EndIf

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         AVReplace("WorkDoc","EXB")

         /*
         IF Empty(cFilEx)
            EXB->EXB_FILIAL := xFilial("EXB")
         Else
            EXB->EXB_FILIAL := cFilEx
         Endif
         */
         EXB->EXB_FILIAL := cFil

         If lPedido
            EXB->EXB_PEDIDO := cPedido
            EXB->EXB_PREEMB := ""
         Else
            EXB->EXB_PREEMB := cPedido
            EXB->EXB_PEDIDO := ""
         EndIf

         EXB->(MsUnlock())
         WorkDoc->(DBSKIP())
      Enddo
   Else
      If lPedido
         If Empty(EXB->EXB_PEDIDO) .Or. !Empty(EXB->EXB_PREEMB) .Or. EXB->EXB_PEDIDO <> cPedido
            Break
         EndIf
      Else
         If !Empty(EXB->EXB_PEDIDO) .Or. Empty(EXB->EXB_PREEMB) .Or. EXB->EXB_PREEMB <> cPedido
            Break
         EndIf
      EndIf

      WorkDoc->(RecLock("WorkDoc", .T.))
      AVReplace("EXB","WorkDoc")
      WorkDoc->WK_RECNO := EXB->(RecNo())
      WorkDoc->(MsUnlock())
   EndIf

End Sequence

Return Nil

/*
Funcao      : AP100DeDoc()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Deletar itens da work da agenda de atividades
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/08/02 11:57
Revisao     :
Obs.        :
*/
*---------------------------------*
Function  AP100DeDoc(nTipo,nRecno)
*---------------------------------*
Local lRet:=.f.

Begin Sequence
   If nTipo==EXC_DET .AND. (lEXBAuto .Or. MsgNoYes(STR0026,STR0027)) //'Confirma Exclusão ?'###"Atenção"
      WorkDoc->(DbGoTo(nRecno))
      If WorkDoc->WK_RECNO # 0
         AADD(aDocDeletados,WorkDoc->WK_RECNO)
      EndIf
      WorkDoc->(DbDelete())
      WorkDoc->(dbSkip(-1))
      IF WorkDoc->(Bof())
         WorkDoc->(dbGoTop())
      Endif
      lRet:=.t.
   EndIf
End Sequence

Return lRet

/*
Funcao          : AP101TPBC()
Parametros      : Nenhum
Objetivos       : Retornar descricao de instituicao bancaria
Autor           : Heder M Oliveira
Data/Hora       : 05/07/99 16:23
Revisao         :
Obs             :
*/
Function AP101TPBC()
   Local lRet:=.T.,cOldArea:=select(),cX5_DESC

   Begin Sequence

      If ! EMPTY(cX5_DESC:=Tabela('J1',Left(M->EEJ_TIPOBC,1)))
         M->EEJ_TIPOBC:=Left(SX5->X5_CHAVE,1) + "-" + cX5_DESC
      Else
         M->EEJ_TIPOBC:=SPACE(AVSX3("EEJ_TIPOBC")[3])
         lRet:=.F.
      EndIf

   End Sequence

   lRefresh:=.T.

   dbselectarea(cOldArea)

Return lRet

/*
    Funcao   : EECSA1F3(cWHENSA1,cPRC)
    Autor    : Heder M Oliveira
    Data     : 12/07/99 8:56
    Revisao  : 12/07/99 8:56
    Uso      : F3 específico
    Recebe   :
    Retorna  :

*/
FUNCTION EECSA1F3(cWHENSA1,cPRC)
   LOCAL lRet := .f.
   LOCAL oDlgF3, FileWork, Tb_Campos:={}, OldArea:=SELECT()
   LOCAL cTitulo,bSetF3 := SetKey(VK_F3)
   LOCAL oSeek,cSeek,oOrdem,cOrd,nOrdem,aOrdem:={},nIndice:=SA1->(IndexOrd())
   LOCAL nRec,cFiltro

   // *** CAF 11:20 - Versao Protheus
   cWhenSA1 := AllTrim(Substr(ReadVar(),4))

   IF Left(cWhenSA1,3) == "EEC"
      cPRC := OC_EM
   Else
      cPRC := OC_PE
   Endif
   // ***

   PRIVATE lInverte := .F., cMarca := GetMark(),cTIPCLI:="4"

   BEGIN SEQUENCE
      //evitar recursividade
      Set Key VK_F3 TO
      IF cPRC=OC_EM
         bReturn:={||M->EEC_IMPORT:=SA1->A1_COD,M->EEC_IMLOJA:=SA1->A1_LOJA,;
                     M->EEC_IMPODE:=SA1->A1_NOME,oDlgF3:End()}
      ELSE
         bReturn:={||M->EE7_IMPORT:=SA1->A1_COD,M->EE7_IMLOJA:=SA1->A1_LOJA,;
                     M->EE7_IMPODE:=SA1->A1_NOME,oDlgF3:End()}
      ENDIF

      DO CASE
         CASE cWHENSA1=="EE7_IMPORT" .OR. cWHENSA1=="EEC_IMPORT"
            IF cPRC=OC_EM
               bReturn:={||M->EEC_IMPORT:=SA1->A1_COD,M->EEC_IMLOJA:=SA1->A1_LOJA,;
                           M->EEC_IMPODE:=SA1->A1_NOME,oDlgF3:End()}

            ELSE
               bReturn:={||M->EE7_IMPORT:=SA1->A1_COD,M->EE7_IMLOJA:=SA1->A1_LOJA,;
                           M->EE7_IMPODE:=SA1->A1_NOME,oDlgF3:End()}
            ENDIF

            cTITULO:=STR0028 //"Importador"
            // 11/08/2000 by CAF cTIPCLI := "I/T"
            cTIPCLI:="A1_TIPCLI == '1' .Or. A1_TIPCLI == '4'"

        CASE cWHENSA1=="EE7_CLIENT" .OR. cWHENSA1=="EEC_CLIENT"
              IF cPRC=OC_EM
                   bReturn:={||M->EEC_CLIENT:=SA1->A1_COD,M->EEC_CLLOJA:=SA1->A1_LOJA,;
                               M->EEC_CLIEDE:=SA1->A1_NOME,oDlgF3:End()}

              ELSE
                   bReturn:={||M->EE7_CLIENT:=SA1->A1_COD,M->EE7_CLLOJA:=SA1->A1_LOJA,;
                               M->EE7_CLIEDE:=SA1->A1_NOME,oDlgF3:End()}
              ENDIF
              cTITULO:=STR0029 //"Cliente"
              // 11/08/2000 by CAF cTIPCLI:="I\N\C\T"
              cTIPCLI:="A1_TIPCLI == '1' .Or. A1_TIPCLI == '3' .Or. A1_TIPCLI == '2' .Or. A1_TIPCLI == '4'"
           CASE cWHENSA1=="EE7_CONSIG" .OR. cWHENSA1=="EEC_CONSIG"
              IF cPRC=OC_EM
                   bReturn:={||M->EEC_CONSIG:=SA1->A1_COD,M->EEC_COLOJA:=SA1->A1_LOJA,;
                               M->EEC_CONSDE:=SA1->A1_NOME,oDlgF3:End()}

              ELSE
                   bReturn:={||M->EE7_CONSIG:=SA1->A1_COD,M->EE7_COLOJA:=SA1->A1_LOJA,;
                               M->EE7_CONSDE:=SA1->A1_NOME,oDlgF3:End()}
              ENDIF
              cTITULO:=STR0030 //"Consignatário"
              // cTIPCLI:="C\T"
              cTIPCLI:="A1_TIPCLI == '2' .Or. A1_TIPCLI == '4'"
           CASE cWHENSA1=="EEN_IMPORT"
               bReturn := {|| M->EEN_IMPORT:=SA1->A1_COD,M->EEN_IMLOJA:=SA1->A1_LOJA,;
                              M->EEN_IMPODE:=SA1->A1_NOME,oDlgF3:End()}

               cTitulo:=STR0031 //"Notify's"
               //cTipCli:="N\T"
               cTIPCLI:="A1_TIPCLI == '3' .Or. A1_TIPCLI == '4'"
           CASE cWHENSA1=="EEL_IMPORT"
              bReturn:={||M->EEL_IMPORT:=SA1->A1_COD,M->EEL_IMLOJA:=SA1->A1_LOJA,;
                          M->EEL_IMPODE:=SA1->A1_NOME,oDlgF3:End()}

              cTITULO:=STR0028 //"Importador"
              // cTIPCLI:="I\T"
              cTIPCLI:="A1_TIPCLI == '1' .Or. A1_TIPCLI == '4'"

           CASE cWHENSA1=="EEL_NOTIFY" // JPM - 24/06/05
              bReturn:={||M->EEL_NOTIFY:=SA1->A1_COD,M->EEL_NOTLOJ:=SA1->A1_LOJA,;
                          M->EEL_NOTDES:=SA1->A1_NOME,oDlgF3:End()}

              cTITULO:=STR0031 //"Notify's"
              //cTipCli:="N\T"
              cTIPCLI:="A1_TIPCLI == '3' .Or. A1_TIPCLI == '4'"

          CASE cWHENSA1=="EEL_CONSIG" // JPM - 24/06/05
              bReturn:={||M->EEL_CONSIG:=SA1->A1_COD,M->EEL_CONLOJ:=SA1->A1_LOJA,;
                          M->EEL_CONDES:=SA1->A1_NOME,oDlgF3:End()}

              cTITULO:=STR0030 //"Consignatário"
              // cTIPCLI:="C\T"
              cTIPCLI:="A1_TIPCLI == '2' .Or. A1_TIPCLI == '4'"

           OtherWise
              bReturn:={||oDlgF3:End()}
              cTITULO:=STR0054 //"Importador/Cliente/Consignatário"
              // cTIPCLI:="I\T"
              cTIPCLI:="4==4"
      ENDCASE
      cSEEK:=SPACE(45)
      AADD(aORDEM,STR0032) //"Código + Loja"
      AADD(aORDEM,cTITULO+STR0033) //" + Loja"
      AADD(Tb_Campos,{"A1_COD"  ,,STR0034}) //"Código"
      AADD(Tb_Campos,{"A1_LOJA" ,,STR0035}) //"Loja"
      AADD(Tb_Campos,{"A1_NOME",,cTITULO})

      DBSELECTAREA("SA1")
      SA1->(DBSETORDER(1))
      cFiltro := "'"+xFilial("SA1")+"'== A1_FILIAL .And. ("+cTipCli+")"
      // SET FILTER TO cSA1FILIAL==SA1->A1_FILIAL .AND. SA1->A1_TIPCLI$cTIPCLI
      //SET FILTER TO &cFiltro
      dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)//AOM - 16/07/2011 - Versao M11.5
      SA1->(DBSEEK(XFILIAL("SA1"))) //DBGOTOP())

      DEFINE MSDIALOG oDlgF3 TITLE cTitulo FROM 62,15 TO 310,460 OF oMainWnd PIXEL


         // by CRF 21/10/2010 - 11:40
         TB_Campos := AddCpoUser(TB_Campos,"SA1","2")

         oMark:= MsSelect():New("SA1",,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
         oMark:baval:= {|| nRec:=SA1->(RecNo()), lRet := .t.,Eval(bReturn) }

         @ 091, 14 SAY STR0022 SIZE 42,7 OF oDlgF3 PIXEL //"Pesquisar por:"
         @ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlgF3 PIXEL ON CHANGE (SEEKF3(oMARK,,oOrdem))
         @ 104, 14 SAY STR0023 SIZE 32, 7 OF oDlgF3 PIXEL //"Localizar"
         @ 104, 58 MSGET oSeek VAR cSeek SIZE 120, 10 OF oDlgF3 PIXEL
         oSeek:bChange := {|nChar| SA1->(SEEKF3(oMARK,RTrim(oSeek:oGet:Buffer)))}

         DEFINE SBUTTON FROM 10,187 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlgF3 PIXEL
         DEFINE SBUTTON FROM 25,187 TYPE 2 ACTION (oDlgF3:End()) ENABLE OF oDlgF3 PIXEL
      ACTIVATE MSDIALOG oDlgF3

   ENDSEQUENCE

   SA1->(DBSETORDER(nIndice))

   DBSELECTAREA("SA1")
   SET FILTER TO
   DBSELECTAREA(OldArea)

   IF !Empty(nRec)
      SA1->(dbGoto(nRec))
   Endif

   SetKey(VK_F3,bSetF3)

RETURN lRet

/*
Funcao      :   Alias->(SEEKF3(oMSBROWSE,cSeek))
Parametros  :   Browse e Seek e ComboBox
Autor       :   AWR
Data/Hora   :   19/08/99 11:48
*/
Function SEEKF3(oMSBROWSE,cSeek,oBox)
Local nReg := Recno()

IF oBox # Nil
   DBSETORDER(oBox:nAT)
ELSE
   dbSeek(xFilial()+cSeek)

   IF Eof()
       dbgoto(nReg)
   Endif

ENDIF

oMSBROWSE:oBrowse:Refresh()

Return .t.

/*
    Funcao   : EECSA2F3(cWHENSA2)
    Autor    : Heder M Oliveira
    Data     : 12/07/99 10:36
    Revisao  : 12/07/99 10:36
    Uso      : F3 específico
    Recebe   :
    Retorna  :

*/
FUNCTION EECSA2F3(cWHENSA2,cPRC)
   Local lRet := .f.
   LOCAL oDlgF3, FileWork, Tb_Campos:={}, OldArea:=SELECT()
   LOCAL bSetF3 := SetKey(VK_F3)
   LOCAL oSeek,cSeek,oOrdem,cOrd,nOrdem,aOrdem:={},nIndice:=SA2->(IndexOrd())
   Local nRec
   Local cFiltro := "" //AOM - 16/07/2011 - Versao M11.5
   LOCAL cTitulo := STR0036//Fornecedor
   // *** CAF 11:32 - Versao Protheus
   // AMS 13/06/2003 - 14:36
   //cWhenSA2 := AllTrim(Substr(ReadVar(),4))
   cWhenSA2 := AllTrim( SubStr( ReadVar(), At( ">", ReadVar() ) + 1 ) )

   IF Left(cWhenSA2,3) == "EEC"
      cPRC := OC_EM
   Else
      cPRC := OC_PE
   Endif
   // ***

   PRIVATE lInverte := .F., cMarca := GetMark(),cTIPFOR:="3",cSA2FILIAL:=XFILIAL("SA2")

   BEGIN SEQUENCE
      //evitar recursividade
      Set Key VK_F3 TO
      IF ( cPRC=OC_EM )
         bReturn:={||M->EEC_FORN:=SA2->A2_COD,M->EEC_FOLOJA:=SA2->A2_LOJA,;
                     M->EEC_FORNDE:=SA2->A2_NOME,oDlgF3:End()}

      ELSE
         bReturn:={||M->EE7_FORN:=SA2->A2_COD,M->EE7_FOLOJA:=SA2->A2_LOJA,;
                     M->EE7_FORNDE:=SA2->A2_NOME,oDlgF3:End()}
      ENDIF

      DO CASE
         CASE cWHENSA2=="EE7_FORN" .OR. cWHENSA2=="EEC_FORN"
            IF ( cPRC=OC_EM )
               bReturn:={||M->EEC_FORN:=SA2->A2_COD,M->EEC_FOLOJA:=SA2->A2_LOJA,;
                          M->EEC_FORNDE:=SA2->A2_NOME,oDlgF3:End()}
            ELSE
               bReturn:={||M->EE7_FORN:=SA2->A2_COD,M->EE7_FOLOJA:=SA2->A2_LOJA,;
                           M->EE7_FORNDE:=SA2->A2_NOME,oDlgF3:End()}
            ENDIF
            cTITULO:=STR0036        //"Fornecedor"
            cTIPFOR:="2\3"
         CASE cWHENSA2=="EE7_EXPORT" .OR. cWHENSA2=="EEC_EXPORT"
            IF ( cPRC=OC_EM )
               bReturn:={||M->EEC_EXPORT:=SA2->A2_COD,M->EEC_EXLOJA:=SA2->A2_LOJA,;
                           M->EEC_EXPODE:=SA2->A2_NOME,oDlgF3:End()}
            ELSE
               bReturn:={||M->EE7_EXPORT:=SA2->A2_COD,M->EE7_EXLOJA:=SA2->A2_LOJA,;
                           M->EE7_EXPODE:=SA2->A2_NOME,oDlgF3:End()}
            ENDIF
            cTITULO:=STR0037        //"Exportador"
            cTIPFOR:="4\3"
         CASE cWHENSA2=="EE7_BENEF" .OR. cWHENSA2=="EEC_BENEF"
            IF ( cPRC=OC_EM)
               bReturn:={||M->EEC_BENEF:=SA2->A2_COD,M->EEC_BELOJA:=SA2->A2_LOJA,;
                           M->EEC_BENEDE:=SA2->A2_NOME,oDlgF3:End()}
            ELSE
               bReturn:={||M->EE7_BENEF:=SA2->A2_COD,M->EE7_BELOJA:=SA2->A2_LOJA,;
                           M->EE7_BENEDE:=SA2->A2_NOME,oDlgF3:End()}
            ENDIF
            cTITULO:=STR0038      //"Beneficiário"
            cTIPFOR:="5\3"
         CASE cWHENSA2=="EEL_EXPORT"
               bReturn:={||M->EEL_EXPORT:=SA2->A2_COD,M->EEL_EXLOJA:=SA2->A2_LOJA,;
                           M->EEL_EXPODE:=SA2->A2_NOME,oDlgF3:End()}
            cTITULO:=STR0037        //"Exportador"
            cTIPFOR:="4\3"
         CASE cWHENSA2=="EEL_BENEF"
               bReturn:={||M->EEL_BENEF:=SA2->A2_COD,M->EEL_BELOJA:=SA2->A2_LOJA,;
                           M->EEL_BENEDE:=SA2->A2_NOME,oDlgF3:End()}
            cTITULO:=STR0038      //"Beneficiário"
            cTIPFOR:="5\3"

         CASE cWHENSA2=="EE7_SHIPPE" // JPM - 24/01/06 - Compra FOB
            bReturn:={||M->EE7_SHIPPE:=SA2->A2_COD,M->EE7_SHLOJA:=SA2->A2_LOJA,oDlgF3:End()}
            cTITULO:=STR0037        //"Exportador"
            cTIPFOR:="4\3"

      ENDCASE
   cSEEK:=SPACE(45)
   AADD(aORDEM,STR0032) //"Código + Loja"
   AADD(aORDEM,cTITULO+STR0033) //" + Loja"

   AADD(Tb_Campos,{"A2_COD" ,,STR0034}) //"Código"
   AADD(Tb_Campos,{"A2_LOJA",,STR0035}) //"Loja"
   AADD(Tb_Campos,{"A2_NOME",,cTITULO})
   AADD(TB_CAMPOS,ColBrw("A2_END")) // ENDERECO
   AADD(TB_CAMPOS,ColBrw("A2_CGC")) // CGC

   DBSELECTAREA("SA2")
   SA2->(DBSETORDER(1))


   SET FILTER TO cSA2FILIAL==SA2->A2_FILIAL .AND. LEFT(SA2->A2_ID_FBFN,1)$cTIPFOR
   SA2->(DBSEEK(XFILIAL("SA2")))//(DBGOTOP())
   DEFINE MSDIALOG oDlgF3 TITLE cTitulo FROM 62,15 TO 310,460 OF oMainWnd PIXEL
       oMark:= MsSelect():New("SA2",,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
           oMark:baval:= {|| nRec:=SA2->(RecNo()),lRet:=.t.,Eval(bReturn) }

       @ 091, 14 SAY STR0022 SIZE 42,7 OF oDlgF3 PIXEL //"Pesquisar por:"
       @ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlgF3 PIXEL ON CHANGE (SEEKF3(oMARK,,oOrdem))
       @ 104, 14 SAY STR0023 SIZE 32, 7 OF oDlgF3 PIXEL //"Localizar"
       @ 104, 58 MSGET oSeek VAR cSeek SIZE 120, 10 OF oDlgF3 PIXEL
       oSeek:bChange := {|nChar|SA2->(SEEKF3(oMARK,RTrim(oSeek:oGet:Buffer)))}

       DEFINE SBUTTON FROM 10,187 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlgF3 PIXEL
       DEFINE SBUTTON FROM 25,187 TYPE 2 ACTION (oDlgF3:End()) ENABLE OF oDlgF3 PIXEL
       ACTIVATE MSDIALOG oDlgF3

   ENDSEQUENCE

   SA2->(DBSETORDER(nIndice))
   DBSELECTAREA("SA2")
   SET FILTER TO
   DBSELECTAREA(OldArea)

   IF !Empty(nRec)
      SA2->(dbGoTo(nRec))
   Endif

   SetKey(VK_F3,bSetF3)

RETURN lRet



FUNCTION BSCTRAN(cTIPTRAN)
    Local cRet:=STR0039,nINC,nCONT //"ITEM NAO CADASTRADO"
    LOCAL cCBOX:=AVSX3("YR_TIPTRAN")[12]
    BEGIN SEQUENCE
        FOR nINC:=1 TO LEN(cCBOX)
            nCONT:=AT(";",cCBOX)
            nCONT:=IF(nCONT==0,LEN(cCBOX)+3,nCONT)
            IF LEFT(cCBOX,1)=cTIPTRAN
                cRET:=SUBSTR(cCBOX,3,nCONT-3)
                EXIT
            ENDIF
            cCBOX:=SUBSTR(cCBOX,nCONT+1)
        NEXT nINC
    ENDSEQUENCE
Return cRet


/*
    Funcao   : EECEE3F3(cCONTAT,cPRC)
    Autor    : Heder M Oliveira
    Data     : 12/07/99 8:56
    Revisao  : 12/07/99 8:56
    Uso      : F3 específico
    Recebe   :
    Retorna  :

*/
FUNCTION EECEE3F3(cCONTAT,cPRC,cCompl)
   Local lRet := .f.
   LOCAL oDlgF3, FileWork, Tb_Campos:={}, OldArea:=SELECT()
   LOCAL bSetF3 := SetKey(VK_F3)
   Local nRec, cFiltra

   DEFAULT cPRC:=OC_PE
   PRIVATE lInverte := .F., cMarca := GetMark(),cEE3FILIAL:=XFILIAL("EE3")
   PRIVATE cTIPOCAD:=CD_SA2

   BEGIN SEQUENCE
      //evitar recursividade
      Set Key VK_F3 TO

      IF cPRC=OC_EM
         bReturn:={||M->EEC_RESPON:=EE3->EE3_NOME,oDlgF3:End()}
      ELSEIF cPRC=OC_PE
         bReturn:={||M->EE7_RESPON:=EE3->EE3_NOME,oDlgF3:End()}
      ELSEIF cPRC=OC_FI
         // ** By JBJ - 05/01/04 - 16:56 Campo substituido pela rotina de câmbio.
         bReturn:={|| /*M->EEC_CBRESP:=EE3->EE3_NOME,*/ oDlgF3:End()}
      ELSE //RETORNAR PARA QUALQUER CHAMADA QUE TENHA PASSADO cPRC="R" (RDMAKE)
         bReturn:={||M->cCONTATO:=EE3->EE3_NOME,oDlgF3:End()}
      ENDIF

      AADD(Tb_Campos,{"EE3_NOME"  ,,STR0040}) //"Nome"
      AADD(Tb_Campos,{"EE3_CARGO" ,,STR0041}) //"Cargo"
      AADD(Tb_Campos,{"EE3_DEPART",,STR0042}) //"Departamento"

      cCompl := AvKey(cCompl,"EE3_COMPL")
      cContat:= AvKey(cContat,"EE3_CONTAT")

      DBSELECTAREA("EE3")
      EE3->(DBSETORDER(1))

      // BAK - Alteração para carregar os contatos sem complemento - 29/07/2011
      If !Empty(cCompl)
         cFiltra := "'" +cEE3FILIAL+ "' == EE3->EE3_FILIAL .AND."
         cFiltra += "EE3->EE3_CODCAD=='"+cTIPOCAD+"'.AND. EE3->EE3_CONTAT=='"+cCONTAT+"'.AND. EE3->EE3_COMPL=='"+cCompl+"'"
      Else
         cFiltra := "'" +cEE3FILIAL+ "' == EE3->EE3_FILIAL .AND."
         cFiltra += "EE3->EE3_CODCAD=='"+cTIPOCAD+"'.AND. EE3->EE3_CONTAT=='"+cCONTAT+"'"
      EndIf

      dbSetFilter(&("{|| "+cFiltra+"}"),cFiltra)//AOM - 16/07/2011 - Versao M11.5
      //SET FILTER TO &cFiltra

      EE3->(DBSEEK(XFILIAL("EE3")))

      DEFINE MSDIALOG oDlgF3 TITLE STR0043 FROM 4,3 TO 20,55 OF oMainWnd //"Contatos"
         oMark:= MsSelect():New("EE3",,,TB_Campos,@lInverte,@cMarca,{20,6,100,160})
         oMark:baval:= {|| lRet:=.t.,nRec:=EE3->(RecNo()), Eval(bReturn) }

         DEFINE SBUTTON FROM 10,165 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlgF3 PIXEL
         DEFINE SBUTTON FROM 25,165 TYPE 2 ACTION (oDlgF3:End()) ENABLE OF oDlgF3 PIXEL
      ACTIVATE MSDIALOG oDlgF3
   ENDSEQUENCE

   EE3->(DBCLEARFILTER())
   DBSELECTAREA(OldArea)

   IF !Empty(nRec)
      EE3->(dbGoTo(nRec))
   Endif

   SetKey(VK_F3,bSetF3)

RETURN lRet

/*
    Funcao   : AV_F3()
    Autor    : Alexandro Wallauer (AWR)
    Data     : 19/08/99 17:00
    Uso      : F3 Generica
*/
Function Av_F3()
Local lRet := .f.
LOCAL oDlgF3, FileWork, Tb_Campos:={}, OldArea:=SELECT()
LOCAL cTitulo,bSetF3 := SetKey(VK_F3),cAlias:="EEH"
LOCAL oSeek,cSeek,oOrdem,cOrd,nOrdem,aOrdem:={},nIndice,cSeek1:=""
LOCAL cCampo:=UPPER(AllTrim(READVAR())),cPRC:=OC_PE,lChange:=.f.
Local cFiltro,nRec
Local oMarca  // TRP - 31/08/07 - Definição de objeto local utilizado pela função.
Local oWnd

PRIVATE lInverte := .F., cMarca := GetMark(),cFILIAL:="  "
PRIVATE bSeek:={|nChar|RTrim(oSeek:oGet:Buffer)}

BEGIN SEQUENCE

    //evitar recursividade
    Set Key VK_F3 TO

    DO CASE

        CASE Type("aF3Generico") == "A" .AND. Len(aF3Generico) >= 9
             cAlias:= aF3Generico[1]

             If !Empty(aF3Generico[2])
                Eval(aF3Generico[2])
             EndIf

             nIndice:=(cAlias)->(IndexOrd())
             cFILIAL:=xFilial(cAlias)

             lChange:=aF3Generico[4]

             cSeek1 :=aF3Generico[5]
             DBSELECTAREA(cAlias)
             DBSETORDER(1)

             cFiltro := aF3Generico[6]
             If !Empty(cFiltro)
                dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)
             EndIf

             DBGOTOP()
			 bReturn := {|| Eval(aF3Generico[7]), oDlgF3:End()}

             cTITULO:= aF3Generico[8]//STR0046+EEC->EEC_PREEMB //"Empresas do Embarque Nr. "
             aORDEM := aF3Generico[9]//AADD(aORDEM,STR0034) //"Código"

             If Len(aF3Generico) >= 10 .AND. !Empty(aF3Generico[10])
   			    Tb_Campos := aF3Generico[10]
             Else
                Tb_Campos := AV_F3COLS(cAlias)
             EndIf
             //AADD(Tb_Campos,{"EEB_CODAGE" ,,STR0034}) //"Código"

		CASE cCampo=="M->EE8_GPCOD" .OR. cCampo=="M->EE9_GPCOD"
             IF ( cCAMPO=="M->EE9_GPCOD" )
                cPRC:=OC_EM
                cIDCAPA := M->EEC_IDIOMA
             Else
                cPRC:=OC_PE
                cIDCAPA := M->EE7_IDIOMA
             ENDIF

             cIDCAPA :=cIDCAPA+Space(AVSX3("EE4_IDIOMA",AV_TAMANHO)-Len(cIDCAPA))

             cAlias:="EEH"
             nIndice:=EEH->(IndexOrd())
             cFILIAL:=xFilial("EEH")
             lChange:=.f.
             DBSELECTAREA("EEH")
             DBSETORDER(4)
             cFiltro := "'"+xFilial("EEH")+"'== EEH->EEH_FILIAL .AND. EEH->EEH_IDIOMA == '"+cIDCAPA+"'"
             dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)//AOM - 16/07/2011 - Versao M11.5
             //SET FILTER TO &cFiltro
             DBGOTOP()

             IF ( cPRC=OC_EM )
                bReturn:={||M->EE9_GPCOD:=EEH->EEH_COD,oDlgF3:End()}
             ELSE
                bReturn:={||M->EE8_GPCOD:=EEH->EEH_COD,oDlgF3:End()}
             ENDIF

             cTITULO:=STR0044 //"Grupo de Famílias"
             AADD(aORDEM,STR0034) //"Código"

             AADD(Tb_Campos,{"EEH_COD" ,,STR0034}) //"Código"
             AADD(Tb_Campos,{"EEH_NOME",,cTITULO})

        CASE cCampo=="M->EE8_DPCOD" .OR. cCampo=="M->EE9_DPCOD"

             IF ( cCAMPO=="M->EE9_DPCOD" )
                cPRC:=OC_EM
                cIDCAPA :=M->EEC_IDIOMA
             Else
                cPRC:=OC_PE
                cIDCAPA := M->EE7_IDIOMA
             ENDIF

             cIDCAPA :=cIDCAPA+Space(AVSX3("EE4_IDIOMA",AV_TAMANHO)-Len(cIDCAPA))

             cAlias:="EEG"
             nIndice:=EEG->(IndexOrd())
             cFILIAL:=xFilial("EEG")
             lChange:=.f.
             cSeek1 :=cIDCAPA
             DBSELECTAREA("EEG")
             DBSETORDER(1)
             cFiltro := "'"+xFilial("EEG")+"'==EEG->EEG_FILIAL .AND. EEG->EEG_IDIOMA ='"+cIDCAPA+"'"
             dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)//AOM - 16/07/2011 - Versao M11.5
             //SET FILTER TO &cFiltro
             DBGOTOP()

             IF ( cPRC=OC_EM )
                bReturn:={||M->EE9_DPCOD:=EEG->EEG_COD,oDlgF3:End()}
             ELSE
                bReturn:={||M->EE8_DPCOD:=EEG->EEG_COD,oDlgF3:End()}
             ENDIF

             cTITULO:=STR0045 //"Divisão de Famílias"
             AADD(aORDEM,STR0034) //"Código"

             AADD(Tb_Campos,{"EEG_COD" ,,STR0034}) //"Código"
             AADD(Tb_Campos,{"EEG_NOME",,cTITULO})

        CASE cCampo $ "MV_PAR02,MV_PAR03,MV_PAR04,CEMPRESA"
             cAlias:="EEB"

             nIndice:=(cAlias)->(IndexOrd())
             cFILIAL:=xFilial(cAlias)
             lChange:=.f.
             cSeek1 :=EEC->EEC_PREEMB
             DBSELECTAREA(cAlias)
             DBSETORDER(1)
             cFiltro := "'"+cFilial+"'==EEB->EEB_FILIAL .AND. EEB->EEB_PEDIDO=='"+EEC->EEC_PREEMB+"' .And. EEB->EEB_OCORRE=='"+OC_EM+"'"
             dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)//AOM - 16/07/2011 - Versao M11.5
             //SET FILTER TO &cFiltro
             DBGOTOP()

             do Case
                Case cCampo == "MV_PAR02"
                     bReturn:={||M->MV_PAR02 := EEB->EEB_CODAGE+EEB->EEB_TIPOAG, oDlgF3:End() }
                Case cCampo == "MV_PAR03"
                     bReturn:={||M->MV_PAR03 := EEB->EEB_CODAGE+EEB->EEB_TIPOAG, oDlgF3:End() }
                Case cCampo == "MV_PAR04"
                     bReturn:={||M->MV_PAR04 := EEB->EEB_CODAGE+EEB->EEB_TIPOAG, oDlgF3:End() }
                Case cCampo == "CEMPRESA"
                     bReturn:={||cEmpresa := EEB->EEB_NOME,cContatoE:=AllTrim(EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",1)) + If( Empty( EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",7 ) ), "", " - " ) + AllTrim(EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",7)), oDlgF3:End() } //Alteração por Alexsander M.S, com a rotina If( Empty( EECCONTATO(CD_SY5,EEB->EEB_CODAGE,,"1",7 ) ), "", " - " ).
             End Case

             cTITULO:=STR0046+EEC->EEC_PREEMB //"Empresas do Embarque Nr. "
             AADD(aORDEM,STR0034) //"Código"

             AADD(Tb_Campos,{"EEB_CODAGE" ,,STR0034}) //"Código"
             AADD(Tb_Campos,{"EEB_TIPOAG",,STR0047}) //"Tipo"
             AADD(Tb_Campos,{"EEB_NOME",,STR0040}) //"Nome"

        CASE cCampo==""//Proximo Help

    ENDCASE
    cSEEK:=SPACE(45)
    DBSELECTAREA(cAlias)

    DEFINE MSDIALOG oDlgF3 TITLE cTitulo FROM 62,15 TO 310,460 OF oMainWnd PIXEL
        oMark:= MsSelect():New(cAlias,,,TB_Campos,@lInverte,@cMarca,{10,12,80,186})
        oMark:baval:= {|| nRec := (cAlias)->(RecNo()), lRet:=.t.,Eval(bReturn) }

        @ 091, 14 SAY STR0022 SIZE 42,7 OF oDlgF3 PIXEL //"Pesquisar por:"
        @ 090, 59 COMBOBOX oOrdem VAR cOrd ITEMS aOrdem SIZE 119, 42 OF oDlgF3 PIXEL ON CHANGE (IF(lChange,SEEKF3(oMARK,,oOrdem),))
        @ 104, 14 SAY STR0023 SIZE 32, 7 OF oDlgF3 PIXEL //"Localizar"
        @ 104, 58 MSGET oSeek VAR cSeek SIZE 120, 10 OF oDlgF3 PIXEL
        oSeek:bChange := {|nChar|(cAlias)->(SEEKF3(oMARK,cSeek1+EVAL(bSeek,nChar)))}

        DEFINE SBUTTON FROM 10,187 TYPE 1 ACTION (Eval(oMark:baval)) ENABLE OF oDlgF3 PIXEL
        DEFINE SBUTTON FROM 25,187 TYPE 2 ACTION (oDlgF3:End()) ENABLE OF oDlgF3 PIXEL
    ACTIVATE MSDIALOG oDlgF3

END SEQUENCE

(cAlias)->(DBSETORDER(nIndice))

dbSelectArea(cAlias)
SET FILTER TO
DBGOTOP()
DBSELECTAREA(OldArea)

IF !Empty(nRec)
   (cAlias)->(dbGoTo(nRec))
Endif

SetKey(VK_F3,bSetF3)

oWnd := GetWndDefault()
If ValType(oWnd) == "O"
   aEval(oWnd:aControls,{|X| if(GetClassName(X) == "TGET",X:Refresh(),)})
   oWnd:Refresh()
EndIf

If Type("aF3Generico") == "A" .AND. Len(aF3Generico) >= 11 .AND. !Empty(aF3Generico[11])
   Eval(aF3Generico[11])
EndIf

RETURN .F. //lRet

Function AV_F3COLS(cAlias)
Local aCpos := {}
Local i
Local cCampo

SX3->(dbSetOrder(2))
For i := 1 To (cAlias)->(FCount())
   cCampo := (cAlias)->(FieldName(i))
   If SX3->(dbSeek(cCampo))
      aAdd(aCpos,{cCampo,,SX3->X3_TITULO})
   EndIf
Next i

Return aClone(aCpos)

/*
Funcao      : AP100Notify()
Parametros  : cOcorrencia := P - PEDIDO
                             E - EMBARQUE
              nOpc := Inclusao/Alt./Excl./Vis.
Retorno     : .T./.F.
Objetivos   : Executa rotina externa de lancamento de Notify's
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/08/99 9:49
Revisao     :
Obs.        :
*/
Function AP100Notify(cOcorrencia,nOpc,aAuto)

Local lRet:=.T.,nOldArea:=Select(),nOpcA:=0,oDlg
Local cFileBackup := CriaTrab(,.F.)
Local oMark
Local bOk := {|| nOpcA := 1, If(lEENAuto, Nil, oDlg:End()) }
Local bCancel := {|| oDlg:End() }, aDelBak
Local oPanel

cOcorrencia := Upper(cOcorrencia)

Private oTotItens, nTotItens
Private cProc := IF(cOcorrencia==OC_PE,M->EE7_PEDIDO,M->EEC_PREEMB)
Private nRegistro := 0
Private lEENAuto := ValType(aAuto) == "A"

Begin Sequence

   IF ! (cOcorrencia $ OC_PE+OC_EM)
      EasyHelp(STR0048+Capital(ProcName()),STR0049) //"Erro no paramêtro da função "###"Aviso"
      lRet:=.F.
      Break
   EndIf

   dbSelectArea("WorkNo")
   WorkNo->(dbGoTop())
   TETempBackup(cFileBackup)
   aDelBak := aClone(aNoDeletados)
   nTotItens := EasyReccount("WorkNo")

   WorkNo->(dbGoTop())

   If !lEENAuto

      DEFINE MSDIALOG oDlg TITLE STR0050+cProc FROM 9,0 TO 28,70 OF oMainWnd //"Notify's do Processo "

         AP100NoTela(.T., oDlg, cOcorrencia)    // GFP - 01/10/2012 - Inclusao do parametro cOcorrencia

         oMark := MSSELECT():New("WorkNo",,,aNoBrowse,,,aNoPos)
         oMark:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //wfs
         oMark:bAval := {|| IF(Str(nOpc,1) $ Str(VISUALIZAR,1)+"/"+Str(EXCLUIR,1),AP100NoMan(VIS_DET,cOcorrencia,oMark),AP100NoMan(ALT_DET,cOcorrencia,oMark)) }

      ACTIVATE MSDIALOG oDlg ON INIT ;
           AVBar(nOpc,oDlg,bOk,bCancel,ENCH_ADD,{|opc| AP100NoMan(opc,cOcorrencia,oMark)}) CENTERED
   Else
      If EasySeekAuto("WorkNo",aAuto,1)
         If nOpc == INCLUIR//Upsert
            nOpc := ALT_DET
         ElseIf nOpc == ALTERAR
            nOpc := ALT_DET
         ElseIf nOpc == EXCLUIR
            nOpc := EXC_DET
         EndIf
      ElseIf nOpc == INCLUIR//Upsert
         nOpc := INC_DET
      ElseIf (nOpc == ALTERAR) .Or. (nOpc == EXCLUIR)
         EasyHelp(STR0131, STR0049) //"Falha de Integração: Registro não localizado na tabela de Notifys."###"Aviso"
         lRet := .F.
      EndIf
      If lRet
         If (lRet := AP100NoMan(nOpc,cOcorrencia,Nil,aAuto))
            Eval(bOk)
         EndIf
      EndIf
   EndIf

   IF nOpcA == 0 //Cancelar
      AvZap("WorkNo")//WorkNo->(AvZap())
      dbSelectArea("WorkNo")
      TERestBackup(cFileBackup)
      aNoDeletados := aClone(aDelBak)
   EndIf

   fErase(cFileBackup+GetDBExtension())

End Sequence

dbselectarea(nOldArea)

Return lRet

/*
Funcao      : AP100NoGrv()
Parametros  : lGRVs  -> .T. ->GERA WORK
                        .F. ->GRAVA "EEN"
              cOcorrencia -> Pedido/Embarque.
              lIntegracao -> Chamada a partir de rotina de integração.
Retorno     :
9Objetivos  : Grava arquivo de trabalho ou EEN
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/08/99 10:05
Revisao     :
Obs.        :
*/
Function AP100NoGrv(lGrv,cOcorrencia,lIntegracao)

Local lRet:=.T.
Local nInc
Local cProc

Default lIntegracao := .f.

If Type("lEE7Auto") <> "L"
   lEE7Auto:= .F.
EndIf

cOcorrencia := Upper(cOcorrencia)
cProc := IF(cOcorrencia==OC_PE,M->EE7_PEDIDO,M->EEC_PREEMB)

Begin Sequence

   If !lIntegracao
      IF ! (cOcorrencia $ OC_PE+OC_EM)
         EECMsg(STR0048+Capital(ProcName()), STR0049, "MsgStop") //"Erro no paramêtro da função "###"Aviso"
         lRet := .F.
         Break
      Endif
   EndIf

   IF !lGrv
      For nInc:=1 to LEN(aNoDeletados)
         EEN->(DBGOTO(aNoDeletados[nInc]))

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         EEN->(RecLock("EEN",.F.))
         EEN->(DBDELETE())
         EEN->(MsUnlock())
      Next nInc

      WorkNo->(DBGOTOP())

      While ! WorkNo->(EOF())
         If WorkNo->WK_RECNO != 0
            EEN->(DBGOTO(WorkNo->WK_RECNO))
            EEN->(RecLock("EEN",.F.))
         Else
            EEN->(RecLock("EEN",.T.)) // bloquear e incluir registro vazio
         EndIf

         If !lIntegracao .And. !lEE7Auto
            IncProc()
         EndIf

         AVReplace("WorkNo","EEN")
         EEN->EEN_FILIAL := xFilial("EEN")
         EEN->EEN_PROCES := cProc
         EEN->EEN_OCORRE := cOcorrencia
         EEN->(MsUnlock())

         WorkNo->(DBSKIP())
      Enddo
   Else
      AVReplace("EEN","WorkNo")
      WorkNo->WK_RECNO := EEN->(RECNO())
   EndIf

End Sequence

Return Nil

/*
Funcao      : AP100NoTela(lInit)
Parametros  : lInit:= .T. = inicilizar valores
              .F. = envia mensagem de atualizacao
Retorno     : nenhum
Objetivos   : Apresentar Header de Notify's
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/08/1999 10:25
Revisao     :
Obs.        :
*/
Static Function AP100NoTela(lInit,oDlg, cOcorrencia)
   Local nOldArea := Select(),cTITULO := If(cOcorrencia == "P",AVSX3("EE7_PEDIDO",AV_TITULO),STR0129) // "Embarque"  // GFP - 01/10/2012
   Local nL1, nC1, nC2, nC3, nC4
   Local oPanel

   Begin Sequence
      nL1:=1.4 ; nC1:=0.8 ; nC2:=15 ; nC3:=08 ; nC4:=20

      If lInit

         oPanel:= TPanel():New(0, 0, "",oDlg, , .F., .F.,,, (oDlg:nRight-oDlg:nLeft), (oDlg:nBottom-oDlg:nTop)*0.15)

         @nL1,nC1 SAY cTITULO OF oPanel
         @nL1,nC2 SAY STR0051 OF oPanel //"Total Itens"

         @nL1,nC3 MSGET cProc PICTURE AVSX3("EE7_PEDIDO",AV_PICTURE) WHEN .F. SIZE 50,7 OF oPanel
         @nL1,nC4 MSGET oTotItens VAR nTotItens PICTURE "@E 9999"  WHEN .F. SIZE 50,7 RIGHT OF oPanel

         oPanel:Align:= CONTROL_ALIGN_TOP
      Else
         oTotItens:Refresh()
      EndIf
   End Sequence

   dbselectarea(nOldArea)
Return NIL

/*
Funcao      : AP100NoMan
Parametros  : nOpc := Opcao
              cOcorrencia := P (default) pedido
                             E (embarque) pedido
Retorno     : nenhum
Objetivos   : Manutencao de Import.
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/08/1999 10:35
Revisao     :
Obs.        :
*/
Static Function AP100NoMan(nOpc,cOcorrencia,oMark,aAuto)

Local nOldArea:=Select(),oDlg,nInc,nOpcA:=0,cNewTit
Local nRecOld := WorkNo->(RecNo()), nPos:=0, aCmpNotEdit := {}, J:=0
Private aNoCampos := {}

Private aTela[0][0],aGets[0],aHeader[0]
Private bOk     := {||nOpcA:=1,If(AP100NoVal(nOpc,nRecNo),If(lEENAuto, Nil, oDlg:End()),nOpcA:=0)}
Private bCancel := {||oDlg:End()}
Private nOpcPE := nOpc // GFP - 18/04/2016

Begin Sequence

   IF EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"AP101NOMAN_INICIO")
   Endif

   IF nOpc <> INC_DET
      IF WorkNo->(Eof() .And. Bof())
         HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      Endif
   Endif

   IF nOpc == INC_DET
      WorkNo->(dbGoBottom())
      WorkNo->(dbSkip())
   Endif

   // ** Tratamentos para impedir a edição do campos de código do notify na opção de alteração.
   aNoCampos := aClone(aNoEnchoice)
   If nOpc == ALT_DET
      aCmpNotEdit := {"EEN_IMPORT","EEN_IMLOJA"}
      For j:=1 To Len(aCmpNotEdit)
         nPos := aScan(aNoCampos,aCmpNotEdit[j])
         If nPos > 0
            aDel(aNoCampos,nPos)
            aSize(aNoCampos, Len(aNoCampos)-1)
         EndIf
      Next
   EndIf

   nRecNo := WorkNo->(RecNo())

   For nInc := 1 TO WorkNo->(FCount())
      M->&(WorkNo->(FieldName(nInc))) := WorkNo->(FieldGet(nInc))
   Next nInc

   M->EEN_PROCES := cProc
   M->EEN_OCORRE := cOcorrencia

   cNewTit := STR0052 //"Definição dos Notify's"

   IF EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"NOT_DIALOG")
   Endif

   aNoEnchoice:= AddCpoUser(aNoEnchoice,"EEN","1")

   aNoCampos:= AddCpoUser(aNoCampos,"EEN","1")

   If !lEENAuto
      DEFINE MSDIALOG oDlg TITLE cNewTit FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         EnChoice("EEN", , 3, , , ,aNoEnchoice , PosDlg(oDlg),IF(STR(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aNoCampos) , 3 )
         // Botão para funcionar a exclusão
         DEFINE SBUTTON FROM 10025,187 TYPE 2 ACTION (.T.) ENABLE OF oDlg PIXEL

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   Else
      EnchAuto("EEN",ValidaEnch(aAuto, IF(STR(nOpc,1) $ Str(VIS_DET,1)+"/"+Str(EXC_DET,1),{},aNoCampos)),{|| Obrigatorio(aGets,aTela)},3, aNoEnchoice)
      If !lMsErroAuto
         Eval(bOk)
      EndIf
   EndIf

   If nOpcA != 0
      If nOpc == INC_DET
         WorkNo->(RecLock("WorkNo", .T.))
         nTotItens ++
      Else
         WorkNo->(RecLock("WorkNo", .F.))
      EndIf

      If !(Str(nOpc,1) $ Str(EXC_DET,1)+"/"+Str(VIS_DET,1))
         AVReplace("M","WorkNo")
      Elseif nOpc == EXC_DET
         nTotItens --
      EndIf
      WorkNo->(MsUnlock())
      If !lEENAuto
         oMark:oBrowse:Refresh()
         AP100NoTela(.F.)
      EndIf
   Else
      IF nOpc == INC_DET
         WorkNo->(dbGoto(nRecOld))
      Endif
   EndIf
End Sequence

dbselectarea(nOldArea)

Return If(lEENAuto, !lMsErroAuto, Nil)

/*
Funcao      : AP100NoVal()
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : Consistir/Deletar Notify's
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/08/1999 10:55
Revisao     :
Obs.        :
*/
Static Function  AP100NoVal(nOpc,nRecno)
   Local lRet:=.T.

   Begin Sequence
      If nOpc == INC_DET .Or. nOpc == ALT_DET
         lRet:=Obrigatorio(aGets,aTela) .And.  (nOpc == ALT_DET .Or.  AP100NotiExist())
      ElseIf nOpc == EXC_DET .And. (lEENAuto .Or. MsgNoYes(STR0053,STR0009)) //'Confirma Exclusão ? '###'Excluir'
         WorkNo->(DBGOTO(nRecNo))
         If WorkNo->WK_RECNO != 0
            AADD(aNoDeletados,WorkNo->WK_RECNO)
         EndIf
         WorkNo->(DBDELETE())
         WorkNo->(dbSkip(-1))
         IF WorkNo->(Bof())
            WorkNo->(dbGoTop())
         Endif
      EndIf
   End Sequence

Return lRet

/*
Funcao      : AP100NotiExist
Parametros  : nenhum
Retorno     : .T./.F.
Objetivos   : Verificar se o Notify ja existe
Autor       : Cristiano A. Ferreira
Data/Hora   : 25/08/1999 15:00
Revisao     :
Obs.        :
*/
Function AP100NotiExist()

Local lRet := .t.

Local aOrd := SaveOrd("WorkNo",1)

Begin Sequence

   IF Empty(M->EEN_IMLOJA)
      Break
   Endif

   IF WorkNo->(dbSeek(M->EEN_IMPORT+M->EEN_IMLOJA))
      IF nRegistro != WorkNo->(RecNo())
         HELP(" ",1,"AVG0005000") //MsgStop("Notify já cadastrado !","Aviso")
         lRet := .f.
         Break
      Endif
   Endif

   //** BY JBJ - 26/07/01 9:48
   //M->EEN_ENDIMP := IF(EMPTY(M->EEN_ENDIMP),EECMEND("SA1",1,M->EEN_IMPORT,.T.)[1],M->EEN_ENDIMP)
   //M->EEN_END2IM := IF(EMPTY(M->EEN_END2IM),EECMEND("SA1",1,M->EEN_IMPORT,.T.)[2],M->EEN_END2IM)

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : AP100Agenda()
Parametros  : Nenhum
Retorno     : .t./.f.
Objetivos   : Agenda de atividades / Documentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 03/08/2002 16:19
Revisao     :
Obs.        :
*/
*-------------------------------*
Function AP100Agenda(cOcorrencia, nOpcAuto, aAuto)
*-------------------------------*
Local lRet:=.t., nOldArea:=Select(), oDlg, aPos
Local bIsEmpty := {|| IF(IsVazio("WorkDoc"),(HELP(" ",1,"AVG0000632"),.F.),.T.) }
Local lPedido := If(cOcorrencia==OC_PE,.t.,.f.)
Local cPedido := If(lPedido,M->EE7_PEDIDO,M->EEC_PREEMB)
Local bCancel := {|| oDlg:End()}, bOk := {|| oDlg:End()}
Local aButtons := {}, cCodLjImp
Local lVisualizar := If(nSelecao = VISUALIZAR,.T.,.F.)
Private lEXBAuto := ValType(aAuto) == "A" .And. ValType(nOpcAuto) == "N"
Private aHeader := {}, aCampos :={}, oMsSelect

Begin Sequence

   aAdd(aButtons,{"HISTORIC",{||AP100HistImpr(cPedido,lPedido)},STR0055}) //"Histórico de Impressões"

   If INCLUI .Or. ALTERA
      aAdd(aButtons,{"BMPINCLUIR" /*"EDIT"*/,   {||AP100TaskMan(INC_DET,oMsSelect,lPedido)},STR0056}) //"Incluir"
      aAdd(aButtons,{"EDIT" /*"ALT_CAD"*/,{||If(Eval(bIsEmpty),AP100TaskMan(ALT_DET,oMsSelect,lPedido),Nil)},STR0057}) //"Alterar"
      aAdd(aButtons,{"EXCLUIR",{||If(Eval(bIsEmpty),AP100TaskMan(EXC_DET,oMsSelect,lPedido),Nil)},STR0058}) //"Excluir"
   EndIf

   cCodLjImp:=If(lPedido,M->EE7_IMPORT+M->EE7_IMLOJA,M->EEC_IMPORT+M->EEC_IMLOJA)
   AddTarefa(Posicione("SA1",1,xFilial("SA1")+cCodLjImp,"A1_PAIS"),cCodLjImp,lPedido)

   WorkDoc->(DbGoTop())

   If !lEXBAuto

      DEFINE MSDIALOG oDlg TITLE STR0059 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Agenda de Atividades/Documentos"

         aPos:=PosDlg(oDlg) ; aPos[1] := 15
         oMsSelect := MsSelect():New("WorkDoc",,,aDocBrowse,,,aPos)
         oDlg:lMaximized:= .T.
         oMsSelect:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT
         oMsSelect:bAval := {|| If(lVisualizar,AP100DocView(cPedido,lPedido),Nil),oMsSelect:oBrowse:Refresh()}

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons)
   Else
      If EasySeekAuto("WorkDoc",aAuto,2)
         If nOpcAuto == INCLUIR//Upsert
            nOpcAuto := ALT_DET
         ElseIf nOpcAuto == ALTERAR
            nOpcAuto := ALT_DET
         ElseIf nOpcAuto == EXCLUIR
            nOpcAuto := EXC_DET
         EndIf
      ElseIf nOpcAuto == INCLUIR//Upsert
         nOpcAuto := INC_DET
      ElseIf (nOpcAuto == ALTERAR) .Or. (nOpcAuto == EXCLUIR)
         EasyHelp(STR0132, STR0049) //"Falha de Integração: Registro não localizado na tabela de Agenda de Documentos."###"Aviso"
         lRet := .F.
      EndIf
      If lRet
         lRet := AP100TaskMan(nOpcAuto,Nil,lPedido,aAuto)
      EndIf
   EndIf

End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : AddTarefa(cImpPais,cCodLjImp,lPedido)
Parametros  : cImpPais  => Pais do importador
              cCodLjImp => Codigo + Loja do importador
              lPedido   => Pedido ou embarque
Retorno     : .t./.f.
Objetivos   : Adcionar tarefa no EXB.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/08/2002 17:24
Revisao     :
Obs.        :
*/
*--------------------------------------------*
Function AddTarefa(cImpPais,cCodLjImp,lPedido)
*--------------------------------------------*
Local lRet:=.f., aOrd:=SaveOrd("EE1")
Local lEE7_PEDIDO, lEEC_PREEMB
Private lBreak := .F.
Default lPedido := .t.

Begin Sequence

   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,{"AP101_ADDTAREFA",cImpPais,cCodLjImp,lPedido})
      If lBreak
         Break
      EndIf
   EndIf

   If WorkDoc->(EasyReccount("WorkDoc")) <> 0
      Break
   EndIf

   EE1->(DbSetOrder(3))

   lEE7_PEDIDO:= Type("M->EE7_PEDIDO") == "C"
   lEEC_PREEMB:= Type("M->EEC_PREEMB") == "C"
   If EE1->(DbSeek(xFilial("EE1")+TR_ARQ+cImpPais+cCodLjImp))
      Do While EE1->(!Eof() .And. EE1_FILIAL == xFilial("EE1")) .And. EE1->EE1_CODCLI+EE1->EE1_CLLOJA == cCodLjImp

         If (lPedido .And. EE1->EE1_FASE <> "2") .Or. (!lPedido .And. EE1->EE1_FASE <> "3")
            EE1->(DbSkip())
            Loop
         EndIf

         WorkDoc->(RecLock("WorkDoc", .T.))

         If lPedido
            If lEE7_PEDIDO
               WorkDoc->EXB_PEDIDO:=M->EE7_PEDIDO
            Else
               WorkDoc->EXB_PEDIDO:=EE7->EE7_PEDIDO
            EndIf
         Else
            If lEEC_PREEMB
               WorkDoc->EXB_PEDIDO:=M->EEC_PREEMB
            Else
               WorkDoc->EXB_PEDIDO:=EEC->EEC_PREEMB
            EndIf
         EndIf

         WorkDoc->EXB_CODATV:=EE1->EE1_DOCUM
         WorkDoc->EXB_TIPO  :="1" // Ativo
         WorkDoc->EXB_FLAG  :="2" // Automatico
         WorkDoc->EXB_ORDEM := EE1->EE1_ORDEM
         WorkDoc->(MsUnlock())
         EE1->(DbSkip())
      EndDo

   ElseIf EE1->(DbSeek(xFilial("EE1")+TR_ARQ+cImpPais+Space(AVSX3("EE1_CODCLI",AV_TAMANHO))+Space(AVSX3("EE1_CLLOJA",AV_TAMANHO))))
      Do While EE1->(!Eof() .And. EE1_FILIAL == xFilial("EE1")) .And. cImpPais == EE1->EE1_PAIS .And.;
               EE1->EE1_CODCLI+EE1->EE1_CLLOJA == Space(AVSX3("EE1_CODCLI",AV_TAMANHO))+Space(AVSX3("EE1_CLLOJA",AV_TAMANHO))

         If (lPedido .And. EE1->EE1_FASE <> "2") .Or. (!lPedido .And. EE1->EE1_FASE <> "3")
            EE1->(DbSkip())
            Loop
         EndIf

         WorkDoc->(RecLock("WorkDoc", .T.))
         WorkDoc->EXB_PEDIDO:=If(lPedido ,M->EE7_PEDIDO,"")
         WorkDoc->EXB_PREEMB:=If(!lPedido,M->EEC_PREEMB,"")
         WorkDoc->EXB_CODATV:=EE1->EE1_DOCUM
         WorkDoc->EXB_TIPO  :="1" // Ativo
         WorkDoc->EXB_FLAG  :="2" // Automatico
         WorkDoc->EXB_ORDEM := EE1->EE1_ORDEM
         WorkDoc->(MsUnlock())
         EE1->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP100TaskMan(nTipo,oMsSelect)
Parametros  : nTipo  := INC_DET/ALT_DET/EXC_DET
Retorno     : .T.
Objetivos   : Permitir manutencao de tarefas.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/08/02 10:07
Obs.        :
*/
*--------------------------------------------*
Function AP100TaskMan(nTipo,oMsSelect,lPedido,aAuto)
*--------------------------------------------*
Local lRet:=.T.,cOldArea:=Select()
Local oDlg,nInc,cSequencia
Local nRecno,aPos, i, cNewTit
Local nOpcA := 0, aBufferIt
Local bOk, bCancel := {|| oDlg:End()},aButtons:={}

Private aTela[0][0],aGets[0], nUsado, aTaskEnchoice:={}

Default lPedido := .t.

Begin Sequence

   IF nTipo <> INC_DET
      IF WorkDoc->(Eof() .And. Bof())
         HELP(" ",1,"AVG0000632") //MsgInfo("Não existem registros para a manutenção !","Aviso")
         Break
      Endif
   Endif

   aTaskEnchoice:= {"EXB_CODATV","EXB_DTREAL","EXB_OBS","EXB_FLAG","EXB_USER","EXB_DATA","EXB_VM_DES"}

   If nTipo==INC_DET

      bOk:={||If(Obrigatorio(aGets,aTela) .And. !IsDocDisable(.T.),(nOpca:=1,If(lEXBAuto,Nil,oDlg:End())),Nil)}
      cNewTit:= STR0060 //"Inclusão de Tarefa"

      WorkDoc->(DBGOBOTTOM())
      cOrdem := Str(Val(WorkDoc->EXB_ORDEM)+1,TAMSX3("EXB_ORDEM")[1])
      WorkDoc->(DBSKIP())

   ElseIf nTipo == ALT_DET

      If WorkDoc->EXB_FLAG # "1"
         EasyHelp(STR0061,STR0027) //"Só é permitida a alteração de tarefas específicas."###"Atenção"
         Break
      EndIf

      bOk:={|| nOpca:=1,If(lEXBAuto, Nil, oDlg:End())}
      cNewTit:= STR0062 //"Alteração de Tarefa"

   Else

      If WorkDoc->EXB_FLAG # "1"
         EasyHelp(STR0063,STR0027) //"Só é permitida a exclusão de tarefas específicas."###"Atenção"
         Break
      EndIf

      bOk:={|| If(AP100DeDoc(EXC_DET,WorkDoc->(RecNo())),If(lEXBAuto,Nil,oDlg:End()),Nil)}
      cNewTit:= STR0064 //"Exclusão de Tarefa"

   EndIf
   nRecno:=WorkDoc->(RecNo())

   For nInc := 1 TO WorkDoc->(fCount())
      M->&(WorkDoc->(FieldName(nInc))) := WorkDoc->(FieldGet(nInc))
   Next

   If nTipo == INC_DET .Or. nTipo == ALT_DET

      If nTipo == INC_DET
         M->EXB_ORDEM  := cOrdem
      EndIf

      M->EXB_PEDIDO := If(lPedido,M->EE7_PEDIDO,M->EEC_PREEMB)
      M->EXB_TIPO   := "1"
      M->EXB_FLAG   := "1"
      M->EXB_USER   := cUserName
      M->EXB_DATA   := dDataBase

   EndIf

   If !lEXBAuto

      DEFINE MSDIALOG oDlg TITLE cNewTit FROM 7,3 TO 30,80 OF oMainWnd

         aPos := PosDlg(oDlg)
         aPos[1] := 30
         EnChoice("EXB",,If(nTipo=INC_DET,3,4),,,,aTaskEnchoice,aPos)

      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED
   Else
      EnchAuto("EXB",aAuto,{|| Obrigatorio(aGets,aTela)},If(nTipo=INC_DET,3,4), aTaskEnchoice)
      If !lMsErroAuto
         Eval(bOk)
      EndIf
   EndIf

   If nOpcA == 1
      If nTipo == INC_DET
         WorkDoc->(RecLock("WorkDoc", .T.))
         AvReplace("M","WorkDoc")
         WorkDoc->EXB_ORDEM:=cOrdem

      Elseif nTipo == ALT_DET
         WorkDoc->(RecLock("WorkDoc", .F.))
         AvReplace("M","WorkDoc")
      EndIf
      WorkDoc->(MsUnlock())
      If !lEXBAuto
         oMsSelect:oBrowse:Refresh()
      EndIf
   EndIf

End Sequence

dbSelectArea(cOldArea)

Return lRet

/*
Funcao      : AP100DocView(cProc)
Parametros  :
Retorno     : .t.
Objetivos   : Vizualizar documentos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/08/2002 16:22
Revisao     :
Obs.        :
*/
*----------------------------------*
Function AP100DocView(cProc,lPedido)
*----------------------------------*
Local lRet:=.t., aSemSx3, cArqWork
Local nRecPedido,nOldArea:=Select()

Private aCampos:=Array(EEA->(fCount())), cSeqRel

Default lPedido:= .t.

Begin Sequence

   cAlias     := If(lPedido,"EE7","EEC")
   nRecPedido := If(lPedido,EE7->(RecNo()), EEC->(RecNo()))

   EEA->(DbSeek(xFilial("EEA")+WorkDoc->EXB_CODATV))

   If Left(EEA->EEA_TIPDOC,1) == "4"
      AP100TaskMan(ALT_DET,oMsSelect,lPedido)
   EndIf

   aSemSx3 := {{ "WKFLAG" ,"C",2,0 },;
               {"WKPAISEX","C",3,0},{"WKIDPROC","C",AVSX3("EEA_IDIOMA",AV_TAMANHO),0},;
               {"WKIDPAIS","C",AVSX3("EEA_IDIOMA",AV_TAMANHO),0}}

   cArqWork:=E_CriaTrab("EEA",aSemSX3,"WorkID")
   IndRegua("WorkId",cARQWORK+TEOrdBagExt(),"EEA_COD")

   cIndex2 := CriaTrab(,.f.)
   IndRegua("WorkId",cIndex2+TEOrdBagExt(),"EEA_TITULO")
   Set Index To (cArqWork+TEOrdBagExt()),(cIndex2+TEOrdBagExt())

   WorkId->(RecLock("WorkId", .T.))
   AvReplace("EEA","WorkId")
   WorkId->WKFLAG:="*"

   /*
   If !Empty(WorkDoc->EXB_DTREAL)
      // chamada do documento do histórico
      SY0->(DbSetOrder(4))
      If SY0->(DbSeek(xFilial("SY0")+cProc+WorkId->EEA_FASE+AvKey(WorkId->EEA_COD,"Y0_CODRPT")))
         Do While SY0->(!Eof()) .And. SY0->Y0_FILIAL == xFilial("SY0") .And.;
                  SY0->Y0_PROCESS == cProc .And. SY0->Y0_FASE == WorkId->EEA_FASE .And.;
                  SY0->Y0_CODRPT == AvKey(WorkId->EEA_COD,"Y0_CODRPT")

            nRec:=SY0->(RecNo())

            SY0->(DbSkip())
         EndDo
         SY0->(DbGoTo(nRec))
         AvRPTView()
      EndIf
   Else
      cSeqrel :=GetSxeNum("SY0","Y0_SEQREL")
      CONFIRMSX8()

      AA100CRW(cProc,WorkId->EEA_FASE)
   EndIf
   */
   // ** By JBJ - 05/02/2003 - Sempre chamar o rdmake do documento selecionado.
   cSeqrel :=GetSxeNum("SY0","Y0_SEQREL")
   CONFIRMSX8()

   AA100CRW(cProc,WorkId->EEA_FASE)

   WorkId->(MsUnlock())

   WorkID->(E_EraseArq(cArqWork,cIndex2))

End Sequence

(cAlias)->(DbGoTo(nRecPedido))
DbSelectArea(nOldArea)

Return lRet

/*
Funcao      : AP100HistImpr(cProcesso)
Parametros  : cProcesso
Retorno     : .t.
Objetivos   : Vizualizar histórico de impressões.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/08/2002 11:12
Revisao     :
Obs.        :
*/
*---------------------------------------*
Function AP100HistImpr(cProcesso,lPedido)
*---------------------------------------*
Local nAliasOld := Select()
Local lRet:=.t., cWork, aSemSx3:={}, oDlg, aPos, aHisBrowse:={}
Local oMsSelect, aButtons, aOrd:=SaveOrd("EXB")
Local bOk     := {|| oDlg:End()}
Local bCancel := {|| oDlg:End()}

Local cPedido, cPreemb

Private aCampos:=Array(Exb->(fCount()))

Default lPedido := .t.

Begin Sequence

   cWork:=E_CriaTrab("EXB",aSemSX3,"WorkH")
   IndRegua("WorkH",cWork+TEOrdBagExt(),"EXB_DATA")
   Set Index To (cWork+TEOrdBagExt())

   cPedido := If(lPedido,cProcesso,Space(AvSx3("EE7_PEDIDO",AV_TAMANHO)))
   cPreemb := If(lPedido,Space(AvSx3("EEC_PREEMB",AV_TAMANHO)),cProcesso)

   EXB->(DbSetOrder(1))
   EXB->(DbSeek(xFilial("EXB")+cPreemb+cPedido))

   Do While EXB->(!Eof()) .And. EXB->EXB_FILIAL == xFilial("EXB") .And.;
            EXB->EXB_PREEMB == cPreemb .And.;
            EXB->EXB_PEDIDO == cPedido

      WorkH->(RecLock("WorkH", .T.))
      AvRePlace("EXB","WorkH")
      WorkH->(MsUnlock())  
      EXB->(DbSkip())
   EndDo

   //MCF - 10/09/2015
   aHisBrowse := {{{|| If (!Empty(WorkH->EXB_FLAG),WorkH->EXB_FLAG+"-"+If(WorkH->EXB_FLAG="1",STR0065,STR0066),"")},"",STR0067},; //"Específica"###"Padrão(Cliente/País)"###"Tipo de Tarefa"
                  {{|| If (!Empty(WorkH->EXB_CODATV),AllTrim(WorkH->EXB_CODATV)+" - "+Posicione("EEA",1,xFilial("EEA")+WorkH->EXB_CODATV,"EEA_TITULO"),"")},"",AVSX3("EXB_CODATV",AV_TITULO)},;
                  {{|| If (!Empty(WorkH->EXB_TIPO),WorkH->EXB_TIPO+"-"+If(WorkH->EXB_TIPO="1",STR0068,STR0069),"")},"",AVSX3("EXB_TIPO",AV_TITULO)},; //"Ativo"###"Histórico"
                  {{|| If (!Empty(WorkH->EXB_DTREAL),Transf(WorkH->EXB_DTREAL,"  /  /  "),"")},"",AVSX3("EXB_DTREAL",AV_TITULO)},;
                  {{|| WorkH->EXB_OBS},"",AVSX3("EXB_OBS",AV_TITULO)},;
                  {{|| WorkH->EXB_USER},"",AVSX3("EXB_USER",AV_TITULO)},;
                  {{|| If (!Empty(WorkH->EXB_DATA),Transf(WorkH->EXB_DATA,"  /  /  "),"")},"",AVSX3("EXB_DATA",AV_TITULO)}}


   // by CRF 22/10/2010 - 12:02
   aHisBrowse :=AddCpoUser(aHisBrowse,"EXB","2")
   WorkH->(DbGoTop())
   WorkH->(DbSetOrder(1))

   DEFINE MSDIALOG oDlg TITLE STR0055 FROM 7,3 TO 30,80 OF oMainWnd //"Histórico de Impressões"

      aPos:=PosDlg(oDlg) ; aPos[1] := 15
      oMsSelect := MsSelect():New("WorkH",,,aHisBrowse,,,aPos)
      oMsSelect:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT //wfs
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

End Sequence

WorkH->(E_EraseArq(cWork))

RestOrd(aOrd)
dbSelectArea(nAliasOld)

Return lRet

*------------------------------*
Function AP101EstCtb(aEst, aInc)
*------------------------------*
Local cPreemb, cEvento, aDeletaECF := {}, dDataDesp, cNum, z, x, h, nValor := 0

ECF->(DbSetOrder(9))

For h:=1 to Len(aInc)

    // Estorna os eventos de estorno caso ainda não sejam contabilizados.
    cPreemb    := aInc[h,1]
    cEvento    := aInc[h,2]
    nValor     := aInc[h,3]
    aDeletaECF := {}

    ECF->(DbSeek(cFilECF+"EX"+cPreemb))

    Do While ECF->(!Eof()) .And. ECF->ECF_ORIGEM = 'EX' .And. ECF->ECF_FILIAL = cFilECF .And. ECF->ECF_PREEMB = cPreemb

       If Empty(ECF->ECF_NR_CON) .And. ECF->ECF_ID_CAM = '999' .And. ECF->ECF_LINK = cEvento .And. ECF->ECF_VALOR = nValor
          ECF->(RecLock("ECF",.F.))
   		  ECF->(DbDelete())
   		  ECF->(MsUnlock())
       Endif

       ECF->(DbSkip())
    Enddo

Next

For h:=1 to Len(aEst)

    cPreemb    := aEst[h,1]
    cEvento    := aEst[h,2]
    dDataDesp  := aEst[h,3]
    cNum       := aEst[h,4]
    aDeletaECF := {}

    ECF->(DbSeek(cFilECF+"EX"+cPreemb))

    Do While ECF->(!Eof()) .And. ECF->ECF_ORIGEM = 'EX' .And. ECF->ECF_FILIAL = cFilECF .And. ECF->ECF_PREEMB = cPreemb

       If ECF->ECF_ID_CAM = cEvento .And. ECF->ECF_DTCONV = dDataDesp .And. ECF->ECF_NR_CON = cNum
          Aadd( aDeletaECF, ECF->(Recno()) )
       Endif

       ECF->(DbSkip())
    Enddo

    For z := 1 to Len(aDeletaECF)

     Begin Transaction

        ECF->(DbGoto(aDeletaECF[z]))

        FOR x := 1 TO ECF->(FCount())
            M->&(ECF->(FIELDNAME(x))) := ECF->(FIELDGET(x))
   		NEXT

        ECF->(RecLock("ECF",.F.))
   		ECF->(DbDelete())
   		ECF->(MsUnlock())

   		// Grava Registro de Estorno
        ECF->(RecLock("ECF",.T.))
   		AvReplace("M","ECF")
        ECF->ECF_ID_CAM := '999'
        ECF->ECF_NR_CON := Space(04)
        ECF->ECF_DTCONT := dDataBase
        ECF->ECF_DTCONV := M->ECF_DTCONT
   		ECF->(MsUnlock())

   	 End Transaction
    Next
Next
ECF->(DbSetOrder(1))

Return NIL

/*
Funcao      : EECFlags(cNmRotina).
Parametros  : cNmRotina - Nome da rotina.
Retorno     : .t./.f.
Objetivos   : Set da flag de controle para a rotina especificada.
Autor       : Jeferson Barros jr.
Data/Hora   : 05/06/03 17:19.
Revisao     :
Obs.        :
*/
*--------------------------*
Function EECFlags(cNmRotina)
*--------------------------*
Local lRet:=.f., aCmp:={}, i, j:=0, aSaveOrd := SaveOrd({"EC6", "SX3"}), cOld, aCampos
Local cArea := Select()
Static cFilAnterior // JPM

Static lAgenteComis // Tratamento para comissão por agente.
Static lOrdenaProcs // Tratamento para ordenacao decrescente de processos.
Static lFreSegCom   // Tratamento para a rotina de cambio, frete, seguro e comissão.
Static lCompleEmb   // Tratamento para manutenção da tabela EXL (Dados Complementares de Embarque).
Static lEXLCapa     // Tratamento exibição dos Dados Complementares de Embarque na capa do processo de embarque.
Static lHistPreCalc // Tratamento para manutenção da tabela EXL (Dados Complementares de Embarque).
Static lItensLc     // Tratamento de Carta de Crédito por Item
Static lInvoice     // Tratamento para vinculação de invoices( Tabelas EXP e EXR) FJH 06/09/05
Static lConsign     // Tratamento para consignação
Static lControlQtd  /* Tratamento de controle de quantidades entre filiais Br. e Off-Shore para
                       ambientes com rotina de Commodities e Off-Shore ligadas. JPM - 22/09/05 */
Static lCommodity   // Rotina de Commodities. JPM - 22/09/05
Static lIntermed    // Rotina de Intermediação. (Off-Shore) JPM - 22/09/05
Static lAmostra     // Tratamento para a rotina de amostras RMD - 24/10/05
Static lBolsas      // Tratamento para a rotina de cotações de bolsas de valores RMD - 10/11/05
Static lNewRv       // Novo Tratamento para a rotina de R.V., para tratamentos de Café - JPM - 16/11/05
Static lCafe        // Tratamento para rotinas relacionadas a Exportação de Café RMD - 16/11/05
Static lFatFilial   // Tratamento para que as notas de um embarque possam ser geradas em várias filiais - JPM - 21/12/05
Static lEstufagem   // Nova rotina de estufagem de exportação RMD - 13/02/2008
Static lPreContainer//Pré-Estufagem de containeres
Static lInttra      // Tratamento para integração com o Inttra - ER - 14/08/2007
Static lIntEmb      // Tratamento para geração de Pedido de Venda a Partir do Embarque - ER - 18/01/2008
Static lVisPdf      // Configurações para exibição de arquivos pdf RMD - 26/03/08
Static lCprFob      // Tratamento para compra FOB - RMD - 04/05/08
Static lCafe_Opc    // Processos opcionais de exportação de café RMD - 26/05/08
Static lCommo_Opc   // Processos opcionais de exportação de commodities IAC - 12/06/08
Static lNovoCambio  // Tratamento para nova legislação e regulamentação câmbial - AAF - 08/02/2008
Static lAmBase      // Opção para informar uma amostra de outro processo como base para um embarque
Static lAdParcial   // Adiantamentos com vinculação parcial quando integrado com o Financeiro
Static lWizardRE
Static lNovoEx      // Integração com o Siscomex Exportação Web
Static lTitParcelas // Tratamento de parcelas de titulos a receber quando integrado EECXFIN - FSM - 02/08/2012
Static lAltEasyLink // Tratamento para real alteração de titulos atraves do EasyLink - FSM - 02/08/2012

Private aTabelas := {} /*RRC - 06/12/2013 - Necessário declarar a variável aTabelas, pois a mesma é utilizada na verificação da flag "CAMBIO_EXT", porém, também existe
variável private com o mesmo nome no EICDI500(), por onde ocorre a chamada para integração entre SIGAEIC x SIGAESS*/

Begin Sequence

   If cFilAnterior <> AvGetM0Fil() // JPM - quando é mudada a filial, alguns tratamentos podem ser diferentes
      lFatFilial := Nil
   EndIf

   cNmRotina := Upper(AllTrim(cNmRotina))

   If EasyGetBuffers("EECFLAGS",cFilAnt+','+cNmRotina,@lRet)
      break
   EndIf
   
   Do Case
      Case cNmRotina == "COMISSAO" // ** Tratamento para comissão por agente.

         If ValType(lAgenteComis) = "U"
            lAgenteComis := .f.

            If EEB->(FieldPos("EEB_TIPCOM")) > 0 .And. EEB->(FieldPos("EEB_TIPCVL")) > 0 .And.;
               EEB->(FieldPos("EEB_VALCOM")) > 0 .And. EEB->(FieldPos("EEB_REFAGE")) > 0 .And.;
               EEB->(FieldPos("EEB_TOTCOM")) > 0 .And. EE8->(FieldPos("EE8_CODAGE")) > 0 .And.;
               EE9->(FieldPos("EE9_CODAGE")) > 0 .And. EE8->(FieldPos("EE8_PERCOM")) > 0 .And.;
               EE9->(FieldPos("EE9_MAXCOM")) > 0 .And. EE9->(FieldPos("EE9_PERCOM")) > 0

               /*
               AMS - 22/08/2005. Implementado consistência abaixo, para verificar a existencia de campos virtuais
                                 no dicionário de dados.
               */
               aCmp := {"EE7_DSCCOM",;
                        "EE8_DSCAGE",;
                        "EE8_VLCOM",;
                        "EEC_DSCCOM",;
                        "EE9_DSCAGE",;
                        "EE9_VLCOM"}

               For j := 1 To Len(aCmp)
                  If !AvSX3(aCmp[j],,, .T.)
                     Break
                  EndIf
               Next

               lAgenteComis := .t.

            EndIf
         EndIf

         lRet := lAgenteComis

      Case cNmRotina == "ORD_PROC" // ** Tratamento para rotina de ordenação de processos.

         If ValType(lOrdenaProcs) = "U"
            lOrdenaProcs := .f.

            If EE7->(FieldPos("EE7_KEY")) > 0 .And. EasyGParam("MV_AVG0056",,.f.)
               lOrdenaProcs := .t.
            EndIf
         EndIf

         lRet := lOrdenaProcs

      Case cNmRotina == "FRESEGCOM" // ** Tratamento para a rotina de cambio, frete, seguro e comissão.

         If ValType(lFreSegCom) = "U"
            cOld := Select()
            //JPM - 08/03/05
            IF SX2->(dbSeek("EXL"))
               dbSelectArea("EXL")
            Endif

            /*AMS - 28/09/2004 às 17:25*/
            If !EECFlags("COMISSAO")
               Break
            EndIf

            IF Select("EXL") == 0
               Break
            Endif

            lFreSegCom := .t.

            aCmp := {{"EEQ","EEQ_CODEMP"},{"EEQ","EEQ_FORN"  },{"EEQ","EEQ_FOLOJA"},;
                     {"EEQ","EEQ_IMPORT"},{"EEQ","EEQ_IMLOJA"},{"EEQ","EEQ_MOEDA" },;
                     {"EEQ","EEQ_PARI"  },{"EEQ","EEQ_TIPO"  },{"EEQ","EEQ_CGRAFI"},;
                     {"EEQ","EEQ_AREMET"},{"EEQ","EEQ_ADEDUZ"},{"EET","EET_CODAGE"},;
                     {"EET","EET_TIPOAG"}}

            aDespesas := X3DIReturn()

            For j:=1 To Len(aDespesas)
               aAdd(aCmp,{"EXL","EXL_VD"+aDespesas[j,1]})
               aAdd(aCmp,{"EXL","EXL_CP"+aDespesas[j,1]})
               aAdd(aCmp,{"EXL","EXL_DT"+aDespesas[j,1]})
               aAdd(aCmp,{"EXL","EXL_FO"+aDespesas[j,1]})
               aAdd(aCmp,{"EXL","EXL_LF"+aDespesas[j,1]})
               aAdd(aCmp,{"EXL","EXL_EM"+aDespesas[j,1]})
            Next j

            For j:=1 To Len(aCmp)
               If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                  lFreSegCom := .f.
                  Exit
               EndIf
            Next

            /* by jbj - 06/10/04 - 15:55 O campo virtual Valor de Fechamento Cambial deverá existir
                                         no SX3. */
            If !AvSX3("EEQ_VLFCAM",,,.t.)
               lFreSegCom := .f.
               lRet := lFreSegCom
               Break
            EndIf

            /*
            AMS - 28/09/2004 às 17:25. Verifica se os parametros que definem o evento para as despesas
                                       (Despesas Internacionais), estão do SX6.
            */

            /* Alterado para tratar na geração de parcelas de cambio (AF200GPARC)
            aCmp := X3DIReturn()

            For j := 1 To Len(aCmp)

               If !EasyGParam("MV"+SubStr(aCmp[j][2], 4), .T.)
                  lFreSegCom := .F.
                  Exit
               EndIf

               If !EC6->(dbSeek(xFilial()+AVKey("EXPORT", "EC6_TPMODU")+AVKey(EasyGParam("MV"+SubStr(aCmp[j][2], 4)), "EC6_ID_CAM")))
                  lFreSegCom := .F.
                  Exit
               EndIf

            Next
            */
            DbSelectArea(cOld)
         EndIf

         lRet := lFreSegCom

      Case cNmRotina == "COMPLE_EMB" // Tratamento para manutenção de complemento de embarque.

         If ValType(lCompleEmb) = "U"
            lCompleEmb := .t.

            // by CAF 06/01/2005 - Para tratar novas tabelas na 8.11, deve-se verificar o SX2.
            IF SX2->(dbSeek("EXL"))
               dbSelectArea("EXL")
            Endif

            If Select("EXL") <= 0
               lCompleEmb := .f.
            EndIf
         EndIf

         lRet := lCompleEmb

      Case cNmRotina == "COMPLE_EMB_CAPA"
      //Permitir que a enchoice da tabela de complemento de embarque seja exibida em um folder na capa do embarque

         If ValType(lEXLCapa) == "U"

            SX2->(DbSetOrder(1))
            IF SX2->(dbSeek("EXL"))
               dbSelectArea("EXL")
            EndIf

            SX3->(DbSetOrder(2))
            If Select("EXL") > 0
               lEXLCapa := SX3->(DbSeek(IncSpace("EEC_EXL", AvSX3("X3_CAMPO",AV_TAMANHO),.F.))) .And.;
                           !Empty(SX3->X3_FOLDER) .And. SXA->(DbSeek("EEC"+SX3->X3_FOLDER)) .And. X3Usado("EEC_EXL")
            EndIf
         EndIf

         lRet := lEXLCapa

      Case cNmRotina == "HIST_PRECALC" // Tratamento para manutenção de histórico de pré-calculo.

         If ValType(lHistPreCalc) = "U"
            lHistPreCalc := .t.

            //DFS - 10/12/10 - Inclusão de ChkFile para retornar .T. se o arquivo já estiver aberto.
            If !ChkFile("EXM") .Or. !ChkFile("EXL") .OR. (Select("EXM") <= 0 .Or. !EasyGParam("MV_AVG0072",.t.) .Or. !EasyGParam("MV_AVG0072") .Or.;
               Select("EXL") <= 0 .Or. EXL->(FieldPos("EXL_TABPRE")) == 0)
               lHistPreCalc := .f.
            EndIf
         EndIf

         lRet := lHistPreCalc

      Case cNmRotina == "INVOICE" // ** By OMJ - 17/06/05 - Manutenção de Invoice.

         If ValType(lInvoice) = "U" //FJH 08/09/05 Correção na verificação de campos das tabelas EXP e EXR
            lInvoice:=.T.
         Endif

         lRet := lInvoice

      Case cNmRotina == "ITENS_LC" // Tratamento de Carta de Crédito por item

         If ValType(lItensLc) = "U"
            lItensLc := .f.
            If !EasyGParam("MV_AVG0125", , .T.)//Parametro para define definir se o sistema utiliza o tratamento de Carta de Crédito por item.
               Break                      //Caso não exista o parâmetro cadastrado no sistema, a rotina continua habilitada.
            EndIf
            SX2->(DbSetOrder(1))
            If SX2->(DbSeek("EXS"))
               cOld := Select()
               DbSelectArea("EE9") //para abrir a tabela caso não esteja carregada.
               DbSelectArea("EXS") //para abrir a tabela caso não esteja carregada.
               If Select("EXS") > 0
                  If EE9->(FieldPos("EE9_LC_NUM") > 0 .And. FieldPos("EE9_SEQ_LC") > 0)
                     lItensLc := .t.
                  EndIf
               EndIf
               DbSelectArea(cOld)
            EndIf
         EndIf

         lRet := lItensLc

      Case cNmRotina == "CONSIGNACAO"// Tratamentos de consignação
         /*
         If ValType(lConsign) == "L"
            lRet := lConsign
            Break
         Else
            ChkFile("EY5")
            ChkFile("EY6")
            ChkFile("EY7")
            ChkFile("EER")
            If Select("EY5") > 0 .And. Select("EY6") > 0 .And. Select("EY7") > 0 .And. Select("EER") > 0
               //Campos Reais
               aCmp := {{"EY5","EY5_FILIAL"},{"EY5","EY5_IMPORT"},{"EY5","EY5_IMLOJA"},;
                        {"EY5","EY5_PREEMB"},{"EY5","EY5_PEDIDO"},{"EY5","EY5_SEQUEN"},;
                        {"EY5","EY5_COD_I" },{"EY5","EY5_RE"    },{"EY5","EY5_DTRE"  },;
                        {"EY5","EY5_INVOIC"},{"EY5","EY5_UNIDAD"},{"EY5","EY5_SLDINI"},;
                        {"EY5","EY5_SLDATU"},{"EY5","EY5_DTREC" },{"EY5","EY5_ORIGEM"},;
                        {"EY6","EY6_FILIAL"},{"EY6","EY6_PREEMB"},{"EY6","EY6_RE"    },;
                        {"EY6","EY6_SLDINI"},{"EY6","EY6_SLDATU"},{"EY6","EY6_PRAZO" },;
                        {"EY6","EY6_STATUS"},{"EY6","EY6_HIST"  },{"EY6","EY6_UNIDAD"},;
                        {"EY7","EY7_FILIAL"},{"EY7","EY7_EMBVIN"},{"EY7","EY7_IMPORT"},;
                        {"EY7","EY7_IMLOJA"},{"EY7","EY7_PREEMB"},{"EY7","EY7_PEDIDO"},;
                        {"EY7","EY7_SEQUEN"},{"EY7","EY7_COD_I" },{"EY7","EY7_RE"    },;
                        {"EY7","EY7_DTRE"  },{"EY7","EY7_INVOIC"},{"EY7","EY7_UNIDAD"},;
                        {"EY7","EY7_SLDINI"},{"EY7","EY7_ORIGEM"},{"EEC","EEC_TIPO"  },;
                        {"EE7","EE7_TIPO"  },{"EER","EER_RE"    },{"EER","EER_MANUAL"}}

               For j := 1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                     lRet := lConsign := .F.
                     Break
                  EndIf
               Next
               //Campos Virtuais
               aCmp := {"EEC_DTREC","EY6_STTDES"}
               SX3->(DbSetOrder(2))
               For j := 1 To Len(aCmp)
                  If !SX3->(DbSeek(aCmp[j]))
                     lRet := lConsign := .F.
                     Break
                  EndIf
               Next
            Else
               lRet     := .F.
               lConsign := .F.
               Break
            EndIf
         Endif
         */
         lRet     := .T.
         lConsign := .T.

      Case cNmRotina == "CONTROL_QTD" /* Controle de quantidades entre filiais Br. e Off-Shore para
                                         ambientes com rotina de Commodities e Off-Shore ligadas. JPM - 22/09/05 */

         If ValType(lControlQtd) = "U"
            lControlQtd := .t.
            If !EECFlags("COMMODITY") .Or. !EECFlags("INTERMED")
               lControlQtd := .f.
            EndIf
         EndIf

         lRet := lControlQtd

      Case cNmRotina == "COMMODITY" /* Rotina de Commodities. JPM - 22/09/05 */

         If(Type("cFilBr") <> "C",cFilBr := "",Nil)
         If(Type("cFilEx") <> "C",cFilEx := "",Nil)

        // MPG - 01/08/2018 - Quando executa no inicio da abertura da janela preenche as variáveis e depois quando manda exckuir o processo não passa de novo por aqui mesmo quando a filial é diferente e isso faz com que os itens do pedido não sejam excluídos, assim como os itens das outras tabelas. 
         If Empty(cFilBr) .Or. Empty(cFilEx)
            // As variáveis cFilBr e cFilEx devem ser declaradas como Private antes da chamada da EECFlags("COMMODITY").
            cFilBr := EasyGParam("MV_AVG0023",,"",Alltrim(cFilAnt))
            cFilEx := EasyGParam("MV_AVG0024",,"",Alltrim(cFilAnt))
            cFilBr := If(AllTrim(cFilBr)=".","",cFilBr)
            cFilEx := If(AllTrim(cFilEx)=".","",cFilEx)
         EndIf
   
         If !EasyGetBuffers("EECFLAGS",cNmRotina,@lCommodity)
            lCommodity := .t.

            cAVG0034 := EasyGParam("MV_AVG0034",,"")
            cAVG0034 := IF(AllTrim(cAVG0034)=".","",cAVG0034)

            If !EasyGParam("MV_AVG0029",,.F.) .Or. Empty(cAVG0034)
               lCommodity:=.f.
            EndIf
            /* RMD - 05/04/07 - Na versão atual os campos abaixo já constam no dicionário padrão.
            Else

               aCmp := {{"EE8","EE8_DTCOTA"},{"EE8","EE8_DIFERE"},;
                        {"EE8","EE8_MESFIX"},{"EE8","EE8_STFIX" },;
                        {"EE8","EE8_DTFIX" },{"EE8","EE8_QTDLOT"}}

               For j:=1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                     lCommodity := .f.
                     Exit
                  EndIf
               Next

            EndIf
            */
            EasySetBuffers("EECFLAGS",cNmRotina,@lCommodity)
         EndIf

         lRet := lCommodity

         If lRet .And. EECFlags("COMMODITY_OPCIONAL")
            If Type("cTipoProc") == "C" .And. !(cTipoProc $ PC_CM+PC_CF)
               lRet := .F.
            EndIf
         EndIf

      Case cNmRotina == "INTERMED" /* Rotina de Intermediação. JPM - 22/09/05 */

         If(Type("cFilBr") <> "C",cFilBr := "",Nil)
         If(Type("cFilEx") <> "C",cFilEx := "",Nil)

        // MPG - 01/08/2018 - Quando executa no inicio da abertura da janela preenche as variáveis e depois quando manda exckuir o processo não passa de novo por aqui mesmo quando a filial é diferente e isso faz com que os itens do pedido não sejam excluídos, assim como os itens das outras tabelas. 
         If Empty(cFilBr) .Or. Empty(cFilEx)
            // As variáveis cFilBr e cFilEx devem ser declaradas como Private antes da chamada da EECFlags("INTERMED").
            cFilBr := EasyGParam("MV_AVG0023",,"",Alltrim(cFilAnt))
            cFilEx := EasyGParam("MV_AVG0024",,"",Alltrim(cFilAnt))
            cFilBr := If(AllTrim(cFilBr)=".","",cFilBr)
            cFilEx := If(AllTrim(cFilEx)=".","",cFilEx)
         EndIf

         If !EasyGetBuffers("EECFLAGS",cNmRotina,@lIntermed)
            lIntermed := .t.

            If Empty(cFilBr) .Or. Empty(cFilEx) .Or. !IsFilial()
               lIntermed := .f.
            Else
               aCmp := {{"EE7","EE7_INTERM"},{"EE7","EE7_COND2" },;
                        {"EE7","EE7_DIAS2" },{"EE7","EE7_INCO2" },;
                        {"EE7","EE7_PERC"  },{"EE8","EE8_PRENEG"},;
                        {"EEC","EEC_INTERM"},{"EEC","EEC_COND2" },;
                        {"EEC","EEC_DIAS2" },{"EEC","EEC_INCO2" },;
                        {"EEC","EEC_PERC"  }}

               For j:=1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                     lIntermed := .f.
                     Exit
                  EndIf
               Next

            EndIf
            EasySetBuffers("EECFLAGS",cNmRotina,@lIntermed)
         EndIf

         lRet := lIntermed

      Case cNmRotina == "AMOSTRA" // RMD - 24/10/05 - Manutenção de Amostras

         If !EasyGetBuffers("EECFLAGS",cNmRotina,@lAmostra)
            lAmostra := .T.

            If !EECFlags("CAFE")
               lAmostra := .F./* //RMD - 08/12/17 - Melhoria de performance
            Else
                
	            ChkFile("EXU")
	            ChkFile("EXV")
	            ChkFile("EXW")
	            ChkFile("EXX")
	            ChkFile("EXY")
	
	            If Select("EXU") > 0 .And. Select("EXV") > 0  .And. Select("EXW") > 0 .And. Select("EXX") > 0 .And. Select("EXY") > 0
	
	               aCmp := {{"EE7","EE7_ENVAMO"},{"EEC","EEC_ENVAMO"},{"EXU","EXU_DTMAIL"},;
	                        {"EE9","EE9_CODQUA"},{"EE9","EE9_QUADES"},{"EE9","EE9_CODPEN"},;
	                        {"EE9","EE9_DSCPEN"},{"EE9","EE9_CODTIP"},{"EE9","EE9_DSCTIP"},;
	                        {"EE8","EE8_CODQUA"},{"EE8","EE8_QUADES"},{"EE8","EE8_CODPEN"},;
	                        {"EE8","EE8_DSCPEN"},{"EE8","EE8_CODTIP"},{"EE8","EE8_DSCTIP"},;
	                        {"EXU","EXU_FILIAL"},{"EXU","EXU_NROAMO"},{"EXU","EXU_PEDIDO"},;
	                        {"EXU","EXU_STATUS"},{"EXU","EXU_CODQUA"},{"EXU","EXU_QUADES"},;
	                        {"EXU","EXU_CODPEN"},{"EXU","EXU_DSCPEN"},{"EXU","EXU_CODTIP"},;
	                        {"EXU","EXU_DSCTIP"},{"EXU","EXU_QTD"   },{"EXU","EXU_DTENV" },;
	                        {"EXU","EXU_NROCA" },{"EXU","EXU_DTAPRO"},{"EXU","EXU_DTREJE"},;
	                        {"EXU","EXU_CLAREJ"},{"EXU","EXU_OBS"   },{"EXV","EXV_FILIAL"},;
	                        {"EXV","EXV_NROAMO"},{"EXV","EXV_PEDIDO"},{"EXV","EXV_PREEMB"},;
	                        {"EXV","EXV_QTD"   },{"EXW","EXW_FILIAL"},{"EXW","EXW_CODQUA"},;
	                        {"EXW","EXW_QUADES"},{"EXX","EXX_FILIAL"},{"EXX","EXX_CODPEN"},;
	                        {"EXX","EXX_DSCPEN"},{"EXY","EXY_FILIAL"},{"EXY","EXY_CODTIP"},;
	                        {"EXY","EXY_DSCTIP"},{"EXU","EXU_TIPOAM"}}
	
	               For j:=1 To Len(aCmp)
	                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
	                     lAmostra := .F.
	                     Exit
	                  EndIf
	               Next
	            Else
	               lAmostra := .F.
	            EndIf */
			   EndIf
            EasySetBuffers("EECFLAGS",cNmRotina,@lAmostra)
         Endif

         lRet := lAmostra

         If lRet .And. EECFlags("CAFE_OPCIONAL")
            If Type("cTipoProc") == "C" .And. cTipoProc <> PC_CF
               lRet := .F.
            EndIf
         EndIf

      Case cNmRotina == "BOLSAS" // RMD - 10/11/05 - Cotações de bolsas

         If ValType(lBolsas) = "U"
            lBolsas := .T.

            If !EECFLAGS("COMMODITY")
                lRet := lBolsas := .F.
                Break
            EndIf

            ChkFile("EX7")
            ChkFile("EY0")

            If Select("EX7") > 0 .And. Select("EY0") > 0

               aCmp := {{"EX7","EX7_FILIAL"},{"EX7","EX7_CODBOL"},{"EX7","EX7_MESANO"},;
                        {"EX7","EX7_DATA"  },{"EX7","EX7_VLMIN "},{"EX7","EX7_VALCOT"},;
                        {"EX7","EX7_VLMAX" },{"EY0","EY0_FILIAL"},{"EY0","EY0_COD"   },;
                        {"EY0","EY0_DESC"  },{"EE7","EE7_CODBOL"},{"EE7","EE7_OPCFIX"},;
                        {"EE7","EE7_CONDFI"}}

               For j:=1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                    lBolsas := .F.
                     Exit
                  EndIf
               Next

            Else
               lBolsas := .F.
            EndIf
         Endif

         lRet := lBolsas

      Case cNmRotina == "NEW_RV" // JPM - 16/11/05 - Novos Tratamentos de R.V.

         If ValType(lNewRv) = "U"
            lNewRv := .T.

            // verifica se existem os MVs
            If !EasyGParam("MV_AVG0103",.t.) .Or.; // Habilita rotina de R.V. 1:1
               !EasyGParam("MV_AVG0113",.t.)       // grupo de usuários de supervisão/gerência que terão acessos diferenciados
               lNewRv := .f.
            Else
               aCmp := {{"EEY","EEY_HIST"},{"EEY","EEY_STATUS"}}

               For j:=1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                     lNewRv := .F.
                     Exit
                  EndIf
               Next
            EndIf

         Endif
         lRet := lNewRv

      Case cNmRotina == "CAFE" //RMD - 16/11/06 - Exportação de Café
         If !EasyGetBuffers("EECFLAGS",cNmRotina,@lCafe)
            lCafe := .T.

            If !EasyGParam("MV_AVG0114",,.F.)
               lRet := lCafe := .F.
               Break
            EndIf

            If !EECFlags("COMMODITY")
               lRet := lCafe := .F.
               Break
            EndIf

            ChkFile("EXZ")
            ChkFile("EY2")

            If Select("EXZ") == 0 .Or. Select("EY2") == 0
               lRet := lCafe := .F.
               Break
            EndIf

            aCmp := {{"EXZ","EXZ_FILIAL"},{"EXZ","EXZ_PREEMB"},{"EXZ","EXZ_OIC"   },;
                     {"EXZ","EXZ_QTDE"  },{"EY2","EY2_FILIAL"},{"EY2","EY2_PREEMB"},;
                     {"EY2","EY2_OIC"   },{"EY2","EY2_SEQEMB"},{"EY2","EY2_QTDE"  },;
                     {"EXL","EXL_WOEMB" },{"EEC","EEC_TIPO"  },{"EXL","EXL_TIPOWO"},;
                     {"EXZ","EXZ_SAFRA" },{"EY2","EY2_SAFRA" }}

            For j:=1 To Len(aCmp)
               If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                  lCafe := .F.
                  Exit
               EndIf
            Next
            EasySetBuffers("EECFLAGS",cNmRotina,@lCafe)
         Endif

         lRet := lCafe

         If lRet .And. EECFlags("CAFE_OPCIONAL")
            If Type("cTipoProc") == "C" .And. cTipoProc <> PC_CF
               lRet := .F.
            EndIf
         EndIf

      Case cNmRotina == "CAFE_OPCIONAL"
         lCafe_Opc := .F.
         If EECFlags("CONSIGNACAO")//Campos EEC_TIPO e EE7_TIPO
            If EasyGParam("MV_AVG0155", .T.) .And. EasyGParam("MV_AVG0155",, .F.)
               lCafe_Opc := .T.
            EndIf
         EndIf
         lRet := lCafe_Opc

      Case cNmRotina == "COMMODITY_OPCIONAL"
         If ValType(lCafe_Opc) == "U"
            lCafe_Opc := .F.
            If EECFlags("CONSIGNACAO")//Campos EEC_TIPO e EE7_TIPO
               If EasyGParam("MV_AVG0159", .T.) .And. EasyGParam("MV_AVG0159",, .F.)
                  lCommo_Opc := .T.
               EndIf
            EndIf
         EndIf
         lRet := lCommo_Opc

      Case cNmRotina == "FATFILIAL" //JPM - 21/12/05 - tratamento para geração de notas fiscais em várias filiais.

         If ValType(lFatFilial) = "U"
            lFatFilial := .T.
            If IsIntFat()
               aAlias := {{"SC5","C"},;
                          {"SC6","C"},;
                          {"SF2","E"},;
                          {"SD2","E"} }

               For i := 1 To Len(aAlias)
                  If !ChkFile(aAlias[i][1]) .Or. At( aAlias[i][1] + aAlias[i][2], cArqTab ) = 0
                     lFatFilial := .f.
                     Exit
                  EndIf
               Next

               If lFatFilial
                  If EE9->(FieldPos("EE9_FIL_NF")) = 0 .Or.;
                     EES->(FieldPos("EES_FIL_NF")) = 0 .Or.;
                     EEM->(FieldPos("EEM_FIL_NF")) = 0
                     lFatFilial := .f.
                  EndIf
               EndIf

            Else
               lFatFilial := .f.
            EndIf
         Endif

         lRet := lFatFilial


      Case cNmRotina == "INTTRA" //ER - 14/08/07 - Integração com o Inttra.

         If ValType(lInttra) = "U"

             lInttra := .T.


             If !EasyGParam("MV_AVG0142",,.F.)
                lRet := lInttra := .F.
                Break
             EndIf

             ChkFile("EYI")
             ChkFile("EYJ")
             ChkFile("EYK")
             ChkFile("EYL")

            If Select("EYI") == 0 .Or. Select("EYJ") == 0 .Or. Select("EYK") == 0 .Or. Select("EYL") == 0
               lRet := lInttra := .F.
               Break
            EndIf
            //NCF - 21/08/2012 - Adicionado vários campos complementares a serem verificados para ativar a integração com o sistema INTTRA
            aCmp := {{"EYI","EYI_FILIAL"},{"EYI","EYI_COD"}   ,{"EYI","EYI_LOJA"}  ,{"EYI","EYI_CODIN"} ,{"EYI","EYI_NOMEIN"},{"EE3","EE3_INTTRA"},;
                     {"EEB","EEB_CONTR"} ,{"EXL","EXL_REFADD"},{"EXL","EXL_DEADLI"},{"EXL","EXL_CBKCOM"},{"EXL","EXL_CBKTCO"},{"EXL","EXL_CSICOM"},{"EXL","EXL_BLCLA1"},;
                     {"EXL","EXL_CBLCL1"},{"EXL","EXL_BLCLA2"},{"EXL","EXL_CBLCL2"},{"EXL","EXL_BLCLA3"},{"EXL","EXL_CBLCL3"},{"EXL","EXL_CSIRIN"},{"EXL","EXL_LOCFRE"},;
                     {"EXL","EXL_BOOK"  },{"EXL","EXL_BKRFIN"},{"EXL","EXL_TPSERV"},{"EXL","EXL_TIPMOV"},{"EXL","EXL_LOCREC"},{"EXL","EXL_LOCENT"},{"EXL","EXL_ETDORI"},;
                     {"EXL","EXL_DTRETI"},{"EXL","EXL_HRRETI"},{"EXL","EXL_TIPOBL"},{"EXL","EXL_QTDBL" },{"EXL","EXL_QTDBLC"},{"EXL","EXL_IMPFRE"},{"EXL","EXL_ENVVAL"},;
                     {"EXL",'EXL_STATUS'},{"EXL",'EXL_TIPCON'},{"EXL","EXL_QTDCON"},;
                     {"EXL","EXL_TIPOWO"},{"EYJ","EYJ_FILIAL"},{"EYJ","EYJ_COD"}   ,{"EYJ","EYJ_CCOMPE"},{"EYJ","EYJ_GRAVID"},{"EYJ","EYJ_IMO"   },;
                     {"EYJ","EYJ_IMDG"}  ,{"EYJ","EYJ_UNDG"}  ,{"EYJ","EYJ_TEMRIS"},{"EYJ","EYJ_EMS"}   ,{"EYJ","EYJ_CTNAME"},{"EYJ","EYJ_CTTEL"} ,{"EX9","EX9_TIPCON"},;
                     {"EX9","EX9_CCOTEM"},{"EX9","EX9_ENVTMP"},{"EX9","EX9_TEMP"}  ,{"EX9","EX9_VENT"}  ,{"EX9","EX9_FORCTR"},{"EX9","EX9_FORLCR"},{"EX9","EX9_ID"    },;
                     {"EX9","EX9_TIPO"}  ,{"EX9","EX9_DTRETI"},{"EX9","EX9_DTPREV"},{"EX9","EX9_DTDEVO"},{"EX9","EX9_CSICOM"},{"EX9","EX9_CSIRIN"},{"EX9","EX9_BLCLA1"},;
                     {"EX9","EX9_CBLCL1"},{"EX9","EX9_BLCLA2"},{"EX9","EX9_CBLCL2"},{"EX9","EX9_BLCLA3"},{"EX9","EX9_CBLCL3"},{"EX9","EX9_INFOSI"},{"EX9","EX9_QTDBL" },;
                     {"EX9","EX9_QTDBLC"},{"EX9","EX9_SEQSI"} ,{"EX9","EX9_SINUM"} ,{"EX9","EX9_TIPOBL"},{"EX9","EX9_BLNUM" },{"EX9","EX9_ID"    },{"EX9","EX9_PRECON"},;
                     {"EX9","EX9_CUBAGE"},{"SY5","Y5_SCAC"}   ,{"SY5","Y5_CODIN"}  ,{"EYK","EYK_FILIAL"},{"EYK","EYK_SCAC"}  ,{"EYK","EYK_DESC"}  ,{"SY9","Y9_UNCODE" },;
                     {"EXJ","EXJ_INTTRA"},{"SYF","YF_ISO"}    ,{"EYM","EYM_ALTTRN"},{"EYM","EYM_NAVIO"} ,{"EYM","EYM_VIAGEM"},{"EYM","EYM_ETD"}   ,{"EYO","EYO_LOCREC"},;
                     {"EYO","EYO_ORIGEM"},{"EYO","EYO_PINTER"},{"EYO","EYO_DEST" } ,{"EYO","EYO_LOCENT"},{"EYO","EYO_ETD"}   ,{"EW3","EW3_FILIAL"},{"EW3","EW3_FASE"  },;
                     {"EW3","EW3_PROC"}  ,{"EW3","EW3_CHAVE"} ,{"EW3","EW3_DATA"}  ,{"EW3","EW3_HORA"  },{"EW3","EW3_DESC"}  ,{"EW3","EW3_RESUMO"},{"EW3","EW3_USER"  },;
                     {"EE9","EE9_DINTCD"},{"EEC","EEC_ETAHR" },{"EEC","EEC_ETB"}   ,{"EEC","EEC_ETBHR"} ,{"EEC","EEC_ETDHR"} ,{"EEC","EEC_DLDRAF"},{"EEC","EEC_DLDRHR"},;
                     {"EEC","EEC_DLCARG"},{"EEC","EEC_DLCAHR"},{"EE6","EE6_ETAHR"} ,{"EE6","EE6_ETB"}   ,{"EE6","EE6_ETBHR"} ,{"EE6","EE6_ETDHR"} ,{"EE6","EE6_DLDRAF"},;
                     {"EE6","EE6_DLDRHR"},{"EE6","EE6_DLCAHR"},{"EX8","EX8_ETAHR"} ,{"EX8","EX8_ETBHR"} , {"EX8","EX8_ETDHR"} ,{"EX8","EX8_DLDRAF"},{"EX8","EX8_DLDRHR"},;
                     {"EX8","EX8_DLCARG"},{"EX8","EX8_DLCAHR"},{"EE5","EE5_CODINT"}/*{"EYL","EYL_FILIAL"},{"EYL","EYL_COD"   },{"EYL","EYL_DESC"  }*/ }

            For j:=1 To Len(aCmp)
               If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                  lInttra := .F.
                  Exit
               EndIf
            Next

         EndIf

         lRet := lInttra

      Case cNmRotina == "ESTUFAGEM"
         If ValType(lEstufagem) <> "L"
            lEstufagem := EasyGParam("MV_AVG0146",, .F.) .And. !EasyGParam("MV_AVG0005",, .F.)

            ChkFile("EYH")

            If Select("EYH") == 0
               lRet := lEstufagem := .F.
               Break
            EndIf

            aCmp := {{"EYH", "EYH_CODCON"},{"EYH", "EYH_CODEMB"},{"EYH", "EYH_COD_I "},{"EYH", "EYH_DESEMB"},;
                     {"EYH", "EYH_EMBSUP"},{"EYH", "EYH_ESTUF "},{"EYH", "EYH_FILIAL"},{"EYH", "EYH_ID"    },;
                     {"EYH", "EYH_IDVINC"},{"EYH", "EYH_LOTE"  },{"EYH", "EYH_PREEMB"},{"EYG", "EYG_ALTCON"},;
                     {"EYH", "EYH_QTDEMB"},{"EYH", "EYH_RELSUP"},{"EYH", "EYH_SALDO "},{"EYH", "EYH_SEQEMB"},;
                     {"EYH", "EYH_UNIDAD"},{"EYH", "EYH_PSLQUN"},{"EYH", "EYH_PSBRUN"},{"EYH", "EYH_PSLQTO"},;
                     {"EYH", "EYH_PSBRTO"},{"EYH", "EYH_PLT"   },{"EYG", "EYG_FILIAL"},{"EYG", "EYG_CODCON"},;
                     {"EYG", "EYG_DESCON"},{"EYG", "EYG_COMCON"},{"EX9", "EX9_ID"}}

            For j:=1 To Len(aCmp)
               If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                  lEstufagem := .F.
                  Exit
               EndIf
            Next

         EndIf
         lRet := lEstufagem

      Case cNmRotina == "PRE-CONTAINER"
         If ValType(lPreContainer) <> "L"
            lPreContainer := .T.

            ChkFile("EX9")
            //Verifica se a tabela e os parâmetros existem
            If Select("EX9") == 0 .Or. !EasyGParam("MV_AVG0156", .T.) .Or. !EasyGParam("MV_AVG0157", .T.) .Or. !EasyGParam("MV_AVG0158", .T.)
               lRet := lPreContainer := .F.
               Break
            EndIf

            //Verifica se a rotina está habilitada
            If !(lPreContainer := EasyGParam("MV_AVG0156",, .F.))
               lRet := .F.
               Break
            EndIf

            aCmp := {{"EX9", "EX9_PRECON"}}

            For j:=1 To Len(aCmp)
               If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                  lRet := lPreContainer := .F.
                  Exit
               EndIf
            Next

         EndIf
         lRet := lPreContainer

      Case cNmRotina == "INTEMB"

         If ValType(lIntEmb) = "U"
            lIntEmb := .T.
            If IsIntFat()

               ///////////////////////////////////////////////////
               //Rotina de criação de embarques sem nota fiscal.//
               ///////////////////////////////////////////////////
               If !EasyGParam("MV_AVG0067",.F.,.F.)
                   lIntEmb := .F.
               EndIf

               /////////////////////////////////////////////////////////////////////
               //Rotina de integração de Despesas entre Embarque e Pedido de Venda//
               /////////////////////////////////////////////////////////////////////
               If !EasyGParam("MV_AVG0141",.F.,.F.)
                   lIntEmb := .F.
               EndIf

               //////////////////////////////////////////////////////////
               //Verifica os campos necessários para habilitar a rotina//
               //////////////////////////////////////////////////////////
               aCmp := {{"EEC","EEC_PEDFAT"},{"EE9","EE9_FATIT"}}

               For j:=1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                     lIntEmb := .F.
                     Exit
                  EndIf
               Next

            Else
               lIntEmb := .f.
            EndIf
         Endif

         lRet := lIntEmb

      Case cNmRotina == "VISUALIZA_PDF"
         If ValType(lVisPdf) == "U"
            If !EasyGParam("MV_AVG0151", .T.) .Or. Empty(EasyGParam("MV_AVG0151",, "")) .Or. SY0->(FieldPos("Y0_ARQPDF")) == 0
               lVisPdf := .F.
            Else
               lVisPdf := .T.
            EndIf
         EndIf

         lRet := lVisPdf

      Case cNmRotina == "COMPRAFOB"

         If ValType(lCprFob) <> "L"
            If (lCprFob := (EECFlags("CAFE") .And. EECFlags("INTERMED") .And. (Type("cFilEx") == "C") .And. (xFilial("EE7") == cFilEx)))
               aCmp := {{"EE8","EE8_DIFCPR"},{"EE8","EE8_PRCCOM"},{"EE7","EE7_SHLOJA"},;
                        {"EE8","EE8_UNPRCC"},{"EE7","EE7_CPRFOB"},{"EE7","EE7_SHIPPE"}}

               For j:=1 To Len(aCmp)
                  If (aCmp[j][1])->(FieldPos(aCmp[j][2])) == 0
                     lCprFob := .F.
                     Exit
                  EndIf
               Next
            EndIf
         EndIf
         lRet := lCprFob
      Case cNmRotina == "CAMBIO_EXT"

         If ValType(lNovoCambio) = "U"
            lNovoCambio := GetMv("MV_AVG0144",,.F.) .AND. !Empty(GetMv("MV_AVG0145",,""))
         EndIf
         lRet := lNovoCambio

      Case cNmRotina == "AMOSTRA_BASE"
         If ValType(lAmBase) <> "L"
            lAmBase := .T.
            If .F.//!EECFlags("AMOSTRA")
               lRet := lAmBase := .F.
            EndIf
            ChkFile("EXU")

            If Select("EXU") == 0
               lRet := lAmBase := .F.
               Break
            EndIf

            aCmp := {{"EEC", "EEC_AMBASE"}, {"EE7", "EE7_AMBASE"}}

            For j:=1 To Len(aCmp)
               If (aCmp[j][1])->(FieldPos(aCmp[j][2])) = 0
                  lAmBase := .F.
                  Exit
               EndIf
            Next

         EndIf
         lRet := lAmBase

      //AOM - 26/04/2010 - Rotina para verificar se o xml de baixa adiantamento está atualizado para efetuar baixa parcial.
      Case cNmRotina == "ADIANTAMENTO_PARCIAL"
         If ValType(lAdParcial) <> "L"
            lAdParcial := .F.
            If IsIntEnable("001")
               cArqXML := MemoRead(EasyGParam("MV_AVG0135",,"\XML") + "\" + "avlink005.xml" )
               If At("ADIANTAMENTO_PARCIAL", cArqXML) > 0
                  lAdParcial := .T.
               EndIf
            Else
               lAdParcial := .T.
            EndIf
         EndIf
         lRet := lAdParcial

	  Case cNmRotina == "WIZARD_RE"
	     If ValType(lWizardRE) <> "L"
		    /*lWizardRE := ChkFile("EXO") .and. EXO->(FieldPos("EXO_COD")) > 0 .and.;
                         EXO->(FieldPos("EXO_DESCR")) > 0 .and.;
                         EXO->(FieldPos("EXO_RE"))    > 0 .and.;
                         EXO->(FieldPos("EXO_ANEXO")) > 0 .and.;
                         EE9->(FieldPos("EE9_CODUE")) > 0 .and.;
                         EE9->(FieldPos("EE9_LOJUE")) > 0 .and. EasyGParam("MV_AVG0123",,.F.)*/
			lWizardRE := AvExisteTab("EXO") .AND. AvExisteCampo({"EXO_COD","EXO_DESCR","EXO_RE","EXO_ANEXO","EE9_CODUE","EE9_LOJUE"})
		 EndIf
		 lRet := lWizardRE

      Case cNmRotina == "NOVOEX"

	  //OAP- 08/02/2011 - Adequação para que o usuário possa gerar o RE do modo antigo
	  If EasyGParam("MV_AVG0201",,"1") == "1" .OR. (Type("lValidN_EX") == "L" .AND. lValidN_EX)
	     If ValType(lNovoEx) <> "L"
		    lNovoEx := EECFlags("WIZARD_RE") .AND. AvExisteTab({"EWI","EWJ","EWK","EWL","EWM","EWN","EWO","EWP","EWQ"}) .AND.;
			           AvExisteCampo({{"EE9","EE9_ID"},{"EE9","EE9_SEQRE"}})
		 EndIf
	  lRet := lNovoEx

 	  Else
 	     lRet := .F.
	  EndIf

	  // ** FSM - 21/07/2012 **
      Case cNmRotina == "TIT_PARCELAS"
           If !(ValType(lTitParcelas) == "L")
              lTitParcelas := EEC->(FieldPos("EEC_TITCAM")) > 0 .And. (EasyGParam("MV_AVG0214",,.F.) .And. IsIntEnable("001") .OR. AvFlags("EEC_LOGIX"))
           EndIf
           lRet := lTitParcelas

      Case cNmRotina == "ALT_EASYLINK"
           If !(ValType(lAltEasyLink) == "L")
              lAltEasyLink :=  EasyGParam("MV_AVG0213",,.F.) .And. IsIntEnable("001")
           EndIf
           /*THTS - 05/09/2019 - NOPADO - Quando utilizado ALT_EASYINK com TIT_PARCELAS desligado, os cenários de quebra e compensação do câmbio estavam gerando novos titulos*/
           //If lAltEasyLink .AND. !EECFlags("TIT_PARCELAS")  // GFP - 01/10/2014
              //SE1->(DbSetOrder(1))
              //If Empty(EEQ->EEQ_FINNUM) .Or. (SE1->(DbSeek(xFilial()+"EEC"+EEQ->EEQ_FINNUM)) .AND. SE1->E1_VALOR # EEQ->EEQ_VL - EEQ->EEQ_CGRAFI)
                 //lRet := .F.
              //Else
                 //lRet := lAltEasyLink
              //EndIf
           //Else
              lRet := lAltEasyLink
           //EndIf
	  // ** FIM -  FSM - 21/07/2012 **
      OtherWise

           If cEmpAnt == '99' .AND. ValType(GetApoInfo("EASYAUTTESTE.PRW")) == "A" .AND. Len(GetApoInfo("EASYAUTTESTE.PRW")) > 0
              UserException("Falha de EECFlags: Parametro '"+cNmRotina+"' não tratado.")
           EndIf
   End Case
   
   IF !cNmRotina $ "COMMODITY,INTERMED,AMOSTRA,CAFE"
      EasySetBuffers("EECFLAGS",cFilAnt+','+cNmRotina,@lRet)
   EndIf

End Sequence
DbSelectArea(cArea)
cFilAnterior := AvGetM0Fil()
RestOrd(aSaveOrd)

Return lRet

/*
Funcao      : F3AgCom().
Parametros  :
Retorno     : .t.
Objetivos   : Montar F3 para Agentes Recebdores de Comissão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/06/2003 - 10:03.
Revisao     :
Obs.        :
*/
*----------------*
Function F3AgCom()
*----------------*
Local cCliente, cCampo, cTitulo, cAlias, cCodAge
Local oSeek, cSeek, oOrdem, cOrd, aOrdem:={}
Local nAliasOld := Select()
Local bReturn, Tb_Campos
Local lRet:=.f., nRecNo
Local oMarkAge, oDlgAge            // By JPP 30/12/04 - 09:00 - Definição de objetos locais utilizados pela função.
Local cCompl := ""

If Type("cMarca") = "U"  // By JPP 30/12/04 - 09:00
   Private cMarca := GetMark()
EndIf

// ** Set das variáveis.
cAlias  := If(Type("M->EE7_PEDIDO")<>"U","EE8","EE9")
cCampo  := cAlias+"_CODAGE"
cCodAge := M->&(cCampo)
bReturn := {||M->&(cCampo):= WorkAg->EEB_CODAGE,oDlgAge:End()}
cTitulo := STR0080 //"Agentes Recebedores de Comissão."

Tb_Campos   := {{"EEB_CODAGE ",,STR0034},;  //"Codigo"
                {"EEB_NOME"   ,,STR0018}} //"Descrição"

If (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0 //JPM - tipo de comissão por item
   bReturn := {||M->&(cCampo):= WorkAg->EEB_CODAGE,M->&(cAlias+"_TIPCOM"):= WorkAg->EEB_TIPCOM,oDlgAge:End()}
   AAdd(Tb_Campos,{ {||BscxBox("EEB_TIPCOM",WorkAg->EEB_TIPCOM) } ,,AllTrim(AvSx3("EEB_TIPCOM",AV_TITULO))})
   cCompl := RTrim(M->&(cAlias+"_TIPCOM"))
EndIf

Private aHeader[0]

//Opcoes de consulta
aAdd(aOrdem,STR0034) //"Codigo"
aAdd(aOrdem,STR0018) //"Descrição"  // GFP - 27/05/2014

Begin Sequence
   WorkAg->(DbSetOrder(1))

   WorkAg->(dbSetFilter({|| SubStr(EEB_TIPOAG,1,1) == CD_AGC },"SubStr(EEB_TIPOAG,1,1) =='"+CD_AGC+"'"))
   WorkAg->(dbGoTop()) //MCF - 24/09/2015

   // ** Posiciona no registro correto...
   If !Empty(cCodAge)
      //WorkAg->(DbSeek(cCodAge+CD_AGC)) - JPM - 02/06/05
      WorkAg->(DbSeek(cCodAge+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+cCompl))
   EndIf

   //by CRF 22/10/2010 - 14:06
   TB_Campos:=AddCpoUser(TB_Campos,"EEB","2")

   DEFINE MSDIALOG oDlgAge TITLE cTitulo FROM 62,15 TO 310,460 OF oMainWnd PIXEL

      cSeek:=Space(Len(WorkAg->EEB_CODAGE))

      oMarkAge:= MsSelect():New("WorkAg",,,TB_Campos,,@cMarca,{10,12,80,186}) // By JPP - 30/11/04 - 09:00 - Inclusão do tipo de marca, para esta MSSELECT não interferir em outra MSSELECT.
      oMarkAge:baval:={|| lRet:=.t.,Eval(bReturn)}

      @ 091, 14 Say STR0022 Size 42,7 OF oDLGAge PIXEL  //"Pesquisar por:"
      @ 090, 59 Combobox oOrdem Var cOrd Items aOrdem Size 119, 42 OF oDlgAge PIXEL OF oDlg PIXEL ON CHANGE AgChgOrd(cOrd,@cSeek)  // GFP - 27/05/2014

      @ 104, 14 Say STR0023 Size 32, 7 OF oDlgAGe PIXEL  //"Localizar"
      @ 104, 58 Msget oSeek Var cSeek Size 120, 10 OF oDlgAge PIXEL

      oSeek:bChange := {|x| AgComSeek(oMarkAge,oSeek,"WorkAg")}

      DEFINE SBUTTON FROM 10,187 TYPE 1  ACTION (Eval(oMarkAge:baval)) ENABLE OF oDlgAge PIXEL
      DEFINE SBUTTON FROM 25,187 TYPE 2  ACTION (oDlgAge:End())        ENABLE OF oDlgAge PIXEL

   ACTIVATE MSDIALOG oDlgAge

   nRecNo := WorkAg->(RecNo())
   WorkAg->(dbClearFilter())
   WorkAg->(DbGoTo(RecNo()))

End Sequence

Select(nAliasOld)

Return lRet

/*
Funcao      : AgComSeek(oMark,oSeek).
Parametros  : oMark := Objeto p/ refresh do browse.
              oSeek := Objeto p/ executar oGet:Buffer.
Retorno     : .t.
Objetivos   : Efetuar pesquisa no momento da digitação.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/06/2003 - 11:27.
Revisao     :
Obs.        :
*/
*-------------------------------------------*
Static Function AgComSeek(oMark,oSeek,cAlias)
*-------------------------------------------*
Local lRet:=.t.

(cAlias)->(DbSeek(RTrim(oSeek:oGet:Buffer)))
oMark:oBrowse:Refresh()

Return lRet

/*
Funcao      : EECValidAg().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Validar Agente Recebedor de Comissão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/06/2003 - 13:39.
Revisao     :
Obs.        :
*/

*--------------------------*
Function EECValidAg(lCodAg)
*--------------------------*
Local lRet:=.t., cCodAg
Local cAlias := If(Type("M->EE7_PEDIDO") <> "U","EE8","EE9")
Local lTipComChave := (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0
Local cTipCom
Default lCodAg := .t.
Begin Sequence

   cCodAg := AvKey(M->&(cAlias+"_CODAGE"),"EEB_CODAGE")
   If lCodAg //define se é a validação do campo EE8/EE9_CODAGE
      If !Empty(cCodAg)
         WorkAg->(DbSetOrder(1))
         If !WorkAg->(DbSeek(cCodAg+CD_AGC))
            Help("",1,"REGNOIS")
            lRet:=.f.
            Break
         EndIf
         //JPM - 30/05/05 - preencher o campo "tipo de comissão" no item.
         If lTipComChave
            If !Empty(M->&(cAlias+"_TIPCOM")) .And. !WorkAg->(DbSeek(cCodAg+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+M->&(cAlias+"_TIPCOM")))
               WorkAg->(DbSeek(cCodAg+CD_AGC))
               M->&(cAlias+"_TIPCOM") := WorkAg->EEB_TIPCOM
            ElseIf Empty(M->&(cAlias+"_TIPCOM"))
               M->&(cAlias+"_TIPCOM") := WorkAg->EEB_TIPCOM
            EndIf
         EndIf
      ElseIf lTipComChave //JPM - limpar o campo de tipo de comissão quando o agente estiver vazio.
         M->&(cAlias+"_TIPCOM") := CriaVar(cAlias+"_TIPCOM")
      EndIf
   Else //validação do campo EE8/EE9_TIPCOM
      WorkAg->(DbSetOrder(1))
      cTipCom := AvKey(M->&(cAlias+"_TIPCOM"),"EEB_TIPCOM")
      If !Empty(cCodAg) .And. !WorkAg->(DbSeek(cCodAg+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+cTipCom))
         Help("",1,"REGNOIS")
         lRet:=.f.
         Break
      EndIf
   EndIf

End Sequence

Return lRet


/*
Funcao      : EECDscAg().
Parametros  : Nenhum.
Retorno     : cRet : Descrição do agente recebedor de comissão.
Objetivos   : Buscar descrição do agente de acordo com a WorkAg.
Autor       : Jeferson Barros Jr.
Data/Hora   : 06/06/2003 - 14:43.
Revisao     :
Obs.        :
*/
*-----------------*
Function EECDscAg()
*-----------------*
Local cRet:="", cAlias, cCodAge, cAliasWork

Begin Sequence

   cAlias  := If(Type("lIsPed")="L","EE8","EE9")
   cAliasWork := IF(cAlias = "EE8","WorkIt","WorkIP")

   //RMD - 06/02/17 - Trecho redundante (a carga já é chamada na função EECAP102)
   /*
   IF Select("WorkAg") == 0  .Or. IsVazio("WorkAg") //LRS - 22/07/2015 - Caso a WorkAp não esta carregada.
      AP102CriaWork()
   EndIF
   */

   If Type(cAliasWork+"->"+cAlias+"_CODAGE") <> "U"
      cCodAge := (cAliasWork)->&(cAlias+"_CODAGE")
      If !Empty(cCodAge)
         //If WorkAg->(DbSeek(AvKey(cCodAge,"EEB_CODAGE")+CD_AGC)) - JPM - 02/06/05
         If WorkAg->(DbSeek(AvKey(cCodAge,"EEB_CODAGE")+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")))
            //If((cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0,(cAliasWork)->&(cAlias+"_TIPCOM"),M->EEB_TIPCOM))) - ASK 12/06/07
            cRet := WorkAg->EEB_NOME
         EndIf
      EndIf
   EndIf

End Sequence

Return cRet

/*
Funcao      : EECResCom().
Parametros  : Nenhum.
Retorno     : cRet : Resumo da(s) comissão(ões) do processo.
Objetivos   : Analisar as comissões lançadas e montar descrisao com o resumo das informações.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/2003 - 14:30.
Revisao     :
Obs.        : aAgente por Dimensao: aAgente[1][1] - Nome do agente.
                                           [1][2] - Valor da comissao.
*/
*------------------*
Function EECResCom()
*------------------*
Local cRet:="", aAgente:={}//, cAux:=""
Local nTotCom:=0, cAlias:="", nFob, y:=0, i
Local cOcorrencia, cProcesso
Local aOrd:=SaveOrd("EEB")
Local lComItens := .F.
Private cAux := ""

Begin Sequence

   If Type("cOcorre") <> "C"
      cAlias := If(Type("M->EE7_PEDIDO")<>"U","EE7","EEC")
      cOcorrencia := If(cAlias=="EE7",OC_PE,OC_EM)
   Else
      cOcorrencia := cOcorre
      cAlias := If(cOcorre == OC_PE,"EE7","EEC")
   EndIf

   nFob := EECFob(cOcorrencia)

   If Select("WorkAg") > 0 .AND. !IsInCallStack("CriaVar")  // RMD - 18/09/2014

	   //RMD - 09/09/14 - Verifica se a comissão é por item ou sobre o total do processo.
	   cProcesso := AvKey(&(If(Type("M->"+cAlias+"_FILIAL") == "C", "M", cAlias)+"->"+cAlias+"_"+If(cOcorrencia == OC_PE,"PEDIDO","PREEMB")),"EEB_PEDIDO")

	   EEB->(DbSetOrder(1))
	   EEB->(DbSeek(xFilial("EEB")+cProcesso+cOcorrencia))
	   Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == xFilial("EEB") .And.;
	                                EEB->EEB_PEDIDO == cProcesso .And.;
	                                EEB->EEB_OCORRE == cOcorrencia
	      If EEB->EEB_TIPCOM == "3"/*Deduzir da fatura*/ .And. Left(EEB->EEB_TIPOAG,1) == CD_AGC//Ag. Rec. Comi.
	         lComItens := .T.
	      EndIf

	      EEB->(DbSkip())
	   EndDo
   EndIf

   //RMD - 09/09/14 - Se a comissão for por item, o retorno da função EECFob contém o FOB + Desconto, então considera o parâmetro MV_AVG0086
   If lComItens
      If EasyGParam("MV_AVG0086",,.f.)
         If Type("M->"+cAlias+"_DESCON") <> "U"
            nFob := nFob - M->&(cAlias+"_DESCON")
         Else
            nFob := nFob - (cAlias)->&(cAlias+"_DESCON")
         EndIf
      EndIf
   Else
      /*
      RMD - 09/09/14 - Se a comissão for sobre o total, considera o campo XXX_TOTPED, que já contém o valor calculado.
      */
      nFob := &(If(Type("M->"+cAlias+"_FILIAL") == "C", "M", cAlias)+"->"+cAlias+"_TOTPED") + If(EasyGParam("MV_AVG0139",,.F.),0,&(If(Type("M->"+cAlias+"_FILIAL") == "C", "M", cAlias)+"->"+cAlias+"_DESCON"))

      aDespesas := X3DIReturn(cOcorrencia)  // RMD - 18/09/2014
      For i := 1 to Len(aDespesas)
         If Type(If(Type("M->"+cAlias+"_FILIAL") == "C", "M", cAlias)+"->"+aDespesas[i][2]) <> "U"
            nFob -= &(If(Type("M->"+cAlias+"_FILIAL") == "C", "M", cAlias)+"->"+aDespesas[i][2])
         EndIf
      Next

   EndIf

   If Select("WorkAg") > 0 .AND. !IsInCallStack("CriaVar") //LRS 15:00
      WorkAg->(DbGoTop())
      Do While WorkAg->(!Eof())
         If Left(WorkAg->EEB_TIPOAG,1) == CD_AGC
            aAdd(aAgente,{WorkAg->EEB_NOME,WorkAg->EEB_TOTCOM, If(WorkAg->EEB_TIPCVL == "1", WorkAg->EEB_VALCOM, 0)})  // RMD - 18/09/2014
         EndIf

         WorkAg->(DbSkip())
      EndDo
   Else
      cOcorrencia := If(cAlias=="EE7",OC_PE,OC_EM)
      cProcesso   := AvKey(If(cAlias=="EE7",MemField("PEDIDO","EE7"),MemField("PREEMB","EEC")),"EEB_PEDIDO")

      EEB->(DbSetOrder(1))
      EEB->(DbSeek(xFilial("EEB")+cProcesso+cOcorrencia))

      Do While EEB->(!Eof()) .And. EEB->EEB_FILIAL == xFilial("EEB") .And.;
                                   EEB->EEB_PEDIDO == cProcesso .And.;
                                   EEB->EEB_OCORRE == cOcorrencia

         If Left(EEB->EEB_TIPOAG,1) == CD_AGC
            aAdd(aAgente,{EEB->EEB_NOME,EEB->EEB_TOTCOM, If(EEB->EEB_TIPCVL == "1", EEB->EEB_VALCOM, 0)})  // RMD - 18/09/2014
         EndIf

         EEB->(DbSkip())
      EndDo
   EndIf

   If Len(aAgente) > 0
      If Len(aAgente) = 1
         If aAgente[1][3] > 0  // RMD - 18/09/2014
		    //RMD - 17/09/14 - Se houver somente um agente e for do tipo percentual, utiliza o percentual digitado
            nPerc := aAgente[1][3]
         Else
            nPerc := Round((aAgente[1][2]/nFob)*100,2)
         EndIf

         cAux  := AllTrim(aAgente[1][1])+" - "+;
                  STR0081+M->&(cAlias+"_MOEDA")+Space(1)+AllTrim(Transf(aAgente[1][2],AvSx3("EEB_TOTCOM",AV_PICTURE)))+" = "+; //"Total: "
                  AllTrim(Transf(nPerc,AvSx3("EE8_PERCOM",AV_PICTURE)))+" % FOB."
      Else
         nPerc := 0
         nTotCom := 0
         For y:=1 To Len(aAgente)
            If aAgente[y][3] > 0
               nPerc += aAgente[y][3]
            Else
               nPerc += Round((aAgente[y][2]/nFob)*100,2)
            EndIf
            //MFR 19/07/2019 OSSME-3536
            nTotCom := nTotCom + aAgente[y][2]
         Next

         //nPerc := Round((nTotCom/nFob)*100,2)
         //nTotCom := Round(nFob*(nPerc/100),2)

         cAux := AllTrim(Str(Len(aAgente)))+STR0082+M->&(cAlias+"_MOEDA")+Space(1)+; //" Agentes - Total: "
                 AllTrim(Transf(nTotCom,AvSx3("EEB_TOTCOM",AV_PICTURE)))+ " = "+;
                 AllTrim(Transf(nPerc,AvSx3("EE8_PERCOM",AV_PICTURE)))+" % FOB."
      EndIf

      //ER - 29/03/2007
      If EasyEntryPoint("EECAP101")
         ExecBlock("EECAP101",.F.,.F.,{"RESCOM",aAgente})
      EndIf

      cRet := cAux
   EndIf

End Sequence

RestOrd(aOrd)

If Select("WorkAg") > 0
   WorkAg->(DbGoTop())
EndIf

Return cRet

/*
Funcao      : EECTotCom().
Parametros  : cOcorrencia = Pedido/Embarque.
              lDif        = Define se a diferença entre os totais de agentes e dos itens será calculada.
              lCalc : .T. = Calcula os totais por agente, independente do parametro MV_AVG0059.
                      .F. = Não calcula os totais por agente. (Default)
Retorno     : .t.
Objetivos   : Calcular o total da comissão para os agentes.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/2003 - 13:10.
Revisao     :
Obs.        :
*/
*----------------------------------*
Function EECTotCom(cOcorrencia, lDif, lCalc)
*----------------------------------*
Local nRet:=.t.
Local cAlias, cAliasIt
Local nVlFob:=0, nVlTotCom:=0, nTotCom := 0, nTotCom1_2 := 0 //(Total Percentual e Valor Fixo)
Local nPerCom, nFob := EECFob(cOcorrencia), lTemPercent := .f., nVlCom, nTotComIt, nTotCom3//total perc. p/ item
Local nTotCif := 0
Local nVlCom := 0
Local nRec
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.) //JPM - 06/04/05
//Local cFobItem, cAliasCapa //JPM - 06/04/05
Local cAliasCapa
Local lTipComChave
Local cAlias, cAliasIt, cAliasCapa
Local lTIPCVL := .F. //LRS - 
Local aOrd
Local oRatComis
Private cFobItem

Private nTotComAux := 0, nVlFobAux := 0, nVlTotComAux := 0//Variáveis utilizadas em ponto de entrada

Private lTotRodape := EEC->(FieldPos("EEC_TOTFOB")) # 0  .AND. EEC->(FieldPos("EEC_TOTLIQ")) # 0   // GFP - 11/04/2014

Default cOcorrencia := OC_PE
Default lDif := .t. //Define se a diferença entre os totais de agentes e dos itens será calculada.
Default lCalc := .F.

Begin Sequence
  
   /*
   AMS - 10/11/2005. Imposta condição para não calcular os valores de comissão por agente.
                     O objetivo dessa alteração é permitir calcular ou não a comissão por agente a cada seleção de item.
   */
   If !lCalc
      If !EasyGParam("MV_AVG0059",, .T.)
         Return(.T.)
      EndIf
   EndIf

   cOcorrencia := Upper(cOcorrencia)

   If cOcorrencia = OC_PE
      cAlias     := "EE8"
      cAliasIt   := "WorkIt"
      cAliasCapa := "EE7"
   Else
      cAlias   := "EE9"
      cAliasIt := "WorkIp"
      cAliasCapa := "EEC"
      nTotCif := nFob + M->EEC_SEGPRE + M->EEC_FRPREV + AvGetCpo("M->EEC_DESP1") + AvGetCpo("M->EEC_DESP2") + M->EEC_DESPIN + M->EEC_FRPCOM - M->EEC_DESCON 

   EndIf

   aOrd := SaveOrd({"WorkAg", cAliasIt})

   lTipComChave := ( (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0 )

   If lFobDescontado
      nFob := nFob - M->&(cAliasCapa+"_DESCON")
      cFobItem := cAliasIt+"->"+cAlias+"_PRCINC - "+cAliasIt+"->"+cAlias+"_VLDESC"
   Else
      cFobItem := cAliasIt+"->"+cAlias+"_PRCINC"
   EndIf

   //ER - 29/03/2007
   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,{"COMIS_TOT",cAlias,cAliasIt})
   EndIf

   nRec := (cAliasIt)->(RecNo())

   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof()) 

      //JPM - 01/02/05 - verifica se é agente recebedor de comissão
      If Left(WorkAg->EEB_TIPOAG,1) <> CD_AGC
         WorkAg->(DbSkip())
         Loop
      EndIf

      // ** Não calcula o total da comissão para tipo "Valor Fixo".
      If WorkAg->EEB_TIPCVL = "2"
         WorkAg->EEB_TOTCOM := WorkAg->EEB_VALCOM
         If AvFlags("COMISSAO_VARIOS_AGENTES")
            nTotCom1_2 += WorkAg->EEB_TOTCOM
         EndIf
         WorkAg->(DbSkip())
         Loop
      EndIf

      If WorkAg->EEB_TIPCVL = "1" /*Percentual*/ .And. AvFlags("COMISSAO_VARIOS_AGENTES")
         lTemPercent := .t.
         WorkAg->EEB_TOTCOM := Round((WorkAg->EEB_VALCOM / 100) * nFob,2)
         nTotCom1_2 += WorkAg->EEB_TOTCOM
         WorkAg->(DbSkip())
         Loop
      EndIf

      (cAliasIt)->(DbGoTop())
      Do While (cAliasIt)->(!Eof())

         If AvFlags("COMISSAO_VARIOS_AGENTES") .And. WorkAg->EEB_TIPCVL <> "3"
            (cAliasIt)->(DbSkip())
            Exit
         EndIf

         lTIPCVL := .T. //LRS - 18/09/18 - Variavel que diz que o tipo da comissao e diferente de comissao por item
         // ** Verifica se o item esta marcado para embarque.
         If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
            WorkIp->(DbSkip())
            Loop
         EndIf

         /*If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE
            If WorkAg->EEB_TIPCVL = "1" // Percentual
               nTotCom += Round((cAliasIt)->&(cAlias+"_PRCINC")*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)
            Else // Percentual por item
               nVlFob    += (cAliasIt)->&(cAlias+"_PRCINC")
               nVlTotCom += Round((cAliasIt)->&(cAlias+"_PRCINC")*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)
            EndIf
         EndIf */

         //If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE - JPM - 02/06/05
         If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE .And.;
            If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") == WorkAg->EEB_TIPCOM,.t.)

            If WorkAg->EEB_TIPCVL = "1" // Percentual
               /*
               AMS - 22/08/2005. Retirado o arredondamento(round) do valor de comissão por item, na totalização para evitar
                                 um total deflacionado.
               nTotCom += Round(&(cFobItem)*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)
               */
                //MFR 18/07/2019
               nTotCom += round(&(cFobItem)*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)

            Else // Percentual por item

               nVlFob    += &(cFobItem)
               /*
               AMS - 22/08/2005. Retirado o arredondamento(round) do valor de comissão por item, na totalização para evitar
                                 um total deflacionado.
               nVlTotCom += Round(&(cFobItem)*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)
               */
               //MFR 18/07/2019
               nVlTotCom += round(&(cFobItem)*((cAliasIt)->&(cAlias+"_PERCOM")/100),AVSX3(cAlias+"_VLCOM",AV_DECIMAL))
            EndIf
         EndIf
         If EasyEntryPoint("EECAP101")
            nTotComAux := nVlFobAux := nVlTotComAux := 0
            ExecBlock("EECAP101", .F., .F., {"PE_COMIS_IT", (cAliasIt)->&(cAlias+"_CODAGE")})
            nTotCom   += nTotComAux
            nVlFob    += nVlFobAux
            nVlTotCom += nVlTotComAux
         EndIf
         (cAliasIt)->(DbSkip())
      EndDo
      (cAliasIt)->(DbGoTop())

      // ** Grava o total na work de agentes.
      If WorkAg->EEB_TIPCVL = "1" // Percentual.
         If !AvFlags("COMISSAO_VARIOS_AGENTES")
            WorkAg->EEB_TOTCOM := Round(nTotCom, 2)
         EndIf
      Else // Percentual por item.
         /*
         AMS - 22/08/2005.
         WorkAg->EEB_VALCOM := Round((Round(nVlTotCom/nVlFob,4)*100),2)
         */
//       WorkAg->EEB_VALCOM := Round(nVlTotCom/nVlFob, 2)
         WorkAg->EEB_TOTCOM := Round(nVlTotCom, AVSX3("EEB_TOTCOM",AV_DECIMAL)) //LRS - 16/10/2018

         If AvFlags("COMISSAO_VARIOS_AGENTES")
            nTotCom1_2 += nVlTotCom
         EndIf

      EndIf

      nTotCom   := 0
      nVlFob    := 0
      nVlTotCom := 0

      WorkAg->(DbSkip())
   EndDo

//   If AvFlags("COMISSAO_VARIOS_AGENTES")
//      nTotCom1_2 += nVlTotCom
//   EndIf

   If AvFlags("COMISSAO_VARIOS_AGENTES") .And. nTotCom1_2 > 0 //Atualiza os percentuais de comissão dos itens
      /*
      AMS - 22/08/2005. Retirado o arredondamento do percentual de comissão para não obter um resultado deflacionado.
      nPerCom := Round((nTotCom1_2 / nFob) * 100,2)
      */
      IF EasyGParam("MV_AVG0085",,.f.) //LRS - 24/04/2018
         nPerCom := (nTotCom1_2/(nFob+M->&(cAliasCapa+"_DESCON")))*100
      Else
         nPerCom :=nTotCom1_2/nFob*100
      EndIF
      nPercom := round(nPercom,Avsx3(cAlias+"_PERCOM",AV_DECIMAL))

      nTotComIt := 0
      oRatComis := EasyRateio():New(nTotCom1_2, nFob, EasyRecCount(cAliasIt), AVSX3(cAlias+"_VLCOM",AV_DECIMAL))
      (cAliasIt)->(DbGoTop())
      While (cAliasIt)->(!EoF())

         //MFR OSSME-2928 07/05/2019
         If cAliasIt == "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
            WorkIp->(DbSkip())
            Loop
         EndIf

//         (cAliasIt)->&(cAlias+"_PERCOM") := Round(nPerCom, 2)
         IF !lTIPCVL .Or. Empty((cAliasIt)->&(cAlias+"_CODAGE")) 
            (cAliasIt)->&(cAlias+"_PERCOM") := IF(lTIPCVL,0,IF(nPerCom>100,100,nPerCom))// MFR 02/02/2021 já foi arredondado na inha 6080
         EndIF
         
         //nVlCom := Round((nPerCom / 100) * (cAliasIt)->&(cAlias+"_PRCINC"),2)

         /*
         AMS - 22/08/2005. Retirado o arredondamento do valor da comissão para não obter um resultado deflacionado.
         nVlCom := Round((nPerCom / 100) * &(cFobItem),2)
         */
         //nVlCom := (nPerCom/100)*&(cFobItem) 
         nVlCom := oRatComis:GetItemRateio(&(cFobItem))                                 
         nTotComIt += nVlCom
         
         /*
         AMS - 22/08/2005.
         (cAliasIt)->&(cAlias+"_VLCOM")  := nVlCom
         */
         IF !lTIPCVL .Or. Empty((cAliasIt)->&(cAlias+"_CODAGE")) 
            (cAliasIt)->&(cAlias+"_VLCOM")  := IF(lTIPCVL,0,nVlCom)            
         EndIF
         IF(EXISTBLOCK("EECAP101"),EXECBLOCK("EECAP101",.F.,.F.,"TROCA_PERCOM_VLCOM"),) //LRS - 19/04/2018
         (cAliasIt)->(DbSkip())
         
      EndDo
      (cAliasIt)->(DbGoTop())

      If nTotComIt <> nTotCom1_2 .And. (lDif .Or. lTemPercent) .AND. !lTIPCVL
                                //se houver diferenca, então acrescenta a diferenca no EEB_TOTCOM de 1 agente
                                //de "Percentual"(se não houver, acrescenta em um ag. de "Valor Fixo").
         WorkAg->(DbGoTop())
         While WorkAg->(!EoF())
            If Left(WorkAg->EEB_TIPOAG,1) = CD_AGC
               If WorkAg->EEB_TIPCVL = "1" .Or. (!lTemPercent .And. WorkAg->EEB_TIPCVL = "2")
                  WorkAg->EEB_TOTCOM := Round(WorkAg->EEB_TOTCOM+(nTotComIt-nTotCom1_2), 2)
                  If WorkAg->EEB_TIPCVL = "2"
                     WorkAg->EEB_VALCOM := WorkAg->EEB_TOTCOM
                  EndIf
                  If WorkAg->EEB_TOTCOM <= 0
                     EECMsg(STR0122 + AllTrim(WorkAg->EEB_CODAGE) + STR0123,STR0049)
                     /*"O total da comissão do agente '###' ficou com o valor zerado, decorrente de acertos
                        executados pela manutenção. O sistema irá prosseguir normalmente, porém, se desejar,
                        aumente o valor da comissão ou altere o tipo para 'Percentual por Item' onde a
                        porcentagem deverá ser informada para cada item.","Aviso"*/
                  EndIf
                  Exit
               EndIf
            EndIf
            WorkAg->(DbSkip())
         EndDo
      EndIf
   EndIf

End Sequence

// Atualiza o campo resumo da comissao na capa do processo.
If cAlias ="EE8"
   M->EE7_DSCCOM := EECResCom()
   M->EE7_VALCOM := 0 // GFP - 11/04/2014
   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())
      M->EE7_VALCOM += WorkAg->EEB_TOTCOM
      WorkAg->(DbSkip())
   EndDo
   If lTotRodape
      M->EE7_TOTLIQ := M->EE7_VLFOB - AE102CalcAg()// - M->EE7_VALCOM  // GFP - 28/10/2014
   EndIf
Else
   M->EEC_DSCCOM := EECResCom()
   M->EEC_VALCOM := 0 // GFP - 11/04/2014
   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())
      M->EEC_VALCOM += WorkAg->EEB_TOTCOM
      WorkAg->(DbSkip())
   EndDo
   If lTotRodape
      If WorkIp->(EasyRecCount("WorkIp")) # 0  // GFP - 28/10/2014
         nVlCom := AE102CalcAg()
         M->EEC_TOTLIQ :=  M->EEC_TOTFOB - nVlCom// - M->EE7_VALCOM
         M->EEC_TOTPED := nTotCif - nVlCom
      EndIf
   EndIf
EndIf

RestOrd(aOrd, .T.)

Return nRet

/*
Funcao      : EECTrataIt(lGrvProc,cOcorrencia)
Parametros  : lGrvProc := .t. - Chamada a partir da gravação do processo.
                          .f. - Chamada a partir da tela de agentes.
              cOcorrencia = Pedido/Embarque.
Retorno     : .t./.f.
Objetivos   : Verificar e tratar os itens sem agente.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/03 08:09.
Revisao     : JPM - 31/01/05 - Tratamentos de comissão com mais de um agente para o mesmo item
Obs.        :
*/
*---------------------------------------*
Function EECTrataIt(lGrvProc,cOcorrencia)
*---------------------------------------*
Local lRet:=.t., lItemSemAg := .f., lGravaAgentes := .f.
Local cCodAg:="", cTipCom := ""
Local nRec
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)
//Local cFobItem

Private cFobItem := ""
Private nVlCom := 0
Private lMsgAgente:= .T.

Default lGrvProc := .t.
Default cOcorrencia := OC_PE

If Type("lSched") <> "L" 
   lSched:= .F.
EndIf

Begin Sequence

   cOcorrencia := Upper(cOcorrencia)

   If cOcorrencia = OC_PE
      cAlias   := "EE8"
      cAliasIt := "WorkIt"
   Else
      cAlias   := "EE9"
      cAliasIt := "WorkIp"
   EndIf

   If lFobDescontado
      cFobItem := cAliasIt+"->"+cAlias+"_PRCINC - "+cAliasIt+"->"+cAlias+"_VLDESC"
   Else
      cFobItem := cAliasIt+"->"+cAlias+"_PRCINC"
   EndIf

   //ER - 29/03/2007
   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,{"COMIS_IT",cAlias,cAliasIt})
   EndIf

   nRec := (cAliasIt)->(RecNo())

   // ** Só efetua a verificação para agentes recebedores de comissão.
   If Left(WorkAg->EEB_TIPOAG,1) <> CD_AGC
      Break
   EndIf

   //Flag para que não seja exibida a mensagem do agente
   If !lMsgAgente
      lRet:=.f.
      If !AvFlags("COMISSAO_VARIOS_AGENTES")
         Break
      EndIf
   EndIf

   // ** Verifica se existe algum item sem agente.
   (cAliasIt)->(DbGoTop())
   Do While (cAliasIt)->(!Eof())

      // ** Verifica se o item esta marcado para embarque.
      If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
         WorkIp->(DbSkip())
         Loop
      EndIf

      // ** Verifica se o item está agenciado.
      If Empty((cAliasIt)->&(cAlias+"_CODAGE")) .And. !lGravaAgentes .And. If(AvFlags("COMISSAO_VARIOS_AGENTES"),WorkAg->EEB_TIPCVL = "3",.t.)//Perc. p/ Item
         If ((type("lEEBAuto") == "L" .and. !lEEBAuto) .or. (type("lEE7Auto") == "L" .and. !lEE7Auto)) .And. !EECMsg(STR0083,STR0027, "MsgYesNo") //"Existe(m) item(ns) sem agente de comissão. Deseja vinculá-lo(s) a um agente?"###"Atenção"
            lRet:=.f.
            If !AvFlags("COMISSAO_VARIOS_AGENTES")
               Break
            EndIf
         EndIf
         lGravaAgentes := .t.

         // ** Na chamada a partir da gravacao do processo posiciona no agente correto.
         If lGrvProc .And. lRet
            If lSched .Or. !Ap101GetAg() // ** Funcao para get do agente desejado.
               lRet := .t.
               If !AvFlags("COMISSAO_VARIOS_AGENTES")
                  Break
               EndIf
            EndIf
         EndIf

         cCodAg  := If(lGrvProc, WorkAg->EEB_CODAGE,M->EEB_CODAGE)
         cTipCom := If(lGrvProc, WorkAg->EEB_TIPCOM,M->EEB_TIPCOM) //JPM - 31/05/05

         // ** Define o valor da comissão.
         If WorkAg->EEB_TIPCVL <> "3" // Percentual por item
            If lGrvProc
               nVlCom := WorkAg->EEB_VALCOM
            Else
               nVlCom := M->EEB_VALCOM
            EndIf
         ElseIf lRet .And. If(lGrvProc,AvFlags("COMISSAO_VARIOS_AGENTES"),.t.)
            If lSched .Or. !Ap101GetCom()
               lRet:= .f.
               If !AvFlags("COMISSAO_VARIOS_AGENTES")
                  Break
               EndIf
            EndIf
         EndIf

      EndIf

      If AvFlags("COMISSAO_VARIOS_AGENTES")
         If Empty((cAliasIt)->&(cAlias+"_CODAGE"))
            If lGravaAgentes .And. lRet
               (cAliasIt)->&(cAlias+"_CODAGE") := cCodAg
               (cAliasIt)->&(cAlias+"_DSCAGE") := EECDscAg()
               If (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0 //JPM - 02/06/05
                  (cAliasIt)->&(cAlias+"_TIPCOM") := cTipCom
               EndIf

               (cAliasIt)->&(cAlias+"_PERCOM") := nVlCom
               //(cAliasIt)->&(cAlias+"_VLCOM")  := Round((cAliasIt)->&(cAlias+"_PRCINC")*(nVlCom/100),2)//JPM - 07/04/05
               (cAliasIt)->&(cAlias+"_VLCOM")  := Round(&(cFobItem)*(nVlCom/100),AVSX3(cAlias+"_VLCOM",AV_DECIMAL))   
            EndIf

         ElseIf WorkAg->EEB_TIPCVL <> "3"
            (cAliasIt)->&(cAlias+"_CODAGE") := ""// só serão vinculados aos itens agentes que sejam de "Perc. p/ Item"
            If (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0 //JPM - 02/06/05
               (cAliasIt)->&(cAlias+"_TIPCOM") := cTipCom
            EndIf
            (cAliasIt)->&(cAlias+"_PERCOM") := 0 // Calculado apenas no final da gravacao do processo.
            (cAliasIt)->&(cAlias+"_VLCOM")  := 0
         EndIf

      Else
         If Empty((cAliasIt)->&(cAlias+"_CODAGE")) .And. lGravaAgentes
            (cAliasIt)->&(cAlias+"_CODAGE") := cCodAg
            (cAliasIt)->&(cAlias+"_DSCAGE") := EECDscAg()

            If (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0 //JPM - 02/06/05
               (cAliasIt)->&(cAlias+"_TIPCOM") := cTipCom
            EndIf

            If WorkAg->EEB_TIPCVL $ "1/3" // Percentual/Percentual por item.
               (cAliasIt)->&(cAlias+"_PERCOM") := nVlCom
               //(cAliasIt)->&(cAlias+"_VLCOM")  := Round((cAliasIt)->&(cAlias+"_PRCINC")*(nVlCom/100),2)//JPM - 07/04/05
               (cAliasIt)->&(cAlias+"_VLCOM")  := Round(&(cFobItem)*(nVlCom/100),AVSX3(cAlias+"_VLCOM",AV_DECIMAL))
            Else // Valor Fixo
               (cAliasIt)->&(cAlias+"_PERCOM") := 0 // Calculado apenas no final da gravacao do processo.
               (cAliasIt)->&(cAlias+"_VLCOM")  := nVlCom
            EndIf
         EndIf
      Endif

      (cAliasIt)->(DbSkip())
   EndDo

End Sequence

(cAliasIt)->(DbGoTo(nRec))

Return lRet

/*
Funcao      : Ap101GetCom()
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Get do percentual de comissão para o tipo percentual por item.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/03 10:25.
Revisao     :
Obs.        :
*/
*--------------------*
Function Ap101GetCom()
*--------------------*
Local lRet:=.f., oDlg
Local bCancel:={|| oDlg:End()}
Local bOk := {|| If(nVlCom > 0,(oDlg:End(),lRet:=.t.),EasyHelp(STR0084,STR0027))} //"Informe o valor da comissão."###"Atenção"
Private lOk := .F.

Begin Sequence

   Define MsDialog oDlg Title STR0085 From 10,12 TO 25,49 OF oMainWnd //"Comissão " //LRS - 19/01/2015

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 03/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 1.1, 0.5 TO 4.8,18 Label STR0086 Of oPanel //"Informe a comissão"

      @ 32,10 Say STR0087 Size 50,10 Of oPanel Pixel //"Percentual"
      @ 32,65 MsGet nVlCom Picture "99.99" Size 60,10 Valid Positivo(nVlCom) of oPanel Pixel

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

//** AAF - 06/01/2014
lOk:= lRet
If EasyEntryPoint("EECAP101")
   ExecBlock("EECAP101",.F.,.F.,"FIM_TELA_GET_COM_ITEM")
Endif
//**

Return lRet

/*
Funcao      : EECInitCmpAg()
Parametros  : cOcorrencia
Retorno     : .t.
Objetivos   : Inicializar os campos referente a agente na tela de edição de itens para a opção de inclusão.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/03 11:49.
Revisao     :
Obs.        :
*/
*--------------------------------*
Function EECInitCmpAg(cOcorrencia)
*--------------------------------*
Local lRet:=.t.

Default cOcorrencia := OC_PE

Begin Sequence

   cOcorrencia = Upper(cOcorrencia)

   cAlias := If(cOcorrencia = OC_PE, "EE8","EE9")

   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())
      If Left(WorkAg->EEB_TIPOAG,1) = CD_AGC
         M->&(cAlias+"_CODAGE"):= WorkAg->EEB_CODAGE
         If (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0 //JPM - 02/06/05
            M->&(cAlias+"_TIPCOM") := WorkAg->EEB_TIPCOM
         EndIf

         If WorkAg->EEB_TIPCVL $ "1/3" // Percentual./Percentual por item.
            M->&(cAlias+"_PERCOM") := WorkAg->EEB_VALCOM
         Else // Valor Fixo
            M->&(cAlias+"_VLCOM") := WorkAg->EEB_VALCOM
         EndIf
         Break
      EndIf

      WorkAg->(DbSkip())
   EndDo

End Sequence

Return lRet

/*
Funcao      : EECAtuIt()
Parametros  : cOcorrencia = Pedido/Embarque.
Retorno     : .t.
Objetivos   : Atualizar os campos referente a agente nos itens.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/03 16:10.
Revisao     :
Obs.        :
*/
*----------------------------*
Function EECAtuIt(cOcorrencia)
*----------------------------*
Local lRet := .t., nRec
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)
Local lTipComChave

Begin Sequence

   cOcorrencia := Upper(cOcorrencia)

   If cOcorrencia = OC_PE
      cAlias   := "EE8"
      cAliasIt := "WorkIt"
   Else
      cAlias   := "EE9"
      cAliasIt := "WorkIp"
   EndIf

   lTipComChave := (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0

   nRec := (cAliasIt)->(RecNo())

   (cAliasIt)->(DbGoTop())
   Do While (cAliasIt)->(!Eof())

      // ** Verifica se o item esta marcado para embarque.
      If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
         WorkIp->(DbSkip())
         Loop
      EndIf

      If lTipComChave .And.; //JPM - se estiver ativo o tratamento de Tipo de Comissão por Item
         cTipComAnt <> WorkAg->EEB_TIPCOM .And. (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE .And.;
         (cAliasIt)->&(cAlias+"_TIPCOM") == cTipComAnt

         (cAliasIt)->&(cAlias+"_TIPCOM") := WorkAg->EEB_TIPCOM

      EndIf

      //If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE - JPM - 02/06/05
      If (cAliasIt)->&(cAlias+"_CODAGE") == WorkAg->EEB_CODAGE .And.;
         If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") = WorkAg->EEB_TIPCOM,.t.)

         If WorkAg->EEB_TIPCVL = "1" // Percentual
            (cAliasIt)->&(cAlias+"_PERCOM") := WorkAg->EEB_VALCOM
            If lFobDescontado //JPM - 07/04/05
               (cAliasIt)->&(cAlias+"_VLCOM")  := Round(&(cAliasIt+"->"+cAlias+"_PRCINC - "+cAliasIt+"->"+cAlias+"_VLDESC")*(WorkAg->EEB_VALCOM/100),2)
            Else
               (cAliasIt)->&(cAlias+"_VLCOM")  := Round((cAliasIt)->&(cAlias+"_PRCINC")*(WorkAg->EEB_VALCOM/100),2)
            EndIf
         ElseIf WorkAg->EEB_TIPCVL = "2"// Valor Fixo
            (cAliasIt)->&(cAlias+"_PERCOM") := 0
            (cAliasIt)->&(cAlias+"_VLCOM")  := WorkAg->EEB_VALCOM
         EndIf
      EndIf

      (cAliasIt)->(DbSkip())
   EndDo

End Sequence

(cAliasIt)->(DbGoTo(nRec))

Return lRet

/*
Funcao      : EECVlComIt()
Parametros  : Nennum.
Retorno     : nValorCom
Objetivos   : Atualizar o campo virtual valor da comissão no item do processo.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/06/03 17:39.
Revisao     :
Obs.        :
*/
*-------------------*
Function EECVlComIt()
*-------------------*
Local nRet:=0, cAliasIt
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)

Begin Sequence

   /*
   Nopado por ER - 19/11/2007.
   A verificação está incorreta porque na manutenção de Pedido a WorkIp não é criada, e
   na manutenção de Embarque a WorkIt também não é criada.

   If !(Select("WorkAg") > 0) .OR. !(Select("WorkIp") > 0) .OR. !(Select("WorkIt") > 0)
      Break
   EndIf
   */

   //ER - 19/11/2007
   If !(Select("WorkAg") > 0)
      Break
   EndIf

   cAlias   := If(Type("M->EE7_PEDIDO")<>"U","EE8","EE9")

   If cAlias == "EE8"
     If !(Select("WorkIt") > 0)
        Break
     EndIf
   Else
     If !(Select("WorkIp") > 0)
        Break
     EndIf
   EndIf

   cAliasIt := If(Type("M->EE7_PEDIDO")<>"U","WorkIt","WorkIp")

   If !Empty((cAliasIt)->&(cAlias+"_CODAGE"))
      //If WorkAg->(DbSeek((cAliasIt)->&(cAlias+"_CODAGE")+CD_AGC)) - JPM 02/06/05
      If WorkAg->(DbSeek((cAliasIt)->&(cAlias+"_CODAGE")+AvKey(CD_AGC+"-"+Tabela("YE",CD_AGC,.f.),"EEB_TIPOAG")+;
                         If((cAlias)->(FieldPos(cAlias+"_CODAGE")) > 0,(cAliasIt)->&(cAlias+"_TIPCOM"),"") ))

         If WorkAg->EEB_TIPCVL $ "13" // Percentual/Percentual por item.
            If lFobDescontado //JPM - 07/04/05
               nRet := Round(&(cAliasIt+"->"+cAlias+"_PRCINC - "+cAliasIt+"->"+cAlias+"_VLDESC")*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)
            Else
               nRet := Round((cAliasIt)->&(cAlias+"_PRCINC")*((cAliasIt)->&(cAlias+"_PERCOM")/100),2)
            EndIf
         Else // Valor Fixo
            nRet := WorkAg->EEB_VALCOM
         EndIf
      EndIf
   EndIf

End Sequence

Return nRet

/*
Funcao      : EECComVlFix()
Parametros  : cOcorrencia = Pedido/Embarque.
Retorno     : .t.
Objetivos   : Efeturar rateio para obter percentual de comissão dos itens para apenas para os agentes
              que possuam comissão do tipo 'Valor Fixo'.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/06/03 08:25.
Revisao     :
Obs.        :
*/
*-------------------------------*
Function EECComVlFix(cOcorrencia)
*-------------------------------*
Local lRet:=.t., nRec
Local cAlias, cAliasIt
Local nVlFob:=0, nPerc:=0
Local lFobDescontado := EasyGParam("MV_AVG0086",,.f.)
Local lTipComChave

Default cOcorrencia := OC_PE

Begin Sequence

   cOcorrencia := Upper(cOcorrencia)

   If cOcorrencia = OC_PE
      cAlias   := "EE8"
      cAliasIt := "WorkIt"
   Else
      cAlias   := "EE9"
      cAliasIt := "WorkIp"
   EndIf

   lTipComChave := (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0

   nRec := (cAliasIt)->(RecNo())

   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())

      // ** Efetua o rateio apenas para os agentes que possuam comissao do tipo 'Valor Fixo'.
      If WorkAg->EEB_TIPCVL <> "2"
         WorkAg->(DbSkip())
         Loop
      EndIf

      // ** Verifica o total fob dos itens para este agente.
      (cAliasIt)->(DbGoTop())
      Do While (cAliasIt)->(!Eof())
         // ** Verifica se o item esta marcado para embarque.
         If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
            WorkIp->(DbSkip())
            Loop
         EndIf

         //If (cAliasIt)->&(cAlias+"_CODAGE") = WorkAg->EEB_CODAGE - JPM - 02/06/05
         If (cAliasIt)->&(cAlias+"_CODAGE") = WorkAg->EEB_CODAGE .And.;
            If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") = WorkAg->EEB_TIPCOM,.t.)

            // Acumula o total FOB.
            If lFobDescontado
               nVlFob += &(cAliasIt+"->"+cAlias+"_PRCINC - "+cAliasIt+"->"+cAlias+"_VLDESC")
            Else
               nVlFob += (cAliasIt)->&(cAlias+"_PRCINC")
            EndIf
         EndIf

         (cAliasIt)->(DbSkip())
      EndDo

      // ** Faz o Rateio da comissão.
      (cAliasIt)->(DbGoTop())
      Do While (cAliasIt)->(!Eof())
         // ** Verifica se o item esta marcado para embarque.
         If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
            WorkIp->(DbSkip())
            Loop
         EndIf

         //If (cAliasIt)->&(cAlias+"_CODAGE") = WorkAg->EEB_CODAGE - JPM - 02/06/05
         If (cAliasIt)->&(cAlias+"_CODAGE") = WorkAg->EEB_CODAGE .And.;
            If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") = WorkAg->EEB_TIPCOM,.t.) //JPM - 31/05/05

            // Calcula o percentual
            nPerc := Round(Round(WorkAg->EEB_VALCOM/nVlFob,4)*100,2)
            (cAliasIt)->&(cAlias+"_PERCOM") := nPerc
         EndIf

         (cAliasIt)->(DbSkip())
      EndDo

      nVlFob := 0
      WorkAg->(DbSkip())
   EndDo

End Sequence

(cAliasIt)->(DbGoTo(nRec))

Return lRet

/*
Funcao      : Ap101GetAg().
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : Get do código do agente recebedor de comissao.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/06/03 09:35.
Revisao     :
Obs.        :
*/
*--------------------------*
Static Function Ap101GetAg()
*--------------------------*
Local lRet:=.f., oDlg , lPedido:=.t.
Local bCancel:={|| oDlg:End()}
Local bOk := {|| If(!Empty(&(cVar)),(oDlg:End(),lRet:=.t.),MsgInfo(STR0088,STR0027))} //"Informe o código do agente."###"Atenção"

Begin Sequence

   lPedido := Type("M->EE7_PEDIDO") <> "U"
   If lPedido
      M->EE8_CODAGE:= CriaVar("EE8_CODAGE")
      cVar := "M->EE8_CODAGE"
      If EE8->(FieldPos("EE8_TIPCOM")) > 0
         M->EE8_TIPCOM := CriaVar("EE8_CODAGE")
      EndIf
   Else
      M->EE9_CODAGE:= CriaVar("EE9_CODAGE")
      cVar := "M->EE9_CODAGE"
      If EE9->(FieldPos("EE9_TIPCOM")) > 0
         M->EE9_TIPCOM := CriaVar("EE9_CODAGE")
      EndIf
   EndIf

   Define MsDialog oDlg Title STR0089 From 10,12 TO 24.5,48 OF oMainWnd //"Agente "

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 30/09/2015 - Ajustes Tela P12.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 1.2, 0.5 TO 4.8,17 Label STR0090 Of oPanel //"Informe o agente"
      @ 32,10 Say STR0034 Size 50,10 Of oPanel Pixel //"Código"

      If lPedido
         @ 32,45 MsGet M->EE8_CODAGE F3 "AGE" Size 20,10 Valid EECValidAg() of oPanel Pixel
      Else
         @ 32,45 MsGet M->EE9_CODAGE F3 "AGE" Size 20,10 Valid EECValidAg() of oPanel Pixel
      EndIf

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

Return lRet

/*
Funcao      : EECVerifyAg().
Parametros  : cOcorrencia.
Retorno     : .t./.f.
Objetivos   : Verifica se existe algum agente lançado que não esteja associado à itens.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/06/03 09:35.
Revisao     :
Obs.        :
*/
*-------------------------------*
Function EECVerifyAg(cOcorrencia)
*-------------------------------*
Local lRet:=.t., cAlias, cAliasIt, aAgentes:={}
Local lTemItem := .f.,y:=0, nRec
Local lTipComChave, xRetPto

Private lMsgAgente:= .T.

Default cOcorrencia := OC_PE

Begin Sequence

   If cOcorrencia = OC_PE
      cAlias   := "EE8"
      cAliasIt := "WorkIt"
   Else
      cAlias   := "EE9"
      cAliasIt := "WorkIp"
   EndIf

   lTipComChave := (cAlias)->(FieldPos(cAlias+"_TIPCOM")) > 0

   nRec := (cAliasIt)->(RecNo())

   WorkAg->(DbGoTop())
   Do While WorkAg->(!Eof())

      If Left(WorkAg->EEB_TIPOAG,1) <> CD_AGC
         WorkAg->(DbSkip())
         Loop
      EndIf

      lTemItem := .f.

      (cAliasIt)->(DbGoTop())
      Do While (cAliasIt)->(!Eof()) .And. !lTemItem

         // ** Verifica se o item esta marcado para embarque.
         If cAliasIt = "WorkIp" .And. Empty((cAliasIt)->&("WP_FLAG"))
            WorkIp->(DbSkip())
            Loop
         EndIf

         If AvFlags("COMISSAO_VARIOS_AGENTES") .And. WorkAg->EEB_TIPCVL <> "3"
            lTemItem := .t. //com o novo tratamento, agentes que não são de percentual por item não precisam
            Exit            //estar vinculados a algum item.
         EndIf

         // If (cAliasIt)->&(cAlias+"_CODAGE") = WorkAg->EEB_CODAGE - JPM - 02/06/05
         If (cAliasIt)->&(cAlias+"_CODAGE") = WorkAg->EEB_CODAGE .And.;
            If(lTipComChave,(cAliasIt)->&(cAlias+"_TIPCOM") = WorkAg->EEB_TIPCOM,.t.)

            lTemItem := .t.
            Exit
         EndIf

         If EasyEntryPoint("EECAP101")
            If ValType(xRetPto := ExecBlock("EECAP101", .F., .F., "VERIFYAG_CHECAITEM")) == "L" .And. xRetPto
               lTemItem := .T.
               Exit
            EndIf
         EndIf

         (cAliasIt)->(DbSkip())
      EndDo

      If !lTemItem
         aAdd(aAgentes,WorkAg->(RecNo()))
      EndIf

      WorkAg->(DbSkip())
   EndDo

   (cAliasIt)->(DbGoTop())
   WorkAg->(DbGoTop())

   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101", .F., .F., "EECVERIFYAG_MSGAGENTE")
   EndIf

   If Len(aAgentes) > 0 .And. lMsgAgente
      If EECMsg(STR0091+ENTER+; //"Existe(m) agente(s) recebedores de comissão sem itens associados. Deseja "
                  STR0092, STR0049, "MsgYesNo") //"excluir o(s) agente(s) não utilizado(s) ?"###"Aviso"

         For y:=1 To Len(aAgentes)
            WorkAg->(dbGoTo(aAgentes[y]))
            If WorkAg->WK_RECNO # 0
               aAdd(aAgDeletados,WorkAg->WK_RECNO)
            EndIf
            WorkAg->(dbDelete())
         Next
      EndIf
   EndIf

End Sequence

(cAliasIt)->(DbGoTo(nRec))

Return lRet

/*
Funcao      : SetMbrowse(cAlias).
Parametros  : cAlias.
Retorno     : .t.
Objetivos   : Tratamentos para chamada da MBrowse.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/11/03 11:09.
Obs.        :
*/
*--------------------------------------*
Function SetMbrowse(cAlias,cExpTopFil)
*--------------------------------------*
Local lRet:=.t., cOcorrencia, nPos:=0
Private uExpTopFil := NIL
Private aCores := {}
Private cAliasAtu:= cAlias // TDF - 01/03/11 - Para utilização em ponto de entrada
Private lSair := .F. //LRS - 19/03/2015 - usado para o Break no ponto de entrada PE_SETMBROWSE

//RMD - 10/12/14 - Variáveis para utilização via ponto de entrada
Private aFixe
Private nClickDef

//** PLB 03/08/07 - Expressão de Filtro a ser aplicado antes do MBrowse
#IFDEF TOP
   If Empty(cExpTopFil)
      uExpTopFil := NIL
   ElseIf !Empty( (cAlias)->( DBFilter() ) )  // Se tabela já estiver filtrada não aplica expressão de filtro
      uExpTopFil := NIL
   Else
      uExpTopFil := cExpTopFil
   EndIf
#ELSE
   uExpTopFil := NIL
#ENDIF
//**

Begin Sequence

   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"PE_SETMBROWSE")
   EndIf

   If lSair
     Break
   EndIf

   If !EECFlags("ORD_PROC")
      If Upper(AllTrim(cAlias)) <> "EE7"  //GFC 10/02/05
         If (nPos:=aScan(aRotina,{|x| x[2]=="AxPesqui"})) > 0
            aRotina[nPos,2] := "AF201Pes"
         EndIf
      EndIf
      //mBrowse( 6, 1,22,75,cAlias,,,,,,aCores)
      // PLB 03/08/06

      //mBrowse( 6, 1,22,75,cAlias,,,,,,aCores,,,,,,,,uExpTopFil) //RMD - 10/12/14 - Incluídas variáveis para uso em ponto de entrada.
      mBrowse( 6, 1,22,75,cAlias,aFixe,,,,nClickDef,aCores,,,,,,,,uExpTopFil)


   Else
      cOcorrencia := If(Upper(AllTrim(cAlias))=="EE7",OC_PE,OC_EM)

      nPos := aScan(aRotina,{|x| x[4] = 1})
      //DFS 27/05/11 - Comentado para que, seja mostrado filtro de pesquisa no Pedido e Embarque
      /*If nPos > 0
         aRotina[nPos][2] := "SetPesquisa"
      EndIf*/

      If cOcorrencia == OC_PE
         EE7->(DbSetOrder(9)) // Filial+Chave Pesquisa.
         //mBrowse(6,1,22,75,"EE7",,,,,,aCores)
         // PLB 03/08/06

      //mBrowse(6,1,22,75,"EE7",,,,,,aCores,,,,,,,,uExpTopFil) //RMD - 10/12/14 - Incluídas variáveis para uso em ponto de entrada.
      mBrowse( 6, 1,22,75,"EE7",aFixe,,,,nClickDef,aCores,,,,,,,,uExpTopFil)

      Else // Fase Embarque.
         EEC->(DbSetOrder(13)) // Filial+Chave Pesquisa.
         //mBrowse(6,1,22,75,"EEC",,,,,,aCores)
         // PLB 03/08/06

      // mBrowse(6,1,22,75,"EEC",,,,,,aCores,,,,,,,,uExpTopFil) //RMD - 10/12/14 - Incluídas variáveis para uso em ponto de entrada.
         mBrowse(6,1,22,75,"EEC",aFixe,,,,nClickDef,aCores,,,,,,,,uExpTopFil)
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : SetPesquisa.
Parametros  : Default Retorno aRotina.
Retorno     : .t.
Objetivos   : Tratamentos para chamada da AxPesqui.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/11/03 12:01.
Obs.        :
*/
*-------------------------------------*
Function SetPesquisa(cAlias,nReg,nOpc )
*-------------------------------------*
Local lRet

Begin Sequence

   cAlias := Upper(AllTrim(cAlias))

   If (cAlias == "EE7")
      If EE7->(IndexOrd()) = 9 // Filial+Chave Ordenação.
         EE7->(DbSetOrder(1))
      EndIf
      AxPesqui()
   Else
      If EEC->(IndexOrd()) = 13 // Filial+Chave Ordenação.
         EEC->(DbSetOrder(1))
      EndIf

      If !AF201Pes()//AAF - 22/01/05 - Nova Função de Pesquisa para Embarque e Cambio.
         // BHF - 04/07/08 - Verificação de cancelamento de pesquisa.
         EEC->( dbSetOrder(13) )//AAF - 06/07/05 - Volta ao Indice original.
      EndIf
   EndIf


End Sequence

Return lRet

/*
Funcao      : Ap101GetKey(cOcorrencia)
Parametros  : Ocorrencia = OC_PE - Pedido.
                           OC_EM - Embarque.
Retorno     : .t.
Objetivos   : Gravação do campo de chave para rotina de ordenação de processos.
Autor       : Jeferson Barros Jr.
Data/Hora   : 07/11/03 15:12.
Obs.        :
*/
*-------------------------------*
Function Ap101GetKey(cOcorrencia)
*-------------------------------*
Local nRet:=0, aOrd:={}

Begin Sequence

   cOcorrencia := Upper(AllTrim(cOcorrencia))

   nRec := EE7->(RecNo())

   If (cOcorrencia == OC_PE)
      aOrd:=SaveOrd("EE7")

      EE7->(DbSetOrder(9))
      EE7->(DbSeek(xFilial("EE7")))

      nRet := (EE7->EE7_KEY - 1)
   Else
      aOrd:=SaveOrd("EEC")

      EEC->(DbSetOrder(13))
      EEC->(DbSeek(xFilial("EEC")))

      nRet := (EEC->EEC_VLNFC - 1)
   EndIf

End Sequence

RestOrd(aOrd)

Return nRet

/*
Funcao      : Ap101VldQtde(cOcorrencia).
Parametros  : Ocorrencia    = OC_PE - Pedido.
                              OC_EM - Embarque.
              lAtualiza     = .t.   - Realiza as atualizações.
                              .f.   - Realiza somente as validações.
              lOkAProdutos =  .t.   - A função não irá reapurar os produros que sofreram alterações.
                              .f.   - A função irá realizar tratamentos diversos de acordo com os
                                      demais produtos.
              cNextProcOffShore =  Nro do processo utilizado para embarques com mais de um nível de
                                   Off-shore.
Retorno     : .t./.f.
Objetivos   : Rotina para conferência de quantidades para os itens da filial de off-shore e fil. brasil.
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/04/04 13:22.
Obs.        : aProdutos por dimensão
                        aProdutos [1][1]  - Pedido.
                                  [1][2]  - Código do Item.
                                  [1][3]  - Descrição.
                                  [1][4]  - Qtde na Fil. Atual.
                                  [1][5]  - Qtde na Fil. Contrária.
*/
*-----------------------------------------------------------------------------------*
Function Ap101VldQtde(cOcorrencia,lAtualiza,lShowMsg,lOkAProdutos,cNextProcOffShore)
*-----------------------------------------------------------------------------------*
Local lRet:=.t., cAliasWk, cAlias, aProdutos:={}, j:=0
Local cMsg:="" , cFil, cOldProd:="", nPos, cProcesso, nRecEEC := 0

Private lTemEmbarque := .f.

Default lAtualiza         := .t.
Default lShowMsg          := .f.
Default lOkAProdutos      := .f.
Default cNextProcOffShore := ""

Begin Sequence

   cOcorrencia := Upper(AllTrim(cOcorrencia))
   cFil        := If(xFilial("EE8")==cFilBr,cFilEx,cFilBr)

   If cOcorrencia == OC_PE
      aProdComDif := {}
      If xFilial("EE8") == cFilBr
         If !(M->EE7_INTERM $ cSim)
            Break
         EndIf
      EndIf

      cAliasWk  := "WorkIt"
      cAlias    := "EE8"
      cProcesso := M->EE7_PEDIDO

      EE8->(DbSetOrder(1))
   Else
      If !Empty(cNextProcOffShore)
         /*
         If !(EEC->EEC_INTERM $ cSim)
            Break
         EndIf
         */
         EE9->(DbSetOrder(2))
         cFil      := cFilEx // Os vários níveis de off-shore são sempre gravados na filial do exterior.
         cAlias    := "EE9"
         cProcesso := cNextProcOffShore
      Else
         aProdComDif := {}
         If xFilial("EE9") == cFilBr
            If !(M->EEC_INTERM $ cSim)
               Break
            EndIf
         EndIf

         EE9->(DbSetOrder(2))
         cAliasWk    := "WorkIp"
         cAlias      := "EE9"
         cProcesso   :=  M->EEC_PREEMB

         /* Verifica se o  processo de  embarque possue  data de  embarque na filial oposta.
            Este tratamento é realizado apenas se a função não estiver verificando os níveis
            de off-shore. */

         If xFilial("EEC") == cFilEx
            nRecEEC:= EEC->(RecNo())
            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(cFil+cProcesso))
               If !Empty(EEC->EEC_DTEMBA)
                  lTemEmbarque := .t.
               EndIf
            EndIf
            EEC->(DbGoTo(nRecEEC))
         EndIf
      EndIf
   EndIf

   // ** O processo deve obrigatóriamente existir nas duas filiais envolvidas no processo de intermediação.
   If Empty(cNextProcOffShore)
      If !(cAlias)->(DbSeek(cFil+cProcesso))
         Break
      EndIf
   EndIf

   aProdutos := {}

   /* Carrega o array aProdutos, com as quantidades gravadas na filial atual (logada)
      agrupando as informações por pedido + produto. */

   If Empty(cNextProcOffShore)

      (cAliasWk)->(DbGoTop())
      Do While (cAliasWk)->(!Eof())

         If cOcorrencia == OC_EM // ** Verifica se o item está marcado para embarque.
            If Empty(WorkIp->WP_FLAG)
               WorkIp->(DbSkip())
               Loop
            EndIf
         EndIf

         If cOldProd <> (cAliasWk)->&(cAlias+"_PEDIDO") + (cAliasWk)->&(cAlias+"_COD_I")
            aAdd(aProdutos,{(cAliasWk)->&(cAlias+"_PEDIDO"),;
                            (cAliasWk)->&(cAlias+"_COD_I") ,;
                            Memoline(AllTrim((cAliasWk)->&(cAlias+"_VM_DES")),25,1),;
                            (cAliasWk)->&(cAlias+"_SLDINI"),;
                            0})

            cOldProd := (cAliasWk)->&(cAlias+"_PEDIDO") + (cAliasWk)->&(cAlias+"_COD_I")
         Else
            nPos := aScan(aProdutos,{|x| x[1] == (cAliasWk)->&(cAlias+"_PEDIDO") .And.;
                                         x[2] == (cAliasWk)->&(cAlias+"_COD_I")})
            If nPos > 0
               aProdutos[nPos][4] += (cAliasWk)->&(cAlias+"_SLDINI")
            EndIf
         EndIf

         (cAliasWk)->(DbSkip())
      EndDo

      (cAliasWk)->(DbGoTop())

   Else

      // ** Os tratamentos abaixo são realizados apenas na fase de embarque.
      EE9->(DbSetOrder(2))
      If EE9->(DbSeek(cFil+EEC->EEC_PREEMB))
         Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFil .And.;
                                      EE9->EE9_PREEMB == EEC->EEC_PREEMB

            If cOldProd <> EE9->EE9_PEDIDO+EE9->EE9_COD_I
               aAdd(aProdutos,{EE9->EE9_PEDIDO,;
                               EE9->EE9_COD_I ,;
                               Memoline(MSMM(EE9->EE9_DESC,AVSX3("EE9_VM_DES",AV_TAMANHO)),25,1),;
                               EE9->EE9_SLDINI,;
                               0})

               cOldProd := EE9->EE9_PEDIDO+EE9->EE9_COD_I
            Else
               nPos := aScan(aProdutos,{|x| x[1] == EE9->EE9_PEDIDO .And.;
                                            x[2] == EE9->EE9_COD_I })
               If nPos > 0
                  aProdutos[nPos][4] += EE9->EE9_SLDINI
               EndIf
            EndIf

            EE9->(DbSkip())
         EndDo
      EndIf
   EndIf

   /* Verifica as quantidades gravadas na filial que completa a intermediação com a filial atual (logada),
      carrega as informações para o array aProdutos, agrupando por pedido + produto */

   (cAlias)->(DbSeek(cFil+cProcesso))
   Do While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFil .And.;
                                     (cAlias)->&(cAlias+If(cOcorrencia==OC_PE,"_PEDIDO","_PREEMB")) == cProcesso

      /* Para a fase de pedido, se o processo já possuir embarque na filial criticada,
         seta a flag lTemEmbarque para controle da disponibilização da opção para
         recriar o pedido na filial que apresenta divergências. */

      If (cOcorrencia == OC_PE) .And. (EE8->EE8_SLDINI <> EE8->EE8_SLDATU)
         lTemEmbarque := .t.
      EndIf

      nPos := aScan(aProdutos,{|x| x[1] == (cAlias)->&(cAlias+"_PEDIDO") .And.;
                                   x[2] == (cAlias)->&(cAlias+"_COD_I")})
      If nPos > 0
         aProdutos[nPos][5] += (cAlias)->&(cAlias+"_SLDINI")
      Else
         aAdd(aProdutos,{(cAlias)->&(cAlias+"_PEDIDO"),;
                         (cAlias)->&(cAlias+"_COD_I"),;
                         Memoline(MSMM((cAlias)->&(cAlias+"_DESC"),AVSX3(cAlias+"_VM_DES",AV_TAMANHO)),25,1),;
                         0,;
                         (cAlias)->&(cAlias+"_SLDINI")})
      EndIf
      (cAlias)->(DbSkip())
   EndDo

   If !lOkAProdutos
      // ** Verifica se existem divergências entre as filiais.
      For j:=1 To Len(aProdutos)
         If aProdutos[j][4] <> aProdutos[j][5] // ** Quantidades diferentes.

            // ** Inclui no aProdComDif, apenas os itens com diferenças na quantidades.
            aAdd(aProdComDif,{aProdutos[j][1],aProdutos[j][2],aProdutos[j][4],aProdutos[j][5]})

            If lShowMsg
               // ** Monta msg para informar usuário das divergências encontradas.
               If Empty(cMsg)
                  // Monta cabeçario da msg.
                  cMsg := STR0093+ENTER+; //"Existem divergências para a quantidade entre as filiais envolvidas "
                          STR0094+Replic(ENTER,2)+; //"no processo de Off-shore."
                          STR0095+Replic(ENTER,2) //"Segue abaixo detalhes dos problemas encontrados:"

                  cMsg += IncSpace(AvSx3("EE7_PEDIDO",AV_TITULO),AvSx3("EE7_PEDIDO",AV_TAMANHO),.f.)+Space(2)+;
                          IncSpace(STR0096,35,.f.)+Space(2)+; //"Produto"
                          IncSpace(STR0097+AllTrim(xFilial(cAlias)),17,.t.)+Space(2)+; //"Qtde. Filial "
                          IncSpace(STR0097+AllTrim(cFil),17,.t.)+Replic(ENTER,2) //"Qtde. Filial "
               EndIf

               cMsg += IncSpace(Transf(AllTrim(aProdutos[j][1]),AvSx3("EE7_PEDIDO",AV_PICTURE)),AvSx3("EE7_PEDIDO",AV_TAMANHO),.f.)+Space(2)+;
                       IncSpace(AllTrim(aProdutos[j][2])+"-"+AllTrim(aProdutos[j][3]),35,.f.)+Space(2)+;
                       IncSpace(AllTrim(Transf(aProdutos[j][4],AvSx3("EE8_SLDINI",AV_PICTURE))),17,.t.)+Space(2)+;
                       IncSpace(AllTrim(Transf(aProdutos[j][5],AvSx3("EE8_SLDINI",AV_PICTURE))),17,.t.)+ENTER
            EndIf
         EndIf
      Next
   EndIf

   If lShowMsg .And. Empty(cMsg)
      Break
   EndIf

   If !lOkAProdutos
      If lShowMsg
         // ** Exibe msg com as divergencias encontradas.
         If !EECView(cMsg,STR0098,STR0099) //"Validação Rotina Off-shore"###"Detalhes"
            lRet := .f.
            Break
         EndIf

         lRet := MsgYesNo(STR0100+AllTrim(cFil)+" ?",STR0027) //"Deseja atualizar os itens na filial "###"Atenção"
         If !lRet
            Break
         EndIf
         If (cOcorrencia == OC_PE)
            /* Para a fase de pedido, verifica se as divergências poderão atualizadas na filial oposta à logada,
               para crítica da rotina de intermediação. */

            ap101CanAtu(cFil,cProcesso,aProdComDif)
         EndIf
      EndIf
   EndIf

   If lAtualiza
      If Len(aProdComDif) > 0
         MsAguarde({|| MsProcTxt(STR0101+; //"Atualizando processo '"
                       AllTrim(Transf(cProcesso,AvSx3(cAlias+If(cOcorrencia==OC_PE,"_PEDIDO","_PREEMB"),AV_PICTURE)))+;
                       STR0102+AllTrim(cFil)+" ..."),; //"' na filial "
                       lRet := Ap101AtuProcs(cFil,cProcesso,aProdComDif,cOcorrencia)}, STR0103) //"Off-shore"
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : ap101CanAtu(cFil).
Parametros  : cFil   = Filial a ser atualizada.
              aProdComDif = Produtos e quantidades nas filiais.
Retorno     : .t./.f.
Objetivos   : Rotina para verificar se as divergencias poderão ser atualizadas na filial 'cfil'.
Autor       : Jeferson Barros Jr.
Data/Hora   : 04/08/04 14:25.
Obs.        :
*/
*-----------------------------------------------------*
Static Function ap101CanAtu(cFil,cProcesso,aProdComDif)
*-----------------------------------------------------*
Local lRet := .t., aOrd:=SaveOrd({"EE8"})
Local j:=0, aAux:={}, cProd := "", cMsg:="", nVl:=0

Begin Sequence

   /* Verifica na filial 'cfil' se o processo possui disponível as quantidades a serem
      ajustadas.  */

   EE8->(DbSetOrder(1))
   If EE8->(DbSeek(cFil+cProcesso))
      Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFil .And.;
                                   EE8->EE8_PEDIDO == cProcesso

         If (cProd <> EE8->EE8_COD_I)
            aAdd(aAux,{EE8->EE8_COD_I,EE8->EE8_SLDATU})
            cProd := EE8->EE8_COD_I
         Else
            nPos := aScan(aAux,{|x| x[1] == EE8->EE8_COD_I})
            aAux[nPos][2] += EE8->EE8_SLDATU
         EndIf

         EE8->(DbSkip())
      EndDo
   EndIf

   For j:=1 To Len(aProdComDif)
      nPos := aScan(aAux,{|x| x[1] == aProdComDif[j][2]})
      nVl  := aProdComDif[j][3] - aProdComDif[j][4]

      If nPos > 0
         If nVl > aAux[nPos][2]
            If Empty(cMsg)
               cMsg := STR0111+cFil+"'."+Replic(ENTER,2) //"Não há quantidade disponível para realizar a atualização na filial '."
               cMsg += STR0112+Replic(ENTER,2) //"Detalhes:"
               cMsg += IncSpace(STR0113,15,.f.)+Space(2)+; //"Produto "
                       IncSpace(STR0114,17,.t.)+Space(2)+; //"Acerto"
                       IncSpace(STR0115,17,.t.)+Replic(ENTER,2) //"Qtde.Disp."
            Else
               cMsg += IncSpace(AllTrim(aProdutos[j][2]),15,.f.)+Space(2)+;
                       IncSpace(AllTrim(Transf(nVl,AvSx3("EE8_SLDINI",AV_PICTURE))),17,.t.)+Space(2)+;
                       IncSpace(AllTrim(Transf(aAux[nPos][2],AvSx3("EE8_SLDINI",AV_PICTURE))),17,.t.)+ENTER
            EndIf
         EndIf
      EndIf
   Next

   If !Empty(cMsg)
      EECView(cMsg,STR0098,STR0099)
      lRet:=.f.
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ap101AtuProcs(cFil,cProcesso,aProdComDif,cOcorrencia,lNiveisOffShore)
Parametros  : cFil        = Filial a ser atualizada.
              cProcesso   = Processo a ser atualizado.
              aProdComDif = Produtos e quantidades nas filiais.
              cOcorrencia = OC_PE - Pedido.
                            OC_EM - Embarque.
              lNiveisOffShore = .t. - Indica que a função foi chamada a partir dos tratamentos
                                      de vários níveis de off-shore.
                                .f. - Indica que a função não foi chamada a partir dos tratamentos
                                      de vários níveis de off-shore.
Retorno     : .t./.f.
Objetivos   : Rotina para atualizar os itens com divergências de quantidade entre as filiais.
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/04/04 11:56.
Obs.        :
*/
*-----------------------------------------------------------------------------------*
Static Function Ap101AtuProcs(cFil,cProcesso,aProdComDif,cOcorrencia,lNiveisOffShore)
*-----------------------------------------------------------------------------------*
Local lRet:=.t., j:=0, k:=0,  aOrd:=SaveOrd({"EE8"})
Local cAliasWk , cAlias, nSld:=0, nPerc:=0, aIt:={}, nVl:=0
Local nAux:=0, nSldAtu:=0

/* aProdComDif por Dimensão:
                aProdComDif[1][1] = Pedido
                           [1][2] = Produto
                           [1][3] = Qtde Fil.Atual
                           [1][4] = Qtde Fil.Interm. */

Default lNiveisOffShore := .f.

Begin Sequence

   If Len(aProdComDif) = 0
      Break
   EndIf

   EE8->(DbSetOrder(1))

   If cOcorrencia == OC_PE
      cAlias  := "EE8"
   Else
      cAlias  := "EE9"
      EE9->(DbSetOrder(2))
   EndIf

   For j:=1 To Len(aProdComDif)
      nSld := aProdComDif[j][3] - aProdComDif[j][4]

      If nSld > 0 // Qtde a ser acrescentada.
         (cAlias)->(DbSeek(cFil+cProcesso))
         Do While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFil .And.;
                  (cAlias)->&(cAlias+If(cOcorrencia==OC_PE,"_PEDIDO","_PREEMB")) == cProcesso

            // ** Verifica apenas os itens que possuem o mesmo produto gravado no array.
            If (cAlias)->&(cAlias+"_PEDIDO")+(cAlias)->&(cAlias+"_COD_I") <> aProdComDif[j][1]+aProdComDif[j][2]
               (cAlias)->(DbSkip())
               Loop
            EndIf

            If cOcorrencia == OC_PE
               If lCommodity .And. !Empty(EE8->EE8_DTFIX)
                  EE8->(DbSkip()) // ** Desconsidera os itens já fixados.
                  Loop
               EndIf
            Else
               If EE8->(DbSeek(cFil+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
                  If (lCommodity .And. !Empty(EE8->EE8_DTFIX)) .Or. Empty(EE8->EE8_SLDATU)
                     EE9->(DbSkip())
                     Loop
                  EndIf

                  nSldAtu := EE8->EE8_SLDATU
               EndIf
            EndIf

            /*
            If lCommodity // ** Para processos com commodity testa a Dt. de Fix.Preço.
               If cOcorrencia == OC_PE
                  If !Empty(EE8->EE8_DTFIX)
                     EE8->(DbSkip()) // ** Desconsidera os itens já fixados.
                     Loop
                  EndIf
               Else
                  If EE8->(DbSeek(cFil+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
                     If !Empty(EE8->EE8_DTFIX) .Or. Empty(EE8->EE8_SLDATU)
                        EE9->(DbSkip())
                        Loop
                     EndIf

                     nSldAtu := EE8->EE8_SLDATU
                  EndIf
               EndIf
            EndIf
            */

            If cOcorrencia = OC_PE
               // ** Atualiza as informações nos itens da filial oposta.
               Ap101AtuIt(cAlias, nSld,cOcorrencia)

               nSld := 0
               Exit
            Else
               aAdd(aIt,{(cAlias)->(RecNo()),nSld})
               nSld := 0
               Exit

               // Atualiza os itens do embarque de acordo com as quantidades disponíveis de saldo nos itens
               //   do pedido - (EE8_SLDATU)

               If nSldAtu >= nSld
                  aAdd(aIt,{(cAlias)->(RecNo()),nSld})
                  nSld := 0
                  Exit
               Else
                  aAdd(aIt,{(cAlias)->(RecNo()),nSld-nSldAtu})
                  nSld -= nSldAtu

                  If nSld = 0
                     Exit
                  EndIf
               EndIf
            Endif

            (cAlias)->(DbSkip())
         EndDo

         /*
         If nSld > 0 // Atualização não realizada com sucesso.
            MsgInfo(STR0104+cFil+STR0105+Replic(ENTER,2)+; //"O(s) item(ns) na filial '"###"' não foi(rão) atualizado(s)!"
                    STR0106+ENTER+; //"Possíveis causas:"
                    STR0107+cFil+"'"+ENTER+; //" - O(s) produto(s) não foi(ram) encontrado(s) na filial '"
                    STR0108,STR0027) //" - Não foi encontrado item sem fixação de preço."###"Atenção"
            lRet:=.f.
            Break
         EndIf
         */

         If Len(aIt) > 0
            For k:=1 To Len(aIt)
               (cAlias)->(DbGoTo(aIt[k][1]))
               Ap101AtuIt(cAlias, aIt[k][2],cOcorrencia)
            Next
            aIt:={}
         EndIf

      Else // Qtde a ser excluída.

         // Verifica se o produto na filial oposta à logada, possue quantidade disponivel para abatimento.
         aIt:={}
         (cAlias)->(DbSeek(cFil+cProcesso))
         Do While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias+"_FILIAL") == cFil .And.;
                  (cAlias)->&(cAlias+If(cOcorrencia==OC_PE,"_PEDIDO","_PREEMB")) == cProcesso

            // ** Verifica apenas os itens que possuem o mesmo produto gravado no array.
            If (cAlias)->&(cAlias+"_PEDIDO")+(cAlias)->&(cAlias+"_COD_I") <> aProdComDif[j][1]+aProdComDif[j][2]
               (cAlias)->(DbSkip())
               Loop
            EndIf

            If lCommodity // ** Para processos com commodity testa a Dt. de Fix.Preço.
               If cOcorrencia == OC_PE
                  If !Empty(EE8->EE8_DTFIX)
                     EE8->(DbSkip()) // ** Desconsidera os itens já fixados.
                     Loop
                  EndIf
               Else
                  If EE8->(DbSeek(cFil+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
                     If !Empty(EE8->EE8_DTFIX)
                        EE9->(DbSkip())
                        Loop
                     EndIf
                  EndIf
               EndIf
            EndIf

            If cOcorrencia = OC_PE
               /* Atualiza as informações nos itens da filial oposta.
                  para o caso de quantidade a menor */

               nVl := Ap101AtuIt(cAlias,nSld)

               If nVl > 0
                  nSld += nVl
               ElseIf nVl < 0
                  nSld -= nVl
               EndIf

               /*
               If nVl > 0
                  nSld += nVl
               ElseIf nVl < 0
                  nSld -= nVl
               ElseIf nVl = 0
                  nSld := 0
               EndIf
               */
            Else
               nAux := nSld + EE9->EE9_SLDINI
               If nAux <= 0
                  aAdd(aIt,{EE9->(RecNo()),0})
               Else
                  aAdd(aIt,{EE9->(RecNo()),nSld})
               EndIf

               nSld += EE9->EE9_SLDINI
            EndIf

            If nSld >= 0
               Exit
            EndIf

            (cAlias)->(DbSkip())
         EndDo

         If nSld < 0
            EasyHelp(STR0104+cFil+STR0105+Replic(ENTER,2)+; //"O(s) item(ns) na filial '"###"' não foi(rão) atualizado(s)!"
                    STR0106+ENTER+; //"Possíveis causas:"
                    STR0107+cFil+"';"+ENTER+; //" - O(s) produto(s) não foi(ram) encontrado(s) na filial '"
                    STR0109+ENTER+; //" - Não foi encontrado item sem fixação de preço;"
                    STR0110+cFil+"'.",STR0027) //" - Não existe quantidade disponível para abatimento na filial '"###"Atenção"
            lRet:=.f.
            Break
         EndIf

         If cOcorrencia == OC_EM
            // ** Atualiza os itens.
            For k:=1 To Len(aIt)
               (cAlias)->(DbGoTo(aIt[k][1]))

               If lNiveisOffShore
                  Ap101AtuIt(cAlias,aIt[k][2],cOcorrencia,cFil)
               Else
                  Ap101AtuIt(cAlias,aIt[k][2],cOcorrencia)
               EndIf
            Next
         EndIf
      EndIf
   Next

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ap101AtuIt(cAlias,nValor,cOcorrencia,cFil)
Parametros  : cAlias = Alias a ser atualizado.
              nValor = Valor a ser atualizado no campo de quantidade.
              cOcorrencia = OC_PE/OC_EM.
              cFil = Filial do processo a ser Atualizado.
Retorno     : nVl = Valor atualizado.
Objetivos   : Atualiza as informações dos itens.
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/04/04 14:54.
Obs.        :
*/
*---------------------------------------------------------*
Static Function Ap101AtuIt(cAlias, nValor,cOcorrencia,cFil)
*---------------------------------------------------------*
Local nRet:=0, aOrd:=SaveOrd({"EE8"}), i

Default cOcorrencia := OC_PE
Default cFil        := If(xFilial("EE8")==cFilBr,cFilEx,cFilBr)

Begin Sequence

   If (cAlias)->(RecLock(cAlias,.f.))

      If cOcorrencia == OC_EM
         If !lMultiOffShore .Or. (lMultiOffShore .And. Empty(EEC->EEC_NIOFFS))

            // Atualiza o saldo do item.
            EE8->(DbSetOrder(1))
            If EE8->(DbSeek(cFil+EE9->EE9_PEDIDO+EE9->EE9_SEQUEN))
               If EE8->(RecLock("EE8",.f.))
                  If nValor <> 0
                     EE8->EE8_SLDATU -= nValor
                  ElseIf nValor = 0
                     EE8->EE8_SLDATU += (cAlias)->&(cAlias+"_SLDINI")
                  EndIf
                  EE8->(MsUnLock())
               EndIf
            EndIf
         EndIf
      EndIf

      If nValor = 0
         // ** Deleta o item.
         For i:=1 To Len(aMemoItem)
            If (cAlias)->(FieldPos(aMemoItem[i][1])) > 0
               MSMM((cAlias)->&(aMemoItem[i][1]),,,,EXCMEMO)
            EndIf
         Next

         (cAlias)->(DbDelete())
      Else

         If nValor > 0
            (cAlias)->&(cAlias+"_SLDINI") += nValor

            If cOcorrencia == OC_PE
               EE8->EE8_SLDATU += nValor
            EndIf
         Else
            If cOcorrencia == OC_PE
               If EE8->EE8_SLDATU > 0
                  If Abs(nValor) <= EE8->EE8_SLDATU
                     EE8->EE8_SLDINI += nValor
                     EE8->EE8_SLDATU += nValor
                     nRet := nValor
                  Else
                     nRet := EE8->EE8_SLDATU
                     EE8->EE8_SLDINI -= EE8->EE8_SLDATU
                     EE8->EE8_SLDATU := 0
                  EndIf
               EndIf

               /*
               If EE8->EE8_SLDATU > 0
                  If Abs(nValor) <= EE8->EE8_SLDATU
                     EE8->EE8_SLDINI += nValor
                     EE8->EE8_SLDATU += nValor
                     nRet := nValor
                  EndIf
               ElseIf EE8->EE8_SLDATU < 0

                  nRet := EE8->EE8_SLDATU
                  EE8->EE8_SLDINI -= EE8->EE8_SLDATU
                  EE8->EE8_SLDATU := 0

               ElseIf EE8->EE8_SLDATU = 0
                  nRet := EE8->EE8_SLDATU
                  EE8->EE8_SLDINI += nValor
               EndIf
               */
               If (EE8->EE8_SLDINI = 0 .And. EE8->EE8_SLDATU = 0)
                  // ** Deleta o item.
                  For i:=1 To Len(aMemoItem)
                     If (cAlias)->(FieldPos(aMemoItem[i][1])) > 0
                        MSMM((cAlias)->&(aMemoItem[i][1]),,,,EXCMEMO)
                     EndIf
                  Next

                  EE8->(DbDelete())
                  lAtuFil := .t.
                  Break
               EndIf
            Else
               (cAlias)->&(cAlias+"_SLDINI") += nValor
            EndIf
         EndIf

         // ** Qtde de embalagens.
         If ((cAlias)->&(cAlias+"_SLDINI") % (cAlias)->&(cAlias+"_QE")) != 0
            (cAlias)->&(cAlias+"_QTDEM1") := Int((cAlias)->&(cAlias+"_SLDINI")/(cAlias)->&(cAlias+"_QE"))+1
         Else
            (cAlias)->&(cAlias+"_QTDEM1") := Int((cAlias)->&(cAlias+"_SLDINI")/(cAlias)->&(cAlias+"_QE"))
         Endif

         // ** Recalculo dos pesos bruto e liquido.
         Ap101CalcPsBr(cOcorrencia)

         (cAlias)->(MsUnLock())
      EndIf

      lAtuFil := .t. // Flag para chamada da precoI() para atualização dos totais para o pedido alterado.
   EndIf

End Sequence

RestOrd(aOrd)

Return nRet

/*
Funcao      : Ap101AtuFil(cOcorrencia)
Parametros  : cOcorrencia - OC_PE = Pedido.
                            OC_EM = Embarque.
              lPosiciona  - .t. - Posiciona no processo correto.
                            .f. - Não posiciona o processo.
              cProcesso   - Nro do processo a ser atualizado.
Retorno     : .t.
Objetivos   : Atualiza o processo na filial oposta a logada, para processos de offshore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 10/04/04 14:54.
Obs.        :
*/
*---------------------------------------------------------*
Function Ap101AtuFil(cOcorrencia,lPosiciona,cFil,cProcesso)
*---------------------------------------------------------*
Local lRet:=.t., aOrd

Default lPosiciona := .t.
Default cFil := If(xFilial("EE8")==cFilBr,cFilEx,cFilBr)

Begin Sequence

   If !lIntermed .Or. (IsMemVar("lAtuFil") .AND. !lAtuFil)// LRS - 28/11/2018
      Break
   EndIf

   cOcorrencia := AllTrim(Upper(cOcorrencia))

   If cOcorrencia == OC_PE

      aOrd := SaveOrd({"EE7"})

      If Empty(cProcesso)
         cProcesso := EE7->EE7_PEDIDO
      EndIf
      If lPosiciona
         EE7->(DbSetOrder(1))
         EE7->(DbSeek(cFil+cProcesso))
      EndIf

      Ap105CallPrecoI(cFil)
   Else

      aOrd := SaveOrd({"EEC"})

      If Empty(cProcesso)
         cProcesso := EEC->EEC_PREEMB
      EndIf
      If lPosiciona
         EEC->(DbSetOrder(1))
         EEC->(DbSeek(cFil+cProcesso))
      EndIf

      Ae105CallPrecoI(cFil)

      /* Os tratamentos abaixo foram substituídos pelas novas regras dos tratamentos de atualização de quantidades para processos com
         off-shore. */
      /*
      If lMultiOffShore
         Ap104SetLevelsOffShore(EEC->EEC_PREEMB)
         aProdComDiff:={}
      EndIf
      */
   EndIf

   RestOrd(aOrd,.t.)

End Sequence

Return lRet

/*
Funcao      : Ap101CalcPsBr().
Parametros  : cOcorrencia - OC_PE = Pedido.
                            OC_EM = Embarque.
Retorno     : .t.
Objetivos   : Calcular o peso bruto total da linha.
Autor       : Jeferson Barros Jr.
Data/Hora   : 12/04/04 09:03.
Obs.        :
*/
*------------------------------------------------------------*
Function Ap101CalcPsBr(cOcorrencia,lWork,lPesoManual,lMemoria)
*------------------------------------------------------------*
Local lRet := .t.,  aOrd:=SaveOrd({"EEK","EE5"})
Local cAlias, cAliasH, cProcesso, cSequen ,cTab,cTabH
Local lBrutoXQtde := .f.

//Local cEmbalagem := ""
Local cUnPes      := ""
Local cLastEmb    := ""

//Local nQtdEmb    := 0
//Local nPesEmb    := 0
Local nQuant     := 0
Local nQe        := 0
Local aOrdEmbs   := {}
Default lWork:= .f.
Default lMemoria := .f.

Private cEmbalagem := ""
Private nQtdEmb    := 0
Private nPesEmb    := 0
Private nQtdeEmbInt:= 0

Begin Sequence

   If cOcorrencia == OC_PE
      cAlias    := If(lWork,"WorkIt","EE8")
      cAliasH   := If(lWork,"M"     ,"EE7")
      cTab      := "EE8"
      cTabH     := "EE7"
      cProcesso := If(lWork,M->EE7_PEDIDO,EE7->EE7_PEDIDO)
      cSequen   := If(lWork,WorkIt->EE8_SEQUEN,EE8->EE8_SEQUEN)
   Else
      cAlias    := If(lWork,"WorkIP","EE9")
      cAliasH   := If(lWork,"M","EEC")
      cTab      := "EE9"
      cTabH     := "EEC"
      cProcesso := If(lWork,M->EEC_PREEMB,EEC->EEC_PREEMB)
      cSequen   := If(lWork,WorkIp->EE9_SEQEMB,EE9->EE9_SEQEMB)
   EndIf

   //WFS 13/01/09
   If cAlias $ "EE8/EE9"
      (cAlias)->(RecLock(cAlias, .F.))
   EndIf

   If EECFlags("INVOICE")
      If cOcorrencia == "INV"
         cAlias    := If(lWork,"WrkSldInv","EXR")
         cAliasH   := If(lWork,"M","EEC")
         cTab      := "EXR"
         cTabH     := "EEC"
         cProcesso := If(lWork,M->EEC_PREEMB,EEC->EEC_PREEMB)
         cSequen   := If(lWork,WrkSldInv->EXR_SEQEMB,EXR->EXR_SEQEMB)
         cUnPes    := If(lWork, Posicione("WorkIp", 1, cSequen, "EE9_UNPES"), Posicione("EE9", 3, xFilial("EE9"+cProcesso+cSeqEmb, "EE9_UNPES")))
      EndIf
   EndIf

   If Valtype(lPesoManual) == "U"
      lPesoManual := GetNewPar("MV_AVG0009",.f.) .Or. (Type("SB1->B1_REPOSIC") <> "U" .And.;
                     Posicione("SB1",1,xFilial("SB1")+EE8->EE8_COD_I,"B1_REPOSIC") $cSim)
   EndIF
   // Calcula Peso Bruto Total = Qtde*Peso Bruto Unit.
   lBrutoXQtde := EasyGParam("MV_AVG0063",,.F.)

   //WFS 23/04/09 ---
   //Conversão para kg. Após os cálculos, retorna para a unidade escolhida para o processo
   If EECFlags("INVOICE") .And. cOcorrencia == "INV"
      If lMemoria
         M->&(cTab+"_PSLQUN"):= AvTransUnid(cUnPes, "KG", M->&(cTab+"_COD_I"), M->&(cTab+"_PSLQUN"), .F.)
      Else
         (cAlias)->&(cTab+"_PSLQUN"):= AvTransUnid(cUnPes, "KG", (cAlias)->&(cTab+"_COD_I"), (cAlias)->&(cTab+"_PSLQUN"), .F.)
      EndIf
   Else
      If lMemoria
         M->&(cTab+"_PSLQUN"):= AvTransUnid(M->&(cTab+"_UNPES"), "KG", M->&(cTab+"_COD_I"), M->&(cTab+"_PSLQUN"), .F.)
      Else
         (cAlias)->&(cTab+"_PSLQUN"):= AvTransUnid((cAlias)->&(cTab+"_UNPES"), "KG", (cAlias)->&(cTab+"_COD_I"), (cAlias)->&(cTab+"_PSLQUN"), .F.)
      EndIf
   EndIf
   //---

   If !lPesoManual
      If lMemoria
         M->&(cTab+"_PSLQTO") := M->&(cTab+"_SLDINI")*M->&(cTab+"_PSLQUN") // Peso liquido total.
      Else
         (cAlias)->&(cTab+"_PSLQTO") := (cAlias)->&(cTab+"_SLDINI")*(cAlias)->&(cTab+"_PSLQUN") // Peso liquido total.
      EndIf
   Endif

   If !lBrutoXQtde .And. If(lWork,Eval(MemVarBlock(cTabH+"_BRUEMB")),(cAliasH)->&(cTabH+"_BRUEMB")) $ cSim
      //Calcular Pesos Brutos

      EE5->(DBSETORDER(1))
      If lMemoria
         EE5->(DbSeek(xFilial("EE5")+M->&(cTab+"_EMBAL1")))
      Else
         EE5->(DbSeek(xFilial("EE5")+(cAlias)->&(cTab+"_EMBAL1")))
      EndIf


      // Peso Bruto Unitário.
      If lMemoria
         M->&(cTab+"_PSBRUN") := (M->&(cTab+"_PSLQUN")*M->&(cTab+"_QE"))+EE5->EE5_PESO
      Else
         (cAlias)->&(cTab+"_PSBRUN") := ((cAlias)->&(cTab+"_PSLQUN")*(cAlias)->&(cTab+"_QE"))+EE5->EE5_PESO
      EndIf

      If !lPesoManual
         // Peso Bruto Total.

         /*
           Nopado por ER - 12/04/2007.
           O cálculo abaixo não considera embalagens que não foram completamente preenchidas.

         If lMemoria
            M->&(cTab+"_PSBRTO") := M->&(cTab+"_PSBRUN")*M->&(cTab+"_QTDEM1")
         Else
            (cAlias)->&(cTab+"_PSBRTO") := (cAlias)->&(cTab+"_PSBRUN")*(cAlias)->&(cTab+"_QTDEM1")
         EndIf

         EE5->(DbSetOrder(1))
         EEK->(DbSetOrder(2))
         EEK->(DbSeek(xFilial("EEK")+cOcorrencia+cProcesso+cSequen+(cAlias)->&(cTab+"_EMBAL1")))
         Do While EEK->(!Eof()) .And. EEK->EEK_TIPO   == cOcorrencia .And.;
                                      EEK->EEK_PEDIDO == cProcesso .And.;
                                      EEK->EEK_SEQUEN == cSequen .And.;
                                      EEK->EEK_CODIGO == (cAlias)->&(cTab+"_EMBAL1")

            If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))
               If lMemoria
                  M->&(cTab+"_PSBRTO") += (EE5->EE5_PESO*EEK->EEK_QTDE)
               Else
                  (cAlias)->&(cTab+"_PSBRTO") += (EE5->EE5_PESO*EEK->EEK_QTDE)
               EndIf
            EndIf

            EEK->(DbSkip())
         EndDo
      */

         If lMemoria
            nQuant     := M->&(cTab+"_SLDINI")
            nQe        := M->&(cTab+"_QE")
            cEmbalagem := M->&(cTab+"_EMBAL1")
         Else
            nQuant     := (cAlias)->&(cTab+"_SLDINI")
            nQe        := (cAlias)->&(cTab+"_QE")
            cEmbalagem := (cAlias)->&(cTab+"_EMBAL1")
         EndIf


         If nQuant <= nQe
            nQtdEmb := 1
         Else
            If (nQuant % nQe) > 0
               nQtdEmb := Int(nQuant / nQe) + 1
            Else
               nQtdEmb := nQuant / nQe
            EndIf
         EndIf

         nPesEmb := nQtdEmb * EE5->EE5_PESO
         nQtdeEmbInt := nQtdEmb
         aOrdEmbs := SaveOrd({"EE5","EEK"})
         //Cálculo para Embalagens Múltiplas.
         EEK->(DbSetOrder(1))
         If EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagem))
            Do While EEK->(!Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                                         EEK->EEK_TIPO   == OC_EMBA .And.;
                                         EEK->EEK_CODIGO == cEmbalagem

               If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))

                  If nQtdEmb <= EEK->EEK_QTDE
                     nQtdEmb    := 1
                  Else
                     If (nQtdEmb % EEK->EEK_QTDE) > 0
                        nQtdEmb := Int(nQtdEmb / EEK->EEK_QTDE) + 1
                     Else
                        nQtdEmb := nQtdEmb / EEK->EEK_QTDE
                     EndIf
                  EndIf

                  nPesEmb += (EE5->EE5_PESO*nQtdEmb)
                  cLastEmb := EEK->EEK_EMB
               EndIf

               EEK->(DbSkip())
            
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

         If lMemoria                                               //NCF - 31/03/2015 - Reapura embalagem interna para utilização em ponto de entrada
            cEmbalagem := M->&(cTab+"_EMBAL1")
         Else
            cEmbalagem := (cAlias)->&(cTab+"_EMBAL1")
         EndIf

         RestOrd(aOrdEmbs,.T.)                                     //NCF - 31/03/2015 - Restarura ordem e recupera registros para

         If EasyEntryPoint("EECAP101")
            ExecBlock("EECAP101",.F.,.F.,"CALC_EMB_MULTIPLA")
         EndIf

         If lMemoria
            M->&(cTab+"_PSBRTO") := M->&(cTab+"_PSLQTO") + nPesEmb
         Else
            (cAlias)->&(cTab+"_PSBRTO") := (cAlias)->&(cTab+"_PSLQTO") + nPesEmb
         EndIf

      EndIf

   Else

      If lMemoria
         M->&(cTab+"_PSBRUN") := If(Empty(M->&(cTab+"_PSBRUN")),;
                                          M->&(cTab+"_PSLQUN") ,;
                                          M->&(cTab+"_PSBRUN"))
      Else
         (cAlias)->&(cTab+"_PSBRUN") := If(Empty((cAlias)->&(cTab+"_PSBRUN")),;
                                                   (cAlias)->&(cTab+"_PSLQUN") ,;
                                                   (cAlias)->&(cTab+"_PSBRUN"))
      EndIf

      If !lPesoManual
         IF !lBrutoXQtde
            If lMemoria
               M->&(cTab+"_PSBRTO") :=  M->&(cTab+"_QTDEM1")*M->&(cTab+"_PSBRUN")
            Else
               (cAlias)->&(cTab+"_PSBRTO") :=  (cAlias)->&(cTab+"_QTDEM1")*(cAlias)->&(cTab+"_PSBRUN")
            EndIf
         Else
            If lMemoria
                M->&(cTab+"_PSBRTO") :=  M->&(cTab+"_SLDINI")*M->&(cTab+"_PSBRUN")
            Else
                (cAlias)->&(cTab+"_PSBRTO") :=  (cAlias)->&(cTab+"_SLDINI")*(cAlias)->&(cTab+"_PSBRUN")
            EndIf
         Endif
      EndIf
   EndIf

   //WFS 23/04/09 ---
   //Após a realização dos cálculos, converter para a unidade real do processo.
   If EECFlags("INVOICE") .And. cOcorrencia == "INV"
      If lMemoria
         M->&(cTab+"_PSLQUN"):= AvTransUnid("KG", cUnPes,, M->&(cTab+"_PSLQUN"), .F.)
         M->&(cTab+"_PSBRUN"):= AvTransUnid("KG", cUnPes,, M->&(cTab+"_PSBRUN"), .F.)
         M->&(cTab+"_PSLQTO"):= AvTransUnid("KG", cUnPes,, M->&(cTab+"_PSLQTO"), .F.)
         M->&(cTab+"_PSBRTO"):= AvTransUnid("KG", cUnPes,, M->&(cTab+"_PSBRTO"), .F.)
      Else
         (cAlias)->&(cTab+"_PSLQUN"):= AvTransUnid("KG", cUnPes,, (cAlias)->&(cTab+"_PSLQUN"), .F.)
         (cAlias)->&(cTab+"_PSBRUN"):= AvTransUnid("KG", cUnPes,, (cAlias)->&(cTab+"_PSBRUN"), .F.)
         (cAlias)->&(cTab+"_PSLQTO"):= AvTransUnid("KG", cUnPes,, (cAlias)->&(cTab+"_PSLQTO"), .F.)
         (cAlias)->&(cTab+"_PSBRTO"):= AvTransUnid("KG", cUnPes,, (cAlias)->&(cTab+"_PSBRTO"), .F.)
      EndIf
   Else
      If lMemoria
         M->&(cTab+"_PSLQUN"):= AvTransUnid("KG", M->&(cTab+"_UNPES"),, M->&(cTab+"_PSLQUN"), .F.)
         M->&(cTab+"_PSBRUN"):= AvTransUnid("KG", M->&(cTab+"_UNPES"),, M->&(cTab+"_PSBRUN"), .F.)
         M->&(cTab+"_PSLQTO"):= AvTransUnid("KG", M->&(cTab+"_UNPES"),, M->&(cTab+"_PSLQTO"), .F.)
         M->&(cTab+"_PSBRTO"):= AvTransUnid("KG", M->&(cTab+"_UNPES"),, M->&(cTab+"_PSBRTO"), .F.)
      Else
         (cAlias)->&(cTab+"_PSLQUN"):= AvTransUnid("KG", (cAlias)->&(cTab+"_UNPES"),, (cAlias)->&(cTab+"_PSLQUN"), .F.)
         (cAlias)->&(cTab+"_PSBRUN"):= AvTransUnid("KG", (cAlias)->&(cTab+"_UNPES"),, (cAlias)->&(cTab+"_PSBRUN"), .F.)
         (cAlias)->&(cTab+"_PSLQTO"):= AvTransUnid("KG", (cAlias)->&(cTab+"_UNPES"),, (cAlias)->&(cTab+"_PSLQTO"), .F.)
         (cAlias)->&(cTab+"_PSBRTO"):= AvTransUnid("KG", (cAlias)->&(cTab+"_UNPES"),, (cAlias)->&(cTab+"_PSBRTO"), .F.)
      EndIf
   EndIf
   //---

   //ER - 22/12/2006 às 09:50
   If EasyEntryPoint("EECAP101")
      ExecBlock("EECAP101",.F.,.F.,"PESOBR")
   EndIf
   //WFS 13/01/09
   If cAlias $ "EE8/EE9"
      (cAlias)->(MsUnlock())
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP100PreCalcGrv()
Parametros  : lGrv  -> .T. ->Gera Work
                       .F. ->Grava "EXM"
              cOcorrencia -> Pedido/Embarque.
Retorno     : .T./.F.
Objetivos   : Grava arquivo de trabalho ou EXM.
Autor       : Jeferson Barros Jr.
Data/Hora   : 21/09/04 - 11:56.
Revisao     :
Obs.        :
*/
*----------------------------------------*
Function AP100PreCalcGrv(lGrv,cOcorrencia)
*----------------------------------------*
Local j:=0
Local cProc
Local lExibeMsg:= .F.

Default cOcorrencia := OC_EM
Default lGrv        := .f.

Begin Sequence

   cOcorrencia := Upper(cOcorrencia)
   cProc := IF(cOcorrencia==OC_PE,M->EE7_PEDIDO,M->EEC_PREEMB)

   If !lGrv
      For j:=1 to Len(aPreCalcDeletados)
         EXM->(DbGoTo(aPreCalcDeletados[j]))

         EXM->(RecLock("EXM",.f.))
         EXM->(DbDelete())
         EXM->(MsUnlock())
      Next

      WorkCalc->(DbGoTop())

      Do While WorkCalc->(!Eof())
         If WorkCalc->WK_RECNO != 0
            EXM->(DbGoTo(WorkCalc->WK_RECNO))
            EXM->(RecLock("EXM",.f.))
         Else
            EXM->(RecLock("EXM",.t.))
         EndIf

         AVReplace("WorkCalc","EXM")
         EXM->EXM_FILIAL := xFilial("EXM")
         EXM->EXM_PREEMB := cProc
         EXM->(MsUnlock())

         WorkCalc->(DbSkip())
      Enddo
   Else
      WorkCalc->(RecLock("WorkCalc", .T.))
      AVReplace("EXM","WorkCalc")

      If AllTrim(WorkCalc->EXM_MOEDA) <> "R$"
         WorkCalc->WK_VALR  := Round(WorkCalc->EXM_VALOR*BuscaTaxa(WorkCalc->EXM_MOEDA,dDataBase,, lExibeMsg),2)
      Else
         WorkCalc->WK_VALR  := Round(WorkCalc->EXM_VALOR,2)
      EndIf

      WorkCalc->WK_RECNO := EXM->(RECNO())
      WorkCalc->(MsUnlock())
   EndIf

End Sequence

Return Nil

/*
Função     : Ap101FilNf()
Retorno    : Retornar a filial da nota, observando os tratamentos necessários
Parâmetros : nenhum, porém deve-se setar o alias. Ex.: WorkIp->(Ap101FilNf())
Autor      : João Pedro Macimiano Trabbold
Data       : 26/12/05
*/
*-------------------*
Function Ap101FilNf()
*-------------------*
Private cFilFatNf
cFilFatNf := If(EECFlags("FATFILIAL"),If(Alias()$"EE9/WORKIP",EE9_FIL_NF,If(Alias()$"EEM/WORKNF",EEM_FIL_NF,EES_FIL_NF)),xFilial("SD2"))

If EECFlags("FATFILIAL") .And. Empty(cFilFatNf)  //LGS-11/12/2014
   cFilFatNf := xFilial("SD2")
Endif

IF(EXISTBLOCK("EECAP101"),EXECBLOCK("EECAP101",.F.,.F.,"TROCA_FILIAL_NOTA"),)

Return cFilFatNf

/*
Função     : Ap101RetFil()
Retorno    : Retornar as filiais em que se deve buscar a nota fiscal
Parâmetros : nenhum
Autor      : João Pedro Macimiano Trabbold
Data       : 27/12/05
*/
*--------------------*
Function Ap101RetFil()
*--------------------*
Local nRec

If EECFlags("FATFILIAL")
   Static aFiliais, cEmp := ""
   If ValType(aFiliais) <> "A" .Or. cEmp <> cEmpAnt
      aFiliais := {}
      nRec := SM0->(RecNo())
      SM0->(DbGoTop())
      While SM0->(!EoF())
         If AllTrim(SM0->M0_CODIGO) == AllTrim(cEmpAnt) // se for da mesma empresa...
            AAdd(aFiliais,AvGetM0Fil())
         EndIf
         SM0->(DbSkip())
      EndDo
      SM0->(DbGoTo(nRec))
   EndIf
   cEmp := cEmpAnt
   Return aFiliais
Else
   Return {xFilial("SD2")}
EndIf

/*
Funcao      : IsProcOffShore()
Parametros  : cProc -> Numero do Processo
              cFase -> Pedido/Embarque.
              cFil  -> Filial
Retorno     : .T./.F.
Objetivos   : Verifica se um Processo faz parte de uma operação Off-Shore
Autor       : Eduardo C. Romanini
Data/Hora   : 08/05/06 - 11:20.
Revisao     :
Obs.        :
*/

Function IsProcOffShore(cProc,cFase,cFil)

Local cAlias := If(cFase == OC_PE,"EE7","EEC")
Local aOrd   := SaveOrd({cAlias})
Local lRet   := .F.
Local lIntermed

Private cFilBr := "", cFilEx := ""

Default cFase := OC_PE
Default cFil  := xFilial(cAlias)

Begin Sequence

   lIntermed := EECFLAGS("INTERMED")
   If !lIntermed
      Break
   EndIF

   (cAlias)->(DbSetOrder(1))

   If cFil == cFilBr //Filial Brasil

      If (cAlias)->(DbSeek(cFil+cProc))
         If (cAlias)->&(cAlias + "_INTERM") == 1 //Sim
            lRet := .T.
            Break
         EndIf
      EndIf

   ElseIf cFil == cFilEx //Filial OffShore

      If (cAlias)->(DbSeek(cFilBr+cProc))
         lRet := .T.
         Break
      EndIf

   Endif

End Sequence

RestOrd(aOrd)

Return lRet

*-------------------------*
Static Function ContaInst()
*-------------------------*
Local nContInst := 0

WorkIn->(dbGoTop())
Do While ! EOF()
	If !WorkIn->DBDELETE
		nContInst+=1
	Endif
	WorkIn->(dbSkip())
Enddo

Return nContInst

/*
Funcao      : AgChgOrd(cOrd,cSeek)
Parametros  : cOrd    := "Código"
                      := "Descrição"
                      := "Descri4ção"
              cSeek   := Item a ser consultado
Retorno     : .T.
Objetivos   : Alterar o Indice do Arquivo Temporário
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 27/05/2014 :: 16:52
*/
Static Function AgChgOrd(cOrd,cSeek)
Local nOrd := 1

IF Left(Upper(cOrd),1) == "C"  // Código
   cSeek:=Space(Len(WorkAg->EEB_CODAGE))
   nOrd := 1
Else  // Descrição
   cSeek:=Space(Len(WorkAg->EEB_NOME))
   nOrd := 2
Endif

WorkAg->(dbSetOrder(nOrd))
Return .t.

/*
Funcao     : AP101RevReg()
Parametros : cFunName        = Nome da função adapter que estava sendo executada na integração
             nOpc            = Opção da rotina adapter que estava sendo executada
Retorno    : Nenhum
Objetivos  : Reverter registro de determinadas tabelas quando a integração com Logix retornar inválida
Autor      : Nilson César
Data/Hora  : 07/08/2014 16:00 hrs
*/
*--------------------------------*
Function AP101RevReg(cFuncName,nOpc)

Local i, j
Local lRet := .F.

If cFuncName == "EECAF216" .and. (Valtype(aDadosEET) == "A" .And. Len(aDadosEET) > 0)

   If (j := aScan(aDadosEET,{ |x| x[2] == EET->(Recno()) }) ) > 0 //   for j:=1 to len(aDadosEET)
      if aDadosEET[j][1] == "INC"
         if ! EET->(IsLocked())
            EET->(Reclock("EET",.F.))
            EET->EET_FINNUM := ""
            EET->(MsUnlock())
            lRet := .T.
         endif
      elseif aDadosEET[j][1] == "ALT" // retorno no momento de falha da inclusão de um novo título depois da exclusão do antigo

            if ! EET->(IsLocked())

               EET->(Reclock("EET",.F.))
                  if nOpc == 3 // caso seja 3 o título anterior já foi excluírdo e deve ser recriado.
                     EET->EET_FINNUM := ""
                  elseif nOpc == 5 // caso seja 3 o título anterior já foi excluírdo e deve ser recriado.
                     // volta os dados de acordo com o backup
                     For i:=1 To EET->(FCount())
                        EET->&(EET->(FieldName(i))) :=  aDadosEET[j][3][i]
                     Next i
                  endif

               EET->(MsUnlock())
               lRet := .T.
            endif

      elseif aDadosEET[j][1] == "DEL"
         if ! EET->(IsLocked()) .and. EET->(deleted())
            EET->(Reclock("EET",.F.))
            EET->(dbRecall())
            EET->(MsUnlock())
            lRet := .T.
         endif
      endif
      aDel(aDadosEET,j)
      aSize( aDadosEET,Len(aDadosEET)-1 )
   endif
endif

Return lRet


Static Function IsDocDisable(lMsg)
Local lret := .F.
Default lMsg := .F.
aOrdEEA := SaveOrd("EEA")
EEA->(DbSetOrder(1))
If EEA->(DbSeek(xFilial("EEA")+M->EXB_CODATV))
   If EEA->EEA_ATIVO == "2"
      lRet := .T.
      If lMsg
         EasyHelp(STR0133,STR0049) //"Documento/Atividade não poderá ser selecionado pois está inativo no cadastro de Documentos!"###"Aviso"
      EndIf
   EndIf
EndIf
RestOrd(aOrdEEA,.T.)
Return lRet

//Retira campos que não podem ser editados no EnchAuto
Static Function ValidaEnch(aAuto, aEdita)
Local i, nPos
Local aReturn := aClone(aAuto)
Local aRetira := {}

    For i := 1 To Len(aReturn)
        If aScan(aEdita, aReturn[i][1]) == 0
            aAdd(aRetira, aReturn[i][1])
        EndIf
    Next
    For i := 1 To Len(aRetira)
        If (nPos := aScan(aReturn, {|x| AllTrim(Upper(x[1])) == AllTrim(Upper(aRetira[i])) })) > 0
            aDel(aReturn, nPos)
            aSize(aReturn, Len(aReturn)-1)
        EndIf
    Next

Return aReturn

/*
Funcao     : AP101ChkI()
Parametros : cAlias      = Alias do arquivo (EET ou WorkDe)
             CCpo        = Campo a ser verificado
             lPreenchido = .T. se for checar se o campo está preenchido e .F. caso contrário
Retorno    : lRet
Objetivos  : Verificar se os campos estão preenchidos/vazios conforme a condição de existência destes campos.
             e habilitação dos mesmos na rotina.
Autor      : Nilson César
Data/Hora  : 15/01/2021
*/
Static Function AP101ChkI(cAlias,cCpo,lPreenchido)

Local lRet := .F.

   If cCpo == "EET_PEDCOM"
      lRet := EasyGParam("MV_EEC0043",,.F.) .And. (cAlias)->(FieldPos("EET_PEDCOM")) > 0 .And. If(lPreenchido,!Empty((cAlias)->EET_PEDCOM),Empty((cAlias)->EET_PEDCOM))
   EndIf

Return lRet

*------------------------------------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECAP101.PRW                                                                                     *
*------------------------------------------------------------------------------------------------------------------*
