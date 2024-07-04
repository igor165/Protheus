/*
Programa..: EECSI301.PRW
Objetivo..: Tratamentos para R.V. (Continua��o do EECSI300.prw)
Autor.....: Jo�o Pedro Macimiano Trabbold
Data/Hora.: 16/11/2005 - 10:46
Obs.......:                 
*/

#Include "EECSI301.CH"
#Include "EEC.cH"
#Define TAMMEMO (AvSx3("YP_TEXTO",AV_TAMANHO)-6)

/*
Fun��o       : SI301MAN()
Objetivo     : Manuten��o de R.V. - Visualiza��o, Altera��o e Prorroga��o
Par�metros   : cAlias, nReg e nOpc
Retorno      : Descri��o do Status
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 17/11/05 - 9:30
*/
*---------------------------------------------*
Function SI301MAN(cAlias, nReg, nOpc, lForcado)
*---------------------------------------------*
Local nOpcRotina := aAuxRotina[nOpc]
Local nOpcEnc    := 4, aWork
Local i, aCposEnchoice, aCposEdit := {}, aPos, aNotEdit
Local oDlg,bOk,bCancel,aButtons := {}
Local lOk := .f., nQtdRv := 0, nSldRv := 0
Local aOrd := SaveOrd({"EEY","EE7", "EE8"})

Private lAltera
Private lVisual := .f., lAlterar := .f., lProrrogar := .f., lBaixa := .f.
Private cRv := EEY->EEY_NUMRV
Private lRvPed11  := (Left(EEY->EEY_PEDIDO,1) <> "*")

If ValType(lForcado) <> "L"
   lForcado := .f.
EndIf

