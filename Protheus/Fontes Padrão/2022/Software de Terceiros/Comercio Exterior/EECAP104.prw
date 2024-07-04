/*
Função      : AP105VE_RV
Objetivo    : Vinculação/Estorno de R.V. Desvinculada.
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 13:06
*/

#INCLUDE "eec.ch"
#INCLUDE "eecap104.ch"

Function AP105VE_RV(cAlias, nRecno, nOpc)

Local lRet     := .F.
Local aSaveOrd := SaveOrd("EE8")
Local nButton  := 0
Local nRadio   := 1
Local aRadio   := {{STR0001, {|| AP100MAN(cAlias, nRecno, nOpc)}},; //"Vinculação de R.V."
                   {STR0002, {|| AP105E_RV()}}}                     //"Estorno de vinculação de R.V."
Local lITcomRV := .F.
Local lITsemRV := .F.

Local nRecNoEE7 := EE7->(RecNo()), aEE7Filter := EECSaveFilter("EE7") // JPM - 02/12/05 - salva e limpa filtro no EE7
EE7->(DbClearFilter())
EE7->(DbGoTo(nRecNoEE7))

If EasyEntryPoint("EECAP104")
   ExecBlock("EECAP104", .F., .F., "RV_INICIO")
EndIf

Begin Sequence

   IF EE7->EE7_STATUS == ST_RV // Pedido Especial para RV
      MsgInfo(STR0003,STR0004) //"Não é permitida a vinculação de RV, nos processos especiais para geração de RV!"###"Aviso"
      Break
   Endif

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial()+EE7->EE7_PEDIDO))

   While EE8->(!Eof() .and. EE8_FILIAL == xFilial() .and. EE8_PEDIDO == EE7->EE7_PEDIDO)
      If(Empty(EE8->EE8_RV), lITsemRV, lITcomRV) := .T.
      EE8->(dbSkip())
   End

   Do Case

      Case lITsemRV .and. !lITcomRV
         Eval(aRadio[1][2])

      Case lITcomRV .and. !lITsemRV
         Eval(aRadio[2][2])

      OtherWise
         Define MSDialog oDlg Title STR0005 From 00, 00 To 146, 389 Of oMainWnd Pixel //"Vinculação/Estorno de R.V."

         @ 20, 09 Radio nRadio Items aRadio[1][1], aRadio[2][1] Size 150, 10 of oDlg Pixel

         Define SButton From 59, 09 Type 1 Action (nButton := 1, oDlg:End()) Enable of oDlg Pixel
         Define SButton From 59, 40 Type 2 Action (nButton := 0, oDlg:End()) Enable of oDlg Pixel

         Activate MSDialog oDlg Centered

         If nButton = 1
            Eval(aRadio[nRadio][2])
         EndIf

   EndCase

End Sequence

// JPM - 02/12/05 - restaura filtro no EE7
nRecNoEE7 := EE7->(RecNo())
EECRestFilter(aEE7Filter)
EE7->(DbGoTo(nRecNoEE7))

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : AP105V_RV
Objetivo    : Vinculação de R.V. para o Item do Pedido.
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 13:06
*/
*------------------*
Function AP105V_RV()
*------------------*
Local lRet     := .F.
Local nRetWork := 0

Private cWorkEE8

Begin Sequence

   If !Empty(WorkIt->EE8_RV)
      MsgInfo(STR0006, STR0007) //"O Item selecionado já possui R.V."###"Atenção"
      Break
   EndIf

   MSAguarde({|| MSProcTxt(STR0008), nRetWork := V_RVGeraWork()}, STR0001) //"Gerando arquivos temporários ..."###"Vinculação de R.V."

   If nRetWork > 0
      If nRetWork = 1
         MsgInfo(STR0009, STR0007) //"Não foram encontrados pedidos com R.V. desvinculada."###"Atenção"
      EndIf
      Break
   EndIf
   
   /* JPM - 28/03/06 - Serão permitidas vinculações parciais qdo o item já possuir embarque.
   If !Empty(WorkIt->WK_PREEMB)
      MsgInfo(STR0135,STR0007) //"O item selecionado já possui embarque, portanto, só serão permitidas vinculações totais de quantidade."###"Atenção"
   EndIf
   */
   
   If !V_RVTela1()
      Break
   EndIf

   lRet := .T.

End Sequence

Return(lRet)


/*
Função      : V_RVGeraWork()
Objetivo    : Geração de Work para Vinculação de R.V.
Retorno     : 0 -> Gerou registros na WorkEE8
              1 -> Não gerou registros na WorkEE8, por não encontrar pedidos com R.V. desvinculada.
              2 -> Não gerou registros na WorkEE8, por não encontrar a conversão entre a unid.medida do item vs.
                   unid.medida do R.V. desvinculado.
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 17:06
*/
*----------------------------*
Static Function V_RVGeraWork()
*----------------------------*
Local nRet         := 0
Local aSaveOrd     := SaveOrd("EE8")
#IFDEF TOP
   Local cQueryString := ""
   Local cCMD         := ""
   Local nPos         := 0
#ENDIF

Local aWorkEE8 := {{"EE8_RECNO",  "N", 07,                              00},;
			       {"EE8_RV",     "C", AVSX3("EE8_RV",     AV_TAMANHO), 00},;
			       {"EE8_DTRV",   "D", AVSX3("EE8_DTRV",   AV_TAMANHO), 00},;
			       {"EE8_QTDE",   "N", AVSX3("EE8_SLDATU", AV_TAMANHO), AVSX3("EE8_SLDATU", AV_DECIMAL)},;
			       {"EE8_SLDATU", "N", AVSX3("EE8_SLDATU", AV_TAMANHO), AVSX3("EE8_SLDATU", AV_DECIMAL)},;
			       {"EE8_DTFIX",  "D", AVSX3("EE8_DTFIX",  AV_TAMANHO), 00},;
			       {"EE8_PRECO",  "N", AVSX3("EE8_PRECO",  AV_TAMANHO), AVSX3("EE8_PRECO", AV_DECIMAL)},;
			       {"EE8_STFIX",  "C", AVSX3("EE8_STFIX",  AV_TAMANHO), 00},;
			       {"EE8_MESFIX", "C", AVSX3("EE8_MESFIX", AV_TAMANHO), 00},;
			       {"EE8_DIFERE", "N", AVSX3("EE8_DIFERE", AV_TAMANHO), AVSX3("EE8_DIFERE", AV_DECIMAL)},;
			       {"EE8_QTDLOT", "N", AVSX3("EE8_QTDLOT", AV_TAMANHO), AVSX3("EE8_QTDLOT", AV_DECIMAL)},;
			       {"EE8_DTCOTA", "D", AVSX3("EE8_DTCOTA", AV_TAMANHO), 00},;
			       {"EE8_RATEIO", "N", 17,			      				15},;
			       {"EE8_FLAG",   "C", 02,					       		00}}

Private aCampos := {}

cWorkEE8 := E_CriaTrab(, aWorkEE8, "WorkEE8")

Begin Sequence

   #IFDEF TOP

      cQueryString += "SELECT "
      cQueryString += "R_E_C_N_O_ AS EE8_RECNO, "
      cQueryString += "EE8_RV, "
      cQueryString += "EE8_DTRV, "
      cQueryString += "EE8_SLDATU, "
      cQueryString += "EE8_DTFIX, "
      cQueryString += "EE8_PRECO, "
      cQueryString += "EE8_STFIX, "
      cQueryString += "EE8_MESFIX, "
      cQueryString += "EE8_DIFERE, "
      cQueryString += "EE8_QTDLOT, "
      cQueryString += "EE8_DTCOTA, "
      cQueryString += "EE8_UNIDAD "
      cQueryString += "FROM " + RetSQLName("EE8") + " EE8 "
      cQueryString += "WHERE "
      cQueryString += "D_E_L_E_T_ <> '*' AND "
      cQueryString += "EE8_FILIAL = '"+xFilial("EE8")+"' AND "
      cQueryString += "EE8_RV <> '' AND "
      cQueryString += "EE8_STATUS = '"+ST_RV+"' AND "
      cQueryString += "EE8_SLDATU > 0 AND "
      cQueryString += "EE8_POSIPI = '"+WorkIt->EE8_POSIPI+"'"

      cCMD := ChangeQuery(cQueryString)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY", .F., .T.)

      TCSetField("QRY", "EE8_DTRV",   "D", 8, 0)
      TCSetField("QRY", "EE8_DTFIX",  "D", 8, 0)
      TCSetField("QRY", "EE8_DTCOTA", "D", 8, 0)

      If QRY->(!Eof()) // JPM - 14/11/05 - só faz verificação se encontrar registros.
         If AVTransUnid(QRY->EE8_UNIDAD, WorkIt->EE8_UNIDAD,, QRY->EE8_SLDATU, .T.) = Nil
            MsgInfo(STR0084+QRY->EE8_UNIDAD+STR0085+WorkIt->EE8_UNIDAD+STR0086, STR0007) //"Não foi encontrada a conversão de "###" para "###" na tabela de conversão de unidade de medida."###"Atenção"
            QRY->(dbCloseArea())
            nRet++
            Break
         EndIf
      EndIF
      
      While !QRY->(Eof())

         WorkEE8->(dbAppend())         

         For nPos := 1 To QRY->(fCount())
				WorkEE8->(&(QRY->(FieldName(nPos)))) := If(QRY->(FieldName(nPos)) <> "EE8_SLDATU", QRY->(FieldGet(nPos)),;
                                                                                               AVTransUnid(QRY->EE8_UNIDAD, WorkIt->EE8_UNIDAD,, QRY->EE8_SLDATU, .F.))
         Next

         QRY->(dbSkip())

      End

      QRY->(dbCloseArea())

   #ELSE

      EE8->(dbSetOrder(1))
      EE8->(dbSeek(xFilial("EE8")+"*"))

      While EE8->(!Eof() .and. EE8_FILIAL == xFilial("EE8") .and. Left(EE8_PEDIDO, 1) = "*")

         If EE8->(!Empty(EE8_RV) .and. EE8_SLDATU > 0 .and.  EE8_POSIPI == WorkIt->EE8_POSIPI)

            If AVTransUnid(EE8->EE8_UNIDAD, WorkIt->EE8_UNIDAD,, EE8->EE8_SLDATU, .T.) = Nil
               MsgInfo(STR0084+EE8->EE8_UNIDAD+STR0085+WorkIt->EE8_UNIDAD+STR0086, STR0007) //"Não foi encontrada a conversão de "###" para "###" na tabela de conversão de unidade de medida."###"Atenção"
               nRet++
               Break
            EndIf

            WorkEE8->(dbAppend())
            WorkEE8->EE8_RECNO  := EE8->(Recno())
            WorkEE8->EE8_RV     := EE8->EE8_RV
            WorkEE8->EE8_DTRV   := EE8->EE8_DTRV
            WorkEE8->EE8_QTDE   := 0
            WorkEE8->EE8_SLDATU := AVTransUnid(EE8->EE8_UNIDAD, WorkIt->EE8_UNIDAD,, EE8->EE8_SLDATU, .F.)
            WorkEE8->EE8_DTFIX  := EE8->EE8_DTFIX
            WorkEE8->EE8_PRECO  := EE8->EE8_PRECO
            WorkEE8->EE8_STFIX  := EE8->EE8_STFIX
            WorkEE8->EE8_MESFIX := EE8->EE8_MESFIX
            WorkEE8->EE8_DIFERE := EE8->EE8_DIFERE
            WorkEE8->EE8_QTDLOT := EE8->EE8_QTDLOT
            WorkEE8->EE8_DTCOTA := EE8->EE8_DTCOTA

         EndIf

         EE8->(dbSkip())

      End

   #ENDIF

End Sequence

If (nRet += If(WorkEE8->(EasyRecCount()) = 0, 1, 0)) > 0
   WorkEE8->(dbCloseArea())
   E_EraseArq(cWorkEE8)
EndIf

RestOrd(aSaveOrd)

Return(nRet)


/*
Função      : V_RVTela1()
Objetivo    : Apresentar tela de dialogo, com pedidos para vinculação de R.V.
Retorno     : .T. -> Ok
              .F. -> Cancel
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 17:58
*/

Static Function V_RVTela1()

Local lRet          := .F.
Local lRetAtuPed    := .T.
Local nOpc          := 0
Local bOk           := {|| If(nQtdeVinc <> WorkIt->EE8_SLDATU,(nOpc := 1, oDlg:End()),MsgInfo(/*STR0130*/"",STR0007) )}//"Selecione pelo menos um R.V."###"Atenção"
Local bCancel       := {|| nOpc := 2, oDlg:End()}

Local aSelectFields := {{"EE8_FLAG","XX",""},;
                       ColBrw("EE8_RV","WorkEE8"), ColBrw("EE8_DTRV","WorkEE8"),;
  			           {{||Transform(WorkEE8->EE8_QTDE,AVSX3("EE8_SLDATU", AV_PICTURE))}, "", "Qtde" },;
					   ColBrw("EE8_SLDATU","WorkEE8"), ColBrw("EE8_DTFIX", "WorkEE8")}
					    
Local lInverte      := .F.
Local nCont         := 0

Local oDlg
DbSelectArea("WorkEE8")
Private cMarca      := GetMark()
Private oMsSelect
Private aCampos     := {}
Private aHeader     := {}

Private nQtdeSelect := 0
Private nQtdeVinc   := WorkIt->EE8_SLDATU

