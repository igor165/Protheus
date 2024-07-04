#Include "EEC.cH"
#Include "EECAD102.CH"

/*
Programa        : EECAD102.PRW
Objetivo        : Manutenção 
Autor           : Rodrigo Mendes Diaz
Data/Hora       : 25/10/2007
Obs. 
*/

#Define NAT_SALDO "SLD"
#Define ATIVO     "1"
#Define CANCELADO "2"

/*
Funcao      : EECAD102
Parametros  : Nenhum
Retorno     : .T.
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 25/10/07
Revisao     : 
Obs.        :
*/
Function EECAD102()
Local aOrd := SaveOrd({"EYS", "EYT"})
Private aRotina := MenuDef()

Private cAlias := "EYS",;
        cTitulo := STR0006 //"Manutenção da DEREX"

mBrowse(6, 1, 22, 75, cAlias)

RestOrd(aOrd, .F.)

Return .T.

/*
Funcao      : AD102MAN
Parametros  : cAlias - Alias da tabela em que será feita a manutenção
              nReg - Recno do registroq que será alterado
              nOpc - Indica o tipo de operação que será efetuada no registro
Retorno     : lOk
Objetivos   : Efetuar manutenção no DEREX
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 25/10/07 - 11:40
Revisao     : 
Obs.        : 
*/
Function AD102MAN(cAlias, nReg, nOpc)
Local oDlg
Local bOk     := {|| If(lOk := Obrigatorio(aGets,aTela),oDlg:End(),)},;
      bCancel := {|| oDlg:End()}
Local aFiles, aOrd := SaveOrd("EYR"), aBancos := {}
Private aButtons := {}
Private lOk := .F.
Private aGets[0],aTela[0]
Private cWorkDet := "WKDET", cWorkCons := "WKCONS"
Private oEnc, oBrwDet, oBrwCons

   aFiles := CriaWorks()
   RegToMemory(cAlias, nOpc == INCLUIR)
   
   If nOpc <> INCLUIR
      EYR->(DbSetOrder(6))
      EYR->(DbSeek(xFilial()+M->EYS_ID))
      While EYR->(!Eof() .And. EYR_FILIAL+EYR_DEREX == xFilial()+M->EYS_ID)
         (cWorkCons)->(DbSkip())
         AvReplace("EYR", cWorkCons)
         EYR->(DbSkip())
      EndDo
   EndIf

Begin Sequence

   aAdd(aButtons,{"NOTE",{|| AD102APUR(nOpc) }, "Apuração"})

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM DLG_LIN_INI,DLG_COL_INI;
                                      TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL

      EnChoice(cAlias, nReg, nOpc,,,,,PosDlg(oDlg))

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,, aButtons) CENTERED
   
   If lOk .And. nOpc <> VISUALIZAR
      If nOpc == INCLUIR .Or. nOpc == EXCLUIR
         (cWorkDet)->(DbGoTop())
         While (cWorkDet)->(!Eof())
            EYR->(DbGoTo((cWorkDet)->WK_RECNO))
            EYR->(RecLock("EYR", .F.))
            If nOpc == INCLUIR
               EYR->EYR_DEREX := M->EYS_ID
            Else
               EYR->EYR_DEREX := ""
            EndIf
            EYR->(MsUnlock())
            (cWorkDet)->(DbSkip())
         EndDo
         (cWorkCons)->(DbGoTop())
         While (cWorkCons)->(!Eof())
            If aScan(aBancos, (cWorkCons)->EYT_BANCO) == 0
               aAdd(aBancos, (cWorkCons)->EYT_BANCO)
            EndIf
         EndDo
         /* nopado por RNLP - 23/09/2020 - Static Function havia sido nopada anteriormente e chamada da função permaneceu no codigo
         GravaBancos(aBancos)
         */
      EndIf
      EYS->(RecLock("EYS", nOpc == INCLUIR))
      If nOpc <> EXCLUIR
         AvReplace("M", "EYS")
      Else
         EYS->(DbDelete())
      EndIf
      EYS->(MsUnlock())
   ElseIf !lOk .And. nOpc == INCLUIR
      RollBackSxE()
   EndIf

End Sequence