Begin Sequence
   
   Do Case
      Case nOpcRotina == 2 // Visualizar R.V.
         lVisual   := .t.
         nOpcEnc   := 2
      Case nOpcRotina == 10 // Alterar R.V.
         lAlterar   := .t.
      Case nOpcRotina == 11 // Prorroga��o do R.V.
         lProrrogar := .t.
      Case nOpcRotina == 9 // Baixa do R.V.
         lBaixa    := .t.
         nOpcEnc   := 2
   EndCase
   lAltera := !lVisual .And. !lBaixa   

   If !SI301Valid("INICIO")
      Break
   EndIf
   
   aWork := CriaWorkItens() // Cria e carrega a work dos itens vinculados a esta R.V.
   
   aCposEnchoice := EECCposEnchoice("EEY") // campos que aparecem na enchoice
   
   // define os campos que ser�o edit�veis
   If lAlterar
      aNotEdit := {"EEY_PESBRU","EEY_DTRV","EEY_SEQ","EEY_PRCUNI","EEY_RATPRC"}
      If !Empty(EEY->EEY_NUMRV) //RMD - 19/01/06
         aAdd(aNotEdit, "EEY_PEEMBI")
         aAdd(aNotEdit, "EEY_PEEMBF")
         aAdd(aNotEdit, "EEY_PESLIQ")
      EndIf

      If !IsVazio("WkIt")
         aAdd(aNotEdit, "EEY_NCM")
         aAdd(aNotEdit, "EEY_DTQNCM")
         aAdd(aNotEdit, "EEY_TPONCM")
      EndIf
      aCposEdit := EECAClone(aCposEnchoice,aNotEdit)
   ElseIf lProrrogar
      aCposEdit := {"EEY_PEEMBI","EEY_PEEMBF","EEY_MESFIX","EEY_ANOFIX"} // na prorroga��o, apenas Per�odo de Embarque e M�s/Ano de Fix. est�o dispon�veis
      
      //OAP - Tratamento para o campo adicionado pelo usuario
      aCposEdit := AddCpoUser(aCposEdit,"EEY","1")

   EndIf
   
   DbSelectArea("EEY")
   // Inicializa vari�veis de mem�ria
   For i := 1 To FCount()
      M->&(FieldName(i)) := FieldGet(i)
      If Empty(M->&(FieldName(i)))
         M->&(FieldName(i)) := CriaVar(FieldName(i))
      EndIf
   Next

   bCancel := {|| oDlg:End() }
   If !lVisual .And. !lBaixa
      bOk := {|| If(SI301Valid("OK",aCposEnchoice),(lOk := .t., oDlg:End()),) }
   ElseIf lBaixa
      bOk := {|| If(MsgYesNo(STR0014,STR0010),(lOk := .t., oDlg:End()),) } // "Deseja fazer a baixa do R.V.? (O R.V. ser� retirado de todos os itens que o utilizem que n�o possuam processo embarcado, e seu saldo ficar� zerado, assim n�o poder� mais ser utilizado.)" ## "Aten��o"
   ElseIf lVisual
      bOk := bCancel
   EndIf
   
   If !lRvPed11 // alimenta campos informativos de qtd. e saldo
      EE8->(DbSetOrder(1))
      EE8->(DbSeek(xFilial()+EEY->EEY_PEDIDO))
      While EE8->(!EoF()) .And. xFilial("EE8")+EEY->EEY_PEDIDO == EE8->(EE8_FILIAL+EE8_PEDIDO)
         nQtdRv += EE8->EE8_SLDINI
         nSldRv += EE8->EE8_SLDATU
         EE8->(DbSkip())
      EndDo
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0015 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL //"Registro de Venda"

      aPos:= PosDlgUp(oDlg)

      If !lRvPed11
         @ 12,2 To aPos[1]+18,aPos[4] pixel

         aPos[1] += 20
         aPos[3] += 10
         @ 20,010 Say   STR0034 Size 50,08 Of oDlg Pixel //"Qtde. R.V."
         @ 18,045 MsGet nQtdRv  Size 70,08 Of oDlg Pixel When .f. Picture AvSx3("EE8_SLDINI",AV_PICTURE)         

         @ 20,130 Say   STR0035 Size 50,08 Of oDlg Pixel //"Saldo R.V."
         @ 18,165 MsGet nSldRv  Size 70,08 Of oDlg Pixel When .f. Picture AvSx3("EE8_SLDINI",AV_PICTURE)
      EndIf
      
      EnChoice(cAlias, nReg, nOpcEnc, , , ,aCposEnchoice, aPos, aCposEdit )

      aPos := PosDlgDown(oDlg)
      If !lRvPed11
         aPos[1] += 10
      EndIf

      oMsSelect := MsSelect():New("WkIt",,,aWork[2],,,aPos)
      oMsSelect:bAval := {|| SI301ViewIt() }
      
   ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel,,aButtons),oDlg:cTitle := If(lForcado, STR0029,oDlg:cTitle)) //"Registro de Venda - Visualizar"
   
   If !lOk .Or. lVisual
      Break
   EndIf
   
   Begin Transaction
      EEY->(RecLock("EEY",.F.))
      If lAlterar .Or. lProrrogar
         GravaHistorico()
         AvReplace("M","EEY")
         If lAlterar .And. lNewRv .And. !lRV11  
            If Empty(EEY->EEY_NUMRV) //RMD - 20/01/06 - Atualiza a quantidade e os pesos do pedido especial.
               EE8->(DbSetOrder(1))
               If EE8->(DbSeek(xFilial("EE8")+EEY->EEY_PEDIDO))
                  EE8->(RecLock("EE8",.F.))
                  EE8->EE8_SLDINI := EEY->EEY_PESLIQ
                  EE8->EE8_SLDATU := EEY->EEY_PESLIQ
                  EE8->EE8_PSLQTO := EEY->EEY_PESLIQ
                  EE8->EE8_PSBRUN := EEY->(EEY_PESBRU / EEY_PESLIQ)
                  EE8->EE8_PSBRTO := EEY->EEY_PESBRU
                  EE8->(MsUnlock())
               EndIf
            EndIf

            If IsVazio("WkIt")
               EE8->(DbSetOrder(1))
               EE8->(DbSeek(xFilial("EE8")+EEY->EEY_PEDIDO))
               While EE8->(!Eof()) .And. EE8->(EE8_FILIAL+EE8_PEDIDO) == xFilial("EE8")+EEY->EEY_PEDIDO
                  EE8->(RecLock("EE8",.F.),;
                  EE8_POSIPI := EEY->EEY_NCM,;
                  EE8_TPONCM := EEY->EEY_TPONCM,;
                  EE8_DTQNCM := EEY->EEY_DTQNCM,;
                  MsUnlock(),;
                  DbSkip())
               EndDo
            EndIf
            
         EndIf
         If lProrrogar
            EEY->EEY_STATUS := ST_PR //status: "Prorrogado"
         EndIf
         
      ElseIf lBaixa
         If AtuIt(1) //Baixa do R.V.
            EEY->EEY_STATUS := ST_BA //status: "Baixado"
         EndIf
      EndIf
      
      EEY->(MsUnlock())
   End Transaction
   
End Sequence

If Select("WkIt") > 0
   WkIt->(E_EraseArq(aWork[1]))
EndIf

RestOrd(aOrd)

Return Nil