Begin Sequence

   Define MSDialog oDlg Title STR0001 From 00, 00 To 471, 555 Of oMainWnd Pixel //"Vinculação de R.V."

      @ 015, 003 To 070, 276 Label STR0010 of oDlg Pixel //"Dados do Item"

      @ 026, 008 Say STR0011 Size 80, 07 Pixel Of oDlg //"NCM"
      @ 038, 008 Say STR0012 Size 80, 07 Pixel Of oDlg //"Qtde"
      @ 052, 008 Say STR0013 Size 80, 07 Pixel Of oDlg //"Qtde à Vincular"
      
      @ 024, 50 MSGet WorkIt->EE8_POSIPI Picture AVSX3("EE8_POSIPI", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 036, 50 MSGet WorkIt->EE8_SLDATU Picture AVSX3("EE8_SLDATU", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
      @ 049, 50 MSGet oQtdeVinc Var nQtdeVinc Picture AVSX3("EE8_SLDATU", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
     
      @ 072, 003 To 233, 276 Label STR0014 of oDlg Pixel //"R.V.(s) Desvinculadas"
      
      aPos := { 79, 06, 230, 273 }

      WorkEE8->(dbGoTop())
      
      oMark       := MsSelect():New("WorkEE8", "EE8_FLAG",, aSelectFields, @lInverte, @cMarca, aPos)
      oMark:bAval := {|| If(V_RVTela1Vld(), V_RVTela2(),)}
      
   Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered
   
   If nOpc = 1
   
      Begin Transaction
         MSAguarde({|| MSProcTxt(STR0015), lRetAtuPed := V_RVAtuPed()}, STR0001) //"Atualizando Pedido ..."###"Vinculação de R.V."
      End Transaction
   
      If lRetAtuPed
         lRet := .T.
      EndIf

   EndIf

End Sequence

WorkEE8->(dbCloseArea())
E_EraseArq(cWorkEE8)

Return(lRet)


/*
Função      : V_RVTela1Vld()
Objetivo    : Validação dos dados da V_RVTela1()
Retorno     : .T. -> Dados ok.
              .F. -> Dados incorretos.
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 23:27.
*/
  
Static Function V_RVTela1Vld()

Local lRet := .T.

Begin Sequence

   If Empty(WorkEE8->EE8_FLAG)
      If nQtdeVinc <= 0
         MsgInfo(STR0016, STR0007) //"Qtde de vinculação já atingiu sua totalização !"###"Atenção"
         lRet := .F.
         Break
      EndIf
      
      If !Ap104VldPrc(.t.)
         lRet := .F.
         Break
      EndIf
   EndIf
   

End Sequence

Return(lRet)


/*
Função      : V_RVTela2()
Objetivo    : Apresentar tela de dialogo, para receber o valor de vinculação da R.V.
Retorno     : .T. -> Ok
              .F. -> Cancel
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 21:40
*/
*-------------------------*
Static Function V_RVTela2()
*-------------------------*
Local lRet    := .F.
Local nOpc    := 0
Local bOk     := {|| nOpc := 1, If(V_RVTela2Vld(), oDlg:End(),)}
Local bCancel := {|| nOpc := 2, oDlg:End()}

Local nCont   := 0, nQtdOld

Local oDlg, nQtd := 0, cSeq := "", nRec

Begin Sequence

   For nCont := 1 To WorkEE8->(FCount())
      M->&(WorkEE8->(FieldName(nCont))) := WorkEE8->(FieldGet(nCont))
   Next
   
   IF Empty(WorkEE8->EE8_FLAG)

      // Iniciar o campo qtde com a qtde disponivel ou total do RV.
      nQtdEm1     := Int(Min(M->EE8_SLDATU,nQtdeVinc)/WorkIt->EE8_QE)
      M->EE8_QTDE := nQtdEm1*WorkIt->EE8_QE // Permitir selecionar um nro multiplo pela qtde de embalagem.

      /* JPM - 28/03/06 - Permitir vinculações parciais.
      If !Empty(WorkIt->WK_PREEMB) .And. WorkIt->EE8_SLDATU > M->EE8_QTDE
         MsgInfo(STR0129, STR0007) //"Para itens que já possuem embarque, não será possível vinculação parcial. Escolha um R.V. com saldo maior ou igual à quantidade a vincular do item." ### "Atenção"
         Break
      EndIf
      */
      
      Define MSDialog oDlg Title STR0017 From 00, 00 To 160, 400 Of oMainWnd Pixel //"Definição da quantidade para vinculação."

         @ 013, 002 To 080, 200 Label STR0018 of oDlg Pixel //"Dados da R.V."
      
         @ 024, 007 Say STR0019 Size 80,07 Pixel Of oDlg //"R.V."
         @ 036, 007 Say STR0020 Size 80,07 Pixel Of oDlg //"Data"
         @ 048, 007 Say STR0021 Size 80,07 Pixel Of oDlg //"Saldo"
         @ 060, 007 Say STR0012 Size 80,07 Pixel Of oDlg //"Qtde"
      
         @ 022, 45 MSGet M->EE8_RV     Picture AVSX3("EE8_RV",     AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F. 
         @ 034, 45 MSGet M->EE8_DTRV   Picture AVSX3("EE8_DTRV",   AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.
         @ 047, 45 MSGet M->EE8_SLDATU Picture AVSX3("EE8_SLDATU", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.       
         @ 060, 45 MSGet M->EE8_QTDE   Picture AVSX3("EE8_SLDATU", AV_PICTURE) Size 050, 07 Pixel Of oDlg Valid V_RVTela2Vld("EE8_QTDE")

      Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   Else 
      M->EE8_QTDE := 0
      nOpc := 1
   Endif

   If nOpc = 1
      
      IF M->EE8_QTDE == 0
         WorkEE8->EE8_SLDATU := (WorkEE8->EE8_SLDATU + WorkEE8->EE8_QTDE)
      Else  
         WorkEE8->EE8_SLDATU := ( M->EE8_SLDATU - M->EE8_QTDE ) 
      Endif

      nQtdOld  := WorkEE8->EE8_QTDE

      WorkEE8->EE8_QTDE   := M->EE8_QTDE      
      
      nRec := WorkIt->(RecNo())
      nQtd := 0
      cSeq := WorkIt->EE8_SEQUEN
      WorkIt->(DbSeek(cSeq))
      While WorkIt->(!EoF()) .And. WorkIt->EE8_SEQUEN == cSeq
         nQtd += WorkIt->EE8_SLDINI
         WorkIt->(DbSkip())
      EndDo
      WorkIt->(DbGoTo(nRec))
      
//      WorkEE8->EE8_RATEIO := ( WorkEE8->EE8_QTDE / WorkIt->EE8_SLDINI )
      WorkEE8->EE8_RATEIO := (WorkEE8->EE8_QTDE / nQtd)
      
      If WorkEE8->EE8_QTDE > 0
         WorkEE8->EE8_FLAG   := cMarca
         nQtdeSelect++
      Else   
         WorkEE8->EE8_FLAG   := ""
         nQtdeSelect--
      EndIf     

      IF M->EE8_QTDE == 0
         nQtdeVinc := (nQtdeVinc + nQtdOld) 
      Else
         nQtdeVinc := (nQtdeVinc - M->EE8_QTDE) 
      Endif
      
      oQtdeVinc:Refresh()

      lRet := .T.

   EndIf

End Sequence

Return(lRet)


/*
Função      : V_RVTela2Vld()
Objetivo    : Validação dos dados da V_RVTela2()
Retorno     : .T. -> Dados ok.
              .F. -> Dados incorretos.
Autor       : Alexsander Martins dos Santos
Data e Hora : 12/04/2004 às 23:27.
*/

Static Function V_RVTela2Vld(cCampo)

Local lRet := .T.

Begin Sequence

   If cCampo == "EE8_QTDE" .or. cCampo = Nil

      If M->EE8_QTDE > M->EE8_SLDATU
         MsgInfo(STR0022, STR0007) //"Saldo insuficiente para vinculação. Informe uma quantidade inferior ao Saldo."###"Atenção"
         lRet := .F.
         Break
      EndIf

      If ( WorkEE8->EE8_QTDE + ( M->EE8_QTDE ) ) < 0
         MsgInfo(STR0023, STR0007) //"Não pode haver quantidade negativada !"###"Atenção"
         lRet := .F.
         Break
      EndIf    
      
      // Permitir selecionar um nro multiplo pela qtde de embalagem.
      IF (M->EE8_QTDE % WorkIt->EE8_QE) <> 0
         MsgInfo(STR0024, STR0007) //"Quantidade deve ser multipla pela qtde de embalagem!"###"Atenção"
         lRet := .F.
         Break
      Endif 
   EndIf

   If ( nQtdeVinc - ( M->EE8_QTDE ) ) < 0
      MsgInfo( STR0025, STR0007 ) //"A quantidade informada é superior a Qtde à vicular. Informe uma qtde inferior ou igual a Qtde à vincular."###"Atenção"
      lRet := .F.
      Break
   EndIf

End Sequence

Return(lRet)


/*
Função      : V_RVAtuPed()
Objetivo    : Atualiza pedido com a vinculação da R.V.
Retorno     : .T. -> Dados ok.
              .F. -> Dados incorretos.
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/04/2004 às 03:46.
*/
*--------------------------*
Static Function V_RVAtuPed()
*--------------------------*
Local lRet     := .F.
Local aSaveOrd := SaveOrd("EE8")
Local nCont    := 1
Local nRegAtu  := WorkIt->(RecNo()), nRecEEC := 0
Local nProxSeq := 0
Local cFatIt := "", lNew := .f., cUnPrc

Local nRegNo := 0, nTotLot := 0, nTotQuant := 0, nQuantPed := 0 , cUnid := ""

Local nSldRest := 0, nSumQtd := 0, nSumSld := 0, cSeq, nSldUtilizado := 0, cPreemb := "", nReg1, nReg2, cSeqAux1, cSeqAux2, nSldTot := 0
Local lChangeSequen := .f. // Define se haverá a troca de sequências...

Local nQtdNaoVinc := WorkIt->EE8_SLDINI // Qtde Não Vinculada - deve ser gerado em um registro a parte.
Local nRateio := 0
Local cOrigemComum := "" /* JPM - 27/09/05 - Na quebra de itens, os itens pai, filho, neto, etc. devem ter
                                             a mesma origem, para que o sistema não se perca no estorno   */

Local aRateio := {} // JPM - 28/03/06 - Array para quebrar os itens no embarque.
Local aAtualiza := {}, i

Local cCpoPreco, lAtuUn := .T.//RMD - 15/05/08 - Atualização da unidade de preço do item

Begin Sequence

   //Recuperar a proxima sequencia do item.
   WorkIt->(dbGoBottom())
   nProxSeq := Val(WorkIt->EE8_SEQUEN)
   WorkIt->(dbGoTo(nRegAtu))

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial("EE8")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN))
   
   // JPM - 27/09/05 - para que todos tenham a mesma origem.
   cOrigemComum := EE8->(If(Empty(EE8_ORIGV),EE8_SEQUEN,EE8_ORIGV))
   
   cSeq    := WorkIt->EE8_SEQUEN
   cPreemb := WorkIt->WK_PREEMB
   
   WorkIt->(DbSeek(cSeq))
   While WorkIt->(!EoF()) .And. WorkIt->EE8_SEQUEN == cSeq
      If !Empty(WorkIt->WK_PREEMB)
         nSldUtilizado += WorkIt->EE8_SLDATU
      EndIf
      If WorkIt->(RecNo()) <> nRegAtu
         nSumQtd     += WorkIt->EE8_SLDINI
         nQtdNaoVinc += WorkIt->EE8_SLDINI
         nSumSld     += WorkIt->EE8_SLDATU
         If !(!Empty(cPreemb) .And. Empty(WorkIt->WK_PREEMB))
            If !lChangeSequen .And. cPreemb <> WorkIt->WK_PREEMB
               lChangeSequen := .t.
            EndIf
         EndIf
      EndIf
      WorkIt->(DbSkip())
   EndDo
   
   WorkIt->(dbGoTo(nRegAtu))
   //nSldTot := WorkIt->EE8_SLDATU + nSumSld - nSldUtilizado
   nSldTot := Posicione("EE8",1,xFilial("EE8")+WorkIt->(EE8_PEDIDO+EE8_SEQUEN),"EE8_SLDATU")
   WorkIt->EE8_SLDINI += nSumQtd
   WorkIt->EE8_SLDATU += nSumSld

   nSldRest := WorkIt->EE8_SLDATU - nSldUtilizado
   
   WorkEE8->(dbGoTop())
   
   If !Empty(cPreemb)
      EE9->(DbSetOrder(3))
      EE9->(DbSeek(xFilial()+WorkIt->(WK_PREEMB+WK_SEQEMB)))
   EndIf
   
   While WorkEE8->(!Eof()) .Or. nQtdNaoVinc > 0

      If (WorkEE8->(!Eof()) .And. !Empty(WorkEE8->EE8_FLAG)) .Or. (WorkEE8->(Eof()) .And. nQtdNaoVinc > 0)

         //Atualização do(s) iten(s) do pedido.
         lNew := .f.
         If nCont = 1
            EE8->(RecLock("EE8", .F.))
            lRet := .T.
            nReg1 := EE8->(RecNo())
         Else
            EE8->(RecLock("EE8", .T.))
            AVReplace("WorkIt", "EE8")
            EE8->EE8_SEQUEN := Str(nProxSeq,AVSX3("EE8_SEQUEN",AV_TAMANHO))
            lNew := .t.
         EndIf

         If Empty(EE8->EE8_ORIGV)
            EE8->EE8_ORIGV := cOrigemComum // WorkIt->EE8_SEQUEN - JPM - 27/09/05
			EndIf

         IF WorkEE8->(!Eof())
            nRateio := WorkEE8->EE8_RATEIO 
         Else
            nRateio := Round(nQtdNaoVinc/WorkIt->EE8_SLDINI,15)
         Endif

         EE8->EE8_PSBRTO := (WorkIt->EE8_PSBRTO * nRateio)
         EE8->EE8_PSLQTO := (WorkIt->EE8_PSLQTO * nRateio)
         EE8->EE8_QTDEM1 := (WorkIt->EE8_QTDEM1 * nRateio)
         EE8->EE8_SLDINI := (WorkIt->EE8_SLDINI * nRateio)
//         EE8->EE8_SLDATU := (WorkIt->EE8_SLDATU * nRateio)

         If Empty(cPreemb) // vinculando item sem embarque
            If lChangeSequen
               If nCont = 1
                  EE8->EE8_SLDATU := EE8->EE8_SLDINI
               ElseIf WorkEE8->(EoF())
                  EE8->EE8_SLDATU := nSldTot
               Else
                  EE8->EE8_SLDATU := (WorkIt->EE8_SLDATU * nRateio)
               EndIf
            Else
               EE8->EE8_SLDATU := (WorkIt->EE8_SLDATU * nRateio) // caso normal.
            EndIf
         Else // vinculando item com embarque
            If WorkEE8->(EoF())
               EE8->EE8_SLDATU := nSldRest
               nTotRateio := 0
               For i := 1 To Len(aRateio)
                  nTotRateio += aRateio[i][2]
               Next
               If nTotRateio < 1
                  AAdd(aRateio,{EE8->(RecNo()),1 - nTotRateio, .F. } )
               EndIf
            Else
               EE8->EE8_SLDATU := 0
               AAdd(aRateio,{EE8->(RecNo()),(EE8->(EE8_SLDINI-EE8_SLDATU))/EE9->EE9_SLDINI, WorkEE8->(!EoF()) } )
            EndIf
         EndIf
         
         nSldTot -= EE8->EE8_SLDATU
         
         IF WorkEE8->(!Eof()) 
            nRegNo := EE8->(RecNo())
            
            EE8->EE8_RV     := WorkEE8->EE8_RV
            EE8->EE8_DTRV   := WorkEE8->EE8_DTRV
            EE8->EE8_DTVCRV := dDataBase
            EE8->EE8_DTFIX  := WorkEE8->EE8_DTFIX
            
            // ** JPM - 16/03/06 - Transferir a unidade de medida do preço do R.V. para o item.
            EE8->(DbGoTo(WorkEE8->EE8_RECNO))
            cUnPrc := EE8->EE8_UNPRC
            EE8->(DbGoTo(nRegNo))
            
            aConvTable := Ap104ConvTable()
            If EasyGParam("MV_AVG0154", .T.) .And. !EasyGParam("MV_AVG0154",,.T.) .And. !Empty(cCpoPreco := FindCpoPreco(cUnPrc, EE8->EE8_UNPRC, "EE8"))
                  lAtuUn := .F.
            Else
               cCpoPreco := "EE8_PRECO"
               lAtuUn := .T.
            EndIf

            If lAtuUn
               EE8->EE8_UNPRC  := cUnPrc
            EndIf
            // **
            
            //EE8->EE8_PRECO  := WorkEE8->EE8_PRECO
            EE8->&(cCpoPreco)  := WorkEE8->EE8_PRECO
            EE8->EE8_STFIX  := WorkEE8->EE8_STFIX
            EE8->EE8_MESFIX := WorkEE8->EE8_MESFIX
            EE8->EE8_DIFERE := WorkEE8->EE8_DIFERE
            
            /*
               ER - 20/01/06 às 09:30
               A quantidade de Lotes é calculada através da Expressão: 
               (Quantidade do Pedido / Quantidade Total Vinculada) * Total de Lotes            
            */
            If !EECFlags("BOLSAS")
               //Aponta para o Pedido especial, para receber os Totais de Quantidade Fixada e Qtde de Lotes.
               EE8->(dbGoto(WorkEE8->EE8_RECNO))
               nTotLot   := EE8->EE8_QTDLOT
               nTotQuant := EE8->EE8_SLDINI
               cUnid     := EE8->EE8_UNIDAD
                         
               EE8->(dbGoto(nRegNo))
               nQuantPed := AVTransUnid(EE8->EE8_UNIDAD,cUnid,EE8->EE8_COD_I,EE8->EE8_SLDINI,.F.)
               EE8->EE8_QTDLOT := (nQuantPed / nTotQuant) * nTotLot

            Else // ** JPM - 02/02/06
               EE8->EE8_QTDLOT := Ap104CalcLot(EE8->EE8_SLDINI,EE8->EE8_UNIDAD,EE7->EE7_CODBOL)
            EndIf
            EE8->EE8_DTCOTA := WorkEE8->EE8_DTCOTA
         Else
            nReg2 := EE8->(RecNo())
         Endif

         If Ap104VerPreco() .and. EECFlags("CAFE")
            //EE8->(EE8_PRECO3 := EE8_PRECO)
            //Ap104GatPreco("EE8_PRECO",.t.,"EE8")
            Ap104GatPreco(cCpoPreco,.t.,"EE8")
         EndIf
         
         If lNew .And. IsIntFat() .And. (EE7->(FIELDPOS("EE7_GPV")) = 0 .OR. EE7->EE7_GPV $ cSIM)         
            If Empty(cFatIt)
               SC6->(DbSetOrder(1))
               SC6->(AvSeekLast(xFilial("SC6")+EE7->EE7_PEDFAT))
               cFatIt := SC6->C6_ITEM
            EndIf
            
            cFatIt := SomaIt(cFatIt)
            EE8->EE8_FATIT := cFatIt //ER - 23/11/05 Incrementa o numero do Item no Faturamento.
         EndIf

         EE8->(MSUnlock())
         
         nQtdNaoVinc -= EE8->EE8_SLDINI

         //Atualização dos registros da R.V.
         IF WorkEE8->(!Eof()) 
            EE8->(dbGoto(WorkEE8->EE8_RECNO))

            EE8->(RecLock("EE8", .F.))     
            EE8->EE8_SLDATU := AVTransUnid(WorkIt->EE8_UNIDAD, EE8->EE8_UNIDAD, EE8->EE8_COD_I, WorkEE8->EE8_SLDATU, .F.)
            EE8->(MSUnlock())
         Endif

         nCont++
         nProxSeq++

      EndIf

      WorkEE8->(dbSkip())

   End

   If lRet
      If !Empty(cPreemb) .And. Len(aRateio) > 0 // vincula o R.V. no embarque.
         
         aAtualiza := Ap104QuebraEE9(aRateio,EE9->EE9_PREEMB,EE9->EE9_SEQEMB)
         For i := 1 To Len(aAtualiza)
            If aAtualiza[i][1]
               EE8->(DbGoTo(aAtualiza[i][2]))
               EE9->(DbGoTo(aAtualiza[i][3]))
               EE9->(RecLock("EE9",.F.))
               EE9->EE9_RV     := EE8->EE8_RV
               EE9->EE9_DTRV   := EE8->EE8_DTRV
               EE9->EE9_PRECO  := EE8->EE8_PRECO
               EE9->EE9_UNPRC  := EE8->EE8_UNPRC
               If Ap104VerPreco() .And. EECFlags("CAFE")
                  Ap104GatPreco("EE9_PRECO",.F.,"EE9")
               EndIf
               EE9->(MsUnlock())
            EndIf
         Next
         
         EEC->(DbSetOrder(1))
         EEC->(DbSeek(xFilial()+cPreemb))
         nRecEEC := EEC->(RecNo())
      EndIf

      If lChangeSequen
         // Troca as sequências
         EE8->(DbGoTo(nReg2))
         cSeqAux2 := EE8->EE8_SEQUEN
         
         EE8->(DbGoTo(nReg1))
         cSeqAux1 := EE8->EE8_SEQUEN
         
         EE8->(RecLock("EE8",.F.))
         EE8->EE8_SEQUEN := cSeqAux2
         EE8->(MsUnlock())
         
         EE8->(DbGoTo(nReg2))
         EE8->(RecLock("EE8",.F.))
         EE8->EE8_SEQUEN := cSeqAux1
         EE8->(MsUnlock())
         
         If !Empty(cPreemb)
            Ap104AtuSequen(cSeqAux1,cSeqAux2,cPreemb)
         EndIf
      EndIf

   EndIf

End Sequence

If EasyEntryPoint("EECAP105")
   ExecBlock("EECAP105", .F., .F., "GRVVCRV")
EndIf

If lRet
   AP105CallPrecoI()

   If nRecEEC > 0 // JPM - 02/01/05
      EEC->(DbGoTo(nRecEEC))
      Ae105CallPrecoI() // recalcula os preços.
   EndIf

   // ** JPM - Envia alterações para o faturamento
   Ap105EnviaFat()
   
   MsgInfo(STR0026) //"Vinculação de R.V. realizada com sucesso !"
EndIf

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : AP105E_RV
Objetivo    : Estorno de R.V.
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/04/2004 às 13:22.
*/

Function AP105E_RV()

Local lRet     := .F.
Local lRetWork := .F.

Private cWorkEE8

Begin Sequence

   MSAguarde({|| MSProcTxt(STR0008), lRetWork := E_RVGeraWork()}, STR0027) //"Gerando arquivos temporários ..."###"Estorno de R.V."

   If !lRetWork
      MsgInfo(STR0028, STR0007) //"Não foram encontrados iten(s) com R.V vinculada."###"Atenção"
      Break
   EndIf

   lRet := E_RVTela1()

End Sequence

If Select("WorkEE8") <> 0
   WorkEE8->(dbCloseArea())
   E_EraseArq(cWorkEE8)
EndIf

Return(lRet)


/*
Função      : E_RVGeraWork()
Objetivo    : Geração de Work para estorno de R.V.
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/04/2004 às 16:25.
*/

Static Function E_RVGeraWork()

Local lRet      := .F.
Local aSaveOrd  := SaveOrd("EE8")

Local aWorkEE8  := {{"EE8_SEQUEN", "C", AVSX3("EE8_SEQUEN", AV_TAMANHO), 00},;
                    {"EE8_VM_DES", "C", AVSX3("EE8_VM_DES", AV_TAMANHO)-10, 00},;
                    {"EE8_SLDATU", "N", AVSX3("EE8_SLDATU", AV_TAMANHO), AVSX3("EE8_SLDATU", AV_DECIMAL)},;
                    {"EE8_SLDINI", "N", AVSX3("EE8_SLDINI", AV_TAMANHO), AVSX3("EE8_SLDINI", AV_DECIMAL)},;
			        {"EE8_RV",     "C", AVSX3("EE8_RV",     AV_TAMANHO), 00},;
				    {"EE8_DTRV",   "D", AVSX3("EE8_DTRV",   AV_TAMANHO), 00},;
				    {"EE8_DTVCRV", "D", AVSX3("EE8_DTVCRV", AV_TAMANHO), 00},;
				    {"EE8_PRECO",  "N", AVSX3("EE8_PRECO",  AV_TAMANHO), AVSX3("EE8_PRECO", AV_DECIMAL)},;
				    {"EE8_DTFIX" , "D", AVSX3("EE8_DTFIX" , AV_TAMANHO), 00},;
				    {"EE8_ORIGV" , "C", AVSX3("EE8_ORIGV" , AV_TAMANHO), 00},;
				    {"EE8_SEQ_RV", "C", AVSX3("EE8_SEQ_RV", AV_TAMANHO), 00},;
				    {"EE8_UNIDAD", "C", AVSX3("EE8_UNIDAD", AV_TAMANHO), 00},;
			        {"EE8_FLAG",   "C", 02, 		  		             00},;
			        {"EE8_RECNO",  "N", 07,                              00}}

Private aCampos := {}

cWorkEE8 := E_CriaTrab(, aWorkEE8, "WorkEE8")

Begin Sequence

   EE8->(dbSetOrder(1))
   EE8->(dbSeek(xFilial("EE8")+EE7->EE7_PEDIDO))
   
   While EE8->(!Eof() .and. EE8_FILIAL == xFilial("EE8") .and. EE8_PEDIDO == EE7->EE7_PEDIDO)

      If !Empty(EE8->EE8_DTVCRV)
         WorkEE8->(dbAppend())
         WorkEE8->EE8_SEQUEN  := EE8->EE8_SEQUEN
         WorkEE8->EE8_VM_DES  := EasyMSMM(EE8->EE8_DESC, AVSX3("EE8_VM_DES", AV_TAMANHO),,, ,,, "EE8","EE8_DESC")   //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
         WorkEE8->EE8_SLDATU  := EE8->EE8_SLDATU
         WorkEE8->EE8_SLDINI  := EE8->EE8_SLDINI
         WorkEE8->EE8_RV      := EE8->EE8_RV
         WorkEE8->EE8_DTRV    := EE8->EE8_DTRV
         WorkEE8->EE8_DTVCRV  := EE8->EE8_DTVCRV
         WorkEE8->EE8_ORIGV   := EE8->EE8_ORIGV 
         WorkEE8->EE8_SEQ_RV  := EE8->EE8_SEQ_RV
         WorkEE8->EE8_UNIDAD  := EE8->EE8_UNIDAD
         WorkEE8->EE8_PRECO   := EE8->EE8_PRECO
         WorkEE8->EE8_DTFIX   := EE8->EE8_DTFIX
         WorkEE8->EE8_RECNO   := EE8->(RecNo())
      EndIf

      EE8->(dbSkip())

   End

   If !(lRet := WorkEE8->(EasyRecCount()) > 0)
      WorkEE8->(dbCloseArea())
      E_EraseArq(cWorkEE8)
   EndIf

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : E_RVTela1()
Objetivo    : Tela para seleção de itens p/ estorno de R.V.
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/04/2004 às 13:22.
*/

Static Function E_RVTela1()

Local oDlg

Local lRet          := .F.
Local lRetAtuPed    := .F.
Local lInverte      := .F.

Local nOpc          := 0
Local bOk           := {|| If(E_RVTela1Vld(), (nOpc := 1,oDlg:End()),), }
Local bCancel       := {|| nOpc := 2, oDlg:End()}

Local aSelectFields := { {"EE8_FLAG","XX",""},;
                         ColBrw("EE8_SEQUEN", "WorkEE8"),;
                         {{|| MemoLine(WorkEE8->EE8_VM_DES, 60, 1)},"",AVSX3("EE8_VM_DES",AV_TITULO)},;
                         ColBrw("EE8_SLDATU", "WorkEE8"),;
                         ColBrw("EE8_RV",     "WorkEE8"),;
                         ColBrw("EE8_DTRV",   "WorkEE8"),;
                         ColBrw("EE8_DTVCRV", "WorkEE8"),;
                         {{|| Transf(WorkEE8->EE8_PRECO, EECPreco("EE8_PRECO", AV_PICTURE))}, "", AVSX3("EE8_PRECO", AV_TITULO)},;
                         ColBrw("EE8_DTFIX",  "WorkEE8") }
                        //ColBrw("EE8_PRECO",  "WorkEE8"),;

Private oMsSelect
Private cMarca      := GetMark()
Private aHeader     := {}
Private nContMark   := 0

Begin Sequence

   Define MSDialog oDlg Title STR0027 From 00, 00 To 471, 650 Of oMainWnd Pixel //"Estorno de R.V."

      @ 015, 003 To 048, 324 Label STR0029 of oDlg Pixel //"Dados do Pedido"

      @ 028, 008 Say STR0030 Size 80, 07 Pixel Of oDlg //"Pedido"
      @ 026,  40 MSGet EE7->EE7_PEDIDO Picture AVSX3("EE7_PEDIDO", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.

      @ 028, 240 Say STR0020   Size 80, 07 Pixel Of oDlg //"Data"
      @ 026, 260 MSGet EE7->EE7_DTPROC Picture AVSX3("EE7_DTPROC", AV_PICTURE) Size 050, 07 Pixel Of oDlg When .F.

      @ 050, 003 To 233, 324 Label STR0031 of oDlg Pixel //"Itens com R.V. vinculada."

      aPos := {57, 06, 230, 321}

      WorkEE8->(dbGoTop())

      oMark       := MsSelect():New("WorkEE8", "EE8_FLAG",, aSelectFields, @lInverte, @cMarca, aPos)
      oMark:bAval := {|| WorkEE8->(EE8_FLAG := If(Empty(EE8_FLAG), Eval({|| If( E_ValidEstorno(),(nContMark++, cMarca),"") }), Eval({|| nContMark--, ""})))}

   Activate MSDialog oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) Centered

   If nOpc = 1
      Begin Transaction
         Processa({|| lRetAtuPed := E_RVAtuPed(), STR0033, STR0032, .F.}) //"Aguarde"###"Estornando Fixação de Preço"
      End Transaction
   EndIf

   If lRetAtuPed
      MsgInfo(STR0034) //"Estorno de vinculação de R.V(s), realizado com sucesso."
      lRet := .T.
   EndIf              

End Sequence

Return(lRet)
  
/*
Função      : E_ValidEstorno()
Objetivos   : Validar se o item poderá ter sua vinculação de R.V. Estornada, no momento da seleção
Parâmetros  : Nenhum
Retorno     : .T./.F.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 07/12/05 às 11:23
*/
*------------------------------*
Static Function E_ValidEstorno()
*------------------------------*
Local lRet := .T.
Local aFil, i

Begin Sequence

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial()+EE7->EE7_PEDIDO+WorkEE8->EE8_SEQUEN))
   
   /* JPM - 29/03/06 - Permitir estorno de item que tenha embarque.
   Posicione("EE9",1,xFilial("EE9")+EE7->EE7_PEDIDO+WorkEE8->EE8_SEQUEN,"EE9_SEQUEN")
   If EE9->(!EoF())
      MsgInfo(STR0128 + STR0127, STR0007) //"Este item possui embarque, " + "portanto não poderá ter sua vinculação de R.V. estornada."###"Atenção"
      lRet := .F.
      Break
   EndIf
   */
   
   If IsIntFat()
      aFil := Ap101RetFil()
      For i := 1 To Len(aFil)
         Posicione("SD2",8,aFil[i]+EE7->EE7_PEDFAT+EE8->EE8_FATIT,"D2_ITEMPV")
         If SD2->(!EoF())
            //MsgInfo(STR0126 + STR0127, STR0007) //"Este item já possui nota fiscal no Faturamento, " + "portanto não poderá ter sua vinculação de R.V. estornada."###"Atenção"
            lRet := .F.
            Break
         EndIf
      Next
   EndIf
   
End Sequence

Return lRet

/*
Função      : E_RVTela1Vld()
Objetivo    : Validação para E_RVTela1().
Autor       : Alexsander Martins dos Santos
Data e Hora : 13/04/2004 às 13:22.
*/

Static Function E_RVTela1Vld()

Local lRet := .T.
Local aItens := {}, i, j, nPos, aVerified := {}, aCheck := {}, nCheck

Begin Sequence

   If nContMark = 0
      MsgInfo( STR0035, STR0007 ) //"Deve ser selecionado no minimo 1 item para estorno !"###"Atenção"
      lRet := .F.
      Break
   EndIf
   
   // ** JPM - 31/03/06 - Verifica se os itens poderão ser agrupados
   WorkEE8->(DbGoTop())
   While WorkEE8->(!EoF()) // levanta os itens marcados para estorno
      If !Empty(WorkEE8->EE8_FLAG)
         AAdd(aItens,{WorkEE8->EE8_RECNO,WorkEE8->EE8_ORIGV})
      EndIf
      WorkEE8->(DbSkip())
   EndDo
   WorkEE8->(DbGoTop())
   
   EE8->(DbSetOrder(1)) // levanta os itens da base que podem ser agrupados
   EE8->(DbSeek(xFilial()+EE7->EE7_PEDIDO))
   While EE8->(!EoF() .And. EE8_FILIAL+EE8_PEDIDO == xFilial()+EE7->EE7_PEDIDO)
      If Empty(EE8->EE8_DTVCRV) .And. !Empty(EE8->EE8_ORIGV) .And. AScan(aItens,{|x| x[1] == EE8->(RecNo())}) = 0
         EE8->(AAdd(aItens,{RecNo(),EE8->EE8_ORIGV}))
      EndIf
      EE8->(DbSkip())
   EndDo
   
   aSort(aItens,,, { |x, y| x[2] < y[2] }) // ordena por ORIGV
   For i := 1 To Len(aItens)
      If AScan(aVerified,i) = 0 // se já foi verificado, desconsidera.
         nPos := AScan(aItens,{|x| x[2] == aItens[i][2] .And. x[1] <> aItens[i][1]}) // procura outro(s) item(ns) com a mesma origem
         If nPos > 0 //se achou, adiciona no aCheck  
            AAdd(aCheck,{aItens[i][1]})
            nCheck := Len(aCheck)
            For j := nPos To Len(aItens)
               If aItens[j][2] <> aItens[i][2]
                  Loop
               EndIf
               AAdd(aCheck[nCheck],aItens[j][1])
               AAdd(aVerified,j)
            Next
         EndIf
      EndIf
   Next

   For i := 1 To Len(aCheck) // Verifica cada um dos possíveis agrupamentos.
      If !Ap104CanJoin(aCheck[i],.T.)
         lRet := .F.
         Break
      EndIf
   Next
   // ** JPM
   
End Sequence

Return(lRet)


/*
Função      : E_RVAtuPed()
Objetivo    : Atualiza pedido com o estorno da vinculação de R.V.
Retorno     : .T. -> Iten(s) estornado(s).
              .F. -> Não houve estorno do(s) iten(s).
Autor       : Alexsander Martins dos Santos
Data e Hora : 14/04/2004 às 15:46.
*/

Static Function E_RVAtuPed()

Local lRet      := .F., nQtd, nRec
Local aSaveOrd := SaveOrd({"EEY", "EE8"})
Local aItDelete := {}

EE8->(dbSetOrder(1))
EE9->(dbSetOrder(1))
EEY->(dbSetOrder(1))

Begin Sequence

   ProcRegua(nContMark)

   WorkEE8->(dbGoTop())

   While WorkEE8->(!Eof())

      If !Empty(WorkEE8->EE8_FLAG)
      
         IncProc()

         If EEY->(dbSeek(xFilial("EEY")+WorkEE8->EE8_RV)) //Base do R.V.

            If EE8->(dbSeek(xFilial("EE8")+EEY->EEY_PEDIDO)) //Origem da R.V.
            
               nQtd := AVTransUnid(WorkEE8->EE8_UNIDAD, EE8->EE8_UNIDAD,, WorkEE8->EE8_SLDINI, .F.)
               While EE8->(!Eof() .And. EE8_FILIAL == xFilial("EE8")) .And.;
                     EE8->EE8_PEDIDO == EEY->EEY_PEDIDO
               
                  IF EE8->EE8_RV <> EEY->EEY_NUMRV .And. EE8->EE8_PRECO == WorkEE8->EE8_PRECO .And. EE8->EE8_DTFIX == WorkEE8->EE8_DTFIX
                     EE8->(dbSkip())
                     Loop
                  Endif      
                  nRec := EE8->(RecNo())
                  If EE8->EE8_SLDATU + nQtd <= EE8->EE8_SLDINI
                     RecLock("EE8", .F.)
                     EE8->EE8_SLDATU += nQtd
                     nQtd := 0
                     EE8->(MSUnLock())
                  EndIf

                  If EE8->(dbSeek(xFilial("EE8")+EE7->EE7_PEDIDO+WorkEE8->EE8_SEQUEN)) //Destino da R.V.

                     RecLock("EE8", .F.)
                     EE8->EE8_RV     := ""
                     EE8->EE8_SEQ_RV := ""
                     EE8->EE8_DTRV   := Ctod("")
                     EE8->EE8_DTVCRV := Ctod("")
                  
                     AP105ClearFix()
                     
                     // Limpa dados dos embarques correspondentes.
                     EE9->(DbSeek(xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN)))
                     While EE9->(!EoF() .And. xFilial()  + EE8->(EE8_PEDIDO+EE8_SEQUEN) == ;
                                              EE9_FILIAL +       EE9_PEDIDO+EE9_SEQUEN)
                        EE9->(RecLock("EE9",.F.),;
                              EE9_RV   := "",;
                              EE9_DTRV := CToD(""),;
                              MsUnlock())
                        EE9->(DbSkip())
                     EndDo
                     
                     /*
                     EE8->EE8_DTFIX  := Ctod("")
                     EE8->EE8_PRECO  := 0
                     EE8->EE8_STFIX  := ""
                     EE8->EE8_MESFIX := ""
                     EE8->EE8_DIFERE := 0
                     EE8->EE8_QTDLOT := 0
                     EE8->EE8_DTCOTA := Ctod("")
                     */
                     EE8->(MSUnLock())
                     Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                                  aCopy(y, x,,, Len(x)-Len(y)+1 )}, aItDelete, AgruparItens(EE7->EE7_PEDIDO, WorkEE8->EE8_ORIGV, {|| Empty(EE8_DTVCRV)}, .f.))
                                  
                  EndIf
                  
                  lRet := .T.

                  If nQtd = 0
                     Exit
                  Else
                     EE8->(DbGoTo(nRec))
                     EE8->(dbSkip())
                  EndIf

               End

            EndIf        

         EndIf

      EndIf

      WorkEE8->(dbSkip())

   End
   
   //ER - Ponto de Entrada
   If EasyEntryPoint("EECAP104")
         ExecBlock("EECAP104", .F., .F., "ESTRV")
   EndIf
   Ap105CallPrecoI()

   // ** JPM - Envia alterações para o faturamento
   Ap105EnviaFat(aItDelete)

End Sequence

RestOrd(aSaveOrd)

Return(lRet)


/*
Função      : AP100RVFixPrice()
Objetivo    : Fixação de preço do pedido especial para R.V. desvinculado.
Parametro   : nQtdeFix -> Qtde de Fixação.
Retorno     : .T. -> Fixado.
            : .F. -> Não fixado.
Autor       : Alexsander Martins dos Santos
Data e Hora : 16/04/2004 às 11:44.
*/

Function AP100RVFixPrice(nPrcFix)

Local lRet       := .F.
Local aSaveOrd   := SaveOrd({"EEY", "EE8"})
Local nRecEE8 := 0
Local nQtdFix := 0, cUM := EE8->EE8_UNIDAD, nQtd := EE8->EE8_SLDINI

Local nQtdLot := EE8->EE8_QTDLOT,;
      cMesAno := EE8->EE8_MESFIX,;
      dDtFix  := EE8->EE8_DTFIX,;
      dDtCot  := EE8->EE8_DTCOTA,;
      nDif    := EE8->EE8_DIFERE,;
      cCod_I  := EE8->EE8_COD_I

Begin Sequence

   EEY->(dbSetOrder(1))
   EEY->(dbSeek(xFilial("EEY")+EE8->EE8_RV))

   If Left(EEY->EEY_PEDIDO, 1) = "*"

      EE8->(dbSetOrder(1))
      EE8->(dbSeek(xFilial("EE8")+EEY->EEY_PEDIDO))  //Origem (Pedido especial para R.V. desvinculada).

      //Rotina para gerar a ultima sequencia do item do pedido.            
      While EE8->(!Eof() .and. EE8_FILIAL == xFilial("EE8") .and. EE8_PEDIDO == EEY->EEY_PEDIDO)
         IF EE8->EE8_RV == EEY->EEY_NUMRV .And. Empty(EE8->EE8_DTFIX)
            nRecEE8 := EE8->(Recno())
            Exit
         Endif
         EE8->(dbSkip())
      End
      
      IF Empty(nRecEE8)
         Break
      Endif
      
      EE8->(dbGoto(nRecEE8))
      //Fim da rotina.

      nQtdFix := AVTransUnid(cUM, EE8->EE8_UNIDAD, cCod_I, nQtd, .F.)
      AP105FixItem(EE8->EE8_PEDIDO, EE8->EE8_SEQUEN, nQtdFix, nQtdLot, nPrcFix, cMesAno, dDtFix, dDtCot, nDif, .f.)// JPM - .f. - Não atualiza RV de novo

   EndIf

End Sequence

EE8->(dbGoto(nRecEE8))

RestOrd(aSaveOrd)

Return(lRet)


/*
Função AP104ItemEmb
Objetivo    : Verifica se o item está embarcado e retorna a posição do embarque.
Parametro   : cPedido    = Código do pedido.
              cSequencia = Sequencia do item no pedido.
              nRetorno   = Indica o que deve retornar. Opções 1(Status) e 2(Qtde) de embarques.
Retorno     : 1(Status) 
              ... 0 = Item não embarcado.
              ... 1 = Item em processo de embarque.
              ... 2 = Item em embarque finalizado.
              2(Qtde)
              ... ? = Qtde de embarques que o item está envolvido.
Autor       : Alexsander Martins dos Santos
Data e Hora : 03/08/2004 às 11:11.
*/

Function AP104ItemEmb(cPedido, cSequencia, nRetorno)

Local nRet     := 0
Local aSaveOrd := SaveOrd({"EE9", "EEC"})
Local nQtdeEmb := 0

Default nRetorno := 1

EE9->(dbSetOrder(1))
EEC->(dbSetOrder(1))

Begin Sequence

   If EE9->(dbSeek(xFilial()+cPedido+cSequencia))
      
      While EE9->(!Eof() .and. EE9_FILIAL == xFilial() .and. EE9_PEDIDO = cPedido .and. EE9_SEQUEN = cSequencia)
        
         EEC->(dbSeek(xFilial()+EE9->EE9_PREEMB))

         If !Empty(EEC->EEC_DTEMBA)
            nRet := 2
            If nRetorno = 1
               Break
            EndIf
         Else
            nQtdeEmb++
         EndIf

         nRet := 1

         EE9->(dbSkip())
   
      End
   
   EndIf

   If nRetorno = 2
      nRet := nQtdeEmb
   EndIf  

End Sequence

RestOrd(aSaveOrd, .T.)

