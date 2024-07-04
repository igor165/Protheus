#Include "Average.ch"

Function AvSayGets()
Return Nil

Class AvSayGets
   
   Data lActive
   Data lNewHeight
   Data cTitulo
   
   Data aGets
   Data oObjPai
   Data ClassName
   
   Data oGets
   Data oBox
   Data oPanel
   Data aPosCols
   
   Data nTop
   Data nLeft
   Data nHeight
   Data nWidth
   Data nRealHeight
      
   Data nLinSay
   Data nLinGet

   Data nPulaLinha   
   Data nPulaCols
   Data nHeightBorder
   Data nEntreSayGet
   
   Data nWidthSay
   Data nHeightSay

   Data nWidthGet
   Data nHeightGet
   
   Data cError

   
   Method New()
   Method SX3Get(cCampo)
   Method Show()
   Method Refresh()
   
   Method Init(hWnd)
   Method TrataGets()
   Method ValidaParam()
   Method CalcPos()
   Method ClassName()
   
End Class

Method ClassName() Class AvSayGets
Return ::ClassName

Method New(cTitulo,oDlg,nTop,nLeft,nHeight,nWidth,aGets,lNewHeight) Class AvSayGets

lParamOK := ::ValidaParam(@cTitulo,"C","") .AND.;
            ::ValidaParam(@oDlg   ,"O",GetWndDefault()) .AND.;
            ::ValidaParam(@nTop   ,"N",0) .AND.;
            ::ValidaParam(@nLeft  ,"N",0) .AND.;
            ::ValidaParam(@nHeight,"N",(oDlg:nBottom-oDlg:nTop)/2) .AND.;
            ::ValidaParam(@nWidth ,"N",(oDlg:nRight-oDlg:nLeft)/2) .AND.;
            ::ValidaParam(@aGets  ,"A",Array(0)) .AND.;
            ::ValidaParam(@lNewHeight,"L",.T.)

//Inicializa parametros de tela (pixel)
::ValidaParam(@::nLinSay      ,"N",03)
::ValidaParam(@::nLinGet      ,"N",03)
::ValidaParam(@::nPulaLinha   ,"N",03)
::ValidaParam(@::nPulaCols    ,"N",10)
::ValidaParam(@::nHeightBorder,"N",04)
::ValidaParam(@::nEntreSayGet ,"N",03)
::ValidaParam(@::nWidthSay    ,"N",40)
::ValidaParam(@::nHeightSay   ,"N",08)
::ValidaParam(@::nWidthGet    ,"N",90)
::ValidaParam(@::nHeightGet   ,"N",08)

If !lParamOk
   ::lActive := .F.
   Return Nil
EndIf

::lActive := .T.
::ClassName := "AvSayGets"

::aPosCols:= {}
::oGets   := {}
::aGets   := aClone(aGets)
::nTop    := nTop
::nLeft   := nLeft
::nHeight := nHeight
::nWidth  := nWidth
::oObjPai := oDlg
::lNewHeight := lNewHeight
::cTitulo := cTitulo

::oPanel := TPanel():New(0, 0, ,::oObjPai, , .F., .F., , , 10, 10, , )
::oPanel:nLeft	 := ::nLeft
::oPanel:nRight	 := ::nLeft+::nWidth
::oPanel:nTop	 := ::nTop
::oPanel:nBottom := ::nTop+::nHeight

::oBox := TScrollBox():New(::oPanel,0,0, 10,10,.T.,.T.,.T.,::oPanel)
::oBox:lVisible := .t.
::oBox:oFont    := oDlg:oFont
::oBox:nLeft	:= 0
::oBox:nRight	:= ::nWidth
::oBox:nTop		:= 0
::oBox:nBottom	:= ::nHeight
::oBox:Align := CONTROL_ALIGN_ALLCLIENT

aAdd(oDlg:aControls,Self)

Return Self

Method Init(hWnd) Class AvSayGets
::TrataGets()
::CalcPos()
::Show()
Return Nil

Method CalcPos() Class AvSayGets
Local i

nHeightBorder := ::nHeightBorder

nLinSay := ::nLinSay
nLinGet := ::nLinGet

nWidthSay  := ::nWidthSay
nHeightSay := ::nHeightSay
nWidthGet  := ::nWidthGet
nHeightGet := ::nHeightGet
nEntreSayGet := ::nEntreSayGet
nPulaCols    := ::nPulaCols
nPulaLinha   := ::nPulaLinha

nWidthCol   := nWidthSay + nEntreSayGet + nWidthGet + nPulaCols
nHeightCol  := Max(nHeightSay,nHeightGet)

nNumCols    := Max(int(::nWidth / nWidthCol ),1) //Numero de Colunas na Linha
nNumLins    := int(Len(::aGets)/nNumCols) + if(mod(Len(::aGets),nNumCols)>0,1,0)