/*
Fun��o     : AtuIt()
Objetivos  : Faz a baixa do R.V.
Par�metros : nTipo : 1 -> Baixa
Retorno    : Nenhum
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 22/11/05 �s 16:41
*/
*--------------------------*
Static Function AtuIt(nTipo)
*--------------------------*
   Local i, j, aEE8 := {}, aAuxEE8 := {}
   Local lRet := .T.
   Local aDetail := {}, aHeader := {}
   
   Begin Sequence
	  
	  aAuxEE8 := SI301ItRv(cRv)
	  
      EE9->(DbSetOrder(1))
      EEC->(DbSetOrder(1))
      
      For i := 1 To Len(aAuxEE8)
         EE8->(DbGoTo(aAuxEE8[i]))
         If EE8->EE8_STATUS <> ST_RV
            If EE9->(DbSeek(xFilial()+EE8->(EE8_PEDIDO+EE8_SEQUEN))) // se tem item no embarque, j� n�o pode tirar o R.V..
               If Empty(aHeader)
                  aHeader := {"EE8_PEDIDO","EE8_SEQUEN","EE8_DTVCRV","EE8_PRECO","EE8_COD_I","EE8_SLDINI","EE8_SLDATU" }
               EndIf
               AAdd(aDetail,Array(Len(aHeader)))
               For j := 1 To Len(aHeader)
                  aDetail[Len(aDetail)][j] := EE8->&(aHeader[j])
               Next
               Loop
            EndIf
         EndIf
         AAdd(aEE8,aAuxEE8[i])
      Next

      If !Empty(aDetail)
         If !EECView({ {STR0028 + Repl(ENTER,2),.t.},{EECMontaMsg(aHeader,aDetail),.f.}},STR0010) // "O R.V. n�o poder� ser desvinculado dos itens a seguir, pois os mesmos j� possuem embarque. Deseja prosseguir com a Baixa?" ## "Aten��o"
            lRet := .f.
            Break
         EndIf
      EndIf

      For i := 1 To Len(aEE8)
         EE8->(DbGoTo(aEE8[i]))

         If EE8->EE8_STATUS = ST_RV  // se for item de pedido especial, s� liquida o saldo
            EE8->(RecLock("EE8",.F.))
            EE8->EE8_SLDATU := 0
            EE8->(MsUnlock())
         Else // se for item de pedido normal, ent�o limpa os campos de R.V., apenas se n�o tiver processo embarcado.

            AP105ClearFix() //Limpa campos de fixa��o

            // agrupa quebras por fixa��o
            AgruparItens(EE8->EE8_PEDIDO, EE8->EE8_ORIGEM, {|| Empty(EE8_DTFIX)}, , EE8->EE8_RV)

            EE8->(RecLock("EE8",.F.))
            // limpa campos de R.V.
            EE8->EE8_RV     := ""
            EE8->EE8_DTRV   := AvCToD("")
            EE8->EE8_DTVCRV := AvCToD("")
            EE8->(MsUnlock())

            // Agrupa quebras por Vincula��o de R.V.
            AgruparItens(EE8->EE8_PEDIDO, EE8->EE8_ORIGV, {|| Empty(EE8_DTVCRV)}, .f.)
               
         EndIf
      Next
   
   End Sequence
   
Return lRet

/*
Fun��o     : SI301ItRv()
Objetivos  : Alimentar array com recnos de itens do EE8 que est�o vinculados ao R.V. 'cRv', inclusive os do pedido especial
Par�metros : cRv -> n�mero do R.V.
Retorno    : Nenhum
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 02/12/05 �s 17:52
*/
*------------------------------*
Function SI301ItRv(cRv)
*------------------------------*
Local aAuxEE8 := {}, cQry

Begin Sequence
   
   If Empty(cRv)
      Break
   EndIf
   
   #IFDEF TOP
      cQry := ""
      cQry += "SELECT "
      cQry += "R_E_C_N_O_ AS RECNO "
      cQry += "FROM " + RetSQLName("EE8") + " EE8 "
      cQry += "WHERE "
      cQry += "D_E_L_E_T_ <> '*' "
      cQry += " AND EE8_FILIAL = '"+xFilial("EE8")+"' "
      cQry += " AND EE8_RV = '"+cRv+"' "
      cQry := ChangeQuery(cQry)
      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QRY", .F., .T.)
      While Qry->(!EoF())
         AAdd(aAuxEE8,Qry->RECNO)
         Qry->(DbSkip())
      EndDo
      Qry->(DbCloseArea()) // fecha arquivo tempor�rio.
   #ELSE
      EE8->(DbSetFilter({|| EE8->(EE8_FILIAL+EE8_RV) ==   xFilial("EE8")+cRv },;
                           "EE8->(EE8_FILIAL+EE8_RV) == "+xFilial('EE8')+cRv ))
      EE8->(DbGoTop())
      While EE8->(!EoF())
         AAdd(aAuxEE8,EE8->(RecNo()))
         EE8->(DbSkip())
      EndDo
      EE8->(DbClearFilter())
   #ENDIF

End Sequence

Return aAuxEE8