Return(nRet)


/*
Função     : AP104SLDEMB
Objetivo   : Atualizar a qtde. à embarcar, através da qtde. de item do pedido.
Parametros : nVlToAtu - Valor a ser atualizado.
             cPedido  - Código do pedido.
             cSequencia - Sequencia do item.
Retorno    : .T. = Atualização efetuada.
             .F. = Atualização não efetuada.
Autor      : Alexsander Martins dos Santos
Data e Hora: 03/08/2004 às 15:48.
*/

Function AP104SLDEMB(nVlToAtu, cPedido, cSequencia)

Local oDlg, oFont, objListBox, oButtonOk, oButtonCancel
Local aListBox := {{}, {}}, aSaveOrd := SaveOrd({"EEC","EE9"})
Local cListBox := "", cMsg := "", cMsgOffShore := ""
Local nButton  := 0, nDiferenca := 0, nHight := 0, i//RMD - 05/03/17
Local lRet     := .f.
Local bOk      := {|| nButton := 1,;
                      If(SLDEMBVLD(aListBox[2][aScan(aListBox[1], cListBox)], nDiferenca),;
                      oDlg:End(),)}

Begin Sequence

   /* by jbj - Caso o ambiente tenha os tratamentos de off-shore habilitados, a atualização será 
               realizada apenas para as alteração efetuadas na filial brasil. */

   If lIntermed .And. AvGetM0Fil() <> cFilBr .Or. nVlToAtu == 0
      Break
   EndIf

   /* Apura a diferença considerando os valores alterados pelo usuário. */
   //nDiferenca := (nNewValor - nOldValor)

   /* by jbj - Realiza o levantamento dos processos onde a atualização da quantidade deverá ser 
               replicada. */
   EEC->(DbSetOrder(1))
   EE9->(DbSetOrder(1))

   EE9->(dbSeek(xFilial("EE9")+AvKey(cPedido,"EE9_PEDIDO")+AvKey(cSequencia,"EE9_SEQUEN")))

   Do While EE9->(!Eof()) .and. EE9->EE9_FILIAL == xFilial("EE9") .And.;
                                EE9->EE9_PEDIDO == AvKey(cPedido,"EE9_PEDIDO") .And.;
                                EE9->EE9_SEQUEN == AvKey(cSequencia,"EE9_SEQUEN")

      /* Disponibiliza para atualização apenas os itens que não possuirem
         notas fiscais. */

      If !Empty(EE9->EE9_NF)
         EE9->(dbSkip())
         Loop
      EndIf

      If EEC->(DbSeek(xFilial("EEC")+EE9->EE9_PREEMB))

         /* Para processos embarcados ou cancelados o sistema não disponibiliza o mesmo
            para replicação das alterações. */

         If !Empty(EEC->EEC_DTEMBA) .Or. EEC->EEC_STATUS = ST_PC
            EE9->(dbSkip())
            Loop
         EndIf
      EndIf
      
      
      //RMD - 21/06/06
      //Não disponibilizar os embarques de Venda por Consignação, visto que os mesmos SEMPRE possuem vinculação com remessas.
      If EECFlags("CONSIGNACAO") .And. EEC->EEC_TIPO $ PC_VR+PC_VB
         EE9->(dbSkip())
         Loop
      EndIf
      //Não disponibilizar os embarques que possuirem Invoices cadastradas, visto que a quantidade total 
      //do embarque SEMPRE possui vinculação com invoices.
      If EECFlags("INVOICE")
         EXP->(DbSetOrder(1))
         If EXP->(DbSeek(xFilial()+EEC->EEC_PREEMB))
            EE9->(dbSkip())
            Loop
         EndIf
      EndIf
      
      
      If EE9->EE9_SLDINI <= Abs(nVlToAtu) // Só disponibiliza itens com quantidade maior que a quantidade a ser atualizada.
         EE9->(dbSkip())
         Loop
      EndIf

      // Adiciona o item ao listbox para visualização e escolha do usuário.
      aAdd(aListBox[1], AllTrim(Transf(EE9->EE9_PREEMB, AvSx3("EE9_PREEM",AV_PICTURE)))+;
                        STR0087+; //", qtde. "
                        AllTrim(Transform(EE9->EE9_SLDINI, AvSx3("EE9_SLDINI", AV_PICTURE)))+Space(1)+;
                        AllTrim(EE9->EE9_UNIDAD))
      
      aAdd(aListBox[2], EE9->(Recno()))

      EE9->(dbSkip())
   EndDo

   If Len(aListBox[1]) = 0
      MsgStop(STR0106+ENTER+; //"Quantidade inválida."
              STR0107,STR0108) //"Não existe nenhum item não embarcado ou que possua disponível a quantidade a ser abatida."###"Atenção"
      lRet := .f.
      Break
   EndIf

   cMsg += STR0089+AllTrim(Str(Len(aListBox[1])))+STR0090 +; //"O item está envolvido em "###" embarque(s), a alteração "
           STR0091 + ENTER +; //"feita na qtde, deverá atualizar um dos embarques "
           STR0092 + AllTrim(Transform(nVlToAtu, AVSX3("EE8_SLDINI", AV_PICTURE))) + "." +; //"envolvidos, com a qtde de "
           Replicate(ENTER, 2)

   /*
   cMsg += STR0093 + Transform(nOldValor,  AVSX3("EE8_SLDINI", AV_PICTURE)) + ENTER +; //"Qtde. anterior   : "
           STR0094 + Transform(nNewValor,  AVSX3("EE8_SLDINI", AV_PICTURE)) + Replicate(ENTER, 2) //"Qtde. atualizada : "
   */
   
   cMsg += STR0095 //"Selecione o embarque a ser atualizado e confirme."

   Define Font oFont Name "Courier New" Size 0,-12

   Do Case
      Case lIntermed .And. M->EE7_INTERM $ cSim 
           nHight := 28
      Case (lIntermed .And. M->EE7_INTERM $ cNao) .Or. (!lIntermed)
           nHight := 24
   EndCase

   If Type("lEE7Auto") <> "L" .Or. !lEE7Auto//RMD - 05/03/17 - Verifica se é execauto antes de mostrar a tela
   Define MSDialog oDlg Title STR0096 From 7, 3 To nHight, 75 Of oMainWnd //"Atualização da qtde. entre Pedido e Embarque"

      oDlg:lEscClose := .F.

      @ 05.0, 05.0 Say cMsg Pixel Size 500, 200
      @ 60.0, 05.0 To 103, 280 Label STR0097 of oDlg Pixel //"Embarque(s)"

      @ 04.8, 01.0 ListBox objListBox ;
                   Var     cListBox   ;
                   Items   aListBox[1];
                   Size    269, 32    ;
                   Of oDlg Font oFont

      objListBox:bChange := {|| oButtonOK:lActive := .T., oButtonOK:Refresh()}

      Do Case
         Case lIntermed .And. M->EE7_INTERM $ cSim

              /* Para os  ambientes em  que a  rotina de intermediação  estiver habilitada,
                 o sistema irá exibir msg para indicar ao usuário que a filial de off-shore
                 será habilitada. */

              cMsgOffShore := STR0099+ENTER+; //"Para o(s) embarque(s) com tratamentos de intermediação, o sistema irá replicar a alteração em todos os"
                              STR0100 //"níveis de off-shore existentes para o(s) processo(s)."

              @ 110.0, 05.0 To 140, 280 Label STR0101 of oDlg Pixel //"Processo(s) de Off-Shore"
              @ 118.0, 10.0 Say cMsgOffShore Pixel Size 500, 200

              Define SButton oButtonOK     From 145, 05 Type 1 Action (Eval(bOk)) Disable of oDlg Pixel
              Define SButton oButtonCancel From 145, 35 Type 2 Action (nButton := 0, oDlg:End()) Enable of oDlg Pixel
       
         Case (lIntermed .And. M->EE7_INTERM $ cNao) .Or. (!lIntermed)
         
              Define SButton oButtonOK     From 112, 05 Type 1 Action (Eval(bOk)) Disable of oDlg Pixel
              Define SButton oButtonCancel From 112, 35 Type 2 Action (nButton := 0, oDlg:End()) Enable of oDlg Pixel
      EndCase

   Activate MSDialog oDlg Centered
   Else
      //RMD - 05/03/17 - Marca o primeiro embarque que tiver saldo disponível.
      For i := 1 To Len(aListBox[2])
         If SLDEMBVLD(aListBox[2][i], nDiferenca)
            cListBox := aListBox[1][i]
            nButton := 1
            Exit
         EndIf
      Next
      If nButton <> 1
         EasyHelp(STR0166, STR0004) //"Não será possível alterar a quantidade do item pois todo o saldo já foi embarcado."###"Aviso"
      EndIf
   EndIf

   If nButton == 1 // Bt. Ok
      M->WP_EE9REG  := aListBox[2][aScan(aListBox[1], cListBox)] // Recno
      M->WP_EE9SLD  := nVlToAtu // nDiferenca
      lRet := .t.

   //Else // Bt. Cancel

      
   //   If nNewValor > nOldValor
         /* Neste caso o usuário aumentou a quantidade do item, dessa maneira ele não é obrigado a 
            selecionar um embarque para replicação da alteração na quantidade. */
   //      lRet := .t.
   //   Else
         /* Neste caso o usuário diminuiu a quantidade do item, dessa maneira o usuário será obrigado
            a escolher um processo de embarque apenas se o item não possuir saldo suficiente para abatimento */

   //      If (M->EE8_SLDATU + nDiferenca >= 0)
   //         lRet := .t.
   //      EndIf
   //   EndIf
   EndIf

   If lRet
      M->EE8_SLDATU += nDiferenca
   EndIf

End Sequence

RestOrd(aSaveOrd,.t.)

Return(lRet)

/*
Função     : SLDEMBVLD
Objetivo   : Validar a atualização na qtde. dos iten(s) do embarque.
Paremetro  : nEE9Reg
Retorno    : .T. = .
             .F. = .
Autor      : Alexsander Martins dos Santos
Data e Hora: 03/08/2004 às 15:48.
*/

Static Function SLDEMBVLD(nEE9Reg, nDiferenca)

Local lRet := .F.

Begin Sequence

   EE9->(dbGoTo(nEE9Reg))

   If EE9->EE9_SLDINI + nDiferenca < 1
      MsgStop(STR0098, STR0007) //"O embarque selecionado não possui saldo suficiente para ser abatido."###"Atenção"
      Break
   EndIf

   lRet := .T.

End Sequence

Return(lRet)

/*
Funcao      : Ap104CanCancel.
Parametros  : cFase - Pedido/Embarque.
              lExibeMsg - Se irá exibir mensagens(.T./.F.).
Retorno     : .t./.f.
Objetivos   : Com a rotina de off-shore habilitada, as operações de cancelamento e eliminação são automaticamente
              replicadas na filial de intermediação e vice-versa. Esta rotina valida a operação, verificando se na
              filial oposta a logada, o processo poderá ser cancelado/eliminado.
Autor       : Jeferson Barros Jr.
Data/Hora   : 20/07/04 11:54.
Revisao     : Nenhuma.
Obs.        : Esta função é executada a partir das rotina de pedido e embarque.
*/
*-------------------------------------------------*
Function Ap104CanCancel(cFase,lExibeMsg,lCanCancel)
*-------------------------------------------------*
Local lRet:=.t., aOrd:=SaveOrd({"EE7","EE8","EEC","EE9","EEQ"})
Local cFil
Local lIsFilBr, cMsg, j:=0, lTemEmbarque := .f., dDtEmba, cPictData := "  /  /  "
Local aEmbarques :={} /* Por dimensão: aEmbarques [1][1] = Nro. Item.
                                                  [1][2] = Cod. Item.
                                                  [1][3] = Desc. Resumida do Item.
                                                  [1][4] = Nro do Embarque.
                                                  [1][5] = Quantidade Embarcada. */

Local aAdiantamentos := {} /* Por dimensão: aAdiantamentos [1][1] = Nro. da Parcela.
                                                           [1][2] = Dt. Adiantamento.
                                                           [1][3] = Valor do Adiantamento. */

Local aRvs := {} /* Por dimensão: [1][1] = Nro. Item.
                                  [1][2] = Cod. Item.
                                  [1][3] = Desc. Resumida do Item.
                                  [1][4] = Nro. do RV. */

Local aRes := {} /* Por dimensão: [1][1] = Nro. Item.
                                  [1][2] = Cod. Item.
                                  [1][3] = Desc. Resumida do Item.
                                  [1][4] = Dt.Re.
                                  [1][5] = Nro.Re.*/

Default cFase      := OC_PE
Default lExibeMsg  := .T.
Default lCanCancel := .f.

Begin Sequence

   lIsFilBr := (AvGetM0Fil() == cFilBr)
   cFil     := If(lIsFilBr,cFilEx,cFilBr)
   cFase    := AllTrim(Upper(cFase))

   Do Case
      Case cFase == OC_PE // Fase Pedido

         // JPM - 06/12/05 - Validações para exclusão - as mesmas validações feitas na exclusão normal
         If !Ap100CanCancel(cFil)
            lRet := .f.
            Break
         EndIf
         
         /* Para a fase de pedido valem as seguintes regras (considerando a filial oposta):
            1) São considerados apenas os processos com tratamentos de off-shore (EE7_INTERM = Sim);
            2) O processo não pode estar envonvido em processo de embarque;
            3) O processo não pode conter lançamentos de adiantamentos vinculados;
            4) O processo não pode conter itens com RV (Registro de venda). (Somente para a Fil. Brasil). */

         EE7->(DbSetOrder(1))
         EE8->(DbSetOrder(1))
         EE9->(DbSetOrder(1))

         If lIsFilBr
            If !(EE7->EE7_INTERM $ cSim)
               Break
            EndIf
         Else
            If EE7->(DbSeek(cFilBr+EE7->EE7_PEDIDO))
               If !(EE7->EE7_INTERM $ cSim)
                  Break
               EndIf
            EndIf
         EndIf

         If EE7->(DbSeek(cFil+EE7->EE7_PEDIDO))

            /* Verifica se o processo possui algum adiantamento vinculado.
               Fase de Pedido */
            If lPagtoAnte
               EEQ->(DbSetOrder(6))
               If EEQ->(DbSeek(cFil+"P"+EE7->EE7_PEDIDO))
                  Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == cFil .And.;
                                               EEQ->EEQ_FASE   == "P"  .And.;
                                               EEQ->EEQ_PREEMB == EE7->EE7_PEDIDO
                     If EEQ->EEQ_TIPO == "A"
                        aAdd(aAdiantamentos,{EEQ->EEQ_PARC,EEQ->EEQ_DTCE,EEQ->EEQ_VL})
                     EndIf

                     EEQ->(DbSkip())
                  EndDo
               EndIf
            EndIf

            /* Verifica se o processo tem algum item envolvido em processo 
               de embarque */
               
            If EE8->(DbSeek(cFil+EE7->EE7_PEDIDO))
               Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFil .And.;
                                            EE8->EE8_PEDIDO == EE7->EE7_PEDIDO

                  If !lIsFilBr // A filial logada não é a brasil porém os dados validados serão todos do brasil.
                     If EE8->(FieldPos("EE8_RV")) > 0
                        If !Empty(EE8->EE8_RV)
                           aAdd(aRvs,{EE8->EE8_SEQUEN,;
                                      EE8->EE8_COD_I ,;
                                      MemoLine(EasyMsmm(EE8->EE8_DESC,Avsx3("EE8_VM_DES",AV_TAMANHO),,, ,,, "EE8","EE8_DESC"),30,1),;
                                      EE8->EE8_RV})
                        EndIf
                     Endif
                  EndIf

                  If (EE8->EE8_SLDINI == EE8->EE8_SLDATU)
                     EE8->(DbSkip())
                     Loop
                  EndIf

                  If EE9->(DbSeek(cFil+EE7->EE7_PEDIDO+EE8->EE8_SEQUEN))
                     Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFil .And.;
                                                  EE9->EE9_PEDIDO == EE7->EE7_PEDIDO .And.;
                                                  EE9->EE9_SEQUEN == EE8->EE8_SEQUEN
                     
                        aAdd(aEmbarques,{EE8->EE8_SEQUEN,;
                                         EE8->EE8_COD_I ,;
                                         MemoLine(EasyMsmm(EE8->EE8_DESC,Avsx3("EE8_VM_DES",AV_TAMANHO),,, ,,, "EE8","EE8_DESC"),30,1),;
                                         EE9->EE9_PREEMB,;
                                         EE9->EE9_SLDINI})
                        EE9->(DbSkip())
                     EndDo
                  EndIf

                  EE8->(DbSkip())
               EndDo
            EndIf
         EndIf

         If (Len(aEmbarques) = 0 .And. Len(aAdiantamentos) = 0 .And. Len(aRvs) = 0)
            Break
         EndIf
         
         If lExibeMsg

            cMsg := STR0037+AllTrim(Transf(EE7->EE7_PEDIDO,Avsx3("EE7_PEDIDO",AV_PICTURE)))+STR0038+Replic(ENTER,2) //"O Processo '"###"' não poderá ser cancelado/eliminado."
            cMsg += STR0039+ENTER //"Este processo possui controles de intermediação e não poderá ser "
            cMsg += STR0040+cFil+"'."+Replic(ENTER,2) //"cancelado/eliminado na filial '"
            cMsg += STR0041+Replic(ENTER,2) //"Segue abaixo os detalhes: "

            If Len(aEmbarques) > 0
               cMsg += STR0042+Replic(ENTER,2) //"O(s) item(ns) do processo esta(ão) envonvido(s) no(s) seguinte(s) embarque(s):"
               cMsg += STR0043+Space(2)+; //"Seq.Item"
                       IncSpace(STR0044,AvSx3("EE8_COD_I",AV_TAMANHO),.f.)+Space(2)+; //"Cod.Item"
                       IncSpace(STR0045,30,.f.)+Space(2)+; //"Descrição"
                       IncSpace(STR0046  ,AvSx3("EEC_PREEMB",AV_TAMANHO),.f.)+Space(2)+; //"Nro.Embarque"
                       IncSpace(STR0047,17,.t.)+Replic(ENTER,2) //"Qtde.Embarcada"

               For j:=1 To Len(aEmbarques)
                  cMsg += IncSpace(aEmbarques[j][1],08,.t.)+Space(2)+;
                          IncSpace(aEmbarques[j][2],AvSx3("EE8_COD_I",AV_TAMANHO),.f.)+Space(2)+;
                          IncSpace(aEmbarques[j][3],30,.f.)+Space(2)+;
                          IncSpace(aEmbarques[j][4],20,.f.)+Space(2)+;
                          IncSpace(AllTrim(Transf(aEmbarques[j][5],AvSx3("EE9_SLDINI",AV_PICTURE))),17,.t.)+ENTER
               Next
               cMsg += Replic(ENTER,2)
            EndIf

            If Len(aAdiantamentos) > 0
               cMsg += STR0048+Replic(ENTER,2) //"O processo possui parcela(s) de adiantamento(s) vinculada(s)."
               cMsg += STR0049+Space(2)+; //"Nro.Parcela"
                       STR0050+Space(2)+; //"Dt.Adiantamento"
                       IncSpace(STR0051,17,.t.)+Replic(ENTER,2) //"Valor"

               For j:=1 To Len(aAdiantamentos)
                  cMsg += IncSpace(aAdiantamentos[j][1],11,.t.)+Space(2)+;
                          IncSpace(Transf(aAdiantamentos[j][2],cPictData),15,.f.)+Space(2)+;
                          IncSpace(AllTrim(Transf(aAdiantamentos[j][3],AvSx3("EEQ_VL",AV_PICTURE))),17,.t.)+ENTER
               Next

               cMsg += Replic(ENTER,2)
            EndIf

            If Len(aRvs) > 0
               cMsg += STR0052+Replic(ENTER,2) //"O processo possui RV(s) vinculada(s)."
               cMsg += STR0043+Space(2)+; //"Seq.Item"
                       IncSpace(STR0044,AvSx3("EE8_COD_I",AV_TAMANHO),.f.)+Space(2)+; //"Cod.Item"
                       IncSpace(STR0045,30,.f.)+Space(2)+; //"Descrição"
                       IncSpace(STR0053,AvSx3("EE8_RV",AV_TAMANHO),.f.)+Replic(ENTER,2) //"Nro.RV"

               For j:=1 To Len(aRvs)
                  cMsg += IncSpace(aRvs[j][1],08,.t.)+Space(2)+;
                          IncSpace(aRvs[j][2],AvSx3("EE8_COD_I",AV_TAMANHO),.f.)+Space(2)+;
                          IncSpace(aRvs[j][3],30,.f.)+Space(2)+;
                          IncSpace(aRvs[j][4],AvSx3("EE8_RV",AV_TAMANHO),.f.)+ENTER
               Next
               cMsg += Replic(ENTER,2)
            EndIf
                               
            If !Empty(cMsg)
               lRet:=.f.
               If !EECView(cMsg,STR0054,STR0055) //"Cancelar/Eliminar"###"Detalhes"
                  Break
               Else
                  If (Len(aEmbarques) = 0 .And. Len(aAdiantamentos) = 0 .And. Len(aRvs) > 0)
                     If !lCanCancel .And. MsgNoYes(STR0056,STR0007) //"Confirma a operação ?"###"Atenção"
                        lRet:=.t.
                        Break
                     Else
                        lRet:=.f.
                        Break                    
                     EndIf
                  EndIf
               EndIf
            EndIf
         Else       

            Do Case  
                    //Não possui embarque nem Adiantamento
               Case (Len(aEmbarques) > 0 .Or. Len(aAdiantamentos) > 0)
                    lRet:=.f.
                    Break
                    
                    // A filial logada não é a brasil porém os dados validados serão todos do brasil. 
               
                    //ER - 27/09/05 16:50. Caso exista RV, a confirmação de cancelamento dependerá 
                    //do parametro lCanCancel
               Case (!lIsFilBr .And. Len(aEmbarques) = 0 .And. Len(aAdiantamentos) = 0 .And. Len(aRvs) > 0)
                                      
                    lRet := lCanCancel
                    Break            
            EndCase            
         EndIf

      Case cFase == OC_EM // Fase Embarque.

         /* O cancelamento de embarques não poderá ser realizado para os níveis posteriores de 
            off-shore. */

         If EEC->(FieldPos("EEC_NIOFFS"))> 0 .And. AvGetM0Fil() == cFilEx .And. !Empty(EEC->EEC_NIOFFS) // JPP - 08/09/2005 - 14:15 - Verificar se o campo EEC_NIOFFS existe na base, antes de usa-lo.
            If lExibeMsg
            MsgStop(STR0102+; //"O cancelamento não poderá ser realizado. Para efetivar a operação, selecione o "
                    STR0103+; //"processo de origem e efetue o cancelamento. O sistema automaticamente irá cancelar "
                    STR0104,STR0105) //"os demais níveis de off-shore existentes."###"Atenção"
            EndIf
            lRet:=.f.
            Break
         EndIf

         /* Para a fase de embarque valem as seguintes regras (considerando a filial oposta):
            1) São considerados apenas os processos com tratamentos de off-shore (EEC_INTERM = Sim);
            2) O processo não pode estar embarcado;
            3) O processo não pode conter lançamentos de adiantamentos vinculados;
            4) O processo não pode conter itens com RE (Registro de Exportação). (Somente para a Fil. Brasil). */

         EEC->(DbSetOrder(1))
         EE9->(DbSetOrder(2))

         If lIsFilBr
            If !(EEC->EEC_INTERM $ cSim)
               Break
            EndIf
         Else
            If EEC->(DbSeek(cFilBr+EEC->EEC_PREEMB))
               If !(EEC->EEC_INTERM $ cSim)
                  Break
               EndIf
            EndIf
         EndIf

         If EEC->(DbSeek(cFil+EEC->EEC_PREEMB))
            If !Empty(EEC->EEC_DTEMBA)
               lTemEmbarque := .t.
               dDtEmba := EEC->EEC_DTEMBA
            EndIf
         EndIf

         If lPagtoAnte
            EEQ->(DbSetOrder(6))
            If EEQ->(DbSeek(cFil+"E"+EEC->EEC_PREEMB))
               Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == cFil .And.;
                                            EEQ->EEQ_FASE   == "E"  .And.;
                                            EEQ->EEQ_PREEMB == EEC->EEC_PREEMB
                  If EEQ->EEQ_TIPO == "A"
                     aAdd(aAdiantamentos,{EEQ->EEQ_PARC,EEQ->EEQ_DTCE,EEQ->EEQ_VL})
                  EndIf                
                  EEQ->(DbSkip())
               EndDo
            EndIf
         EndIf

         EE9->(DbSeek(cFil+EEC->EEC_PREEMB))
         Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == cFil .And. EE9->EE9_PREEMB == EEC->EEC_PREEMB
            If !Empty(EE9->EE9_RE)              
               aAdd(aRes,{EE9->EE9_SEQEMB,;
                          EE9->EE9_COD_I,;
                          MemoLine(Msmm(EE9->EE9_DESC,Avsx3("EE9_VM_DES",AV_TAMANHO)),30,1),;
                          EE9->EE9_DTRE,;
                          EE9->EE9_RE})
            EndIf
            EE9->(DbSkip())
         EndDo

         If (!lTemEmbarque .And. Len(aAdiantamentos) = 0 .And. Len(aRes) = 0)
            Break
         EndIf
         
		 If LExibeMsg	
            cMsg := STR0037+AllTrim(Transf(EEC->EEC_PREEMB,Avsx3("EEC_PREEMB",AV_PICTURE)))+STR0038+Replic(ENTER,2) //"O Processo '"###"' não poderá ser cancelado/eliminado."
            cMsg += STR0039+ENTER //"Este processo possui controles de intermediação e não poderá ser "
            cMsg += STR0040+cFil+"'."+Replic(ENTER,2) //"cancelado/eliminado na filial '"
            cMsg += STR0041+Replic(ENTER,2) //"Segue abaixo os detalhes: "

            If lTemEmbarque .And. !Empty(dDtEmba)
               cMsg += STR0057+Transf(dDtEmba,cPictData)+". "+ENTER //"Processo embarcado em : "
               cMsg += Replic(ENTER,2)
            EndIf

            If Len(aAdiantamentos) > 0
               cMsg += STR0048+Replic(ENTER,2) //"O processo possui parcela(s) de adiantamento(s) vinculada(s)."
               cMsg += STR0049+Space(2)+; //"Nro.Parcela"
                       STR0050+Space(2)+; //"Dt.Adiantamento"
                       IncSpace(STR0051,17,.t.)+Replic(ENTER,2) //"Valor"
   
               For j:=1 To Len(aAdiantamentos)
                  cMsg += IncSpace(aAdiantamentos[j][1],11,.t.)+Space(2)+;
                          IncSpace(Transf(aAdiantamentos[j][2],cPictData),15,.f.)+Space(2)+;
                          IncSpace(AllTrim(Transf(aAdiantamentos[j][3],AvSx3("EEQ_VL",AV_PICTURE))),17,.t.)+ENTER
               Next

               cMsg += Replic(ENTER,2)
            EndIf

            If Len(aRes) > 0
               cMsg += STR0058+Replic(ENTER,2) //"O processo possui RE(s) vinculada(s)."
               cMsg += STR0043+Space(2)+; //"Seq.Item"
                       IncSpace(STR0044,AvSx3("EE9_COD_I",AV_TAMANHO),.f.)+Space(2)+; //"Cod.Item"
                       IncSpace(STR0045,30,.f.)+Space(2)+; //"Descrição"
                       IncSpace(STR0059,15,.f.)+Space(2)+;                     //"Data R.E."
                       IncSpace(STR0060,AvSx3("EE8_RE",AV_TAMANHO),.f.)+Replic(ENTER,2) //"Nro.RE"

               For j:=1 To Len(aRes)
                  cMsg += IncSpace(aRes[j][1],08,.t.)+Space(2)+;
                          IncSpace(aRes[j][2],AvSx3("EE8_COD_I",AV_TAMANHO),.f.)+Space(2)+;
                          IncSpace(aRes[j][3],30,.f.)+Space(2)+;
                          IncSpace(Transf(aRes[j][4],cPictData),15,.f.)+Space(2)+;
                          IncSpace(aRes[j][5],AvSx3("EE8_RV",AV_TAMANHO),.f.)+ENTER
               Next   
               cMsg += Replic(ENTER,2)
            EndIf
            
            If !Empty(cMsg)
               lRet:=.f.
               If !EECView(cMsg,STR0054,STR0055) //"Cancelar/Eliminar"###"Detalhes"
                  Break
               Else
                  If (!lTemEmbarque .And. Len(aAdiantamentos) = 0 .And. Len(aRes) > 0)
                     If !lCanCancel .and. MsgNoYes(STR0056,STR0007) //"Confirma a operação ?"###"Atenção"
                        lRet:=.t.
                        Break
                     EndIf
                  EndIf
               EndIf
            EndIf
         Else
            
            Do Case
               Case (lTemEmbarque .Or. Len(aAdiantamentos) > 0)
                    lRet:=.f.
                    Break
               
                    //ER - 27/09/05 16:50. Caso exista RE, a confirmação de cancelamento dependerá 
                    //do parametro lCanCancel
               Case (!lIsFilBr .And. !lTemEmbarque .And. Len(aAdiantamentos) = 0 .And. Len(aRes) > 0)
                    // A filial logada não é a brasil porém os dados validados serão todos do brasil. 
                    lRet := lCanCancel
                    Break            
            EndCase            
       EndIf       
   EndCase     