nLin := 1
nCol := 1
For i := 1 To Len(::aGets)
   
   nTopSay  := nLinSay+(nPulaLinha+nHeightCol)*(nLin-1)+nPulaLinha
   nTopGet  := nTopSay
   
   nLeftSay := (nPulaCols+nWidthCol)*(nCol-1)+nPulaCols
   nLeftGet := nLeftSay + nWidthSay + nEntreSayGet
   
   aAdd(::aPosCols,{{nTopSay,nLeftSay,nWidthSay,nHeightSay},; //Say
                    {nTopGet,nLeftGet,nWidthGet,nHeightGet},; //Get
                    NIL}) //Campo
   ::aPosCols[Len(::aPosCols)][3] := ::aGets[i]
   
   nCol++
   If nCol > nNumCols
      nLin++
      nCol := 1
   EndIf
   
Next i

::nRealHeight := nLinSay+(nPulaLinha+nHeightCol)*(nLin)+nPulaLinha+nHeightBorder

If ::lNewHeight
   ::oPanel:nBottom := ::oPanel:nTop+2*::nRealHeight
EndIf

Return Nil

Method Show() Class AvSayGets
Local i

oGroup := TGroup():New(0,0,10,10,::cTitulo,::oBox,,, .T.,.T.)
oGroup:Align := CONTROL_ALIGN_ALLCLIENT

::oGets := {}
For i:= 1 To Len(::aPosCols)
    aAdd(::oGets,Array(0))
    
	aAdd(::oGets[i],TSay():New(::aPosCols[i][1][1],::aPosCols[i][1][2],&("{|| '"+::aPosCols[i][3][1]+"'}"),::oBox,,::oBox:oFont,.F.,.F.,.F.,.T., , ,::aPosCols[i][1][3],::aPosCols[i][1][4],.F.,.F.,.F.,.F.,.F.))
	aAdd(::oGets[i],TGet():New(::aPosCols[i][2][1],::aPosCols[i][2][2],&("{|x| if(x<>NIL,"+::aPosCols[i][3][2]+" := x,"+::aPosCols[i][3][2]+") }"),::oBox,::aPosCols[i][2][3],::aPosCols[i][2][4],::aPosCols[i][3][3], {|| ::aPosCols[i][3][4] },,,::oBox:oFont,.F.,,.T.,"",.F.,NIL,.F.,.F.,,.F.,.F.,"",::aPosCols[i][3][2],"",.F.,0,.T.))
	If !::aPosCols[i][3][4]
       ::oGets[i][2]:Disable()
    EndIf
Next i

::oBox:Show()

Return Nil

Method Refresh() Class AvSayGets
Local i

For i := 1 To Len(::oGets)
   ::oGets[i][1]:Refresh()
   ::oGets[i][2]:Refresh()
Next i

::oBox:Refresh()

Return Nil

Method SX3Get(cCampo,lAlt) Class AvSayGets
Local aGet
Default lAlt := .F.

If Type("M->"+cCampo) == AvSX3(cCampo,AV_TIPO)
   cCampoGet := "M->"+cCampo
Else
   cCampoGet := Posicione("SX2",1,cCampo,"X2_ARQUIVO")
EndIf

aGet := {AvSX3(cCampo,AV_TITULO),cCampoGet,AvSX3(cCampo,AV_PICTURE),lAlt}

Return aClone(aGet)

Method ValidaParam(xValue,cTipo,xDefault) Class AvSayGets
Local lRet := .T.
Default xValue := xDefault

If ValType(xValue) <> cTipo
   lRet := .F.
   ::cError := "Parametro incorreto"
EndIf

Return lRet

Method TrataGets() Class AvSayGets
Local aGets
Local i
Local add

aGets := aClone(::aGets)

::aGets := {}
For i := 1 To Len(aGets)
   If ValType(aGets[i]) == "C"
      If At("_",aGets[i]) > 0
         aAdd(::aGets,::SX3Get(aGets[i]))
      ElseIf Len(aGets[i]) == 3 .AND. SX2->(dbSeek(aGets[i]))
         SX3->(dbSetOrder(1),dbSeek(aGets[i]))
         Do While SX3->(!Eof() .AND. AllTrim(X3_ARQUIVO) == AllTrim(aGets[i]))
            aAdd(::aGets,::SX3Get(SX3->X3_CAMPO))
            SX3->(dbSkip())
         EndDo
      EndIf
   ElseIf ValType(aGets[i]) == "A" .AND. Len(aGets[i]) == 2
      If At("_",aGets[i][1]) > 0
         aAdd(::aGets,::SX3Get(aGets[i][1],aGets[i][2]))
      ElseIf Len(aGets[i][1]) == 3 .AND. SX2->(dbSeek(aGets[i][1]))
         SX3->(dbSetOrder(1),dbSeek(aGets[i][1]))
         Do While SX3->(!Eof() .AND. AllTrim(X3_ARQUIVO) == AllTrim(aGets[i][1]))
            aAdd(::aGets,::SX3Get(SX3->X3_CAMPO,aGets[i][2]))
            SX3->(dbSkip())
         EndDo
      EndIf
   ElseIf ValType(aGets[i]) == "A" .AND. Len(aGets[i]) == 3      
      add := aClone(aGets[i])
      aAdd(add,.F.)
      
      aAdd(::aGets,add)
   ElseIf ValType(aGets[i]) == "A" .AND. Len(aGets[i]) == 4
      aAdd(::aGets,aGets[i])
   EndIf
Next i

Return Nil