/*
Fun��o     : GravaHistorico()
Objetivos  : Grava o hist�rico de altera��es do R.V.
Par�metros : Nenhum
Retorno    : Nenhum
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 22/11/05 �s 16:48
*/
*------------------------------*
Static Function GravaHistorico()
*------------------------------*
Local i, mHist := "", aHeader := {}, aDetail := {}, cPict

Begin Sequence
   
   // Monta cabe�alho da mensagem
   AAdd(aHeader,{,"C",STR0016,Len(SX3->X3_TITULO)}) //"Campo Alterado"
   AAdd(aHeader,{,"C",STR0017})                     //"Informa��o Anterior"
   AAdd(aHeader,{,"C",STR0018})                     //"Informa��o Nova"
   
   DbSelectArea("EEY")
   // levanta as altera��es realizadas em cada campo
   For i := 1 To FCount()
      If M->&(FieldName(i)) <> FieldGet(i)
         cPict := Posicione("SX3",2,FieldName(i),"X3_PICTURE")
         AAdd(aDetail,{AvSx3(FieldName(i),AV_TITULO),Transform(FieldGet(i),cPict),Transform(M->&(FieldName(i)),cPict) })
      EndIf
   Next
   
   // se houveram altera��es, ent�o grava no campo memo.
   If Len(aDetail) > 0
      mHist := EECMontaMsg(aHeader,aDetail)
      mHist := SI301HeadHist() + mHist
               
      mHist := mHist + Repl(ENTER,2) + MSMM(M->EEY_HIST,TAMMEMO,,,LERMEMO)

      MSMM(M->EEY_HIST,,,,EXCMEMO)
      MSMM(,TAMMEMO,,mHist,INCMEMO,,,"EEY","EEY_HIST")
      M->EEY_HIST := EEY->EEY_HIST
   EndIf
   
End Sequence

Return Nil

/*
Fun��o     : SI301HeadHist()
Objetivos  : Retornar header do hist�rico de altera��es
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 26/11/05 �s 16:55
*/
*----------------------*
Function SI301HeadHist()
*----------------------*
Return STR0019 + AllTrim(DToC(dDataBase)) + Space(5) +;         //"Data Alter.: "
       STR0026 + AllTrim(Time())          + Space(5) +;         //"Hora: "
       STR0020 + AllTrim(cUserName) + Repl(ENTER,2)             //"Usu�rio: "

/*
Fun��o     : SI301HistFix()
Objetivos  : Gravar hist�rico da fixa��o de pre�o.
Par�metros : lFix -> .T. fixa��o, .F. estorno de fixa��o
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 26/11/05 �s 17:19
*/
*-------------------------*
Function SI301HistFix(lFix)
*-------------------------*
Local mHist
Local cAlias := Alias()
DbSelectArea("EEY")

If lRvPed11
   If lFix
      mHist := STR0030 //"Os seguintes itens deste R.V. foram fixados: "
   Else
      mHist := STR0032 //"Os seguintes itens tiveram suas fixa��es de pre�o estornadas:"
   EndIf
Else
   If lFix
      mHist := STR0031 //"O R.V. teve seu pre�o fixado. Dados: "
   Else
      mHist := STR0033 //"O R.V. teve sua fixa��o de pre�o estornada. Dados:"
   EndIf
EndIf

mHist := SI301HeadHist() + mHist + Repl(ENTER,2) + EECMontaMsg(aHeaderMsg,aDetailMsg)
mHist := mHist + Repl(ENTER,2) + MSMM(EEY->EEY_HIST,TAMMEMO,,,LERMEMO)

MSMM(EEY->EEY_HIST,,,,EXCMEMO)
MSMM(,TAMMEMO,,mHist,INCMEMO,,,"EEY","EEY_HIST")
If !Empty(cAlias)
   DbSelectArea(cAlias)
EndIf
Return Nil

/*
Fun��o     : CriaWorkItens()
Objetivos  : Cria e carrega a work dos itens que est�o vinculados ao R.V.
Par�metros : Nenhum
Retorno    : {nome da work, array de campos para o browse}
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 17/11/05 �s 13:40
*/
*-----------------------------*
Static Function CriaWorkItens()
*-----------------------------*
Local cWork, aCpos := {"EE8_PEDIDO","EE8_SLDINI","EE8_PRECO","EE9_RE","EEQ_NROP","EEQ_TX","EEQ_VL","EEQ_PGT"}
Local aCposBrowse  := {}, cQry := ""
Local i
Private aCampos