End Sequence

RestOrd(aOrd,.t.)

Return lRet           

/*
Funcao      : AP104VldOffShore().
Parametros  : nOpc - Opção da manutenção. (INCLUIR/ALTERAR/EXCLUIR)
              lIsFilBr - .t. - Filial Brasil.
                         .f. - Filial Off-Shore.
Retorno     : .t./.f.
Objetivos   : Validar informações da filial brasil contra a filial de off-shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 24/03/2004 18:45.
Revisao     :
Obs.        : aDiferencas por dimensão.
                           aDiferencas[1]
                                      [1][1] - Campo
                                      [1][2] - Conteúdo Fil. Brasil.
                                      [1][3] - Conteúdo Fil. Off-Shore.
*/
*--------------------------------------*
Function AP104VldOffShore(nOpc,lIsFilBr)
*--------------------------------------*
Local lRet:=.t., aCmpToCompare:={}, j:=0, cCampo, aOrd:=SaveOrd({"EE7"})
//Local cFilBr:=AvKey(EasyGParam("MV_AVG0023",,""),"EE7_FILIAL"),;
//      cFilEx:=AvKey(EasyGParam("MV_AVG0024",,""),"EE7_FILIAL")
Local cMsg, cMemo:=""
Local aDiferencas :={}
Local lTemEmbarque := .f., lTemItemFixado := .f., lTemAdiantamento := .f., lCancelado := .f.

Default lIsFilBr := .t.
Default nOpc     := 0

Begin Sequence

   If lIsFilBr // ** Validações para a filial do brasil contra a filial de off-shore.

      /* Na filial brasil, qdo o processo é lançado sem o tratamento de off-shore, caso o processo já exista
         na filial de off-shore, as validações abaixo são executadas, caso todas as condições tenham sido 
         atendidas, o processo é eliminado da filial de off-shore. (Fluxo Normal) */

      If nOpc == INCLUIR .And. !(M->EE7_INTERM $ cSim)
         EE7->(DbSetOrder(1))
         If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))

            // Verifica se o processo está cancelado.
            If EE7->EE7_STATUS == ST_PC
               lCancelado := .t.
            Else

               /* Verifica se o processo possui algum adiantamento vinculado.
                  Fase de Pedido */
               If lPagtoAnte
                  EEQ->(DbSetOrder(6))
                  If EEQ->(DbSeek(cFilEx+"P"+EE7->EE7_PEDIDO))
                     Do While EEQ->(!Eof()) .And. EEQ->EEQ_FILIAL == cFilEx .And.;
                                                  EEQ->EEQ_FASE   == "P"  .And.;
                                                  EEQ->EEQ_PREEMB == EE7->EE7_PEDIDO                    
                        If EEQ->EEQ_TIPO == "A"
                           lTemAdiantamento := .t.
                           Exit
                        EndIf

                        EEQ->(DbSkip())
                     EndDo
                  EndIf
               EndIf            

               EE8->(DbSetOrder(1))
               EE8->(DbSeek(cFilEx+EE7->EE7_PEDIDO))
               Do While EE8->(!Eof()) .And. EE8->EE8_FILIAL == cFilEx .And.;
                                            EE8->EE8_PEDIDO == EE7->EE7_PEDIDO
   
                  // ** Verifica se o item faz parte de algum embarque.
                  If (EE8->EE8_SLDINI <> EE8->EE8_SLDATU)
                     lTemEmbarque := .t.
                     Exit
                  EndIf

                  // ** Verifica se o item tem preço fixado (Rotina de Commodity Habilitada).
                  If (lCommodity .And. !Empty(EE8->EE8_DTFIX))
                     lTemItemFixado := .t.
                     Exit
                  EndIf
                  EE8->(DbSkip())
               EndDo
            EndIf

            If lTemEmbarque .Or. (lCommodity .And. lTemItemFixado) .Or. lTemAdiantamento .Or. lCancelado
               cMsg := STR0081+Replic(ENTER,2) //"Problema:"
               cMsg += AllTrim(Avsx3("EE7_PEDIDO",AV_TITULO))+Space(1)+AllTrim(Transf(M->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE)))+STR0061+cFilEx+"' "  //"' está lançado na filial '"
               cMsg += STR0062+Replic(ENTER,2) //"e não poderá ser excluído."
               cMsg += STR0063+ENTER //"Detalhes:"

               If lCancelado
                  cMsg+= STR0064+ENTER //" - O processo está cancelado."
               EndIf

               If lTemEmbarque
                  cMsg+= STR0065+ENTER //" - O processo está lançado em fase de embarque."
               EndIf

               If (lCommodity .And. lTemItemFixado)
                  cMsg+= STR0066+ENTER //" - O processo possui item(ns) com preço fixado."
               EndIf

               If lPagtoAnte .And. lTemAdiantamento
                  cMsg+= STR0067+ENTER //" - O processo possui adiantamento(s) vinculado(s)."
               EndIf

               cMsg += ENTER
               cMsg += STR0068+cFilBr+"'." //"O processo, não poderá ser lançado sem tratamento de off-shore na filial '"
            EndIf

            If !Empty(cMsg)
               EECView(cMsg,STR0069,STR0055) //"Validações Off-Shore"###"Detalhes"
               lRet:=.f.
               Break
            Else
               If MsgNoYes(AllTrim(AVSX3("EE7_PEDIDO",AV_TITULO))+Space(1)+AllTrim(Transf(M->EE7_PEDIDO,AVSX3("EE7_PEDIDO",AV_PICTURE)))+STR0070+cFilEx+"' "+ENTER+;  //"' será eliminado na filial '"
                           STR0056,STR0007) //"Confirma a operação ?"###"Atenção"
                  Break
               EndIf
            EndIf
         Else
            Break
         EndIf
      EndIf

      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(cFilEx+M->EE7_PEDIDO))

         /* by jbj - 25/06/04 13:43 - Na inclusão/Alteração de pedido com tratamentos de off-shore, caso 
                                      o processo já exista na filial de off-shore e estiver cancelado a
                                      inclusão/alteração não é permitida.*/
         If EE7->EE7_STATUS = ST_PC
            MsgInfo(STR0071+cFilEx+STR0072+cFilBr+STR0073,STR0007) //"Este processo está cancelado na filial de off-shore ("###") e não poderá ser lançado na filial '"###"' com tratamento de off-shore."###"Atenção"
            lRet:=.f.
            Break
         EndIf

         aCmpToCompare := {"EE7_EXPORT","EE7_CLIENT"}

         For j:=1 To Len(aCmpToCompare)
            If aCmpToCompare[j] == "EE7_EXPORT"
               cCampo := If(!Empty(M->EE7_EXPORT),M->EE7_EXPORT,M->EE7_FORN)

               If cCampo <> EE7->EE7_FORN
                  aAdd(aDiferencas,{AvSx3("EE7_EXPORT",AV_TITULO),;
                                    cCampo,;
                                    EE7->EE7_FORN})
               EndIf
            ElseIf aCmpToCompare[j] == "EE7_CLIENT"
               If M->EE7_CLIENT <> EE7->EE7_IMPORT
                  aAdd(aDiferencas,{AvSx3("EE7_CLIENT",AV_TITULO),;
                                                       M->EE7_CLIENT,;
                                                       EE7->EE7_IMPORT})
               EndIf
            Else
               If M->&(aCmpToCompare[j]) <> EE7->&(aCmpToCompare[j])
                  aAdd(aDiferencas,{AvSx3(aCmpToCompare[j],AV_TITULO),;
                                          AllTrim(M->&(aCmpToCompare[j])),;
                                          AllTrim(EE7->&(aCmpToCompare[j]))})
               EndIf
            EndIf
         Next

         If Len(aDiferencas) > 0
            For j:=1 To Len(aDiferencas)
               If j = 1
                  cMemo := STR0074+ENTER+; //"Este processo contém informações divergentes em relação "
                           STR0075+Replic(ENTER,2)+; //"a filial de off-shore."
                           STR0076+Replic(ENTER,2)+; //"Revise os campos descritos abaixo para efetuar a gravação do processo."
                           STR0063+Replic(ENTER,2)+; //"Detalhes:"
                           IncSpace(STR0077,15,.f.)+Space(1)+IncSpace(STR0078,40,.f.)+Space(1)+; //"Campo"###"Cont.Fil.Br."
                                                             IncSpace(STR0079,40,.f.)+ENTER+; //"Cont.Fil.Off-shore."
                           IncSpace(Replic("-",5),15,.f.)+Space(1)+IncSpace(Replic("-",12),40,.f.)+Space(1)+;
                                                                   IncSpace(Replic("-",19),40,.f.)+ENTER
               EndIf

               cMemo += IncSpace(aDiferencas[j][1],15,.f.)+Space(1)+;
                        IncSpace(aDiferencas[j][2],40,.f.)+Space(1)+;
                        IncSpace(aDiferencas[j][3],40,.f.)+ENTER
            Next

            EECView(cMemo,STR0080,STR0055) //"Detalhes da Validação de Campos - Fil.Brasil X Fil. Off-shore"###"Detalhes"
            lRet:=.f.
         EndIf
      EndIf
   Else

      // ** Validações para a filial do exterior contra a filial brasil.
      nRecEE7 := EE7->(Recno())
      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(cFilBr+M->EE7_PEDIDO)) // Posiciona na fil brasil para realizar as validações.

         Do Case
            Case (nOpc == INCLUIR .And. !(EE7->EE7_INTERM $ cSim))
                 /* Na inclusão de processo na filial exterior, caso o processo já exista na filial
                    brasil com a flag de off-shore = não, bloqueia a inclusão do processo */

                 EE7->(DbGoTo(nRecEE7))
                 MsgInfo(AllTrim(Avsx3("EE7_PEDIDO",AV_TITULO))+Space(2)+AllTrim(Transf(M->EE7_PEDIDO,Avsx3("EE7_PEDIDO",AV_PICTURE)))+"' "+; 
                          STR0082+cFilBr+STR0083,STR0007)  //"não poderá ser lançado nesta filial. Este processo está  lançado na filial '"###"' sem tratamento de off-shore."###"Atenção"
                 lRet:=.f.
                 Break

            Case (EE7->EE7_INTERM $ cSim)
                 // by jbj 11/04/05 - Validações retiradas para atender as novas críticas da rotina de off-shore.                 

                 /* Para validar a filial do Brasil a partir da filial de intermediação, o sistema
                    verifica se no Brasil, o processo está marcado como processo de intermediação
                    Caso contrário não valida as quantidades. 

                    Valida as quantidades de todos os produtos entre os processos da filial
                    de intermediação e da filial brasil */

                 //EE7->(DbGoTo(nRecEE7))
                 //If !Ap101VldQtde(OC_PE)
                 //   lRet:=.f.
                 //   Break
                 //EndIf
         EndCase
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet
/*------------------------------------------------------------------------------*
  Início das rotinas de Controle de Quantidades entre Filiais Brasil e Off-Shore
 *------------------------------------------------------------------------------*/
/*
Funcao      : Ap104VldCommodity()
Parametros  : 
Retorno     : .t./.f.
Objetivos   : Validar se as quantidades entre Brasil e Off-Shore são validas para a rotina de commodities.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 29/09/05 15:30
Obs.        : 
*/
*--------------------------*
Function Ap104VldCommodity()
*--------------------------*
Local lRet := .t.
Local aOrd := SaveOrd({"EE7","EE8","WorkIt"}) // Salva ordens antigas
Local nOldArea := Select()

Local cFilAtu  := xFilial("EE8")                        // Filial atual
Local cFilOpos := If(cFilAtu == cFilBr, cFilEx, cFilBr) // Filial Oposta à atual
Local lFilBr   := (cFilAtu == cFilBr)                   // define se está na filial brasil

// Variáveis auxiliares
Local i, j, k, w, cSeq, nPos, nPos2, cAux, nAux, aAux, aAux2, lDtFix, aSeqs

// Variáveis para mensagem ao usuário
Local aMsg
Local aHeader, aDetail

// Arrays de agrupamento de itens
Private aItensOpos   := {}   // Itens da filial oposta (cFilOpos)
Private aGrpOpos     := {}   // Grupos dos itens da filial oposta

// Arrays para validação
Private aAlteracoes  := {}   // Alterações nos itens da filial atual
Private aItensNaoAtu := {}   // Itens que não puderam ser atualizados
Private lNaoAtu := .f.
/* aAlteracoes por dimensão: [i][1] -> Sequência do item
                             [i][2] -> Sequência consolidada
                             [i][3] -> Tipo ("INCLUIDO","ALTERADO","EXCLUIDO")
                             [i][4] -> quantidade anterior (base)
                             [i][5] -> quantidade alterada (memória)
                             [i][6] -> Conseguiu ser atualizado? "Sim","Não"
*/

// Campos pelos quais os produtos não serão consolidados se tiverem conteúdos diferentes
Private cConsolida := Ap104StrCpos(aConsolida)

Begin Sequence
   
   // Zera o array de atualização da filial oposta
   aAtuQtdFil := {}

   DbSelectArea("EE8")
   
   DbSetOrder(1)
   
   /* Adiciona todos os itens da filial oposta no aItensOpos, para simular os acertos nas quantidades.
      Separa os itens em agrupamentos(aGrpOpos), definidos pelos campos EE8_ORIGEM e EE8_ORIGV. */
      
   DbSeek(cFilOpos+M->EE7_PEDIDO) // posiciona no 1º item da filial oposta

   While !EoF() .And. (EE8_FILIAL+EE8_PEDIDO) == (cFilOpos+M->EE7_PEDIDO)

      EE8->(AddItemGroup(aItensOpos,aGrpOpos))

      DbSkip()
      
   EndDo
   
   WorkIt->(DbGoTop())
   nCont:=1 //WFS 08/01/09
   // Procura alterações nas quantidades dos itens
   While WorkIt->(!EoF())
      If WorkIt->EE8_RECNO = 0 // Se foi incluído, então não busca quantidade na base
         nAux := 0
      Else // Se foi alterado, busca quantidade anterior na base para apurar diferença
         //WFS 08/01/09 - Alterado para buscar o SLDINI da filial oposta
         //EE8->(DbGoTo(WorkIt->EE8_RECNO))
         EE8->(DbGoTo(If(Len(aItensOpos) >= nCont .And. Len(aItensOpos[nCont]) >= 1, aItensOpos[nCont][1], WorkIt->EE8_RECNO)))
         nAux := EE8->EE8_SLDINI
      EndIf
      // apura a diferença entre a quantidade na base e na memória
      nAux := WorkIt->EE8_SLDINI - nAux

      If nAux = 0 // se não houve alteração na quantidade, desconsidera.
         WorkIt->(DbSkip())
         nCont++ //WFS 08/01/09
         Loop
      EndIf

      cSeq := WorkIt->(Ap104SeqIt())       // pega a sequência de origem predominante
      cAux := WorkIt->(&cConsolida)        // campos para agrupamento

      If WorkIt->EE8_RECNO = 0
         AAdd(aAlteracoes,{WorkIt->EE8_SEQUEN,;
                           cSeq,;
                           STR0152,; //"Incluído"
                           0,;
                           WorkIt->EE8_SLDINI,;
                           STR0147}) // "Sim"
      Else
         AAdd(aAlteracoes,{WorkIt->EE8_SEQUEN,;
                           cSeq,;
                           STR0153,; // "Alterado"
                           EE8->EE8_SLDINI,;
                           WorkIt->EE8_SLDINI,;
                           STR0147}) // "Sim"
      EndIf
      
      nPos := AScan(aGrpOpos,{|x| x[1] == cSeq }) // procura a sequência no array de agrupamentos
      
      nPos2 := 0
      If nPos > 0
         nPos2 := AScan(aGrpOpos[nPos][2],{|x| x[1] == cAux }) // procura a sequência de campos no array de agrupamentos
      EndIf

      If nPos2 > 0
         aAux := aGrpOpos[nPos][2][nPos2][2]// aAux será um ponteiro para aGrpOpos[nPos][2][nPos2][2], pois é array
      Else
         aAux := {}
      EndIf
      
      If !AbateSomaIt(nAux,aAux,cSeq)
         lRet := .f.
         Break
      EndIf

      WorkIt->(DbSkip())
      nCont++ //WFS 08/01/09
   EndDo

   For i := 1 to Len(aDeletados) // abate quantidades dos itens deletados dos itens da Fil. Oposta.
      DbGoTo(aDeletados[i])      // posiciona no item excluído
      nAux := - EE8_SLDINI       // apura a diferença (no caso é total)
      
      cSeq := Ap104SeqIt()       // pega a sequência de origem predominante
      cAux := &cConsolida

      AAdd(aAlteracoes,{EE8->EE8_SEQUEN,;
                        cSeq,;
                        STR0154,; //"Excluído"
                        EE8->EE8_SLDINI,;
                        0,;
                        STR0147}) //"Sim"
      
      nPos := AScan(aGrpOpos,{|x| x[1] == cSeq }) // procura a sequência no array de agrupamentos
      
      nPos2 := 0
      If nPos > 0
         nPos2 := AScan(aGrpOpos[nPos][2],{|x| x[1] == cAux }) // procura a sequência de campos no array de agrupamentos
      EndIf
      
      If nPos2 > 0
         aAux := aGrpOpos[nPos][2][nPos2][2]// aAux será um ponteiro para aGrpOpos[nPos][2][nPos2][2], pois é array
      Else   
         aAux := {}
      EndIf
      
      If !AbateSomaIt(nAux,aAux,cSeq)
         lRet := .f.
         Break
      EndIf
   Next
   
   // se houver algum item que não pode ser atualizado...
   If lNaoAtu

      /* Monta header da mensagem - parte 1 - Itens da filial atual
                  |Campo       |Tipo|Título |Tam.|                      */
      aHeader := {{"EE8_SEQUEN"                  },;
                  {"EE8_SEQUEN",    ,STR0155     },; //"Seq. Origem"
                  {            ,"C" ,STR0156,10  },; //"Alteração"
                  {"EE8_SLDINI",    ,STR0109     },; //"Qtde. Anterior"
                  {"EE8_SLDINI",    ,STR0110     },; //"Qtde. Alterada"
                  {"EE8_SLDINI",    ,STR0111     },; //"Dif. Qtde."
                  {            ,"C" ,STR0112,3   }}  //"Atualizado?"

      For i := 1 to Len(aConsolida)
         AAdd(aHeader,{aConsolida[i]}) // adiciona os campos que influenciam na consolidação de itens.
      Next
      
      // Monta detalhes da Msg - parte 1
      aSeqs   := {}
      aDetail := {}
      For i := 1 To Len(aAlteracoes)
         If AScan(aSeqs,aAlteracoes[i][2]) = 0
            AAdd(aSeqs,aAlteracoes[i][2])
         EndIf
         AAdd(aDetail,{aAlteracoes[i][1],; // Sequência
                       aAlteracoes[i][2],; // Sequência de Origem
                       aAlteracoes[i][3],; // Alteração
                       aAlteracoes[i][4],; // Qtde. Ant.
                       aAlteracoes[i][5],; // Qtde. Alterada
                       aAlteracoes[i][5] - aAlteracoes[i][4],; // Dif. Qtde.
                       aAlteracoes[i][6]}) // Atualizado?

         If (lBase := aAlteracoes[i][3] == STR0154) //"Excluído" - pega dados da base somente se for um item excluido.
            EE8->(DbSetOrder(1))
            EE8->(DbSeek(cFilAtu+M->EE7_PEDIDO+aAlteracoes[i][1]))
         Else
            WorkIt->(DbSeek(aAlteracoes[i][1]))
         EndIf

         For j := 1 to Len(aConsolida)
            If lBase
               AAdd(aDetail[i],EE8->&(aConsolida[j]))
            Else
               AAdd(aDetail[i],WorkIt->&(aConsolida[j]))
            EndIf
         Next
      Next

      aMsg := {}


      AAdd(aMsg,{"",.t.}) // vai quebrar linhas na EECView()
      n := Len(aMsg)
      
      aMsg[n][1] += STR0149 //"Foram feitas as seguintes alterações em quantidades de itens (listadas logo abaixo). Porém algumas não puderam ser atualizadas na filial "
      aMsg[n][1] += If(lFilBr,STR0151,STR0150) + ":" + Repl(ENTER,2) // "Off-Shore" ## "Brasil"
      

      AAdd(aMsg,{"",.f.}) // não vai quebrar linhas na EECView()
      n := Len(aMsg)
      aMsg[n][1] += EECMontaMsg(aHeader,aDetail) // Monta a mensagem em forma de cabeçalho e detalhes.
      aMsg[n][1] += ENTER
      

      AAdd(aMsg,{"",.t.}) // vai quebrar linhas na EECView()
      n := Len(aMsg)

      aMsg[n][1] += STR0113 //"Logo abaixo estão os itens da filial "
      aMsg[n][1] += If(lFilBr,STR0151,STR0150) // "Off-Shore" ## "Brasil"
      aMsg[n][1] += STR0114 //" que poderiam ser atualizados. Para que uma alteração na quantidade de um item acima (Filial "
      aMsg[n][1] += If(!lFilBr,STR0151,STR0150) // "Off-Shore" ## "Brasil"
      aMsg[n][1] += STR0115 //") possa ser atualizada em um item abaixo (Filial "
      aMsg[n][1] += If(lFilBr,STR0151,STR0150) // "Off-Shore" ## "Brasil"
      aMsg[n][1] += STR0116 //"), o item a ser atualizado não pode ter data de fixação de preço nem R.V., deve ter saldo suficiente e os seguintes campos entre os itens devem ter o mesmo conteúdo: "
      
      cAux := STR0155 + ", " //"Seq. Origem"
      For i := 1 To Len(aConsolida)
         cAux += AllTrim(AvSx3(aConsolida[i],AV_TITULO)) + ", "
      Next
      cAux := SubStr(cAux,1,Len(cAux) - 2) + "."

      aMsg[n][1] += cAux + Repl(ENTER,2)

  
      aHeader := {}
      aDetail := {}
      
      /* Monta header da mensagem - parte 2 - Itens da filial oposta
                  |Campo       |Tipo|Título |Tam.|                      */
      aHeader := {{"EE8_SEQUEN"                  },;
                  {"EE8_SEQUEN",    ,STR0155     },; //"Seq. Origem"
                  {"EE8_SLDINI",    ,STR0117     },; //"Qtde. Total"
                  {"EE8_SLDINI",    ,STR0118     },; //"Saldo Disponível"
                  {"EE8_DTFIX" ,    ,            },;
                  {"EE8_RV"    ,    ,            }}

      For i := 1 to Len(aConsolida)
         AAdd(aHeader,{aConsolida[i]}) // adiciona os campos que influenciam na consolidação de itens.
      Next
      
      // Monta detalhes da mensagem - Parte 2
      For i := 1 To Len(aSeqs) // Todas as sequencias de origem alteradas

         If (nPos := AScan(aGrpOpos,{|x| x[1] == aSeqs[i] }) ) > 0 // procura o grupo respectivo da sequência

            aAux := aGrpOpos[nPos][2]

            For j := 1 To Len(aAux) // varre todo o subgrupo de campos auxiliares (aConsolida)
               aAux2 := aAux[j][2]
               For k := 1 To Len(aAux2) // coloca cada item na msg.
                  
                  EE8->(DbGoTo(aAux2[k][1])) // Posiciona no item para pegar os dados
                  EE8->(AAdd(aDetail,{EE8_SEQUEN,;
                                      Ap104SeqIt(),;
                                      EE8_SLDINI  ,;
                                      EE8_SLDATU  ,;
                                      EE8_DTFIX   ,;
                                      EE8_RV        }))
            
                  For w := 1 to Len(aConsolida)
                     AAdd(aDetail[Len(aDetail)],EE8->&(aConsolida[w]))
                  Next       
               Next
            Next

         EndIf         

      Next

      AAdd(aMsg,{"",.f.}) // não vai quebrar linhas na EECView()
      n := Len(aMsg)
      aMsg[n][1] += EECMontaMsg(aHeader,aDetail) // Monta a mensagem em forma de cabeçalho e detalhes.
      aMsg[n][1] += ENTER
      
      EECView(aMsg,STR0119,STR0055) //"Controle de Quantidades"###"Detalhes"
      
      aAtuQtdFil := {} // zera o array de atualização da filial oposta
      lRet := .f.
      Break
   EndIf
   
End Sequence

RestOrd(aOrd,.f.) //Restaura ordens antigas
DbSelectArea(nOldArea) // Restaura a área ativa

Return lRet

/*
Função     : AddItemGroup()
Objetivos  : Organiza itens em grupos de acordo com a Origem e o aConsolida
Parâmetros : aItemOpos
Retorno    : Nenhum
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 10/10/05 às 9:38
Obs.       : 
*/
*----------------------------------*
Function AddItemGroup(aItens,aGroup)
*----------------------------------*
Local lDtFix, lRv, cSeq, cAux, nPos, nPos2
Local cConsolida := Ap104StrCpos(aConsolida)
Local lPed := Alias() $ "WORKIT/EE8"

Begin Sequence

   If lPed
      lDtFix := Empty(EE8_DTFIX) // Só itens sem preço fixado podem ser atualizados
      lRv    := Empty(EE8_RV)    // Só itens sem r.v. vinculado podem ser atualizados
      AAdd(aItens, {RecNo(), EE8_SEQUEN, EE8_SLDATU, lDtFix, EE8_SLDINI, lRv} ) // Adiciona o item.
   Else
      AAdd(aItens, {RecNo()} ) // Adiciona o item.
   EndIf

   cSeq := Ap104SeqIt()  // pega a sequência de origem predominante para este item.
   cAux := &cConsolida   // campos para agrupamento
      
   If (nPos := AScan(aGroup,{|x| x[1] == cSeq }) ) = 0 /* se o agrupamento pela sequência
                                                          não existir no array aGroup, adiciona. */
      AAdd(aGroup,{cSeq,{} } )
      nPos := Len(aGroup)
   EndIf
      
   If (nPos2 := AScan(aGroup[nPos][2],{|x| x[1] == cAux }) ) = 0 /* se o agrupamento pelos campos do aConsolida
                                                                    não existir no array, adiciona. */
      AAdd(aGroup[nPos][2],{cAux,{} } )
      nPos2 := Len(aGroup[nPos][2])
   EndIf
                                                               
   AAdd(aGroup[nPos][2][nPos2][2], aItens[Len(aItens)] ) /* Adiciona o item que acabou de ser incluido no 
                                                            aItens (aItens[Len(aItens)]) no 
                                                            seu respectivo grupo dentro de aGroup. */
End Sequence

Return Nil

                                                                         
/*
Função     : Ap104SeqIt()
Objetivos  : Retornar sequência de origem predominante
Parâmetros : lPed - define se é pedido ou embarque
             cFil - filial a ser utilizada, no caso de ser embarque, para dar seek em itens do pedido.
             lSeq - define se, no embarque, só traz a seq. em vez de trazer pedido+seq.
Retorno    : Sequência de Origem do Item 
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/09/05 às 11:50
Obs.       : utilizará os campos da área selecionada. Ex: EE8->(Ap104SeqIt()), WorkIt->(Ap104SeqIt()) ou Ap104SeqIt() (Área selecionada)
*/
*---------------------------------*
Function Ap104SeqIt(lPed,cFil,lSeq)
*---------------------------------*
Local cSeq, cAlias, aCpos, i, aOrd := SaveOrd({"EE7","EE8","EE9","EEC"})
Local cAl := Alias()