DelFiles(aFiles)
Return lOk
/*
Static Function GravaBancos(aBancos)
Local nInc, cContas

   For nInc := 1 To Len(aBancos)
      SA6->(DbSeek(xFilial()+aBancos[nInc]))
      While SA6->(!Eof() .And. SA6->A6_COD == aBancos[nInc])
         cContas += SA6->A6_NUMCON
         SA6->(DbSkip())
      EndDo
   Next

Return Nil
*/
Static Function DelFiles(aFiles)
Local nInc

   For nInc := 1 To Len(aFiles)
      If Select(aFiles[nInc][1]) > 0
         (aFiles[nInc][1])->(DbCloseArea())
      EndIf
      If File(aFiles[nInc][2]+GetDBExtension())
         FErase(aFiles[nInc][2]+GetDBExtension())
      EndIf
      If File(aFiles[nInc][2]+".FPT")
         FErase(aFiles[nInc][2]+".FPT")
      EndIf
      If File(aFiles[nInc][2]+TEOrdBagExt())
         FErase(aFiles[nInc][2]+TEOrdBagExt())
      EndIf
   Next

Return Nil

/*
Funcao     : AD102APUR()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Apurar as movimentações a serem enviadas na DEREX
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 13:00
*/
Static Function AD102APUR(nOpc)
Local oDlg
Local aTreePos
Local bOk     := {|| oDlg:End()},;
      bCancel := {|| oDlg:End()}
Local nInc
Local lOk := .F.
Private aMovement := {}

Private oActiveObj
Private oTree, oMain
Private lInverte := .F., cMarca := "  "
Private aGets[0],aTela[0]
Private nBanco := 1, nPais := 2, nMoeda := 3, nMovs := 4

   Processa({|| aMovement := GetMovements(nOpc)})
   Processa({|| ConsolMov(aMovement)})
   

   DEFINE MSDIALOG oDlg TITLE "Movimentações" FROM DLG_LIN_INI,DLG_COL_INI;
                                              TO DLG_LIN_FIM,DLG_COL_FIM STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL
      aTreePos := PosDlg(oDlg)
      aTreePos[4] := AVG_CORD(100)
      oTree := AvTree(MontaTree(aMovement), aTreePos,, oDlg)
      oTree:bChange := {|| ChangeTree(AllTrim(oTree:GetCargo())) }
      
      aBrowsePos := PosDlg(oDlg)
      aBrowsePos[2] += AVG_CORD(100)
    
      RegToMemory("SA6", .F.)
      Processa({|| CriaObjs(oDlg, aBrowsePos) })
      
      oMain := TScrollBox():New(oDlg, aBrowsePos[1], aBrowsePos[2], aBrowsePos[3] - aBrowsePos[1], aBrowsePos[4] - aBrowsePos[2],.T.,.F.,.T. )
      oMain:Hide()

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOk, bCancel, aButtons) CENTERED
   
Return Nil

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function GetMovements(nOpc)
Local cAlias, bChave
Local nPos1, nPos2, nInc1, nInc2, nInc3, nTot := EYR->(LastRec()) + 1
Local aMovement := {}
Local bSubMes := {|dData| SToD(StrZero(If(Month(dData) == 1, Year(dData) -1, Year(dData)), 4) + StrZero(If(Month(dData) == 1, 12, Month(dData) - 1), 2) + StrZero(Day(dData), 2)  ) }

   ProcRegua(nTot)
   IncProc("Verificando movimentações")
   If nOpc == INCLUIR
      cAlias := "EYR"
      EYR->(DbSetOrder(3))
      EYR->(DbSeek(xFilial("EYR")+M->EYS_ANO))
      bChave := {|| EYR->(!Eof() .And. EYR_FILIAL+Left(EYR_ANOMES, 4) == xFilial("EYR")+M->EYS_ANO) }
   Else
      cAlias := cWorkDet
      (cWorkDet)->(DbGoTop())
      bChave := {|| (cWorkDet)->(!Eof()) }
   EndIf
   While Eval(bChave)
      IncProc("Verificando movimentações (" + AllTrim(Str(EYR->(Recno()))) + "/" + AllTrim(Str(nTot)) + ")")
      
      If (cAlias)->EYR_FLAG <> ATIVO .Or. (cAlias)->EYR_NATURE == NAT_SALDO
         (cAlias)->(DbSkip())
         Loop
      EndIf
      
      If (nPos1 := aScan(aMovement, {|x| x[nBanco]+x[nPais]+x[nMoeda] == (cAlias)->(EYR_BANCO+EYR_PAIS+EYR_MOEDA) })) == 0
         aAdd(aMovement, {(cAlias)->EYR_BANCO, (cAlias)->EYR_PAIS, (cAlias)->EYR_MOEDA, {}})
         nPos1 := Len(aMovement)
      EndIf

      If (nPos2 := aScan(aMovement[nPos1][nMovs], {|x| x[1] == (cAlias)->EYR_NATURE })) == 0
         aAdd(aMovement[nPos1][nMovs], {(cAlias)->EYR_NATURE, {0,0,0,0,0,0,0,0,0,0,0,0}})
         nPos2 := Len(aMovement[nPos1][nMovs])
      EndIf
      aMovement[nPos1][nMovs][nPos2][2][Month((cAlias)->EYR_DATA)] += (cAlias)->EYR_VALOR

      If nOpc == INCLUIR
         (cWorkDet)->(DbAppend())
         AvReplace("EYR", cWorkDet)
      EndIf
      (cAlias)->(DbSkip())
   EndDo
   
   For nInc1 := 1 To Len(aMovement)
      For nInc2 := 1 To Len(aMovement[nInc1][nMovs])
         For nInc3 := 1 To 12
            If nInc3 == 1
               aMovement[nInc1][nMovs][nInc2][2][nInc3] += AD101GetSld(aMovement[nInc1][1],,, Left(DToS(Eval(bSubMes, SToD(M->EYS_ANO + "0101"))), 6))
            Else
               aMovement[nInc1][nMovs][nInc2][2][nInc3] += aMovement[nInc1][nMovs][nInc2][2][nInc3 - 1]
            EndIf
         Next
      Next
   Next