Begin Sequence
   
   For i := 1 To Len(aCpos)
      AAdd(aCposBrowse,ColBrw(aCpos[i],"WkIt"))
   Next
 
   AAdd(aCpos,"EE8_SEQUEN")
   
   For i := 1 To Len(aCpos)
      aCpos[i] := {aCpos[i],AvSx3(aCpos[i],AV_TIPO),AvSx3(aCpos[i],AV_TAMANHO),AvSx3(aCpos[i],AV_DECIMAL)}
   Next

   cWork := E_CriaTrab(,aCpos,"WkIt")

   // se n�o houve retorno do siscomex, ainda n�o pode estar vinculado a nenhum item.
   If Empty(cRv)
      Break
   EndIf
   
   #IFDEF TOP
      cQry += "SELECT "
      cQry += "R_E_C_N_O_ AS RECNO "
      cQry += "FROM " + RetSQLName("EE8") + " EE8 "
      cQry += "WHERE "
      cQry += "D_E_L_E_T_ <> '*'"
      cQry += " AND EE8_FILIAL =  '" + xFilial("EE8") + "'"
      cQry += " AND EE8_RV     =  '" + cRv            + "'"
      If lRvPed11
         cQry += " AND EE8_RV <> '" + Space(AvSx3("EE8_RV",AV_TAMANHO))+ "'"
      Else
         cQry += " AND EE8_STATUS <> '" + ST_RV          + "'"
      EndIf
      cQry := ChangeQuery(cQry)
      dbUseArea(.T., "TOPCONN", TcGenQry(,,cQry), "QRY", .F., .T.)
   #ELSE
      cFilt := "EE8->(EE8_FILIAL+EE8_RV) == '" + xFilial('EE8')+cRv+"' .And. " + If(lRvPed11,"!Empty(EE8->EE8_RV)"," EE8->EE8_STATUS <> '"+ST_RV+"'")
      EE8->(DbSetFilter(&("{|| " + cFilt + " }"),cFilt))
   #ENDIF
  
   #IFDEF TOP
      While Qry->(!EoF())
         EE8->(DbGoTo(QRY->RECNO))
   #ELSE
      While EE8->(!EoF())
   #ENDIF
         WkIt->(DbAppend())
         AvReplace("EE8","WkIt")
         WkIt->EE9_RE   := Posicione("EE9",1,EE8->(EE8_FILIAL+EE8_PEDIDO+EE8_SEQUEN),"EE9_RE")
         WkIt->EEQ_NROP := Posicione("EEQ",1,EE9->(EE9_FILIAL+EE9_PREEMB),"EEQ_NROP")
         WkIt->EEQ_TX   := EEQ->EEQ_TX
         WkIt->EEQ_VL   := EEQ->EEQ_VL
         WkIt->EEQ_PGT  := EEQ->EEQ_PGT
   #IFDEF TOP
         Qry->(DbSkip())
   #ELSE
         EE8->(DbSkip())
   #ENDIF
      EndDo

   #IFDEF TOP
      QRY->(DbCloseArea())
   #ELSE
      EE8->(DbClearFilter())
   #ENDIF
   
End Sequence

WkIt->(DbGoTop())

Return {cWork,aCposBrowse}

/*
Fun��o     : SI301ViewIt()
Objetivos  : Visualizar item na enchoice
Par�metros : Nenhum
Retorno    : Nil
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 17/11/05 �s 14:19
*/
*--------------------*
Function SI301ViewIt()
*--------------------*
Local aOrd := SaveOrd({"EE7","EE8"})
Private aGets, aTela, M->EE7_PEDIDO := EE7->EE7_PEDIDO
Begin Sequence
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial()+WkIt->(EE8_PEDIDO+EE8_SEQUEN)))
   AxVisual("EE8",EE8->(RecNo()),2,,,,,)
End Sequence
RestOrd(aOrd)
Return Nil

/*
Fun��o     : SI301MasterUser()
Objetivos  : Verifica se o usu�rio poder� ter acesso a prorroga��es diferenciadas, sendo de grupos superiores (ger�ncia, supervis�o, etc..)
Par�metros : Nenhum
Retorno    : .T./.F.
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 17/11/05 �s 11:03
*/
*------------------------*
Function SI301MasterUser()
*------------------------*
Local cGrupo := Upper(AllTrim(EasyGParam("MV_AVG0113",,"XXXXXX")))
Local nGroup, nI
Local lRet := .F.
Local aAllGrupo := FWSFAllGrps(),;
      aGrupos   := UsrRetGrp()

//FSM - 20/12/2010
If PswID() == '000000'  //Usu�rio administrador
   lRet := .T.
Else
   For nI := 1 To Len(aGrupos)
       If (nGroup := AScan(aAllGrupo,{|x| AllTrim(x[2]) == AllTrim(aGrupos[nI]) })) > 0
          If Upper(AllTrim(aAllGrupo[nGroup][3])) == cGrupo
             lRet := .T.
             Exit
          EndIf
       EndIf
   Next
EndIf

Return lRet