Default lPed := (Alias() $ "WORKIT/EE8")
Default cFil := xFilial("EE8")
Default lSeq := .f.
If cAlias = "WorkOpos"
   cFil := cFilOpos
EndIf

aCpos := {"EE8_ORIGV" ,; //1
          "EE8_ORIGEM",; //2
          "EE8_SEQUEN"  }//3

/* 
   1 - primeiro verifica a quebra por Origem de Vinc. de R.V. (EE8_ORIGV),
       pois a mesma já engloba as quebras de vinculação por fixação;
   2 - se a origem acima está vazia, então verifica se há quebra 
       por fixação de preço (EE8_ORIGEM);
   3 - se não tem origens, então o item não tem quebras. Por isso,
       a sequência será a do próprio item.
*/

Begin Sequence
   
   If !lPed
      EE8->(DbSetOrder(1))
      EE8->(DbSeek(cFil+(cAl)->(EE9_PEDIDO+EE9_SEQUEN))) //Procura o item correspondente no pedido
      For i := 1 To Len(aCpos)
         aCpos[i] := "EE8->" + aCpos[i] //pra pegar da base.
      Next
   EndIf

   For i := 1 To Len(aCpos)
      If !Empty( &(aCpos[i]) ) .Or. i == Len(aCpos)
         cSeq := &(aCpos[i])
         Break
      EndIf
   Next

End Sequence
   
Return If(lPed .Or. lSeq,"",EE9_PEDIDO) + cSeq // se for embarque, o campo EE9_PEDIDO também entra na chave.

/*
Função     : Ap104StrCpos()
Objetivos  : Montar expressão para consolidar itens
Parâmetros : Array de campos do SX3 que montarão a expressão
Retorno    : String com expressão para consolidação de itens
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/09/05 às 17:10
Obs.       :
*/

*-------------------------------*
Function Ap104StrCpos(aConsolida)
*-------------------------------*
Local cConsolida := "", i
Local aOrd := SaveOrd({"SX3"})

Begin Sequence
   
   SX3->(DbSetOrder(2))
   For i := 1 To Len(aConsolida)
      SX3->(DbSeek(aConsolida[i]))
      If i > 1
         cConsolida += "+"
      EndIf
      If SX3->X3_TIPO = "C"
         cConsolida += aConsolida[i]
      ElseIf SX3->X3_TIPO = "D"
         cConsolida += "DToS(" + aConsolida[i] + ")"
      ElseIf SX3->X3_TIPO = "N"
         cConsolida += "Str(" + aConsolida[i] + ")"
      ElseIf SX3->X3_TIPO = "M"
         cConsolida += "Ap104AuxMemo(" + aConsolida[i] + ")"
      EndIf
   Next

End Sequence

RestOrd(aOrd,.f.)

Return "''"+cConsolida

/*
Função     : Ap104AuxMemo()
Objetivos  : Formatar conteúdo do campo memo para comparar com outro memo
Parâmetros : campo Memo no SX3
Retorno    : String com campo memo formatado para comparação, retirados todos os espaços maiores
             que 1, todas as quebras de linha (CRLF) e colocado como maiúsculo.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 03/10/05 às 9:15
Obs.       : Estrutura do aMemoItem, declarado no EECAP100 e EECAE100:
             aMemoItem[i][1] -> Campo de código do Memo, não usado (X3_USADO)
             aMemoItem[i][2] -> Campo virtual do Memo, que aparece na enchoice
*/

*---------------------------*
Function Ap104AuxMemo(cCampo)
*---------------------------*
Local cConteudo, nSpaces := 2, nPos := 1
Local i

Begin Sequence

   If Alias() $ "WorkIt/WorkIp" // Se é work, não precisa de MSMM, o conteudo do campo memo já está na própria work
      cConteudo := &(cCampo)
   Else // Se não for Work, tem que buscar no SYP (MSMM)
      If (i := AScan(aMemoItem,{|x| x[2] = cCampo}) ) = 0
         Return ""
      EndIf
      cConteudo := EasyMSMM(aMemoItem[i][1],AvSx3(aMemoItem[i][2],AV_TAMANHO),,, ,,,"EE8",aMemoItem[i][1])
   EndIf
   
   cConteudo := StrTran(cConteudo,ENTER,Space(1)) //Tira todos os CRLF

   While .t. //procura lugares da string que têm 2 ou mais espaços, e substitui por apenas 1.
      nPos := At(Space(nSpaces),cConteudo)
      If nPos > 0
         nConteudo := StrTran(cConteudo,Space(nSpaces),Space(1))
      Else
         Exit
      EndIf
      nSpaces++
   EndDo
   
End Sequence

Return Upper(cConteudo)

/*
Função     : AbateSomaIt()
Objetivos  : Auxiliar no abatimento/soma de quantidades entre filiais Brasil/Exterior
Parâmetros : nValor - valor a ser abatido/somado
             aItens - array com os itens disponíveis para abatimento/soma
             cSeq   - sequência que deve ser atualizada
Retorno    : .t./.f.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 03/10/05 às 14:20
Obs.       : aAux[i][3] - Saldo Atual do Item
             aAux[i][5] - Saldo Inicial do Item
*/
*---------------------------------------------*
Static Function AbateSomaIt(nValor,aItens,cSeq)
*---------------------------------------------*
Local lRet := .t., i
Local aOrd := SaveOrd({"EE8"})

Begin Sequence

   If nValor > 0 // se a quantidade foi aumentada, apenas adiciona no primeiro item sem data de fixação da Filial Oposta
      For i := 1 To Len(aItens)
         If aItens[i][4] .And. aItens[i][6] //se não tiver preço fixado e não tiver RV vinculado
            aItens[i][3] += nValor // atualiza o saldo atual
            aItens[i][5] += nValor // atualiza o saldo inicial
            AAdd(aAtuQtdFil,{"ALTERAR",aItens[i][2],nValor}) // Adiciona no array a alteração
            nValor := 0
            Exit
         EndIf
      Next
   Else //Se a quantidade foi diminuida, vai abatendo dos itens da filial oposta.
      For i := 1 To Len(aItens)
         If aItens[i][4] .And. aItens[i][6] // se não tiver preço fixado e não tiver rv vinculado
            /* WFS - 12/01/09
               Se a quantidade foi diminuída, nValor sempre será negativo e menor que aItens[i][3] (saldo)
            If aItens[i][3] > -nValor // se a quantidade do item for maior que a diferença, então abate só dele e sai do loop.
               aItens[i][3] += nValor  // atualiza o saldo atual
               aItens[i][5] += nValor  // atualiza o saldo inicial
               AAdd(aAtuQtdFil,{"ALTERAR",aItens[i][2],nValor}) // Adiciona no array a alteração
               nValor := 0
               Exit
            Else // se a quantidade do item for menor ou igual que a diferença, abate o possível, e segue para o próximo item.
               aItens[i][5] -= aItens[i][3] // atualiza o saldo inicial
               If aItens[i][5] = 0 // se o saldo inicial também ficar zerado, quer dizer que não tem embarque.
                  AAdd(aAtuQtdFil,{"EXCLUIR",aItens[i][2],0}) // Adiciona no array a exclusão
               Else
                  AAdd(aAtuQtdFil,{"ALTERAR",aItens[i][2],nValor}) // Adiciona no array a Alteração (não exclui o item, pois o mesmo tem embarque)
               EndIf
               
               nValor += aItens[i][3] // atualiza o valor que resta para ser abatido
               aItens[i][3] := 0      // atualiza o saldo atual
               If nValor = 0 // se o valor que resta é zero, então finaliza.
                  Exit
               EndIf
            EndIf */            
            
            //WFS - 12/01/09 ---
            aItens[i][3] += nValor  // atualiza o saldo atual
            aItens[i][5] += nValor  // atualiza o saldo inicial                                 

            If aItens[i][3] < 0
               aItens[i][3]:= 0
            EndIf
            
            If aItens[i][5] = 0 // se o saldo inicial também ficar zerado, quer dizer que não tem embarque.
               AAdd(aAtuQtdFil,{"EXCLUIR",aItens[i][2],0}) // Adiciona no array a exclusão
            Else
               //WFS 13/01/09 - Acrescentada a diferença entre o saldo da filial offshore e a digitada pelo usuário, para gravação na base
               AAdd(aAtuQtdFil,{"ALTERAR",aItens[i][2],nValor}) // Adiciona no array a Alteração (não exclui o item, pois o mesmo tem embarque)
            EndIf            
            nValor := 0
            // ---
         EndIf
      Next
   EndIf
   
   If nValor < 0 // o valor não pôde ser abatido totalmente, exibirá mensagem
      aAlteracoes[Len(aAlteracoes)][6] := STR0148 //"Não"
      lNaoAtu := .t.
   ElseIf nValor > 0 // se é um valor maior que zero que não pode ser atualizado, então adiciona no array para incluir o item
      AAdd(aAtuQtdFil,{"INCLUIR",WorkIt->EE8_SEQUEN,nValor,cSeq})
   EndIf
   
End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Função     : Ap104AtuFil()
Objetivos  : Atualizar filial oposta à atual, com as alterações nas quantidades,
             definidas pelo array aAtuQtdFil, alimentado pela função de validação
             Ap104VldCommodity, que simula as alterações, armazenando-as no array.
Parâmetros : Nenhum
Retorno    : .t./.f.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 05/10/05 às 13:44
Obs.       : 
*/

*--------------------*
Function Ap104AtuFil()
*--------------------*
Local lRet := .t., i
Local aOrd := SaveOrd({"EE7","EE8","WorkIt"})
Local nReg := EE7->(Recno())

Private cFilAtu  := xFilial("EE8")                        // Filial atual
Private cFilOpos := If(cFilAtu == cFilBr, cFilEx, cFilBr) // Filial Oposta à atual
Private aWorksBackup := {"WorkIt","WorkAg"}
Private aItDelete    := {}

Begin Sequence

   If cFilAtu == cFilBr // A filial ativa for a filial do brasil?
      If !(M->EE7_INTERM $ cSim)
         Break
      Else 
         If EasyEntryPoint("EECAP100") 
            ExecBlock("EECAP100",.F.,.F.,{"GRV_OFFSHORE"})
         EndIf    
      EndIf      
   Else // Filial do Exterior (MV_AVG0024).
      EE7->(DbSetOrder(1))  // By JPP - 10/05/2006 - 17:55 - Esta função apenas poderá ser executada se existir pedido correspondente na filial oposta.
      If !EE7->(DbSeek(cFilOpos + M->EE7_PEDIDO))   
         EE7->(DbGoTo(nReg))
         Break
      EndIf 
      EE7->(DbGoTo(nReg))
   EndIf
   
   //WFS 08/01/09
   //Validar as quantidades entre Brasil e Off-Shore para a rotina de commodity.
   Ap104VldCommodity()
   
   For i := 1 To Len(aAtuQtdFil)
      If aAtuQtdFil[i][1] = "INCLUIR"
         AuxAtuFilIncluir(i) // inclui o item
         
      ElseIf aAtuQtdFil[i][1] = "ALTERAR"
         AuxAtuFilAlterar(i) // altera a quantidade do item
         
      ElseIf aAtuQtdFil[i][1] = "EXCLUIR"
         AuxAtuFilExcluir(i) // exclui o item
         
      EndIf
   Next

   If Len(aAtuQtdFil) > 0
      // Faz backup das works, pois a Ap105CallPrecoI() modifica o conteúdo delas
      For i := 1 To Len(aWorksBackup)
         &("cBk"+aWorksBackup[i]) := CriaTrab(,.F.)
         dbSelectArea(aWorksBackup[i])
         TETempBackup("cBk"+aWorksBackup[i])
      Next
      
      EE7->(DbSetOrder(1))
      EE7->(DbSeek(cFilOpos + M->EE7_PEDIDO))
      AP105CallPrecoI(cFilOpos) // Recalcula os preços do pedido na filial oposta
      If cFilAtu == cFilEx
         Ap105EnviaFat(aItDelete)  // reenvia dados do faturamento
      EndIf
      EE7->(DbSeek(cFilAtu + M->EE7_PEDIDO))
      
      // Retorna o backup
      For i := 1 To Len(aWorksBackup)
         dbSelectArea(aWorksBackup[i])
         AvZap()
         TERestBackup("cBk"+aWorksBackup[i])
      Next
   EndIf
   
End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Função     : AuxAtuFilIncluir()
Objetivos  : Auxiliar a Ap104AtuFil na Inclusão de itens
Parâmetros : j -> índice atual do aAtuQtdFil
Autor      : João Pedro Macimiano Trabbold
*/
*---------------------------------*
Static Function AuxAtuFilIncluir(j)
*---------------------------------*
Local lRet := .t., i, nRateio
Local nOldArea := Select(), cOldFilter, cFiltro := "" 

Local cSequen := aAtuQtdFil[j][2], nValor  := aAtuQtdFil[j][3], cSeq := aAtuQtdFil[j][4]
Local cNewSeq := ""
Local aCmpToClean := {"EE8_ORIGV" ,"EE8_RV"    ,"EE8_DTRV"  ,"EE8_DTVCRV",;
                      "EE8_DTFIX" ,"EE8_ORIGEM","EE8_QTDLOT","EE8_STFIX" ,;
                      "EE8_DTCOTA","EE8_DIFERE","EE8_MESFIX"}

Begin Sequence

   // Posiciona no item de exemplo na filial atual
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFilAtu + M->EE7_PEDIDO + cSequen))
  
   //Faz uma cópia do item na memória....
   For i := 1 to EE8->(FCount())
      M->&(EE8->(FieldName(i))) := EE8->&(EE8->(FieldName(i)))
   Next

//   EE8->(AvSeekLast(cFilOpos + M->EE7_PEDIDO)) // Posiciona no último item da filial oposta

   SX3->(DbSetOrder(2))
   // Limpa os campos do array aCmpToClean
   For i := 1 to Len(aCmpToClean)
      If SX3->(DbSeek(aCmpToClean[i])) .And. Type("M->"+aCmpToClean[i]) <> "U"
         &("M->"+aCmpToClean[i]) := CriaVar(aCmpToClean[i])
      EndIf
   Next
   
   M->EE8_PRECO  := EE8->EE8_PRENEG

   If Type("EE8->EE8_UNPRNG") <> "U" .And. !Empty(EE8->EE8_UNPRNG)
      M->EE8_UNPRC  := EE8->EE8_UNPRNG
   EndIf
   
   M->EE8_SEQUEN := EE8->EE8_SEQUEN //Str(Val(EE8->EE8_SEQUEN)+1,AvSX3("EE8_SEQUEN",AV_TAMANHO),0) // Grava próxima sequência
   M->EE8_FILIAL := cFilOpos // troca a filial

   nRateio := nValor / M->EE8_SLDINI
   M->EE8_SLDINI := nValor
   M->EE8_SLDATU := nValor
   // Recalcula os pesos....
   M->EE8_PSBRTO *= nRateio
   M->EE8_PSLQTO *= nRateio
   M->EE8_QTDEM1 *= nRateio
   
   DbSelectArea("EE8")
   cOldFilter := DbFilter()
   If(Empty(AllTrim(cOldFilter)),cOldFilter := ".t.",Nil)

   //Set Filter To (EE8_FILIAL+EE8_PEDIDO+Ap104SeqIt() == cFilOpos+M->EE7_PEDIDO+cSeq) //pega um item da mesma origem como exemplo
   cFiltro := "EE8_FILIAL+EE8_PEDIDO+"+Ap104SeqIt()+" == '"+cFilOpos+"+M->EE7_PEDIDO+"+cSeq+"'"
   dbSetFilter(&("{|| "+cFiltro+"}"),cFiltro)//AOM - 16/07/2011 - Versao M11.5
   
   
   EE8->(DbGoTop())
   If EE8->(Bof() .And. Eof())
      
   Else
      // Cria vínculo com itens da mesma origem
      If !Empty(M->EE8_ORIGV+M->EE8_ORIGEM)
         M->EE8_ORIGV  := EE8->EE8_ORIGV
         M->EE8_ORIGEM := EE8->EE8_ORIGEM
      Else // se não tem campos de origem, então o item não foi "quebrado". Então o item que está sendo incluído terá vinculo apenas com ele.
         M->EE8_ORIGEM := EE8->EE8_SEQUEN
         EE8->(RecLock("EE8",.F.))
         EE8->EE8_ORIGEM := M->EE8_ORIGEM
         EE8->(MsUnlock())
      EndIf
   EndIf
   
   //Set Filter to &cOldFilter 
   dbSetFilter(&("{|| "+cOldFilter+"}"),cOldFilter)//AOM - 16/07/2011 - Versao M11.5

   EE8->(RecLock("EE8",.T.)) // Trava um registro novo
   cFilAnt := cFilOpos       // AvReplace grava através do xFilial
   AvReplace("M","EE8")      // copia dados da memória para a base
   cFilAnt := cFilAtu
   EE8->(MsUnlock())         // destrava o registro
   
End Sequence

DbSelectArea(nOldArea)

Return lRet

/*
Função     : AuxAtuFilAlterar()
Objetivos  : Auxiliar a Ap104AtuFil na alteração de itens
Parâmetros : j -> índice atual do aAtuQtdFil
Autor      : João Pedro Macimiano Trabbold
*/
*---------------------------------*
Static Function AuxAtuFilAlterar(j)
*---------------------------------*
Local lRet := .t., nRateio

Local cSequen := aAtuQtdFil[j][2], nValor  := aAtuQtdFil[j][3]

Begin Sequence

   // Posiciona no item que será atualizado
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFilOpos + M->EE7_PEDIDO + cSequen))

   EE8->(RecLock("EE8",.f.)) // Trava o registro para alteração
   
   nRateio := (EE8->EE8_SLDINI + nValor) / EE8->EE8_SLDINI
   EE8->EE8_SLDINI += nValor
   EE8->EE8_SLDATU += nValor
   // Recalcula os pesos....
   EE8->EE8_PSBRTO *= nRateio
   EE8->EE8_PSLQTO *= nRateio
   EE8->EE8_QTDEM1 *= nRateio

   EE8->(MsUnlock())         // destrava o registro
   
End Sequence

Return lRet

/*
Função     : AuxAtuFilExcluir()
Objetivos  : Auxiliar a Ap104AtuFil na Exclusão de itens
Parâmetros : j -> índice atual do aAtuQtdFil
Autor      : João Pedro Macimiano Trabbold
*/
*---------------------------------*
Static Function AuxAtuFilExcluir(j)
*---------------------------------*
Local lRet := .t.
Local cSequen := aAtuQtdFil[j][2]

Begin Sequence

   // Posiciona no item que será atualizado
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(cFilOpos + M->EE7_PEDIDO + cSequen))
   
   AAdd(aItDelete,EE8->(RecNo()))
   
   EE8->(RecLock("EE8",.f.)) // Trava o registro para alteração
   EE8->(DbDelete())         // Deleta o registro
   EE8->(MsUnlock())         // destrava o registro
   
End Sequence

Return lRet

/*
Função     : Ap104LoadGrp()
Objetivos  : Carregar a work de agrupamentos no pedido, e no caso de já existir algum registro, atualiza.
Parâmetros : lPed = é Pedido? (se não for informado, analisa o ambiente.)
Retorno    : .t./.f.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 07/10/05 às 15:45
*/
*-------------------------*
Function Ap104LoadGrp(lPed)
*-------------------------*
Local lRet := .t., aItens := {}, aGroup := {}, i, j, k, x, aAux, aAux2
Local cWork, cAlias, lJaExiste, lTemFlag
Local cConsolida := Ap104StrCpos(aConsolida)
Local nItem := 0
Local nRec := WorkGrp->(RecNo())

Default lPed := Select("WorkIt") > 0

If lPed
   cWork  := "WorkIt"
   cAlias := "EE8"
Else
   cWork := "WorkIp"
   cAlias := "EE9"
EndIf

Begin Sequence
   WorkGrp->(DbSetOrder(1))
   // Agrupa os itens nos arrays aItens e aGroup
   (cWork)->(DbGoTop())
   While (cWork)->(!Eof())
      (cWork)->(AddItemGroup(aItens,aGroup),DbSkip())
   EndDo
   
   For i := 1 To Len(aGroup) // Agrupamentos por sequência
      aAux := aGroup[i][2]   // aAux == Grupo de Itens com origem aGroup[i][1]

      For j := 1 To Len(aAux) // Agrupamentos por campos do aConsolida
         aAux2 := aAux[j][2]  // aAux2 == Grupo de Itens com origem aGroup[i][1] e Campos aAux[j][1] com conteúdo igual
         If Len(aAux2) = 0
            Loop
         EndIf
         
         lJaExiste := .f.
         If WorkGrp->(DbSeek(aGroup[i][1])) //Procura a sequência
            While WorkGrp->(!EoF()) .And. aGroup[i][1] == WorkGrp->(If(lPed, "", EE9_PEDIDO) + &(cAlias + "_ORIGEM"))
               If WorkGrp->&(cConsolida) == aGroup[i][2][j][1] // se achar um registro igual, exclui para incluir novamente.
                  lJaExiste := .t.
                  Exit
               EndIf
               WorkGrp->(DbSkip())
            EndDo
         EndIf
         If lJaExiste
            SX3->(DbSetOrder(2))
            For x := 1 To Len(aGrpCpos)// se já existe, limpa todos os campo, para recalcular
               If SX3->(DbSeek(aGrpCpos[x]))
                  //WorkGrp->&(aGrpCpos[x]) := CriaVar(aGrpCpos[x])
                  WorkGrp->&(aGrpCpos[x]) := CriaVar(aGrpCpos[x], .F.)//SVG - 28/07/08 -ch. 076097 - Para criar em branco, não deve considerar o Inicializador padrão
               Else
                  If AllTrim(ValType(WorkGrp->&(aGrpCpos[x]))) $ "C/M"
                     WorkGrp->&(aGrpCpos[x]) := ""
                  ElseIf ValType(WorkGrp->&(aGrpCpos[x])) = "N"
                     WorkGrp->&(aGrpCpos[x]) := 0
                  ElseIf ValType(WorkGrp->&(aGrpCpos[x])) = "D"
                     WorkGrp->&(aGrpCpos[x]) := AvCToD("  /  /  ")
                  EndIf
               EndIf
            Next
         Else
            WorkGrp->(DbAppend())
         EndIf
         
         If lPed
            lTemFlag := .f.
         Else
            lTemFlag := .f.
            For k := 1 To Len(aAux2) // Itens
               (cWork)->(DbGoTo(aAux2[k][1])) // Posiciona no item da work
               If !Empty(WorkIp->WP_FLAG)
                  lTemFlag := .t.
                  Exit
               EndIf
            Next
         EndIf
         
         nItem := 0
         For k := 1 To Len(aAux2) // Itens
            (cWork)->(DbGoTo(aAux2[k][1])) // Posiciona no item da work

            If !lPed
               // Flag de marcação -> "S","P" e "N" (Sim, Parcial e Não)
               If k == 1
                  WorkGrp->WP_FLAG := If(Empty(WorkIp->WP_FLAG),"N","S")
               Else
                  If AllTrim(WorkGrp->WP_FLAG) <> "P"
                     If If(Empty(WorkIp->WP_FLAG),"N","S") <> AllTrim(WorkGrp->WP_FLAG)
                        WorkGrp->WP_FLAG := "P"
                     EndIf
                  EndIf
               EndIf
               
               WorkGrp->WP_SLDATU += WorkIp->WP_SLDATU
            EndIf
            
            If lTemFlag .And. Empty(WorkIp->WP_FLAG) // se há itens já selecionados, então totaliza de acordo com eles, senão, soma geral.
               Loop
            EndIf
            
            nItem++
            
            For x := 1 To Len(aGrpCpos) // campos da work
               If aGrpCpos[x] = "WP_FLAG" // já foi processado acima
                  Loop
               
               ElseIf aGrpCpos[x] = "WP_SLDATU " // já foi processado acima
                  Loop
               
               ElseIf aGrpCpos[x] = cAlias+"_ORIGEM" // Origem
                  If lPed
                     WorkGrp->&(aGrpCpos[x]) := (cWork)->(Ap104SeqIt())
                  Else
                     WorkGrp->&(aGrpCpos[x]) := (cWork)->(Ap104SeqIt(,,.t.)) //Pra pegar só a sequência
                  EndIf

               ElseIf aGrpInfo[x] = "T" //Totaliza
                  WorkGrp->&(aGrpCpos[x]) += (cWork)->&(aGrpCpos[x])

               ElseIf aGrpInfo[x] = "S" // Sempre igual
                  If Empty(WorkGrp->&(aGrpCpos[x]))
                     WorkGrp->&(aGrpCpos[x]) := (cWork)->&(aGrpCpos[x])
                  EndIf

               ElseIf aGrpInfo[x] = "N" // Não é sempre igual
                  If nItem == 1 // se é o primeiro, atribui o valor do campos
                     WorkGrp->&(aGrpCpos[x]) := (cWork)->&(aGrpCpos[x])
                  Else // se não é o primeiro, e o conteúdo é diferente, o campo fica vazio.
                     If WorkGrp->&(aGrpCpos[x]) <> (cWork)->&(aGrpCpos[x])
                        WorkGrp->&(aGrpCpos[x]) := CriaVar(aGrpCpos[x])
                     EndIf
                  EndIf

               EndIf
            Next // Campos da WorkGrp
         Next // Itens
      Next // Agrupamentos pelos campos do aConsolida
   Next // Agrupamentos por sequência
   
   WorkGrp->(DbGoTo(nRec))
   If nRec <> 0 .Or. WorkGrp->(EoF())
      WorkGrp->(DbGoTop())
   EndIf
   
End Sequence

Return lRet

/*
Função     : Ap104TrtCampos()
Objetivos  : Tratar campos da MsGetDb
Parâmetros : nCall - Chamada
Retorno    : Nenhum
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 18/10/05 às 10:45
Obs.       : 
*/

*------------------------------*
Function Ap104TrtCampos(nCall)
*------------------------------*
Local nPos, i, cPasta, lEmptyPasta, cOldAlias := Alias(), aCposAdic := {}
Local lRet := .T.
Local nRecCont := 0
Local nOldRec := WorkIt->(Recno())