Return aMovement

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function ConsolMov()
Local nInc1, nInc2
Local nAtual := 0, nTotal := 50

   IncProc("Consolidando movimentações")
   aEval(aMovement, {|x| nTotal += Len(x[4]) })
   ProcRegua(nTotal)
   For nInc1 := 1 To Len(aMovement)
      For nInc2 := 1 To Len(aMovement[nInc1][nMovs])
         nAtual++
         IncProc("Consolidando movimentações (" + AllTrim(Str(nAtual)) + "/" + AllTrim(Str(nTotal)) + ")")
         (cWorkCons)->(DbAppend())
         (cWorkCons)->EYR_BANCO  := aMovement[nInc1][nBanco]
         (cWorkCons)->EYR_PAIS   := aMovement[nInc1][nPais]
         (cWorkCons)->EYR_MOEDA  := aMovement[nInc1][nMoeda]
         (cWorkCons)->EYR_NATURE := aMovement[nInc1][nMovs][nInc2][1]
         (cWorkCons)->WK_JAN := aMovement[nInc1][nMovs][nInc2][2][1]
         (cWorkCons)->WK_FEV := aMovement[nInc1][nMovs][nInc2][2][2]
         (cWorkCons)->WK_MAR := aMovement[nInc1][nMovs][nInc2][2][3]
         (cWorkCons)->WK_ABR := aMovement[nInc1][nMovs][nInc2][2][4]
         (cWorkCons)->WK_MAI := aMovement[nInc1][nMovs][nInc2][2][5]
         (cWorkCons)->WK_JUN := aMovement[nInc1][nMovs][nInc2][2][6]
         (cWorkCons)->WK_JUL := aMovement[nInc1][nMovs][nInc2][2][7]
         (cWorkCons)->WK_AGO := aMovement[nInc1][nMovs][nInc2][2][8]
         (cWorkCons)->WK_SET := aMovement[nInc1][nMovs][nInc2][2][9]
         (cWorkCons)->WK_OUT := aMovement[nInc1][nMovs][nInc2][2][10]
         (cWorkCons)->WK_NOV := aMovement[nInc1][nMovs][nInc2][2][11]
         (cWorkCons)->WK_DEZ := aMovement[nInc1][nMovs][nInc2][2][12]
      Next
   Next