/*
Fun��o     : SI301Valid()
Objetivos  : Valida��o
Par�metros : cValid - Valida��o a ser efetuada
Retorno    : .T./.F.
Autor      : Jo�o Pedro Macimiano Trabbold
Data/Hora  : 17/11/05 �s 10:45
*/
*---------------------------------------*
Function SI301Valid(cValid,aCposEnchoice)
*---------------------------------------*
Local lRet := .t., aAux, i

Begin Sequence

   Do Case
      Case cValid = "INICIO" // Usado no SI300MAN e SI301MAN
         
         If EEY->EEY_STATUS == ST_BA .And. If(Type("lVisual")="L",!lVisual,aAuxRotina[nOpc]<>2.And.aAuxRotina[nOpc]<>0.And.aAuxRotina[nOpc]<>4)
            
            If MsgYesNo(STR0011,STR0010) // "Este R.V. j� est� baixado e n�o poder� ser alterado. Deseja visualiz�-lo?" ## "Aten��o"
               SI301MAN("EEY",EEY->(RecNo()),VISUALIZAR,.t.)
            EndIf
            lRet := .f.
            Break
         EndIf
   
         // Valida altera��o e/ou prorroga��o
         
         //RMD - 22/07/08 - Permite prorrogar R.V. com a quantidade total contendo pre�o fixado.
         If /*(Type("lProrrogar") = "L" .And. lProrrogar) .Or.*/ (Type("lAlterar") = "L" .And. lAlterar) //RMD - 19/01/06
            If !RvTemSaldoNaoFixado()
               MsgStop(STR0021,STR0010)//"Este R.V. n�o poder� ser alterado, pois n�o possui saldo dispon�vel sem fixa��o." ## "Aten��o"
               lRet := .f.
               Break
            EndIF
         EndIf
      
         // Valida Prorroga��o
         If Type("lProrrogar") = "L" .And. lProrrogar
            If Empty(EEY->EEY_NUMRV) //RMD - 19/01/06
               MsgStop(STR0040, STR0010)//"N�o � poss�vel prorrogar pois esta prepara��o de R.V. n�o possui retorno do Siscomex." ### "Aten��o"
               lRet := .F.
               Break
            EndIf
            If EEY->EEY_STATUS == ST_PR
               If SI301MasterUser()
                  If !MsgYesNo(STR0012+" "+STR0008,STR0010) //"Este R.V. j� foi prorrogado." ## "Deseja Continuar?" ## "Aten��o"
                     lRet := .f.
                     Break
                  EndIf
               Else
                  MsgStop(STR0012+" "+STR0013,STR0010) //"Este R.V. j� foi prorrogado." ## "Uma nova prorroga��o n�o � permitida." ## "Aten��o"
                  lRet := .f.
                  Break
               EndIf
            EndIf
         EndIf

         
         // Valida Baixa
         If Type("lProrrogar") == "L" .And. lBaixa .And. Empty(EEY->EEY_NUMRV)
            MsgStop(STR0039, STR0010)//"N�o � poss�vel efetuar baixa pois esta prepara��o de R.V. n�o possui retorno do Siscomex." ### "Aten��o"
            lRet := .F.
            Break
         EndIf

      Case cValid = "OK"
         If !SI300V("BOK_GERA",aCposEnchoice)
            lRet := .f.
            Break
         EndIf
         
         If (M->EEY_PEEMBF > EEY->EEY_PEEMBF + 30) // se o per�odo foi prorrogado por mais de 30 dias...
            If SI301MasterUser()
               If !MsgYesNo(STR0007+" "+STR0008,STR0010) //"A prorroga��o do per�odo ultrapassou os 30 dias permitidos pelo SISCOMEX." ## "Deseja Continuar?" ## "Aten��o"
                  lRet := .f.
                  Break
               EndIf
            Else
               MsgStop(STR0007+" "+STR0009,STR0010) //"A prorroga��o do per�odo ultrapassou os 30 dias permitidos pelo SISCOMEX." ## "Com isso, a mesma n�o ser� permitida." ## "Aten��o"
               lRet := .f.
               Break
            EndIf
         EndIf

      Case cValid = "ESTORNO"
         
         If !lRvPed11 // se for RV de Pedido especial, s� poder� ser estornado se n�o houverem itens vinculados ao R.V.
            aAux := SI301ItRv(EEY->EEY_NUMRV)
            For i := 1 To Len(aAux)
               EE8->(DbGoTo(aAux[i]))
               If EE8->EE8_STATUS <> ST_RV // se n�o for item de pedido especial, ent�o � item de contrato que est� vinculado ao R.V.
                  MsgStop(STR0036,STR0010) //"Existem itens vinculados a este R.V., portanto n�o poder� ser estornado." ## "Aten��o"
                  lRet := .f.
                  Break
               EndIf
            Next
         EndIf
   
   EndCase

End Sequence

Return lRet