Begin Sequence
  
   If nCall == 1
      aCposDif := {"EE8_RV    ","EE8_SLDINI","EE8_SLDATU","EE8_QTDEM1","EE8_PRECO ","EE8_DIFERE","EE8_TOTAL "} //EE8_PRENEG

      // ** Incluir campos de fixação de preço no Browse novo
      cPasta := ""
      lEmptyPasta := .t.
      SXA->(DbSetOrder(1))
      SXA->(DbSeek("EE8"))
      While SXA->(!EoF()) .And. SXA->XA_ALIAS == "EE8"
         If AllTrim(SXA->XA_DESCRIC) = "Diferencial de Preco"
            cPasta := SXA->XA_ORDEM
            lEmptyPasta := .f.
            Exit
         EndIf
         SXA->(DbSkip())
      EndDo
   
      SX3->(DbSetOrder(2))
      If lEmptyPasta
         cPasta := "2"
         If SX3->(!DbSeek("EE8_DTFIX ")) .Or. SX3->X3_FOLDER <> cPasta // Verifica se é a pasta de fixação mesmo...
             cPasta := ""
         EndIf
      EndIf
      
      If !Empty(cPasta)
         AAdd(aCposDif,"EE8_MESFIX")
         For i := 1 To Len(aItemEnchoice)
            SX3->(DbSeek(aItemEnchoice[i]))
            If SX3->X3_FOLDER = cPasta .And.; // se for campo de fixação de preço, vai para o browse
               !(SX3->X3_CAMPO $ "EE8_MESFIX/EE8_DIFERE/EE8_UNPRC /EE8_UNPRCC")
               If AScan(aCposDif,SX3->X3_CAMPO) = 0
                  AAdd(aCposDif,SX3->X3_CAMPO)
               EndIf
            EndIf
         Next
      EndIf
      // ** Fim
        
      Eval({|x, y| aSize(x, Len(x)+Len(y)),;
                   aCopy(y, x,,, Len(x)-Len(y)+1 )}, aCposDif, {"EE8_DTPREM","EE8_DTENTR","EE8_SEQUEN",;
                                                                "EE8_PSLQTO","EE8_PSBRTO",;
                                                                "EE8_PRECOI","EE8_PRCINC","EE8_PRCTOT",;
                                                                "EE8_DTVCRV"})
      If EECFlags("CAFE")
         aCposAdic := {"EE8_PRECO2","EE8_PRECO3","EE8_PRECO4","EE8_PRECO5"}
         For i := 1 To Len(aCposAdic)
            If EE8->(FieldPos(aCposAdic[i])) > 0 .And. AScan(aCposDif,aCposAdic[i]) = 0
               aAdd(aCposDif,aCposAdic[i]) // Adicionando os campos novos de preco.
            EndIf
         Next
      Endif
      
      Ap104KeyX3(aCposDif) //Acerta campos
      
      aCposNotShow := {"EE8_SEQUEN","EE8_PSLQTO","EE8_PSBRTO",;
                       "EE8_PRECOI","EE8_PRCINC","EE8_PRCTOT","EE8_VM_FIX",;
                       "EE8_QTDFIX","EE8_DTVCRV","EE8_PRCFIX"}
      
      If xFilial("EE8") = cFilEx
         AAdd(aCposNotShow,"EE8_RV")
      EndIf

      Ap104KeyX3(aCposNotShow)
      
      For i := 1 To Len(aGrpCpos)
         If aGrpInfo[i] = "N" // se for um campo que não é sempre igual para todos os itens, vai para o aCposDif
            If AScan(aCposDif,aGrpCpos[i]) = 0
               AAdd(aCposDif,aGrpCpos[i])
            EndIf
         EndIf
      Next
      
      If EasyEntryPoint("EECAP104")
         ExecBlock("EECAP104", .F., .F., "ARRAY_BROWSE_ITENS")
      EndIf
      
      // campos que vão para o browse
      For i := 1 To Len(aCposDif)
         If AScan(aCposNotShow,aCposDif[i]) = 0
            If aCposDif[i] == "EE8_TOTAL "
               SX3->(DbSeek("EE8_PRCTOT")) //campo de exemplo
               SX3->(AAdd(aCposGetDb,{STR0124,"EE8_TOTAL ",x3_picture,x3_tamanho,x3_decimal,"",nil,x3_tipo,nil,nil}) ) //"Total"
            Else
               AAdd(aCposGetDb,aCposDif[i])
            EndIf
         EndIf
      Next
   
      // FDR - 25/10/10
      aCposGetDb := AddCpoUser(aCposGetDb,"EE8","3")
      aHeader := EECMontaHeader(aCposGetDb) // A header para a MsGetDb() na nova folder de itens
      
      DbSelectArea("WorkIt")
      
      bConsolida := &("{|| WorkIt->(Ap104SeqIt() + " + cConsolida + ") }")
      cGrpFilter := WorkGrp->(EE8_ORIGEM+&(cConsolida))                                                                                  	
      // Filtro para que só sejam considerados os itens que pertençam à consolidação
      WorkIt->(DbSetFilter({|| cGrpFilter == Eval(bConsolida)}, "cGrpFilter == Eval(bConsolida)"))
   
      //ER - 24/11/2006 - Verifica se existe quebra de linha para o Item. Em caso negativo não trata o Item como Consolidação.
      DbGoTop()
      
      nRecCont := 0

      While WorkIt->(!EOF())
         nRecCont ++ 
         WorkIt->(DbSkip())
      EndDo
      
      If nRecCont <= 1
         lRet := .F.
         WorkIt->(DbGoTop())
         lConsolItem := .F.
         nOldRec := WorkIt->(Recno())
         Break
      EndIf
      
      DbGoTop()

      // Cria estrutura para work.
      aStruct := DbStruct()
      SX3->(DbSeek("EE8_PRCTOT"))
      AAdd(aStruct,{"EE8_TOTAL","N",SX3->X3_TAMANHO,SX3->X3_DECIMAL})
      aAdd(aStruct,{"DBDELETE","L",1,0}) //THTS - 31/10/2017 - Este campo deve sempre ser o ultimo campo da Work
      // Cria work auxiliar para MsGetDb()
      cAuxIt := E_CriaTrab(,aStruct,"AuxIt")
         
      /* Carrega AuxIt com dados iguais aos da WorkIt, exceto pelo EE8_RECNO, que aponta para o 
         o registro correspondente na WorkIt */
      WorkIt->(DbGoTop())
      While WorkIt->(!Eof())
         AuxIt->(DbAppend())
         AvReplace("WorkIt","AuxIt")
         AuxIt->EE8_RECNO := WorkIt->(RecNo()) // aponta para o recno respectivo na WorkIt
         AuxIt->EE8_TOTAL := WorkIt->(EE8_PRECO*EE8_SLDINI)
         
         WorkIt->(DbSkip())
      EndDo
   
      WorkIt->(DbGoTop())
      AuxIt->(DbGoTop())
   
      // Limpa filtro
      WorkIt->(DbClearFilter())
   
   ElseIf nCall == 2
   
      If Empty(aEE8CamposEditaveis)
         aEE8CamposEditaveis := aClone(aItemEnchoice)
      EndIf
      
      Ap104KeyX3(aEE8CamposEditaveis)
      Ap104KeyX3(aItemEnchoice)
      
      For i := 1 To Len(aCposDif)
         If AScan(aEE8CamposEditaveis,aCposDif[i]) = 0 .Or. AScan(aItemEnchoice,aCposDif[i]) = 0
            AAdd(aNotEditGetDb,aCposDif[i])
         EndIf

         // Todos os campos do novo browse não aparecerão na enchoice, exceto na(s) situação(ões) enumerada(s) abaixo:
            
         // ** 1 - se é um campo da work de agrupamento e o campo for de totalizar, aparecerá ma enchoice (se já existir no aItemEnchoice), porém não será editável.
         If (nPos := AScan(aGrpCpos,aCposDif[i])) > 0                   // procura na work de agrupamentos
            If aGrpInfo[nPos] = "T"                                       // é de totalizar??
               AAdd(aTotaliza,aCposDif[i])
               If (nPos := AScan(aEE8CamposEditaveis,aCposDif[i])) > 0 // é editável? se for, não será mais.
                  aDel(aEE8CamposEditaveis,nPos)
                  aSize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
               EndIf
               Loop //para não excluir do aItemEnchoice
            EndIf   
         EndIf
         // **
         
         If (nPos := AScan(aItemEnchoice,aCposDif[i])) > 0
            aDel(aItemEnchoice,nPos)
            aSize(aItemEnchoice,Len(aItemEnchoice)-1)
         EndIf

         If (nPos := AScan(aEE8CamposEditaveis,aCposDif[i])) > 0
            aDel(aEE8CamposEditaveis,nPos)
            aSize(aEE8CamposEditaveis,Len(aEE8CamposEditaveis)-1)
         EndIf
      Next
      
      SX3->(DbSetOrder(2))

      For i := 1 To Len(aItemEnchoice)
         If !(aItemEnchoice[i] $ "EE8_PSBRTO/EE8_PSLQTO/EE8_QTDEM1/EE8_SLDINI/EE8_PRCFIX/EE8_QTDFIX") .And. SX3->(DbSeek(aItemEnchoice[i])) .And. SX3->X3_TIPO = "N"
            If (AScan(aAllCpos,aItemEnchoice[i]) = 0)
               AAdd(aAllCpos,aItemEnchoice[i])
            EndIf
         EndIf
      Next

      For i := 1 To Len(aCposDif)
         If !(aCposDif[i] $ "EE8_PSBRTO/EE8_PSLQTO/EE8_QTDEM1/EE8_SLDINI/EE8_PRCFIX/EE8_QTDFIX") .And. SX3->(DbSeek(aCposDif[i])) .And. SX3->X3_TIPO = "N"
            If (AScan(aAllCpos,aCposDif[i]) = 0)
               AAdd(aAllCpos,aCposDif[i])
            EndIf
         EndIf
      Next
      
      SX3->(DbSetOrder(2))
      For i := 1 To Len(aItemEnchoice)
         If SX3->(DbSeek(aItemEnchoice[i]))
            AAdd(aDifValid,{aItemEnchoice[i],SX3->X3_VALID})
         Else
            AAdd(aDifValid,{aItemEnchoice[i],".t."})
         EndIf
      Next
      
      For i := 1 To Len(aCposDif)
         If ASCan(aDifValid,{|x| x[1] == aCposDif[i]}) = 0
            If SX3->(DbSeek(aCposDif[i]))
               AAdd(aDifValid,{aCposDif[i],SX3->X3_VALID})
            Else
               AAdd(aDifValid,{aCposDif[i],".t."})
            EndIf
         EndIf
      Next
   

      Ap104AuxIt(6) //carregar variáveis de memória que devem ser totalizadas
      
   EndIf
 
End Sequence

DbSelectArea(cOldAlias)
WorkIt->(DbGoTo(nOldRec))

Return lRet

/*
Função     : Ap104TelaIt()
Objetivos  : Adicionar folder na tela de detalhes do pedido, e criar Browse de edição de itens
Parâmetros : oMsMGet
Retorno    : Objeto Folder Novo e objeto MsGetDb Novo, em um array
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 11/10/05 às 13:37
Obs.       : 
*/

*---------------------------*
Function Ap104TelaIt(oMsMGet)
*---------------------------*
Local oFolderItem, oMsGetDb, aPos, i, aCpos
Local aAlter := {}

Begin Sequence
   
   If !lLibPes
      AAdd(aNotEditGetDb,"EE8_PSLQTO")
      AAdd(aNotEditGetDb,"EE8_PSBRTO")
   EndIf

   AAdd(aNotEditGetDb,"EE8_SLDATU")
   AAdd(aNotEditGetDb,"EE8_TOTAL")
   
   For i := 1 To Len(aCposGetDb)
      If ValType(aCposGetDb[i]) = "C"
         c := aCposGetDb[i]
      Else
         c := aCposGetDb[i][2]
      EndIf
      If AScan(aNotEditGetDb,c) = 0
         AAdd(aAlter,c)
      EndIf
   Next
   
   //JPM - Adiciona nova folder de itens (oMsmGet:oBox == Instância do TFolder())
   oMsmGet:oBox:AddItem(STR0121 + " &" + AllTrim(WorkGrp->EE8_ORIGEM)) //"Itens da Origem"
   //oFolderItem := Eval({|a| a[Len(a)] },oMsMGet:oBox:aDialogs)
   oFolderItem := ATail(oMsMGet:oBox:aDialogs) // oFolderItem == pasta que acabou de ser adicionada
   
   // para que nas validações e gatilhos feitos para cada item, sejam simuladas as variáveis de memória, baseadas na AuxIt
   For i := 1 To Len(aHeader)
      AddValid(@aHeader[i][2],@aHeader[i][6])
   Next
   
   aPos := PosDlg(oFolderItem)
   
   oMsGetDb := MsGetDb():New(aPos[1],aPos[2],aPos[3],aPos[4],; // Posições da Tela
                             If(nOpcI==ALT_DET,3,2),;          // Tipo (Inclusão, Alt., etc.)
                             "Ap104AuxIt(5)",;                 // cLinhaOk
                             ,,.T.,;                           // Permite deleção de registros
                             aAlter,;                          // Campos que podem ser alterados
                             0,,,;                             // Nro. de Colunas que serão congeladas
                             "AuxIt",,,;                       // Work que será mostrada no Browse
                             .f.,;                             // Define se as linhas poderão ser incluídas
                             oFolderItem,;                     // Objeto no qual está inserida a MsGetDb
                             .f.,,;                            // Define se vai utilizar características do dicionário (gatilhos, consultas...)
                             "Ap104AuxIt(2)",)                 // Função que valida exclusão
   
   oMsGetDb:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oMsGetDb:oBrowse:bAdd  := {||.F.} // não inclui novos itens
   oMsmGet:oBox:bChange := {||Ap104AuxIt(7,,.t.),nOpcFolder := aObjs[3]:oBox:nOption} // calcula totais
   
   oMsGetDb:oBrowse:bLDblClick := {|| If(aHeader[oMsGetDb:oBrowse:nColPos][8]=="M" , AP104DbClick() , ;
                                      oMsGetDb:EditCell()) } // FJH 15/12/05 - Tratamento para cpos memo
   oMsGetDb:oBrowse:bKeyDown   := {|| If(aHeader[oMsGetDb:oBrowse:nColPos][8]=="M" , AP104DbClick() , ;
                                      oMsGetDb:EditCell()) }
   
   // Incluir validação de when: não permitir que itens com RV e Fixação de preço sejam alterados.
   aCpos := oMsGetDb:aInfo
   For i := 1 To Len(aCpos)
      cOldWhen := AllTrim(aCpos[i][4])
      aCpos[i][4] := "Ap104AuxIt(1,2)"
      If !Empty(cOldWhen)
         aCpos[i][4] += " .And. (" + cOldWhen + ")"
      EndIf
                             // carrega var. memoria, valida, restaura var. memo. e retorna validação
      aCpos[i][4] := "Eval( {|| Ap104AuxIt(1,1), ret := (" + aCpos[i][4] + "), Ap104AuxIt(1,3), ret } )"
      
   Next
   
End Sequence

Return {oFolderItem,oMsGetDb,oMsmGet}


// Função Auxiliar
Static Function AddValid(cCpo,cValid)

Begin Sequence
   If Empty(AllTrim(cValid))
      cValid := ".t."
   EndIf
   If cCpo = "EE8_SLDINI" // validação específica para quantidade.
      cValid := "(" + cValid + ") .And. Ap104AuxIt(8)"
   EndIf
   
   cValid := "Eval( {|| Ap104AuxIt(3), ret := (" + cValid + "), Ap104AuxIt(4,ret), ret } )"
   
End Sequence
      
Return Nil

/*
Função     : AP104DbClick()
Objetivos  : Tratamento de campos memo
Parâmetros : nenhum
Retorno    : .T./.F.
Autor      : Fabio Justo Hildebrand
Data/Hora  : 15/12/05 às 11:10
Obs.       : 
*/

Function AP104DbClick(nCol)
Local lRet := .F., oMsGetDb2 := aObjs[2]

lRet := AE104MemoEdit(aMemoItem[aScan(aMemoItem,{|x| x[2] == aHeader[oMsGetDb2:oBrowse:nColPos][2]})][1], ; 
        aHeader[oMsGetDb2:oBrowse:nColPos][2],aHeader[oMsGetDb2:oBrowse:nColPos][1],.T.)
         
//oMsGetDb2:aCols[nLine][oMsGetDb2:oBrowse:nColPos] := &("M->"+aHeader[oMsGetDb2:oBrowse:nColPos][2])
&("AuxIt->"+aHeader[oMsGetDb2:oBrowse:nColPos][2]+" := M->"+aHeader[oMsGetDb2:oBrowse:nColPos][2])

Return lRet

/*
Função     : Ap104AuxIt()
Objetivos  : Validações e Tratamentos diversos para Controle de quantidades fil. Br e Ex
Parâmetros : nTipo
             xAux - Variável auxiliar qualquer
             lAux - Variável auxiliar lógica
Retorno    : .t./.f.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 11/10/05 às 14:25
Obs.       : 
*/

*----------------------------------------*
Function Ap104AuxIt(nTipo,xAux,lAux,lAux2)
*----------------------------------------*
Local  lRet := .t., i, j, nRec, cOldReadVar, aVarBk := {}, lValAndTrigger, lTotaliza
Static aVar := {}
Default lAux2 := .t.

Begin Sequence
   
   *----------------------------------------------------------------------------------------------------------------------------------------------*
   If nTipo == 1 // Validar se o item no MsGetDb pode ser alterado

      If xAux == 1
         Ap104AuxIt(3) // Carrega variáveis de memória e faz backup
      ElseIf xAux == 2
         If AuxIt->(!Empty(EE8_DTFIX) .Or. !Empty(EE8_RV))
            MsgInfo(STR0120,STR0004) //"Não é possível alterar itens com R.V. ou com Preço Fixado.","Aviso"
            lRet := .f.
            Break
         EndIf
      ElseIf xAux == 3
         Ap104AuxIt(4,.f.) // volta backup
      EndIf
   *----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 2 // Validar se o item no MsGetDb pode ser excluído
      If !Ap104AuxIt(1,2)
         lRet := .f.
         Break
      EndIf
      
      If !Ap100VldExc("AuxIt")
         lRet := .f.
         Break
      EndIf
      
      // Ao deletar/undeletar um item da consolidação, deve-se subtrair/somar os campos de total
      For i := 1 To Len(aTotaliza)
         If AuxIt->DBDELETE
            M->&(aTotaliza[i]) -= AuxIt->&(aTotaliza[i])
         Else
            M->&(aTotaliza[i]) += AuxIt->&(aTotaliza[i])
         EndIf
      Next

   *----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 3 /* Chamada antes de qualquer Valid de campos da MsGetDb():
                        Simular que as variáveis de memória tenham o conteúdo da work AuxIt */
      Default lAux := .f.
      lArtificial := .t.
      WorkIt->(DbGoTo(AuxIt->EE8_RECNO))
      aVar := {}
      For i := 1 To Len(aCposDif)
         If lAux .Or. aCposDif[i] <> SubStr(ReadVar(),4)
            AAdd(aVar,M->&(aCposDif[i])) // faz backup da memória
            M->&(aCposDif[i]) := AuxIt->&(aCposDif[i]) // Joga o conteúdo de AuxIt na Memória, para os campos da GetDb
         Else
            AAdd(aVar,Nil)
         EndIf
      Next

   *----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 4 /* Chamada depois de qualquer Valid de campos da MsGetDb():
                        voltar as variáveis de memória simuladas no nTipo == 3 */
      Default xAux := .t.
      Default lAux := .f.
      WorkIt->(DbGoTo(AuxIt->EE8_RECNO))

      If xAux // retorno das validações do campo.
         If Len(aVar) = 0
            Ap104AuxIt(3) // Carrega variáveis de memória e faz backup
         EndIf
         
         cCpo := SubStr(ReadVar(),4,10)
         If lAux2 .Or. !(cCpo $ "EE8_PRECO /EE8_PRECO2/EE8_PRECO3/EE8_PRECO4/EE8_PRECO5/")
            If !(cCpo $ "EE8_QTDFIX/EE8_COD_I ") .And. ExistTrigger(cCpo)
               RunTrigger(1,,,cCpo) /* Executa gatilhos agora, na hora da validação para que 
                                       depois possa voltar os backups (Memória e AuxIt)*/
            EndIf
         EndIf
         
         If cCpo $ "EE8_SLDINI/EE8_PRECO "
            M->EE8_TOTAL := M->EE8_SLDINI*M->EE8_PRECO
         EndIf
         
         If cCpo $ "EE8_QTDEM1/EE8_SLDINI"
            M->EE8_SLDATU := WorkIt->EE8_SLDATU + M->EE8_SLDINI - WorkIt->EE8_SLDINI
         EndIf
         
         If cCpo $ "EE8_QTDEM1"
            // ** Executa validações/gatilhos necessários
            aVarBk := AClone(aVar)
            cOldReadVar := __readvar
            __readvar := "M->EE8_SLDINI"
            Ap104AuxIt(3)
            &(aDifValid[AScan(aDifValid,{|x| x[1] = "EE8_SLDINI"})][2])
            Ap104AuxIt(4,.t.)
            __readvar := cOldReadVar
            aVar := AClone(aVarBk)
            // **
         EndIf
         
         For i := 1 To Len(aCposDif)
            AuxIt->&(aCposDif[i]) := M->&(aCposDif[i]) // Joga o conteúdo da memória na AuxIt, para os campos da GetDb
         Next

      EndIf
      
      If Len(aVar) > 0
         For i := 1 To Len(aCposDif)
            If lAux .Or. aCposDif[i] <> SubStr(ReadVar(),4)
               M->&(aCposDif[i]) := aVar[i] // volta o backup das variáveis de memória
            EndIf
         Next
      EndIf

      aVar := {}
      lArtificial := .f.
   *----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 5 /* Chamada no cLinhaOk da MsGetDb: a cada movimentação na MsGetDb 
                        (consequentemente na AuxIt) a WorkIt deve acompanhar  */
      WorkIt->(DbGoTo(AuxIt->EE8_RECNO))

   *----------------------------------------------------------------------------------------------------------------------------------------------*      
   ElseIf nTipo == 6 // Chamada antes da apresentação da enchoice de itens, para carregar as variáveis de memória que são totalizadas
      For i := 1 To Len(aTotaliza)
         M->&(aTotaliza[i]) := WorkGrp->&(aTotaliza[i]) // pega da WorkGrp, que já está totalizado
      Next

   *----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 7 // Recalcula os totais
      
      Default lAux := .f.
      lArtificial := .t.
      If lAux // chamada do bChange da folder
         lValAndTrigger := .f.
         lTotaliza := .f.
         If aObjs[3]:oBox:nOption = Len(aObjs[3]:oBox:aDialogs) // só valida e gatilha se acabou de mudar para a nova folder.
            lValAndTrigger := .t.
         ElseIf nOpcFolder = Len(aObjs[3]:oBox:aDialogs) // só totaliza se acabou de mudar da nova folder para outra qualquer.
            lTotaliza := .t.
         EndIf
      Else // chamada em outros lugares
         If ValType(xAux) = "L"
            If xAux
               lValAndTrigger := .f.
               lTotaliza := .t.
            Else
               lValAndTrigger := .t.
               lTotaliza := .f.
            EndIf
         Else
            lValAndTrigger := .t.
            lTotaliza := .t.
         EndIf
      EndIf
      nRec := AuxIt->(RecNo())

      If lValAndTrigger
         // ** Executar validações e gatilhos
         AuxIt->(DbGoTop())
         cOldReadVar := __readvar // armazena variável de leitura
         While AuxIt->(!EoF())
            If AuxIt->DBDELETE
               AuxIt->(DbSkip())
               Loop
            EndIf
            Ap104AuxIt(3,,.t.)
            
            For i := 1 To Len(aAllCpos)
               If !("EE8_PRECO" $ aAllCpos[i]) .And. !(aAllCpos[i] $ "EE8_COD_I /EE8_PRCTOT/EE8_PRCINC")
                  __readvar := "M->" + aAllCpos[i]
                  
                  // JPM - 17/01/06 - o gatilho do preço negociado só é executado para linhas sem fixação de preço.
                  If aAllCpos[i] = "EE8_PRENEG" .And. (!Empty(AuxIt->EE8_DTFIX) .Or. Empty(M->EE8_PRENEG))
                     Loop
                  EndIf

                  &(aDifValid[AScan(aDifValid,{|x| x[1] = aAllCpos[i]})][2]) // executa validação
                  If ExistTrigger(aAllCpos[i])
                     RunTrigger(1,,,aAllCpos[i])
                  EndIf
               EndIf
            Next
            
            Ap104AuxIt(4,.t.,.t.,.f.)
            AuxIt->(DbSkip())
         EndDo
         __readvar := cOldReadVar //restaura a variável antiga de leitura
         // **
      EndIf
      
      If lTotaliza
         For i := 1 To Len(aTotaliza)
            M->&(aTotaliza[i]) := 0 // zera, para ser recalculado depois
         Next
   
         // Totaliza os campos de memória
         AuxIt->(DbGoTop())
         While AuxIt->(!EoF())
            If AuxIt->DBDELETE
               AuxIt->(DbSkip())
               Loop
            EndIf
            For i := 1 To Len(aTotaliza)
               M->&(aTotaliza[i]) += AuxIt->&(aTotaliza[i])
            Next
            AuxIt->(DbSkip())
         EndDo
   
      EndIf
      
      AuxIt->(DbGoTo(nRec))
      
      If Type("aObjs[2]:oBrowse") = "O" // testa, pois quando é dado o end da dialog, o oBrowse não esxite mais.
         aObjs[2]:oBrowse:Refresh() //Atualiza os dados do browse da MsGetDb()
      EndIf
      lArtificial := .f.
   *----------------------------------------------------------------------------------------------------------------------------------------------*
   ElseIf nTipo == 8 // Valida alterações na quantidade
      If (WorkIt->EE8_SLDATU + M->EE8_SLDINI - WorkIt->EE8_SLDINI) < 0 // valida saldo alocado em embarque.
         MsgStop(STR0122 +; //"A alteração na quantidade não poderá ser efetuada, pois o saldo alocado em embarque"
                 " (" + Transf(WorkIt->EE8_SLDINI-WorkIt->EE8_SLDATU,AvSx3("EE8_SLDINI",AV_PICTURE)) + " " +;
                 AllTrim(UPPER(WorkIt->EE8_UNIDAD)) + ") " +;
                 STR0123,STR0007) // "é maior.","Atenção"
         lRet := .f.
         Break
      EndIf
   EndIf
   *----------------------------------------------------------------------------------------------------------------------------------------------*
      
End Sequence

Return lRet

// Função auxiliar para formatar arrays de uma dimensão que contenham campos do SX3.
*--------------------*
Function Ap104KeyX3(a)
*--------------------*
Local i
For i := 1 To Len(a)
   a[i] := IncSpace(a[i],10,.f.)
Next
Return Nil
 
/*---------------------------------------------------------------------------*
  Fim das rotinas de Controle de Quantidades entre Filiais Brasil e Off-Shore
 *---------------------------------------------------------------------------*/

/*
Função      : Ap104ValInterm()
Objetivos   : validar se os campos de intermediação foram corretamente preenchidos.
Parâmetros  : lPed (pedido ou embarque)
Retorno     : .T./.F.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 06/12/05 às 11:36
*/
*---------------------------*
Function Ap104ValInterm(lPed)
*---------------------------*
Local lRet := .t., i, cAlias
Local aCpos := {"_CLIENT","_CLLOJA","_EXPORT","_EXLOJA","_COND2","_INCO2"}

Default lPed := Type("M->EE7_PEDIDO") = "C"
cAlias := If(lPed,"EE7","EEC")

Begin Sequence
   For i := 1 To Len(aCpos)
      If Empty(M->&(cAlias+aCpos[i]))
         MsgStop(StrTran(STR0125,"###",AvSx3(cAlias+aCpos[i],AV_TITULO)),STR0007) // "Para processos com intermediação, o campo ### deve ser preenchido.","Atenção"
         lRet := .f.
         Break
      EndIf
   Next
End Sequence

Return lRet

/*
Função      : Ap104GatPreco()
Objetivos   : Executar gatilho para os campos de preço
Parâmetros  : cCpo   - Campo executor do gatilho - padrão - ReadVar()
              lPed   - Pedido ou Embarque
              cAlias - Alias
Retorno     : .T.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 20/12/05 às 11:31
*/
*-----------------------------------------------------------*
Function Ap104GatPreco(cCpo,lPed,cAlias,lConv,nVal,cUn1,cUn2)
*-----------------------------------------------------------*
Local i, nPos, nPosTable, lRet := .t., cAl, nValConv
Local c50, c60, cLb, cTon
Local lEECxFAT := EasyGParam('MV_EECFAT',,'')
Local aCpos, aConvTable, aOrd := SaveOrd("SX3")
aConvTable := Ap104ConvTable()
c50  := aConvTable[2]
c60  := aConvTable[3]
cLb  := aConvTable[4]
cTon := aConvTable[5]
aConvTable := aConvTable[1]

aCpos := {{"_PRECO" ,     },;
          {"_PRECO2",c60  },;
          {"_PRECO3",cLb  },;
          {"_PRECO4",cTon },;
          {"_PRECO5",c50  }}

Default cCpo := AllTrim(SubStr(ReadVar(),4))
Default lPed := Select("WorkIt") > 0
Default cAlias := "M"
cAl := If(lPed,"EE8","EE9")

Default lConv  := .f.
Default nVal   := 0
Default cUn1   := ""
Default cUn2   := ""