Return .T.

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function CriaWorks()
Local aFiles := {}
Local aSemSx3 := {}
Private aHeader, aCampos

   aSemSx3 := {}
   aAdd(aSemSx3, {"EYR_BANCO",AvSx3("EYR_BANCO", AV_TIPO), AvSx3("EYR_BANCO", AV_TAMANHO), AvSx3("EYR_BANCO", AV_DECIMAL)})
   aAdd(aSemSx3, {"EYR_PAIS",AvSx3("EYR_PAIS", AV_TIPO), AvSx3("EYR_PAIS", AV_TAMANHO), AvSx3("EYR_PAIS", AV_DECIMAL)})
   aAdd(aSemSx3, {"EYR_MOEDA",AvSx3("EYR_MOEDA", AV_TIPO), AvSx3("EYR_MOEDA", AV_TAMANHO), AvSx3("EYR_MOEDA", AV_DECIMAL)})
   aAdd(aSemSx3, {"EYR_NATURE",AvSx3("EYR_NATURE", AV_TIPO), AvSx3("EYR_NATURE", AV_TAMANHO), AvSx3("EYR_NATURE", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_JAN","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_FEV","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_MAR","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_ABR","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_MAI","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_JUN","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_JUL","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_AGO","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_SET","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_OUT","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_NOV","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})
   aAdd(aSemSx3, {"WK_DEZ","N", AvSx3("EYR_VALOR", AV_TAMANHO), AvSx3("EYR_VALOR", AV_DECIMAL)})

   aAdd(aFiles, {cWorkCons, E_CriaTrab(, aSemSx3, cWorkCons)})
   
   aHeader := {}
   aCampos := Array(EYR->(FCount()))
   aSemSx3 := {}
   aAdd(aFiles, {cWorkDet, E_CriaTrab("EYR",, cWorkDet)})

Return aFiles

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function MontaTree(aMovement)
Local aTree := {}, nInc

   aAdd(aTree, {"    ", "Banco/País/Moeda", "RAIZ",,, StrZero(0, 4)})
   For nInc := 1 To Len(aMovement)
      aAdd(aTree, {StrZero(0, 4)   , aMovement[nInc][nBanco] + "/PAIS/MOEDA", "A0" + StrZero(nInc, 10),,, StrZero(nInc, 4)})
      aAdd(aTree, {StrZero(nInc, 4), "Consolidados", "WC" + StrZero(nInc, 10),,, "WC" + StrZero(nInc, 3) })
      aAdd(aTree, {StrZero(nInc, 4), "Detalhados", "WD" + StrZero(nInc, 10),,, "WD" + StrZero(nInc, 3)})
   Next

Return aTree

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function CriaABrw(cWork, cTipo)
Local aItensBrw := {}

Do Case
   Case cTipo == "DET"
      aItensBrw := ArrayBrowse("EYR", cWork)
      If aScan(aItensBrw, {|x| "DEREX" $ Upper(x[3]) }) > 0
         aDel(aItensBrw, aScan(aItensBrw, {|x| "DEREX" $ Upper(x[3]) }))
         aSize(aItensBrw, Len(aItensBrw) - 1)
      EndIf

   Case cTipo == "CONS"
      aAdd(aItensBrw, {&("{|| " + cWork + "->EYR_NATURE }"),"", "Natureza"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_JAN, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Janeiro"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_FEV, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Fevereiro"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_MAR, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Março"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_ABR, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Abril"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_MAI, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Maio"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_JUN, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Junho"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_JUL, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Julho"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_AGO, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Agosto"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_SET, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Setembro"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_OUT, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Outubro"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_NOV, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Novembro"})
      aAdd(aItensBrw, {&("{||TRANSF(" + cWork + "->WK_DEZ, AVSX3('EYR_VALOR', " + Str(AV_PICTURE) + "))}"),"", "Dezembro"})

   EndCase

Return aItensBrw

Static Function CriaObjs(oDlg, aPos)

   SA6->(DbGoTop())
   RegToMemory("SA6", .F.)
   oEnc := MsMGet():New("SA6", SA6->(Recno()), VISUALIZAR,,,,, aPos,,,,,,oDlg)
   oEnc:Hide()

   oBrwDet := MsSelect():New(cWorkDet,,, CriaABrw(cWorkDet, "DET"),@lInverte,@cMarca,aPos,,, oDlg)
   oBrwDet:oBrowse:Hide()
   oBrwCons := MsSelect():New(cWorkCons,,, CriaABrw(cWorkCons, "CONS"),@lInverte,@cMarca,aPos,,, oDlg)
   oBrwCons:oBrowse:Hide()

Return Nil

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function ChangeTree(cCargo)
Local nPos
Local cFilter

   If ValType(oActiveObj) == "O"
      oActiveObj:Hide()
   EndIf
   Do Case
      Case cCargo == "RAIZ"
         oActiveObj := oMain

      Case Left(cCargo, 2) == "A0"
         oActiveObj := oEnc
         nPos := Val(Right(cCargo, Len(cCargo) - 2))
         SA6->(DbSeek(xFilial()+aMovement[nPos][nBanco]))
         RegToMemory("SA6", .F.)
         oActiveObj:Refresh()

      Case Left(cCargo, 2) == "WC"
         nPos := Val(Right(cCargo, Len(cCargo) - 2))
         cFilter := "EYR_BANCO == '" + aMovement[nPos][nBanco] + "' "
         (cWorkCons)->(DbClearFilter())
         (cWorkCons)->(DbSetFilter(&("{|| " + cFilter +  " }"), cFilter))
         (cWorkCons)->(DbGoTop())
         oBrwCons:oBrowse:Refresh()
         oActiveObj := oBrwCons:oBrowse

      Case Left(cCargo, 2) == "WD"
         nPos := Val(Right(cCargo, Len(cCargo) - 2))
         cFilter := "EYR_BANCO == '" + aMovement[nPos][nBanco] + "' "
         (cWorkDet)->(DbClearFilter())
         (cWorkDet)->(DbSetFilter(&("{|| " + cFilter +  " }"), cFilter))
         (cWorkDet)->(DbGoTop())
         oBrwDet:oBrowse:Refresh()
         oActiveObj := oBrwDet:oBrowse

   End Case
   If ValType(oActiveObj) == "O"
      oActiveObj:Show()
   EndIf

Return Nil

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Retornar as definições de menu
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 25/10/07 - 11:00
*/
Static Function MenuDef()
Local aRotAdic
Local aRotina  := { { STR0001, "AxPesqui" , 0 , 1},;   //"Pesquisar"
                    { STR0002, "AD102MAN" , 0 , 2},;   //"Visualizar"
                    { STR0003, "AD102MAN" , 0 , 3},;   //"Incluir"
                    { STR0004, "AD102MAN" , 0 , 4},;   //"Alterar"
                    { STR0005, "AD102MAN" , 0 , 5,3}}  //"Cancelar"

Begin Sequence

   If EasyEntryPoint("EAD102MNU")
      aRotAdic := ExecBlock("EAD102MNU",.f.,.f.)
   EndIf

   If ValType(aRotAdic) == "A"
      aEval(aRotAdic,{|x| AAdd(aRotina,x)})
   EndIf

End Sequence

Return aRotina


Function GeraInt()
Local cXML := ""
cXML += "<?xml version='1.0' encoding='UTF-8' standalone='no' ?>"
cXML += "<classe xmlns='http://www.receita.fazenda.gov.br/declaracao' classeJava='serpro.derex.DeclaracaoDerex'>"
cXML += "<identificador dataFinal='" + M->EYS_DTINI + "' dataInicial='" + M->EYS_DTFIM + "' evento='' exercicio='" + M->EYS_ANO + "' inRetificadora='" + M->EYS_RETIF + "' ni='" + M->EYS_CNPJ + "' nome='" + M->EYS_RAZAO + "' situacaoEspecial='" + M->EYS_EVENTO + "' tipoCpfCnpj=''>"
cXML += "<idSistemaOperacional nome='Windows XP' versao='5.1' />"
cXML += "</identificador>"
cXML += "<movimentacoes tipoItens='serpro.derex.movimentacoes.Movimentacao'>"

/*
<item chave='0'>
  <identMov banco='Citibank S/A' endereco='PAULISTA, 1999' identConta='12030394, 234322' identOficial='Q23234' moeda='220' moedaDesc='DOLAR DOS EUA' nomeExterior='JOSE' pais='249' paisDesc='Estados Unidos' tipoDocumento='001' tipoDocumentoDesc='Cédula de Identidade (CI)' /> 
- <planilha saldoAnterior='0,00'>
  <jan aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='01' disponibilidades11371='300,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='700,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='1.000,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <fev aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='02' disponibilidades11371='300,00' disponibilidadesCambio='700,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='1.000,00' saldoMes='2.000,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <mar aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='03' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='2.000,00' saldoMes='2.000,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <abr aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='04' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='2.000,00' saldoAnterior='2.000,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <mai aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='05' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <jun aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='06' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <jul aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='07' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <ago aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='08' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <set aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='09' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <out aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='10' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <nov aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='11' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  <dez aplicFinanc='0,00' aquisBens='0,00' aquisServ='0,00' codigo='12' disponibilidades11371='0,00' disponibilidadesCambio='0,00' emprestimos='0,00' invest='0,00' outrasAplic='0,00' outrasOrigem='0,00' pgtoObrigacoes='0,00' remunDireitos='0,00' rendRecebidosExt='0,00' repatriacaoDispon='0,00' saldoAnterior='0,00' saldoMes='0,00' transfOutrasIFAplic='0,00' transfOutrasIFOrigem='0,00' /> 
  </planilha>
  </item>
  </movimentacoes>
  </classe>
*/
Return