/*
Fun��o       : RvTemSaldoNaoFixado()
Objetivo     : Verificar se o R.V. posicionado tem saldo dispon�vel n�o fixado
Par�metros   : Nenhum
Retorno      : .T./.F.
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 23/11/05 - 13:54
*/
*-----------------------------------*
Static Function RvTemSaldoNaoFixado()
*-----------------------------------*
Local lRet := .f.
Local aOrd := SaveOrd({"EE8"})
Local cPedido, cRv

Begin Sequence
   EEY->(cPedido := EEY_PEDIDO, cRv := EEY_NUMRV)
   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial()+cPedido))
   While EE8->(!EoF()) .And. EE8->(EE8_FILIAL+EE8_PEDIDO) == xFilial("EE8")+cPedido
      If EE8->EE8_RV == cRv
         If Empty(EE8->EE8_DTFIX) .And. EE8->EE8_SLDATU > 0 // se o item n�o tiver pre�o fixado, e tiver saldo, retorna .t.
            lRet := .t.
            Break
         EndIf
      EndIf
      EE8->(DbSkip())
   EndDo
End Sequence

RestOrd(aOrd,.T.)

Return lRet

/*
Fun��o       : SI301Hist()
Objetivo     : Mostrar Hist�rico de Altera��es ou retornar hist�rico j� existente
Par�metros   : lMostra - Define se mostra janela ou n�o (EECView)
Retorno      : Conte�do do hist�rico
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 17/11/05 - 9:30
*/
*-------------------------*
Function SI301Hist(lMostra)
*-------------------------*
Local mHist

If ValType(lMostra) <> "L"
   lMostra := .t.
EndIf

Begin Sequence

   mHist := MSMM(EEY->EEY_HIST,TAMMEMO)

   If lMostra
      mHist := STR0004 + AllTrim(Transform(EEY->EEY_NUMRV,AvSx3("EEY_NUMRV",AV_PICTURE))) + Repl(ENTER,2) +; // "Hist�rico de Altera��es no R.V. n� "
               If(Empty(AllTrim(mHist)),STR0027,mHist) //"N�o houveram altera��es neste R.V.."
      EECView(mHist,STR0005,STR0006) // "Hist�rico" ## "Altera��es Realizadas"
   EndIf
   
End Sequence

Return mHist

/*
Fun��o       : SI301Status()
Objetivo     : Retornar descri��o do Status do R.V.
Par�metros   : C�digo do Status : ST_NO - Normal
                                  ST_PR - Prorrogado
                                  ST_BA - Baixado
Retorno      : Descri��o do Status
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 16/11/05 - 16:30
*/
*------------------------*
Function SI301Status(cCod)
*------------------------*
Local cDesc := ""

Default cCod := If(Type("M->EEY_STATUS") = "C",M->EEY_STATUS,EEY->EEY_STATUS)

Do Case
   Case cCod == ST_NO
      cDesc := STR0001 //"Normal"
   Case cCod == ST_PR
      cDesc := STR0002 //"Prorrogado"
   Case cCod == ST_BA
      cDesc := STR0003 //"Baixado"
EndCase

Return cDesc

/*
Fun��o       : SI301SelPed()
Objetivo     : Solicitar sele��o de pedido ao usu�rio, e posicionar no mesmo.
Par�metros   : Nenhum
Retorno      : .T./.F.
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 23/11/05 - 14:24
*/
*--------------------*
Function SI301SelPed()
*--------------------*
Local lRet := .f., oDlg, oMsSelect
Local bOk     := {|| lRet := .t., oDlg:End()}
Local bCancel := {|| lRet := .f., oDlg:End()}
Private M->EE7_PEDIDO := Space(AvSx3("EE7_PEDIDO",AV_TAMANHO))

Begin Sequence
   
   If EEY->(!EoF())
      M->EE7_PEDIDO := EEY->EEY_PEDIDO
   EndIf
   
   Define MsDialog oDlg Title STR0022 From 1,1 To 15,50 Of oMainWnd // "Selecione o processo para prepara��o do R.V.:" FSM - 27/07/2011
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 11/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      AvBorda(oPanel)
      @ 26,10 Say   STR0023       Size 50 ,10 Of oPanel Pixel //"Processo :"
      @ 24,45 MsGet M->EE7_PEDIDO Size 100,10 Of oPanel Pixel F3 "EE7" Valid ExistCpo("EE7") Picture AvSx3("EE7_PEDIDO",AV_PICTURE)

   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

   Posicione("EE7",1,xFilial("EE7")+M->EE7_PEDIDO,"EE7_PEDIDO")
   
End Sequence

Return lRet