Begin Sequence

   If lConv
      nPosTable := AScan(aConvTable,{|x| x[1]+x[2] == cUn1+cUn2 }) // procura a conversão na tabela.
      If nPosTable > 0
         Return ApPriceConv(nPosTable,nVal)
      Else
         If AvTransUnid(cUn1, cUn2,, 1, .T.,.T.) = Nil
            MsgInfo(StrTran(StrTran(STR0131,"###",cUn2,,1),"###",cUn1,,1),STR0004) //"Não foi encontrada a taxa de conversão de ### para ###.","Aviso"
            Return .f.
         Else
            Return AvTransUnid(cUn1, cUn2,, nVal, .F.,.T.)
         EndIf
      EndIf
   EndIf

   If &(cAlias+"->"+cAl+"_UNPRC") == cLb //MV_AVG0032
      aCpos[1][2] := "DOLARLIBRA"
   Else
      aCpos[1][2] := &(cAlias+"->"+cAl+"_UNPRC")
   EndIf
   
   If !Ap104VerPreco() .Or. !EECFlags("COMMODITY") //wfs
      Break
   EndIf

   If EECFlags("CAFE") .And. Empty(aCpos[1][2]) 
      MsgAlert(STR0167,STR0004) //"Não foi informada a unidade de medida de PREÇO !" ,"Aviso" 
   EndIf
   
   If lPed
      If !(cCpo $ "EE8_PRECO /EE8_PRECO2/EE8_PRECO3/EE8_PRECO4/EE8_PRECO5/")
         cCpo := "EE8_PRECO"
      EndIf
   Else
      If !(cCpo $ "EE9_PRECO /EE9_PRECO2/EE9_PRECO3/EE9_PRECO4/EE9_PRECO5/")
         cCpo := "EE9_PRECO"
      EndIf
   EndIf
   
   For i := 1 To Len(aCpos)
      aCpos[i][1] := cAl + aCpos[i][1]
   Next
   
   nPos := AScan(aCpos,{|x| x[1] = cCpo})
   If Empty(aCpos[nPos][2])// .Or. !(aCpos[nPos][2] $ c50+"/"+c60+"/"+cLb+"/"+cTon)
      Break
   EndIf

   For i := 1 To Len(aCpos)
      If i <> nPos
         nPosTable := 0
         If !Empty(aCpos[i][2]) .And. aCpos[i][2] $ c50+"/"+c60+"/"+cLb+"/"+cTon+"/"+"DOLARLIBRA"
            nPosTable := AScan(aConvTable,{|x| x[1]+x[2] == aCpos[nPos][2]+aCpos[i][2] }) // procura a conversão na tabela.
            If nPosTable > 0
               &(cAlias+"->"+aCpos[i][1]) := If( aCpos[i][1] == 'EE8_PRECO' .And. lEECxFAT , Round( ApPriceConv(nPosTable,&(cAlias+"->"+cCpo)) ,TamSX3('C6_PRCVEN')[2] ) ,  ApPriceConv(nPosTable,&(cAlias+"->"+cCpo))  )
            EndIf
         EndIf
         If nPosTable = 0
            nValConv := ;
             AvTransUnid(aCpos[nPos][2], aCpos[i][2], , &(cAlias+"->"+cCpo), .F.,.T.)
            //Trata retorno NIL da convesão
            If nValConv = NIL
               &(cAlias+"->"+aCpos[i][1]) := 0
               MsgInfo(STR0157 + aCpos[i][2] + STR0158 + aCpos[nPos][2] + STR0159, STR0160) //Conversão de X p/ Y não cadastrada.
            Else
               &(cAlias+"->"+aCpos[i][1]) := If( aCpos[i][1] == 'EE8_PRECO' .And. lEECxFAT , Round( nValConv ,TamSX3('C6_PRCVEN')[2] ) ,  nValConv  )
            End If            
         EndIf
      EndIf
   Next

   If Select("WorkIt") > 0 .AND. EE9->(FieldPos("EE9_PERIE")) > 0 .AND. EE9->(FieldPos("EE9_BASIE")) > 0 .AND. EE9->(FieldPos("EE9_VLRIE")) > 0   // GFP - 17/12/2015
      If Posicione("SX3",2,"EE9_PERIE","X3_TRIGGER") == "S"
         RunTrigger(1)
      EndIf
      RestOrd(aOrd,.T.)
   EndIf

End Sequence

Return lRet

/*
Função     : Ap104ConvTable()
Objetivos  : Retornar tabela de conversão de precos
Autor      : João Pedro Macimiano Trabbold - 19/01/06
*/
*-----------------------*
Function Ap104ConvTable()
*-----------------------*

Local aConvTable
Local c50  := EasyGParam("MV_AVG0115",,""),; // Unidade de Medida para Sacas de 50
      c60  := EasyGParam("MV_AVG0116",,""),; // Unidade de Medida para Sacas de 60
      cLb  := EasyGParam("MV_AVG0032",,""),; // Unidade de Medida para Cents por Libra
      cTon := EasyGParam("MV_AVG0030",,"")   // Unidade de Medida para Tonelada

c50  := AvKey(c50 ,"J5_DE")
c60  := AvKey(c60 ,"J5_DE")
cLb  := AvKey(cLb ,"J5_DE")
cTon := AvKey(cTon,"J5_DE")
cKG  := AvKey("KG","J5_DE")

aConvTable := {{c50 , c60 },; // Tabela de conversões, de acordo com a ApPriceConv()
               {c50 , cLb },;
               {c50 , cTon},;
               {c60 , c50 },;
               {c60 , cLb },;
               {c60 , cTon},;
               {cLb , c50 },;
               {cLb , c60 },;
               {cLb , cTon},;
               {cTon, c50 },;
               {cTon, c60 },;
               {cTon, cLb },;
               {cKG, c50 },;
               {cKG, c60 },;
               {cKG, cLb },;
               {c50 , cKG},;
               {c60 , cKG},;
               {cLb , cKG},;
               {c50 , "DOLARLIBRA"},; //Os tratamentos de DOLARLIBRA foram adicionados para tratar as conversões quando a unidade de medida do preço for Libra
               {c60 , "DOLARLIBRA"},;
               {cLb , "DOLARLIBRA"},;
               {cKG,  "DOLARLIBRA"},;
               {cTon, "DOLARLIBRA"},;
               {"DOLARLIBRA" , c50},;
               {"DOLARLIBRA" , c60},;
               {"DOLARLIBRA" , cLb},;
               {"DOLARLIBRA" , cKG},;
               {"DOLARLIBRA" , cTon}}
                     
Return {aConvTable,c50,c60,cLb,cTon}

/*
Função     : Ap104VerPreco()
Objetivos  : verificar se os novos campos de preço existem.
Retorno    : .t. / .f.
Autor      : João Pedro Macimiano Trabbold - 21/12/05
*/

Function Ap104VerPreco()

Local lRet := .t., aCpos := {{"EE8","EE8_PRECO2"},;
                             {"EE8","EE8_PRECO3"},;
                             {"EE8","EE8_PRECO4"},;
                             {"EE8","EE8_PRECO5"},;
                             {"EE9","EE9_PRECO2"},;
                             {"EE9","EE9_PRECO3"},;
                             {"EE9","EE9_PRECO4"},;
                             {"EE9","EE9_PRECO5"}}
Local i

Begin Sequence
   For i := 1 To Len(aCpos)
      If (aCpos[i][1])->(FieldPos(aCpos[i][2])) = 0
         lRet := .f.
         Break
      EndIf
   Next
End Sequence

Return lRet

/*
Função     : Ap104VldPrc()
Objetivos  : Validar a fixação de preço, no caso de haver já preço inicial
Parâmetros : lRv - se é na fixação por rv ou na fixação em si.
Retorno    : .t./.f.
Autor      : João Pedro Macimiano Trabbold
Data       : 06/01/06
*/

*-----------------------*
Function Ap104VldPrc(lRv)
*-----------------------*
Local lRet := .t., bPreco := {|x| AllTrim(Transf(x,AvSx3("EE8_PRECO",AV_PICTURE))) }, cMsg
Local lTratPreco := (Ap104VerPreco() .and. EECFlags("CAFE"))
Local cUnidPrc := "", cUnidIt := ""
Local aOrd := SaveOrd("EE8")
Local xRetPrc

Default lRv := .f.

Begin Sequence
   
   If lRv
      nPrecoInicial := WorkIt->EE8_PRECO
      cUnidIt       := WorkIt->EE8_UNPRC
      nPrecoFixado  := WorkEE8->EE8_PRECO
      EE8->(DbGoTo(WorkEE8->EE8_RECNO))
      cUnidPrc      := EE8->EE8_UNPRC
   Else
      nPrecoInicial := Posicione("EE8",1,xFilial("EE8")+WorkPed->(EE8_PEDIDO+EE8_SEQUEN),"EE8_PRECO")
      cUnidIt       := EE8->EE8_UNPRC
      nPrecoFixado  := nValFix
      cUnidPrc      := If(lTratPreco,;
                       EasyGParam("MV_AVG0032",,""),;
                       Posicione("EE8",1,xFilial("EE8")+WorkFix->(EE8_PEDIDO+EE8_SEQUEN),"EE8_UNPRC"))
   EndIf
   
   If nPrecoInicial <= 0
      Break
   EndIf
   
   xRetPrc := Ap104GatPreco(,,,.T.,nPrecoInicial,cUnidIt,cUnidPrc)
   If ValType(xRetPrc) = "L" .And. !xRetPrc
      lRet := .f.
      Break
   EndIf

   xRetPrc       := Round(xRetPrc      ,AvSx3("EE8_PRECO",AV_DECIMAL))
   nPrecoInicial := Round(nPrecoInicial,AvSx3("EE8_PRECO",AV_DECIMAL))
   nPrecoFixado  := Round(nPrecoFixado ,AvSx3("EE8_PRECO",AV_DECIMAL))
   
   If xRetPrc == nPrecoFixado
      Break // se o preço for igual, então não dá mensagem.
   EndIf
   
   cMsg := STR0132 //" (Preço no R.V. : ###. Preço Inicial do Item: ###.)"
   cMsg := StrTran(cMsg,"###",Eval(bPreco,nPrecoFixado )+" "+cUnidPrc,,1)
   cMsg := StrTran(cMsg,"###",Eval(bPreco,nPrecoInicial)+" "+cUnidIt,,1)
   
   If lRv
      If !MsgYesNo(STR0133+cMsg,STR0007) //"Se prosseguir com esta vinculação, o preço do R.V. sobreporá o preço inicial do item. Deseja Continuar?"###"Atenção"
         lRet := .f.
         Break
      EndIf
   Else
      If !MsgYesNo(STR0134+cMsg,STR0007) //"O preço do R.V. digitado na tela anterior é diferente do preço inicial do item. Deseja Continuar?"###"Atenção"
         lRet := .f.
         Break
      EndIf
   EndIf
   
End Sequence

RestOrd(aOrd)

Return lRet

/*
Função     : Ap104CalcLot()
Objetivos  : Calcular a quantidade de lotes em uma fixação de preço, de acordo com a bolsa.
Parâmetros : nQtd     -> Quantidade Fixada (ou qtd. lots, se o lReverso = .T.)
             cUnidade -> Unidade de medida da quantidade fixada
             cBolsa   -> Código da Bolsa
             lReverso -> Se .T., calcula a qtde fixada em cima da qtde de lotes ao invés de calcular a qtde de lotes em cima da qtde fixada.
Retorno    : se lReverso == .F. -> Qtde. de Lots
             se lReverso == .T. -> Qtde. Fixada
*/

*--------------------------------------------------*
Function Ap104CalcLot(nQtd,cUnidade,cBolsa,lReverso)
*--------------------------------------------------*
Local nRet := 0, nSacas
Local cUnidSacas := EasyGParam("MV_AVG0115",,"")

Private nFator := 1

Default lReverso := .F.

cBolsa := AvKey(cBolsa,"EE7_CODBOL")

Begin Sequence

   If cBolsa == AvKey("NY","EE7_CODBOL")
      nFator := 283 // 1 Lote == 283 Sacas
   ElseIf cBolsa == AvKey("BMF","EE7_CODBOL")
      nFator := 100 // 1 Lote == 100 Sacas
   ElseIf cBolsa == AvKey("LON","EE7_CODBOL")
      nFator := 83.333333 // 1 Lote == 83.333333 Sacas    // 750/9
   EndIf
   
   If EasyEntryPoint("EECAP104")
      ExecBlock("EECAP104", .F., .F., "AP104CALCLOT")
   EndIf
   
   If lReverso
      nSacas := nQtd * nFator
      nRet   := AvTransUnid(cUnidSacas,cUnidade,,nSacas,.F.)
   Else
      nSacas := AvTransUnid(cUnidade,cUnidSacas,,nQtd,.F.)
      nRet   := Round(nSacas / nFator,AvSx3("EE8_QTDLOT",AV_DECIMAL))
   EndIf
   
End Sequence

Return nRet

/*
Função     : Ap104QuebraEE9
Objetivos  : Quebrar linhas no EE9 de acordo com os rateios do aRateio.
Parâmetros : 1 - aRateio [1] - RecNo do EE8
                         [2] - Fator de rateio
                         [3] - Se deve atualizado
             2 - cPreemb - Embarque do item
             3 - cSeqEmb - Seq. Emb. do item
Retorno    : Array com os RecNos a serem atualizados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 29/03/06 - 14:00
*/
*----------------------------------------------*
Function Ap104QuebraEE9(aRateio,cPreemb,cSeqEmb)
*----------------------------------------------*
Local aAtualiza := {}, i, nSeq := 1,;
      aOrd := {"EE9"},;
      lOic := EECFlags("CAFE"),;
      lInv := EECFlags("INVOICE"),;
      lQuebra := Len(aRateio) > 1
      
Begin Sequence
   
   If lOic
      AAdd(aOrd,"EY2")
   EndIf
   
   If lInv
      AAdd(aOrd,"EXR")
   EndIf
    
   aOrd := SaveOrd(AClone(aOrd))
   
   // Posiciona no item que será quebrado
   EE9->(DbSetOrder(3))
   EE9->(DbSeek(xFilial()+cPreemb+cSeqEmb))
   
   // Cria variáveis de memória e pega a última sequência do embarque, para gerar novas linhas
   If lQuebra
      For i := 1 To EE9->(FCount())
         M->&(EE9->(FieldName(i))) := EE9->(FieldGet(i))
      Next
      EE9->(AvSeekLast(xFilial()+cPreemb))
      nSeq := Val(EE9->EE9_SEQEMB)
      EE9->(DbSeek(xFilial()+cPreemb+cSeqEmb))
   EndIf
   
   For i := 1 To Len(aRateio)
      
      EE8->(DbGoTo(aRateio[i][1]))
      
      If i = 1
         EE9->(RecLock("EE9",.F.))
      Else
         EE9->(RecLock("EE9",.T.))
         AvReplace("M","EE9")
         EE9->EE9_SEQEMB := Str(++nSeq,AvSx3("EE9_SEQEMB",AV_TAMANHO))
      EndIf

      EE9->EE9_SEQUEN := EE8->EE8_SEQUEN

      // array de retorno para atualização.
      AAdd(aAtualiza,{aRateio[i][3],EE8->(RecNo()),EE9->(RecNo()),EE9->EE9_SEQEMB})
      
      If lQuebra
         EE9->EE9_PSBRTO *= aRateio[i,2]
         EE9->EE9_PSLQTO *= aRateio[i,2]
         EE9->EE9_QTDEM1 *= aRateio[i,2]
         EE9->EE9_SLDINI *= aRateio[i,2]
         EE9->EE9_QT_AC  *= aRateio[i,2]
         EE9->EE9_VL_AC  *= aRateio[i,2]
         EE9->EE9_SALISE *= aRateio[i,2]
         If EE9->(FieldPos("EE9_VLPVIN")) > 0  // By JPP - 14/11/2006 - 13:00
            EE9->EE9_VLPVIN *= aRateio[i,2]
         EndIf
      EndIf
      
      EE9->(MsUnlock())
      
   Next
 
   If lQuebra
      If lOic //Quebra itens dos OICs
         EY2->(DbSetOrder(1))
         EY2->(DbSeek(xFilial()+cPreemb))
         While EY2->(!EoF() .And. EY2_FILIAL+EY2_PREEMB == xFilial()+cPreemb)
            If EY2->EY2_SEQEMB == cSeqEmb
               For i := 1 To EY2->(FCount())
                  M->&(EY2->(FieldName(i))) := EY2->(FieldGet(i))
               Next
               For i := 1 To Len(aRateio)
                  If i = 1
                     EY2->(RecLock("EY2",.F.))
                  Else
                     EY2->(RecLock("EY2",.T.))
                     AvReplace("M","EY2")
                     EY2->EY2_SEQEMB := aAtualiza[i][4]
                  EndIf
                  EY2->EY2_QTDE *= aRateio[i,2]
                  EY2->(MsUnlock())
               Next
            EndIf
            EY2->(DbSkip())
         EndDo
      EndIf
      
      If lInv //Quebra itens das invoices
         EXR->(DbSetOrder(1))
         EXR->(DbSeek(xFilial()+cPreemb))
         While EXR->(!EoF() .And. EXR_FILIAL+EXR_PREEMB == xFilial()+cPreemb)
            If EXR->EXR_SEQEMB == cSeqEmb
               For i := 1 To EXR->(FCount())
                  M->&(EXR->(FieldName(i))) := EXR->(FieldGet(i))
               Next
               For i := 1 To Len(aRateio)
                  If i = 1
                     EXR->(RecLock("EXR",.F.))
                  Else
                     EXR->(RecLock("EXR",.T.))
                     AvReplace("M","EXR")
                     EXR->EXR_SEQEMB := aAtualiza[i][4]
                  EndIf                              	

                  EXR->EXR_SLDINI *= aRateio[i,2]
                  EXR->EXR_PSBRTO *= aRateio[i,2]
                  EXR->EXR_PSLQTO *= aRateio[i,2]
                  EXR->EXR_VLFRET *= aRateio[i,2]
                  EXR->EXR_VLSEGU *= aRateio[i,2]
                  EXR->EXR_VLOUTR *= aRateio[i,2]
                  EXR->EXR_VLDESC *= aRateio[i,2]
                  EXR->EXR_PRCTOT *= aRateio[i,2]
                  EXR->EXR_PRCINC *= aRateio[i,2]
                  
               Next
            EndIf
            EXR->(DbSkip())
         EndDo
      EndIf
   EndIf
      
   
End Sequence

RestOrd(aOrd,.T.)

Return aAtualiza

/*
Função     : Ap104LoadAtuSequen{}
Objetivos  : Carregar array com os alias que devem ser atualizados quando há mudança de EE8_SEQUEN
Retorno    : array descrito acima
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/03/06 - 10:10
*/
*---------------------------*
Function Ap104LoadAtuSequen()
*---------------------------*
Local aAtuSequen := {}

AAdd(aAtuSequen,{"EE9",;                                         // Alias da Tabela a ser atualizada
                 1,;                                             // Índice
                 {|seq,emb| xFilial("EE9")+EE7->EE7_PEDIDO+seq },; // codeblock pra dar seek
                 {|| EE9->(EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN) },; // codeblock para comparar com o do seek para o while
                 {|seq,emb| EE9->EE9_PREEMB == emb },;           // codeblock com condição para atualizar a sequência
                 {|seq| EE9->EE9_SEQUEN := seq }})               // codeblock para atualizar a sequência
                 
AAdd(aAtuSequen,{"EES",;
                 1,;
                 {|seq,emb| xFilial("EES")+emb },;
                 {|| EES->(EES_FILIAL+EES_PREEMB) },;
                 {|seq,emb| EES->EES_SEQUEN == seq .And. EES->EES_PREEMB == emb },;
                 {|seq| EES->EES_SEQUEN := seq }})

Return aAtuSequen

/*
Função     : Ap104AtuSequen()
Objetivos  : Atualizar as sequências de pedido modificadas em diversas tabelas
Parâmetros : cSeqAux1 - Sequência antiga a ser procurada.
             cSeqAux2 - Sequência nova que será atualizada.
             cPreemb  - Processo de embarque.
             aNaoAtu  - para cada posição : [1] - Alias
                                            [2] - Array com os Recnos do Alias que não devem ter a sequência atualizada.
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/03/06 - 10:40
*/
*---------------------------------------------------------------*
Function Ap104AtuSequen(cSeqAux1,cSeqAux2,cPreemb,aNaoAtu,lRecur)
*---------------------------------------------------------------*
Local i, aAtuSequen := Ap104LoadAtuSequen(), nPos
Local cAlias, nOrd, bSeek, bWhile, bCond, bExec
Local aAtualizados := {}
Default aNaoAtu := {}
Default lRecur  := .T.

Begin Sequence

   For i := 1 To Len(aAtuSequen)
      cAlias := aAtuSequen[i][1]; nOrd  := aAtuSequen[i][2]; bSeek := aAtuSequen[i][3]
      bWhile := aAtuSequen[i][4]; bCond := aAtuSequen[i][5]; bExec := aAtuSequen[i][6]
      
      (cAlias)->(DbSetOrder(nOrd))
      (cAlias)->(DbSeek(Eval(bSeek,cSeqAux1,cPreemb)))

      While (cAlias)->(!EoF()) .And. ;
            Eval(bSeek,cSeqAux1,cPreemb) == Eval(bWhile)
         (cAlias)->(DbSkip())
         nRec := (cAlias)->(RecNo())
         (cAlias)->(DbSkip(-1))
         If Eval(bCond,cSeqAux1,cPreemb) .And. ((nPos := AScan(aNaoAtu,{|x| x[1] = cAlias})) = 0 .Or. AScan(aNaoAtu[nPos][2],(cAlias)->(RecNo())) = 0)
            (cAlias)->(RecLock(cAlias,.f.))
            Eval(bExec,cSeqAux2)
            (cAlias)->(MsUnlock())
            nPos := AScan(aAtualizados,{|x| x[1] = cAlias})
            If nPos = 0
               AAdd(aAtualizados,{cAlias,{}})
               nPos := Len(aAtualizados)
            EndIf
            AAdd(aAtualizados[nPos][2],(cAlias)->(RecNo()))
         EndIf
         (cAlias)->(DbGoTo(nRec))
      EndDo
   Next
   
   If lRecur
      Ap104AtuSequen(cSeqAux2,cSeqAux1,cPreemb,aAtualizados,.F.)
   EndIf
End Sequence

Return Nil

/*
Função     : Ap104CanJoin()
Objetivos  : Verifica se 2 ou mais itens podem ser agrupados
Parâmetros : aItens  - recnos do EE8 a serem agrupados
             lRv     - define se a chamada é do R.V. ou Fixação de Preço
             lMsg    - define se é apresentada mensagem no caso de não-conformidade
Retorno    : .T./.F.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/03/06 - 15:48
*/
*------------------------------------*
Function Ap104CanJoin(aItens,lRv,lMsg)
*------------------------------------*
Local i, j, k,lRet := .T., w
Local aCpo := {"EE9_RE"    ,"EE9_DTRE"  ,"EE9_ATOCON",;
               "EE9_SEQED3","EE9_NRSD"  ,"EE9_DTAVRB",;
               "EE9_SEQSIS"}
Local aEE9 := {}, aAux, aRec, aConteudo
Local aHeader1, aDetail1, aHeader2, aDetail2
Local aItem := {}, aCapa := {}, aMsg, aLinhasVazias := {}, cPedido := ""

Default lRv  := .F.
Default lMsg := .T.

Begin Sequence
   aSort(aItens,,, { |x, y| EE8->(DbGoTo(x)),a:=EE8->EE8_SEQUEN, EE8->(DbGoTo(y)),a < EE8->EE8_SEQUEN }) // ordena SEQUEN.

   aHeader1 := {"EE8_SEQUEN","EE8_RV    ","EE8_DTRV  ","EE8_DTFIX ","EE8_PRECO ","EE8_SLDINI"}
   aDetail1 := {}
   EE9->(DbSetOrder(1))
   For j := 1 To Len(aItens)
      EE8->(DbGoTo(aItens[j]))
      If Empty(cPedido)
         cPedido := EE8->EE8_PEDIDO
      EndIf
      EECAddLine(aHeader1,aDetail1,"EE8")
      EE9->(DbSeek(xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN)))
      While EE9->(!EoF() .And. EE9->(EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN) == xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN))
         If (nPos := AScan(aEE9,{|x| x[1] == EE9->EE9_PREEMB })) = 0
            AAdd(aEE9,{EE9->EE9_PREEMB,{},{}})
            nPos := Len(aEE9)
         EndIf
         AAdd(aEE9[nPos][2],EE9->EE9_SEQUEN)
         AAdd(aEE9[nPos][3],EE9->(RecNo()))
         EE9->(DbSkip())
      EndDo
   Next

   lCapa := .F.
   For i := 1 To Len(aEE9)
      If Len((aAux := aEE9[i][2])) <= 1
         Loop
      EndIf
      If lCapa
         AAdd(aItem,0)
      EndIf
      aRec := aEE9[i][3]
      aConteudo := Array(Len(aCpo))
      lDif := .F.
      For j := 1 To Len(aAux)
         EE9->(DbGoTo(aRec[j]))
         For k := 1 To Len(aCpo)
            If j > 1 .And. EE9->&(aCpo[k]) <> aConteudo[k] .Or. lDif
               If EE9->&(aCpo[k]) <> aConteudo[k] .And. AScan(aCapa,aCpo[k]) = 0
                  AAdd(aCapa,aCpo[k])
                  lCapa := .T.
               EndIf
               lDif := .T.
               If AScan(aItem,aRec[j]) = 0
                  AAdd(aItem,aRec[j])
                  For w := 1 To (j-1)
                     If AScan(aItem,aRec[w]) = 0
                        AAdd(aItem,aRec[w])
                     EndIf
                  Next
               EndIf
               lRet := .F.
            EndIf
            aConteudo[k] := EE9->&(aCpo[k])
         Next
      Next
   Next
   
   If !lRet .And. lMsg
      aHeader2 := {"EE9_PREEMB","EE9_SEQUEN","EE9_SEQEMB","EE9_RV    ","EE9_DTRV  ","EE9_PRECO ","EE9_SLDINI"}
      ASize(aHeader2,Len(aHeader2)+Len(aCapa))
      For i := 1 To Len(aCapa)
         AIns(aHeader2,i+2)
         aHeader2[i+2] := aCapa[i]
      Next
      aDetail2 := {}
      For i := 1 To Len(aItem)
         If aItem[i] = 0
            EE9->(DbGoBottom(),DbSkip())
         Else
            EE9->(DbGoTo(aItem[i]))
         EndIf
         EECAddLine(aHeader2,aDetail2,"EE9")

         If EE9->(EoF())
            AAdd(aLinhasVazias,Len(aDetail2))
         EndIf
      Next
      
      aMsg := {}
      AAdd(aMsg,{StrTran(STR0136,"##",AllTrim(cPedido)) + Repl(ENTER,2),.T.}) //"Esta operação não pode ser realizada, pois para isto, os itens abaixo do pedido ## teríam que ser agrupados:"
      AAdd(aMsg,{EECMontaMsg(aHeader1,aDetail1)+ENTER,.F.})
      cMsg := STR0137 + If(Len(aCapa)==1,STR0138,STR0139) //"Sendo assim, os itens correspondentes no embarque também teriam de ser agrupados. Porém, " # "o campo " # "os campos "
      For i := 1 To Len(aCapa)
         If i > 1 .And. i < Len(aCapa)
            cMsg += ", "
         ElseIf i = Len(aCapa) .And. Len(aCapa)>1
            cMsg += STR0141 //" e "
         EndIf
         cMsg += '"'+AllTrim(AvSx3(aCapa[i],AV_TITULO))+'"'
      Next
      If Len(aCapa) > 1
         cMsg += STR0140 + Repl(ENTER,2) //" estão diferentes entre os itens, não podendo assim serem agrupados, conforme tabela abaixo:"
      Else
         cMsg += STR0144 + Repl(ENTER,2) //" está diferente entre os itens, não podendo assim serem agrupados, conforme tabela abaixo:"
      EndIf
      AAdd(aMsg,{cMsg,.T.})
      AAdd(aMsg,{EECMontaMsg(aHeader2,aDetail2,,,aLinhasVazias),.F.})
      EECView(aMsg,If(lRv,STR0142,STR0143),STR0055) //"Estorno de Vinculação de R.V."###"Estorno de Fixação de Preço"###"Detalhes"
   EndIf
   
End Sequence

Return lRet


/*
Funcao      : AP104ReplyChanges().
Parametros  : Filial, Processo e itens para atualização.
Retorno     : .t./.f.
Objetivos   : Replicar a alteração realizada no item do pedido, para os embarques onde o item
              foi embarcado. 
              Caso o ambiente esteja configurado para habilitar a rotina de off-shore, o sistema
              irá realizar automaticamente a replicação da alteração em toso os níveis de off-shore.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/03/2005 14:04.
Revisao     :
Obs.        :
*/
*--------------------------------------------*
Function AP104ReplyChanges(cFil,cProcesso,aIt)
*--------------------------------------------*
Local lRet:=.t.
Local aOrd := SaveOrd({"EEC","EE9"}), aAux := {}
Local j:= 0, nSaldoOld := 0

If Type("cFilAtu") <> "C"
   Private cFilAtu  := xFilial("EEC")
EndIf

If Type("lFilBr") <> "L"
   Private lFilBr   := cFilAtu == cFilBr
EndIf

If Type("cFilOpos") <> "C"
   Private cFilOpos := If(lFilBr,cFilEx,cFilBr)
EndIf

If Type("lSelNotFat") <> "C"//FSY - 14/02/2014 - Declaraçao da variavel lSelNotFat logico.
	Private lSelNotFat := EasyGParam("MV_AVG0067", .F., .F., xFilial("EE9"))
EndIf

Begin Sequence

   WorkIP->(AvZap())
   WorkDe->(AvZap())
   WorkAg->(AvZap())
   WorkIn->(AvZap())
   WorkEm->(AvZap())
   WorkNF->(AvZap())
   WorkNo->(AvZap())
   WorkDoc->(AvZap())

   If(Select("WorkCalc") > 0,WorkCalc->(AvZap()),)

   EEC->(DbSetOrder(1))
   EEC->(DbSeek(cFil+cProcesso))

   For j := 1 TO EEC->(FCount())
      M->&(EEC->(FieldName(j))) := EEC->(FieldGet(j))
   Next

   If EECFlags("COMPLE_EMB")
      EXL->(DbSetOrder(1))
      If EXL->(DbSeek(xFilial("EXL")+cProcesso))
         For j := 1 TO EXL->(FCount())
            M->&(EXL->(FieldName(j))) := EXL->(FieldGet(j))
         Next
      EndIf
   EndIf

   M->EEC_MARCAC := MSMM(EEC->EEC_CODMAR,AVSX3("EEC_MARCAC",AV_TAMANHO),,,LERMEMO)
   M->EEC_GENERI := MSMM(EEC->EEC_DSCGEN,AVSX3("EEC_GENERI",AV_TAMANHO),,,LERMEMO)
   M->EEC_OBSPED := MSMM(EEC->EEC_CODOBP,AVSX3("EEC_OBSPED",AV_TAMANHO),,,LERMEMO)
   M->EEC_OBS    := MSMM(EEC->EEC_CODMEM,AVSX3("EEC_OBS",AV_TAMANHO)   ,,,LERMEMO)

   aE102LoadEmb(cProcesso,cFil) // Carrega os dados de itens e complementos do embarque.

   WorkIp->(DbSetOrder(2))
   For j:= 1 To Len(aIt)
      If WorkIp->(DbSeek(aIt[j][1]))

         nSaldoOld := WorkIP->WP_SLDATU+WorkIP->EE9_SLDINI
         WorkIp->EE9_SLDINI += aIt[j][2]
         WorkIp->WP_SLDATU  += aIt[j][2] //WorkIp->WP_SLDATU  := nSaldoOld-WorkIp->EE9_SLDINI

         If WorkIp->WP_SLDATU  < 0
            WorkIp->WP_SLDATU := 0
         EndIf
      EndIf
   Next

   WorkIp->(DbSetOrder(1))
   aE102SetGrvEmb(.f.) // Realiza a gravação do embarque.

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : AP104TrataWorks().
Parametros  : cFase - OC_PE = Pedido.
                      OC_EM = Embarque.
              lSave - .t. Salva as works com nome secundário.
                      .f. Restaura as works antigas para o nome original.
Retorno     : .t.
Objetivos   : A função irá abrir os arquivos referentes as works com outro alias para possibilitar,
              a utilização das funções automáticas de gravação e inclusão de pedido/embarques.
Autor       : Jeferson Barros Jr.
Data/Hora   : 08/03/2005 18:50.
Revisao     :
Obs.        :
*/
*-----------------------------------*
Function AP104TrataWorks(lSave,cFase)
*-----------------------------------*
Local lRet := .t.
Local aTabelas := {}
Local j:= 0
Local aTabAlias := {}  // PLB 21/09/06

Static aOrd := {}
Static aOldGrpCpos   := Nil
Static aOldGrpInfo   := Nil
Static aOldGrpBrowse := Nil 

Default lSave  := .t.
Default cFase  := OC_PE

Begin Sequence

   If lSave
      Do Case
         Case cFase == OC_PE
              aTabelas := {{"WorkIt"    ,cNomArq   },;
                           {"WorkEm"    ,cNomArq1  },;
                           {"WorkAg"    ,cNomArq2  },;
                           {"WorkIn"    ,cNomArq3  },;
                           {"WorkDe"    ,cNomArq4  },;
                           {"WorkNo"    ,cNomArq5  },;
                           {"WorkDoc"   ,cNomArq6  },;
                           {"WorkGrp"   ,cNomArq7  },; // PLB 21/09/06
                           {"WORKSLD_AD",cArqAdiant},; // PLB 21/09/06
                           {"WK_NFRem"  ,cArqNFRem }}  //FSY - 03/02/2014
              //aOrd := SaveOrd({"WorkIt","WorkEm","WorkAg","WorkIn","WorkDe","WorkNo","WorkDoc"})
              //** PLB 21/09/06
              aTabAlias := {"WorkIt","WorkEm","WorkAg","WorkIn","WorkDe","WorkNo","WorkDoc"}
              IIF(Select("WK_NFRem"  ) > 0, AAdd(aTabAlias,"WK_NFRem"  ), )//FSY - 07/02/2014
              IIF(Select("WorkGrp"   ) > 0, AAdd(aTabAlias,"WorkGrp"   ), )
              IIF(Select("WORKSLD_AD") > 0, AAdd(aTabAlias,"WORKSLD_AD"), )
              aOrd := SaveOrd(aTabAlias)
              //**
              
              If EECFlags("INTERMED")
                 aOldGrpCpos := aClone(aGrpCpos)
              
                 aGrpCpos  := {"WP_FLAG",;
                               "EE9_PEDIDO","EE9_ORIGEM","EE9_COD_I" ,"EE9_VM_DES",;
                               "EE9_FORN"  ,"EE9_FOLOJA","EE9_FABR"  ,"EE9_FALOJA",;
                               "EE9_PART_N","EE9_PRECO" ,"EE9_UNIDAD","EE9_SLDINI",;
                               "EE9_PRCTOT","EE9_PRCINC","EE9_PSLQUN","EE9_PSLQTO",;
                               "EE9_EMBAL1","EE9_QTDEM1","EE9_QE"    ,"EE9_PSBRUN",;
                               "EE9_PSBRTO","WP_SLDATU"}
              
                 Ap104KeyX3(aGrpCpos) // acerta tamanho
               
                 aOldGrpInfo := aClone(aGrpInfo)
               
                 aGrpInfo  := {"S",;
                               "S","S","S","N",; 
                               "S","S","S","S",;
                               "S","N","S","T",;
                               "T","T","S","T",;
                               "S","T","S","S",;
                               "T","T"}
              EndIf
               
               aOldGrpBrowse := aClone(aGrpBrowse)
              
         Case cFase == OC_EM
              aTabelas := {{"WorkIp"    ,cNomArqIp    },;
                           {"WorkDe"    ,cNomArq1     },;
                           {"WorkAg"    ,cNomArq2     },;
                           {"WorkIn"    ,cNomArq3     },;
                           {"WorkEm"    ,cNomArq4     },;
                           {"WorkNF"    ,cNomArq6     },;
                           {"WorkNo"    ,cNomArq7     },;
                           {"WorkDoc"   ,cNomArq8     },;
                           {"WorkCalc"  ,cNomArq9     },;
                           {"WorkInv"   ,cArqCapInv   },;   // PLB 21/09/06
                           {"WorkDetInv",cArqDetInv   },;   // PLB 21/09/06
                           {"WORKSLD_AD",cArqAdiant   },;   // PLB 21/09/06
                           {"WkEY5"     ,cArqWkEY5    },;   // PLB 21/09/06
                           {"WkEY6"     ,cArqWkEY6    },;   // PLB 21/09/06
                           {"WkEY7"     ,cArqWkEY7    },;   // PLB 21/09/06
                           {"WorkGrp"   ,cNomArqGrp   },;
                           {"WorkOpos"  ,cNomArqOpos  },;
                           {"WKEXZ"     ,cArqCapOIC   },;
                           {"WKEY2"     ,cArqDetOIC   },;
                           {"WkArm"     ,cWorkArmazem },;
                           {"Wk_NfRem"  ,cArqNFRem    }}//RMD - 07/02/17 - Não tratava a work de Nf de remessa

              //aOrd := If(Select("WorkCalc") > 0,;
              //           SaveOrd({"WorkIp","WorkDe","WorkAg","WorkIn","WorkEm","WorkNF","WorkNo","WorkDoc","WorkCalc"}),;
              //           SaveOrd({"WorkIp","WorkDe","WorkAg","WorkIn","WorkEm","WorkNF","WorkNo","WorkDoc"}))

              //** PLB 21/09/06
              aTabAlias := {"WorkIp","WorkDe","WorkAg","WorkIn","WorkEm","WorkNF","WorkNo","WorkDoc"}
              IIF(Select("WorkCalc"  ) > 0, AAdd(aTabAlias,"WorkCalc"  ), )
              IIF(Select("WorkInv"   ) > 0, AAdd(aTabAlias,"WorkInv"   ), )
              IIF(Select("WorkDetInv") > 0, AAdd(aTabAlias,"WorkDetInv"), )
              IIF(Select("WORKSLD_AD") > 0, AAdd(aTabAlias,"WORKSLD_AD"), )
              IIF(Select("WkEY5"     ) > 0, AAdd(aTabAlias,"WkEY5"     ), )
              IIF(Select("WkEY6"     ) > 0, AAdd(aTabAlias,"WkEY6"     ), )
              IIF(Select("WkEY7"     ) > 0, AAdd(aTabAlias,"WkEY7"     ), )
              IF(Select("WorkGrp")  > 0, aAdd(aTabAlias, "WorkGrp"),)
              IF(Select("WorkOpos") > 0, aAdd(aTabAlias, "WorkOpos"),)
              If(Select("WKEXZ")    > 0, aAdd(aTabAlias, "WKEXZ"),)
              If(Select("WKEY2")    > 0, aAdd(aTabAlias, "WKEY2"),)
              If(Select("WkArm")    > 0, aAdd(aTabAlias, "WkArm"),)
              IIF(Select("WK_NFRem") > 0, AAdd(aTabAlias,"WK_NFRem"), )//RMD - 07/02/17 - Não tratava a work de Nf de remessa
              aOrd := SaveOrd(aTabAlias)
              //**
      EndCase

      For j:=1 To Len(aTabelas)
         If Select(aTabelas[j][1]) > 0
            (aTabelas[j][1])->(DbCloseArea())
            TETempReopen(aTabelas[j][2],AllTrim(Left(aTabelas[j][1],9))+"2")
         EndIf
      Next
   Else

      Do Case
         Case cFase == OC_PE       

              WorkIt2->(DbCloseArea())
              TETempReopen(cNomArq,"WorkIt")
              Set Index To (cNomArq+TEOrdBagExt())
              
              WorkEm2->(DbCloseArea())
              TETempReopen(cNomArq1,"WorkEm")
              Set Index To (cNomArq1+TEOrdBagExt())

              WorkAg2->(DbCloseArea())
              TETempReopen(cNomArq2,"WorkAg")
              Set Index To (cNomArq2+TEOrdBagExt())

              WorkIn2->(DbCloseArea())
              TETempReopen(cNomArq3,"WorkIn")
              Set Index To (cNomArq3+TEOrdBagExt())

              WorkDe2->(DbCloseArea())
              TETempReopen(cNomArq4,"WorkDe")
              Set Index To (cNomArq4+TEOrdBagExt())

              WorkNo2->(DbCloseArea())
              TETempReopen(cNomArq5,"WorkNo")
              Set Index To (cNomArq5+TEOrdBagExt())

              WorkDoc2->(DbCloseArea())
              TETempReopen(cNomArq6,"WorkDoc")
              Set Index To (cNomArq6+TEOrdBagExt()),(cNomArq62+TEOrdBagExt())

              //** PLB 21/09/06
              If Select("WorkSld_A2") > 0
                 WORKSLD_A2->(DbCloseArea())
                 TETempReopen(cArqAdiant,"WORKSLD_AD")
                 Set Index To (cArqAdiant+TEOrdBagExt())
              EndIf
              
              If EECFlags("INTERMED") 
                 WorkGrp2->(DbCloseArea())
                 TETempReopen(cNomArq7,"WorkGrp")
                 Set Index To (cNomArq7+TEOrdBagExt())
              EndIf
              //**
              
              //**FSY - 04/02/2014
              If Select("WK_NFRem2") > 0 
                 WK_NFRem2->(DbCloseArea())
                 TETempReopen(cArqNFRem,"WK_NFRem")
                 Set Index To (cArqNFRem+TEOrdBagExt())
              End If
              //**
              
              If EECFlags("INTERMED")
                 aGrpCpos      := aClone(aOldGrpCpos)
                 aOldGrpCpos   := Nil
              
                 aGrpInfo      := aClone(aOldGrpInfo)
                 aOldGrpInfo   := Nil
              EndIf
              
              aGrpBrowse    := aClone(aOldGrpBrowse)
              aOldGrpBrowse := Nil
    
          Case cFase == OC_EM

              WorkIp2->(DbCloseArea())
              TETempReopen(cNomArqIp,"WorkIp")
              Set Index to (cNomArqIp+TEOrdBagExt()),(cNomArq5+TEOrdBagExt())

              WorkDe2->(DbCloseArea())
              TETempReopen(cNomArq1,"WorkDe")
              Set Index to (cNomArq1+TEOrdBagExt()),(cNomArq1A+TEOrdBagExt()),(cNomArq1B+TEOrdBagExt()),(cNomArq1C+TEOrdBagExt())//RMD - 24/02/20

              WorkAg2->(DbCloseArea())
              TETempReopen(cNomArq2,"WorkAg")
              Set Index to (cNomArq2+TEOrdBagExt())

              WorkIn2->(DbCloseArea())
              TETempReopen(cNomArq3,"WorkIn")
              Set Index to (cNomArq3+TEOrdBagExt())

              WorkEm2->(DbCloseArea())
              TETempReopen(cNomArq4,"WorkEm")
              Set Index to (cNomArq4+TEOrdBagExt())

              WorkNF2->(DbCloseArea())
              TETempReopen(cNomArq6,"WorkNF")
              Set Index to (cNomArq6+TEOrdBagExt())

              WorkNo2->(DbCloseArea())
              TETempReopen(cNomArq7,"WorkNo")
              Set Index to (cNomArq7+TEOrdBagExt())

              WorkDoc2->(DbCloseArea())
              TETempReopen(cNomArq8,"WorkDoc")
              Set Index To (cNomArq8+TEOrdBagExt()),(cNomArq82+TEOrdBagExt())

              If EECFlags("HIST_PRECALC")
                 WorkCalc2->(DbCloseArea())
                 TETempReopen(cNomArq9,"WorkCalc")
                 Set Index to (cNomArq9+TEOrdBagExt())
              EndIf
              
              //** PLB 21/09/06
              If Select("WorkSld_A2") > 0
                 WORKSLD_A2->(DbCloseArea())
                 TETempReopen(cArqAdiant,"WORKSLD_AD")
                 Set Index to (cArqAdiant+TEOrdBagExt())
              EndIf
              
              If EECFlags("INVOICE")
                 WorkInv2->(DbCloseArea())
                 TETempReopen(cArqCapInv,"WorkInv")
                 Set Index to (cArqCapInv+TEOrdBagExt())

                 WorkDetIn2->(DbCloseArea())
                 TETempReopen(cArqDetInv,"WorkDetInv")
                 Set Index To (cArqDetInv+TEOrdBagExt()),(cArq2DetInv+TEOrdBagExt()) 
              EndIf

              If EECFlags("CAFE")
                 WKEXZ2->(DbCloseArea())
                 TETempReopen(cArqCapOIC,"WKEXZ")
                 Set Index To (cArqCapOIC+TEOrdBagExt()),(cArq2CapOIC+TEOrdBagExt()) 
              
                 WKEY22->(DbCloseArea())
                 TETempReopen(cArqDetOIC,"WKEY2")
                 Set Index To (cArqDetOIC+TEOrdBagExt()),(cArq2DetOIC+TEOrdBagExt())

                 WkArm2->(DbCloseArea())
                 TETempReopen(cWorkArmazem,"WkArm")
                 Set Index to (cWorkArmazem+TEOrdBagExt())
              EndIf
              
              If EECFlags("INTERMED")
                 WorkGrp2->(DbCloseArea())
                 TETempReopen(cNomArqGrp,"WorkGrp")
                 Set Index to (cNomArqGrp+TEOrdBagExt())

                 WorkOpos2->(DbCloseArea())
                 TETempReopen(cNomArqOpos,"WorkOpos")
                 Set Index to (cNomArqOpos+TEOrdBagExt())
              EndIf
                  
              If EECFlags("CONSIGNACAO")

                 If cTipoProc == PC_VR .Or. cTipoProc == PC_VB
                    WkEY52->(DbCloseArea())
                    TETempReopen(cArqWkEY5,"WKEY5")
                    Set Index To (cArqWkEY5+TEOrdBagExt()),(cArq2WkEY5+TEOrdBagExt())
                 
                    WkEY72->(DbCloseArea())
                    TETempReopen(cArqWkEY7,"WKEY7")
                    Set Index To (cArqWkEY7+TEOrdBagExt()),(cArq2WkEY7+TEOrdBagExt())
                 EndIf

              EndIf

			  //LGS-18/08/2015-Retirado validação se processo é consignação ou não.
              If Empty(cTipoProc) .Or. cTipoProc == PC_RC .Or. cTipoProc == PC_BC
                 WkEY62->(DbCloseArea())
                 TETempReopen(cArqWkEY6,"WKEY6")
                 Set Index to (cArqWkEY6+TEOrdBagExt())
              EndIf
              //**

              //RMD - 07/02/17 - Não estava reabrindo a work da NF de Remessa na fase de embarque
              If Select("WK_NFRem2") > 0 
                 WK_NFRem2->(DbCloseArea())
                 TETempReopen(cArqNFRem,"WK_NFRem")
                 Set Index To (cArqNFRem+TEOrdBagExt()), (cArq2NFRem+TEOrdBagExt()), (cArq3NFRem+TEOrdBagExt())
              End If
              
       EndCase

       RestOrd(aOrd,.t.)
       aOrd := {}
   EndIf

End Sequence

Return lRet

/*
Funcao      : Ap104SetLevelsOffShore().
Parametros  : cProcesso.
Retorno     : .t.
Objetivos   : A função irá realizar as atualizações nos outros níveis de off-shore existentes para o 
              embarque previamente atualizado pela Ae100Grava().
Autor       : Jeferson Barros Jr.
Data/Hora   : 09/03/2005 15:55.
Revisao     :
Obs.        :
*/
*----------------------------------------*
Function Ap104SetLevelsOffShore(cProcesso)
*----------------------------------------*
Local aOrd:= SaveOrd({"EEC","EE9","EE8"})
Local lRet := .t.

Begin Sequence

   EEC->(DbSetOrder(14))
   If EEC->(DbSeek(cFilEx+cProcesso))
      Ap101VldQtde(OC_EM,,.f.,.t.,EEC->EEC_PREEMB)

      Ap104SetLevelsOffShore(EEC->EEC_PREEMB)
   EndIf

End Sequence

RestOrd(aOrd)

Return lRet

/*
Funcao      : Ap104CanDel
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : A função irá verificar se o item poderá ser excluído, em caso
              negativo o sistema irá exibir msg de alterta ou usuário.
Autor       : Jeferson Barros Jr.
Data/Hora   : 17/03/2005 11:39.
Revisao     :
Obs.        :
*/
*--------------------*
Function Ap104CanDel()
*--------------------*
Local aOrd:=SaveOrd({"EE8","EE7"})
Local aSaveOrd
Local cProc, cSeq ,x  // LRS
Local lRet:=.t.
Local lFilComp:=.F.,lExistNota := .F.  //LRS

Begin Sequence

   If lIntermed .And. AvGetM0Fil() == cFilEx

      /* Para ambientes com a rotina de off-shore habilitada, caso o usuário tente alterar um item
         a partir da filial de off-shore, o sistema irá verificar se o processo  existe  na filial
         brasil, em caso positivo, a alteração só é permitida a partir da filial brasil. */

      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(cFilBr+M->EE7_PEDIDO))
         Easyhelp(STR0161+; //STR0161	Exclusão de itens deverá ser realizada apenas na filial Brasil, o sistema
                 STR0162,STR0108)  //STR0162	"irá atualizar a filial de Off-shore automaticamente." //STR0108	"Atenção"
         lRet := .f.
         Break
      EndIf
   EndIf

   cProc := WorkIt->EE8_PEDIDO
   cSeq  := WorkIt->EE8_SEQUEN  
   
   If (Posicione("SX2",1,"EE7","X2_MODO") == "C" .AND. Posicione("SX2",1,"EE8","X2_MODO") == "C") //LRS - 13/08/2014 - Validação do EE7 e EE8 no X2_modo
      lFilComp := .T.
   EndIF
   
   EE8->(DbSetOrder(1))
   SD2->(DbSetOrder(8)) //CCH - 10/09/2008 - Posiciona SD2 (ITENS DE VENDA DA NF) para uso na validação de Exclusão, linha 5010.
   
   //CCH - 10/09/2008 - Identificacao do Pedido e Item do Pedido no SIGAFAT
   cPedFat := Posicione("EE7",1,xFilial("EE7")+M->EE7_PEDIDO,"EE7_PEDFAT")
   cFatIt  := Posicione("EE8",1,xFilial("EE8")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN,"EE8_FATIT")
   
   cPedFat := AvKey(cPedFat,"D2_PEDIDO")  
   cFatIt  := AvKey(cFatIt ,"D2_ITEMPV")
   
   If !Empty(cPedFat) .And. !Empty(cFatIt) .And. IsIntFat()
   
   IF !lFilComp 
      lExistNota := If (SD2->(DbSeek(EE8->EE8_FILIAL+cPedFat+cFatIt)),.T.,.F.) //CCH - 10/09/2008 - Verifica a existência de Item com Nota Fiscal
   Else
      aSaveOrd := SaveOrd("SM0") //LRS - 18/09/2014 - Verificação de todas as filiais caso a tabela EE7 e EE8 estiver compartilhada.
      SM0->(DbGoTop())
      x := 1
      Do While SM0->(!Eof()) .And. x <= SM0->(LastRec())
         If SD2->(DbSeek(AvGetM0Fil()+cPedFat+cFatIt))
            lExistNota := .T.
            x := SM0->(LastRec())
         EndIf
         x++
         SM0->(DbSkip())
      EndDo
      RestOrd(aSaveOrd,.t.)
   EndIF
      //CCH - 10/09/2008 - Não permite Exclusão do Item do Pedido caso o Pedido esteja Faturado no SIGAFAT e com Nota Fiscal gerada
      
      If EE8->(DbSeek(xFilial("EE8")+M->EE7_PEDIDO+WorkIt->EE8_SEQUEN)) //LRS - Validação para Tabela EE7 e EE8 Compartilhada e Exclusiva
         If !lFilComp  // LRS - Se for Compartilhada
         	If lExistNota
         		MsgStop(STR0163,STR0108)
         		lRet := .F.
         	EndIF	
         Else
         	 If lExistNota
            	 MsgStop(STR0163,STR0108) //STR0163"O Item não poderá ser excluído visto que o mesmo está Faturado e possui Nota Fiscal"//STR0108	"Atenção"   
            	 lRet := .f.
         	 EndIf
         EndIF	
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet

/*
Funcao      : Ap104CanInsert
Parametros  : Nenhum.
Retorno     : .t./.f.
Objetivos   : A função irá verificar se o item poderá ser incluído, em caso
              negativo o sistema irá exibir msg de alterta ou usuário.
Autor       : Jeferson Barros Jr.
Data/Hora   : 30/03/2005 13:42.
Revisao     :
Obs.        :
*/
*-----------------------*
Function Ap104CanInsert()
*-----------------------*
Local lRet:= .t., aOrd:=SaveOrd({"EE7"})

Begin Sequence

   If lIntermed .And. AvGetM0Fil() == cFilEx

      /* Para ambientes com a rotina de off-shore habilitada, caso o usuário tente alterar um item
         a partir da filial de off-shore, o sistema irá verificar se o processo  existe  na filial
         brasil, em caso positivo, a alteração só é permitida a partir da filial brasil. */

      EE7->(DbSetOrder(1))
      If EE7->(DbSeek(cFilBr+M->EE7_PEDIDO))
         //MsgStop(STR0164+; //STR0164	"Inclusão de itens no processo deverá ser realizada apenas na filial Brasil, o sistema "
         //        STR0165,STR0108) //STR0165	"irá atualizar a filial de Off-shore automaticamente." //STR0108	"Atenção"
         EasyHelp(STR0164+; //STR0164	"Inclusão de itens no processo deverá ser realizada apenas na filial Brasil, o sistema "
                 STR0165,STR0108) //STR0165	"irá atualizar a filial de Off-shore automaticamente." //STR0108	"Atenção"
         lRet := .f.
         Break
      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.t.)

Return lRet           

/*
Funcao      : Ap104ValProc(nOpc,cFase).
Parametros  : nOpc - Opção da manutenção. (INCLUIR/ALTERAR/EXCLUIR)
              cFase - Fase(Pedido/Embarque)
Retorno     : .t./.f.
Objetivos   : Validar se o pedido na filial Brasil já existe na filial off-shore e vice-versa.
Autor       : Julio de Paula Paz
Data/Hora   : 12/05/2006 - 11:45
*/
Function Ap104ValProc(nOpc,cFase)
Local lRet := .T.
Local cFilAtual := AvGetM0Fil()
Local cFilOposta := If(cFilAtual==cFilBr, cFilEx, cFilBr)
Local nReg, aOrd := SaveOrd({"EE7","EEC"})

Begin Sequence
   If lIntermed .And. nOpc == INCLUIR
      If cFase == OC_PE
         nReg := EE7->(Recno())
         EE7->(DbSetOrder(1))
         If EE7->(DbSeek(cFilOposta+M->EE7_PEDIDO))
            MsgInfo(STR0037+AllTrim(M->EE7_PEDIDO)+STR0145+; //"O Processo '"###"' já está cadastrado na filial: "
                    cFilOposta+STR0146,STR0007) // ". Informe um outro Processo."###"Atenção"
            lRet := .F.
         EndIf  
         EE7->(DbGoto(nReg))
      Else
         nReg := EEC->(Recno())
         EEC->(DbSetOrder(1))
         If EEC->(DbSeek(cFilOposta+M->EEC_PREEMB))
            MsgInfo(STR0037+AllTrim(M->EEC_PREEMB)+ STR0145+; //"O Processo '"###"' já está cadastrado na filial: "
                    cFilOposta+STR0146,STR0007) // ". Informe um outro Processo."###"Atenção"
            lRet := .F.
         EndIf
          EEC->(DbGoto(nReg))   
      EndIf
   EndIf
End Sequence    
RestOrd(aOrd,.T.)
Return lRet

/*
Funcao      : FindCpoPreco(cUnMed, cUnMedIt, cAlias)
Parametros  : cUnMed   - Unidade de medida da R.V.
              cUnMedIt - Unidade de medida do item
              cAlias   - Tabela a ser verificada (EE8/EE9)
Retorno     : cCampoPrc - Campo correspondente à moeda do R.V., se encontrada
Objetivos   : Verificar se existe algum campo na tabela de itens do pedido/embarque correspondente à moeda da R.V.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 16/05/08
*/
Static Function FindCpoPreco(cUnMed, cUnMedIt, cAlias)
Local aConvTable := Ap104ConvTable()
Local c50  := aConvTable[2]
Local c60  := aConvTable[3]
Local cLb  := aConvTable[4]
Local cTon := aConvTable[5]
Local aCpos := {{"_PRECO" , cUnMedIt},;
                {"_PRECO2", c60     },;
                {"_PRECO3", cLb     },;
                {"_PRECO4", cTon    },;
                {"_PRECO5", c50     }}

Local nPos := aScan(aCpos, {|x| x[2] == AvKey(cUnMed, "J5_DE") })
Local cCampoPrc := ""

If cAlias $ "EE8/EE9"
   If nPos > 0
      cCampoPrc := cAlias + aCpos[nPos][1]
   EndIf
EndIf

Return cCampoPrc
*------------------------------------------------------------------------------------------------------------------*
*                                            FIM DO PROGRAMA EECAP104                                              *
*------------------------------------------------------------------------------------------------------------------*