/*
Fun��o       : SI301RatPreco()
Objetivo     : Calcular e gravar o campo Rateio-Preco do EEY (posicionado)
Par�metros   : Nenhum
Retorno      : Nil
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 02/12/05 - 15:37
*/
*----------------------*
Function SI301RatPreco()
*----------------------*
Local nRatPrc := 0, aEE8 := {}, i, nQtdeTot := 0
Local aOrd := SaveOrd({"EE7","EE8","EEY"})

Begin Sequence

   EE8->(DbSetOrder(1))
   EE8->(DbSeek(xFilial("EE8")+EEY->EEY_PEDIDO))
   While EE8->(!EoF()) .And. xFilial("EE8")+EEY->EEY_PEDIDO == EE8->(EE8_FILIAL+EE8_PEDIDO)
      If EE8->(EE8_RV == EEY->EEY_NUMRV .And. !Empty(EE8_DTFIX))
         AAdd(aEE8,EE8->(RecNo()))
      EndIf
      EE8->(DbSkip())
   EndDo
   
   For i := 1 To Len(aEE8)
      EE8->(DbGoTo(aEE8[i]))
      nQtdeTot += EE8->EE8_SLDINI
   Next

   For i := 1 To Len(aEE8)
      EE8->(DbGoTo(aEE8[i]))
      nRatPrc += EE8->EE8_PRECO * (EE8->EE8_SLDINI/nQtdeTot)
   Next
   
   EEY->(RecLock("EEY",.F.) ,;
         EEY_RATPRC := Round(nRatPrc,AvSx3("EEY_RATPRC",AV_DECIMAL)) ,;
         MsUnlock())
   
End Sequence

RestOrd(aOrd,.t.)

Return Nil

/*
Fun��o       : SI301RvMan()
Objetivo     : Gerar arquivo Txt para retorno de R.V.
Par�metros   : Nenhum
Retorno      : Nil
Autor        : Jo�o Pedro Macimiano Trabbold
Data/Hora    : 19/12/05 - 19:37
*/
*-------------------*
Function SI301RvMan()
*-------------------*
Local hFile, cFile, c := ""
Local cProc, cHora

Posicione("EE7",1,xFilial("EE7")+EEY->EEY_PEDIDO,"EE7_PEDIDO")

Private cNumRv := CriaVar("EEY_NUMRV"), dData := AvCtoD("  /  /  ")

Begin Sequence
   
   If Empty(EEY->EEY_NUMRV)
      If Empty(EEY->EEY_TXTSIS) 
         SI300Gera(.T.)
      EndIf
   Else
      MsgInfo(STR0038,STR0010) //"Este R.V. j� foi retornado." ## "Aten��o"
      Break
   EndIf
   
   cFile := AllTrim(EEY->EEY_TXTSIS)
   c := ""
   cProc := EEY->EEY_PEDIDO
   cHora := SubStr(Time(),1,5)
   
   // tela com gets dos dados do R.V.
   If !GetNumRv()
      Break
   EndIf
   
   cFile := Left(cFile,Len(cFile)-3) + "OK" // nome do arquivo de retorno.
   hFile := EasyCreateFile(cPathOr+cFile)          // cria o arquivo
   c := IncSpace(cProc,20,.f.) + IncSpace(cNumRv,20,.f.) + IncSpace(AllTrim(DToC(dData)),10,.t.) + IncSpace(cHora,5,.f.)
   fWrite(hFile,c,Len(c))             // grava o conte�do
   fClose(hFile)                      // fecha o arquivo
   
   SI300Ret()
   
   If MsgYesNo(STR0041, STR0010)//"Deseja fixar o pre�o do R.V.?"###"Aten��o"
      AP100OpcFix()
   EndIf
   
End Sequence

Return Nil

*------------------------*
Static Function GetNumRv()
*------------------------*
Local lRet := .f., oDlg, i
Local bOk     := {|| lRet := .t., oDlg:End()}
Local bCancel := {|| lRet := .f., oDlg:End()}

Begin Sequence

   Define MsDialog oDlg Title STR0037 From 1,1 To 9,50 Of oMainWnd // "Informe o n�mero e a data do R.V. " FSM - 27/07/2011
      AvBorda(oDlg)
      @ 26,10  Say   AvSx3("EEY_NUMRV",AV_TITULO) Size 50 ,10 Of oDlg Pixel
      @ 24,50  MsGet cNumRv Size 40,06 Of oDlg Pixel Valid NaoVazio() .And. ExistChav("EEY",cNumRv) Picture AvSx3("EEY_NUMRV",AV_PICTURE)

      @ 26,100  Say   AvSx3("EEY_DTRV",AV_TITULO) Size 50 ,10 Of oDlg Pixel
      @ 24,130 MsGet dData Size 40,08 Of oDlg Pixel Valid NaoVazio() Picture AvSx3("EEY_DTRV",AV_PICTURE)
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

Return lRet
