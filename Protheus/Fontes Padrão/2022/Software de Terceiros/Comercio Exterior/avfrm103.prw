#include "AVERAGE.CH"
#include "XMLXFUN.CH"
#INCLUDE "TOPCONN.CH"
#include "AVFRM101.CH"

#Define ITRECEBIDOS   "A"
#Define ITENVIADOS    "B"
#Define ITNAOENVIADOS "C"
#Define ITPROCESSADOS "D"
#Define ITBUSCA       "E"

#Define FONTE_PADRAO "Padrão"

#Define DIR_INBOUND		"comex\easylink\inttra\inbound\"
#Define DIR_OUTBOUND	"comex\easylink\inttra\outbound\"
#Define DIR_RESOURCES	"comex\easylink\inttra\resources\"

#Define XML_ISO_8859_1 "<?xml version='1.0' encoding='ISO-8859-1' ?>"

/*
Classe      : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/07
Revisao     : 
Obs.        : 
*/
*=========*
Class AvgXml
*=========*

Data cFile
Data oXML
Data cError
Data cWarning

Method New() Constructor
Method SetFile(cFile)
Method ReadXml()
Method SearchNod(cNod, cAtt, lSearchAll, oNod, __nNivel, __nNivelMax, __cType)

End Class

/*
Método      : 
Classe      : AvgXML
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method New() Class AvgXML

   ::cFile    := ""
   ::cError   := ""
   ::cWarning := ""

Return Self

/*
Método      : 
Classe      : AvgXML
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method SetFile(cFile) Class AvgXML
Local lRet := .F.

   ::cFile := cFile
   lRet := .T.

Return lRet

/*
Método      : 
Classe      : AvgXML
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method ReadXML() Class AvgXML
Local lRet := .F.

   ::lXmlLoaded := .F.
   If !Empty(::cError)
      Return lRet
   EndIf
   If File(DIR_RESOURCES + ::cFile)
      ::oXML := XmlParserFile(DIR_RESOURCES + ::cFile , "_", ::cError, ::cWarning)
      If Empty(::cError)
         ::lXmlLoaded := .T.
         lRet := .T.
      EndIf
   Else
      ::cError += StrTran(STR0036, "###", DIR_RESOURCES + ::cFile) + ENTER//"Arquivo '###' não encontrado."
      EECView({{Self:cError, .T.}}, "Aviso")
   EndIf

Return lRet

/*
Método      : 
Classe      : AvgXML
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
+Revisao     :
Obs.        :
*/
Method SearchNod(cNod, cAtt, lSearchAll, oNod, __nNivel, __nNivelMax, __cType) Class AvgXML
Local xRet := .F.
Local nInc, nChild := 0
Local cTipo
Local oChild
Default cAtt := ""
Default lSearchAll := .T.
Default oNod := ::oXML:_MENU
Default __nNivel    := 0
Default __nNivelMax := 0
Default __cType := "NOD"

Begin Sequence
   
   If !Empty(cAtt)
      __cType := "ATT"//Define que será feita a busca somente em atributos
   EndIf

   //Define o nível máximo de busca
   If !lSearchAll
      __nNivelMax := 1
   EndIf
   
   //Verifica se ultrapassou o nível máximo de busca
   If __nNivelMax > 0 .And. __nNivel > __nNivelMax
      Break
   EndIf

   If (cTipo := ValType(oNod)) == "O"
      //Verifica se está posicionado na tag procurada
      If Upper(oNod:RealName) == Upper(cNod)  .And. oNod:TYPE == __cType//A propriedade type indica se o objeto corresponde a uma tag (TAG) ou atributo (ATT)
         xRet := oNod//Se encontrada a tag, encerra a busca (final das recursões)
         Break
      EndIf
      //Verifica o número de tags "filhas" da atual, se estiver posicionado em um objeto do tipo tag
      If oNod:Type == "NOD"
         nChild := XmlChildCount(oNod)
      EndIf
   ElseIf cTipo == "A"//É possível encontrar um "Array" de tags, que deverá ser percorrido assim como o objeto
      nChild := Len(oNod)
   Else
      Break
   EndIf
   
   //Obtém o objeto das tags "filhas" da atual
   For nInc := 1 To nChild
      If cTipo == "O"
         oChild := XmlGetChild(oNod, nInc)
      Else//"A"
         oChild := oNod[nInc]
      EndIf
      
      //Faz a busca em profundidade nas tags "filhas"
      xRet := ::SearchNod(cNod, cAtt, , oChild, __nNivel + 1, __nNivelMax, __cType)

      If ValType(xRet) <> "L"
         If __nNivel == 0
            If !Empty(cAtt)
               //Busca o atributo da tag em alargamento e somente no primeiro nível.
               xRet := ::SearchNod(cAtt, , , xRet, , 1, "ATT")
            EndIf
         EndIf
         Break
      EndIf
   Next

End Sequence

Return xRet

/*
Classe      : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/07
Revisao     : 
Obs.        : 
*/
*========================*
Class AvgXML2Tree From AvgXML
*========================*

   Data aTree
   Data aMenu
   Data aPos
   Data aActions
   Data aConds
   Data oTree
   Data oFont
   Data oWait
   Data cMode
   Data cOnClick_All
   Data nNivel
   Data cMenuIdentifier
   Data lTreeLoaded
   Data lXmlLoaded

   Method New() Constructor
   Method SetId(cId)
   Method SetMode(cMode)
   Method SetMenu(aMenu)
   Method SetPosition(aPos)
   Method SetFont(oFont)
   Method Click(cCargo)
   Method LoadTree(oXML, nNivel, nNivelPai)
   Method ChkNod(oNod, nNivel, nNivelPai)
   Method AddNod(nNivel, nNivelPai, cText, cCargo, cImg1, cImg2)
   Method AddCompNod(oNod, nNivelPai)
   Method AddTree(oTree, nNivelPai)
   Method CreateTree(oDlg)
   Method Refresh()
   Method OpenTree()

End Class

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method New() Class AvgXML2Tree

   ::aTree           := {}
   ::aMenu           := {}
   ::aPos            := {}
   ::aActions        := {}
   ::aConds          := {}
   ::cMode           := "SIMPLES"
   ::cMenuIdentifier := ""
   ::cOnClick_All    := ""
   ::lTreeLoaded     := .F.
   ::lXmlLoaded      := .F.
   ::nNivel          := 0
   ::cFile           := ""
   ::cError          := ""
   ::cWarning        := ""

Return Self

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method LoadTree(oXML, nNivelPai) Class AvgXML2Tree
Local oChild
Local cTipo
Local nInc, nChild
Local lOk := .F.
Default nNivelPai := 0

Begin Sequence

   If !::lXmlLoaded .And. !::ReadXml()
      ::lTreeLoaded := .F.
      Break
   EndIf

   If ValType(oXML) <> "O" .And. ValType(oXML) <> "A"
      oXML := ::SearchNod(::cMenuIdentifier, , .F.)
   EndIf
   
   If (cTipo := ValType(oXML)) == "O"
      If (lOk := ::ChkNod(oXML, nNivelPai))
         nNivelPai := ::nNivel
      EndIf
      nChild := XmlChildCount(oXML)
   ElseIf cTipo == "A"
      nChild := Len(oXML)
      lOk := .T.
   EndIf
   
   If lOk
      For nInc := 1 To nChild
         If cTipo == "O"
            oChild := XmlGetChild(oXML, nInc)
         ElseIf cTipo == "A"
            oChild := oXML[nInc]
         EndIf
         ::LoadTree(oChild, nNivelPai)
      Next
   EndIf

End Sequence

::lTreeLoaded := lOk

Return ::lTreeLoaded

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method SetId(cId) Class AvgXML2Tree

   If ValType(cId) == "C"
      ::cMenuIdentifier := cId
   EndIf

Return ::cMenuIdentifier

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method SetMode(cMode) Class AvgXML2Tree

   If ValType(cMode) == "C"
      ::cMode := cMode
   EndIf

Return ::cMode

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method SetMenu(aMenu) Class AvgXML2Tree

   ::aMenu := aMenu

Return ::aMenu

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method SetPosition(aPos) Class AvgXML2Tree

   ::aPos := aPos

Return ::aPos

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method SetFont(oFont) Class AvgXML2Tree

   ::oFont := oFont

Return ::oFont

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method ChkNod(oNod, nNivelPai) Class AvgXML2Tree
Local lRet := .F.

   If ::cMode == "SIMPLES"
      ::nNivel++
      lRet := ::AddNod(::nNivel, nNivelPai, oNod:Text, oNod:Text, "", "")
   ElseIf ::cMode == "COMPLETO"
      If oNod:RealName == ::cMenuIdentifier
         lRet := .T.
      EndIf
      If oNod:RealName $ "TREE"
         ::nNivel++
         lRet := ::AddTree(oNod, nNivelPai)
      EndIf
      If oNod:RealName == "TREEINFO"
         lRet := .F.
      EndIf
      If oNod:RealName $ "TWIG/LEAF"
         ::nNivel++
         lRet := ::AddCompNod(oNod, nNivelPai)
      EndIf
   EndIf

Return lRet

Method AddNod(nNivel, nNivelPai, cText, cCargo, cImg1, cImg2) Class AvgXML2Tree

   aAdd(::aTree, {StrZero(nNivelPai, 4), cText, cCargo, cImg1, cImg2, StrZero(nNivel, 4)})

Return .T.

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method AddCompNod(oNod, nNivelPai) Class AvgXML2Tree
Local oName, oCargo, oIcon1, oIcon2, oOnClick, oCond
Local cName, cCargo, cIcon1, cIcon2, cOnClick := ::cOnClick_All , cCond
Local lRet := .F.

Begin Sequence

   If ValType(oName  := ::SearchNod("NAME" ,, .F., oNod)) == "O"
      cName := oName:Text
   EndIf

   If ValType(oCargo := ::SearchNod("CARGO",, .F., oNod)) == "O"
      cCargo := oCargo:Text
   EndIf
   
   If ValType(cName) <> "C" .And. ValType(cCargo) <> "C"
      Break
   EndIf

   If ValType(oIcon1 := ::SearchNod("ICON1",, .F., oNod)) == "O"
      cIcon1 := oIcon1:Text
   EndIf
   
   If ValType(oIcon2 := ::SearchNod("ICON2",, .F., oNod)) == "O"
      cIcon2 := oIcon2:Text
   EndIf

   If ValType(oCond := ::SearchNod("COND",, .F., oNod)) == "O"
      cCond := oCond:Text
      aAdd(::aConds, {cCargo, cCond})
   EndIf
 
   If (lRet := ::AddNod(::nNivel, nNivelPai, cName, cCargo, cIcon1, cIcon2))
      If ValType(oOnClick := ::SearchNod("ONCLICK",, .F., oNod)) == "O" .And. ValType(cCargo) == "C"
         If !Empty(cOnClick)
            cOnClick += ", "
         EndIf
         cOnClick += oOnClick:Text
      EndIf
      If !Empty(cOnClick)
         aAdd(::aActions, {cCargo, &("{|Self, cCargo|" + cOnClick + "}")})
      EndIf
   EndIf

End Sequence
   
Return lRet

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method Refresh() Class AvgXML2Tree
/*
Local nInc, nPos
Local bBackChange := ::oTree:bChange, bBackLDblClick := ::oTree:bLDblClick
Local aTreeNew := {}

   ::oWait:Show()
   ::oTree:bChange   := {||}
   ::oTree:bLDblClick := {||}
   ::oTree:TreeSeek(StrZero(0, 4))
   For nInc := 1 To Len(::aTree)
      If ::oTree:TreeSeek(::aTree[nInc][3])
         ::oTree:DelItem(::aTree[nInc][3])
      EndIf
      If ((nPos := aScan(::aConds, {|x| x[1] == ::aTree[nInc][3]})) > 0 .And. !Eval(&("{|| " + ::aConds[nPos][2] + "}")))
         Loop
      EndIf
      aAdd(aTreeNew, aClone(::aTree[nInc]))
   Next
   ::oTree:TreeSeek(StrZero(0, 4))
   ::oTree:DelItem(StrZero(0, 4))   
   AvTree(aTreeNew,,,, ::oTree)
   ::OpenTree()
   ::oTree:bChange   := bBackChange
   ::oTree:bLDblClick := bBackLDblClick
   ::oWait:Hide()
*/
Return

Method OpenTree() Class AvgXML2Tree
Local nInc

   If Empty(::cError)
      For nInc := 1 To Len(::aTree)
        ::oTree:TreeSeek(::aTree[nInc][3])
      Next
      nInc := aScan(::aTree, {|x| x[1] == StrZero(0, 4) })
      ::oTree:TreeSeek(::aTree[nInc][3])
   EndIf

Return

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method Click(cCargo) Class AvgXML2Tree
Local nPos
Private cName := AllTrim(cCargo)         	
Default cCargo := ""

   If (nPos := aScan(::aActions, {|x| x[1] == cName})) > 0 .And. ValType(::aActions[nPos][2]) == "B"
      Eval(::aActions[nPos][2], Self, cName)
   EndIf

Return Nil

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method AddTree(oTree, nNivelPai) Class AvgXML2Tree
Local lRet := .F.
Local oInfo, oModule, oOnClick_All
   
   If ValType(oInfo := ::SearchNod("TREEINFO",, .F., oTree)) == "O"
      If ValType(oModule := ::SearchNod("MODULE",, .F., oInfo)) == "O"
         If Val(oModule:Text) == nModulo
            If ValType(oOnClick_All := ::SearchNod("ONCLICK_ALL",, .F., oInfo)) == "O"
               ::cOnClick_All := oOnClick_All:Text
            EndIf
            lRet := ::AddCompNod(oInfo, nNivelPai)
         EndIf
      EndIf
   EndIf

Return lRet

/*
Método      : 
Classe      : AvgXML2Tree
Parâmetros  : 
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method CreateTree(oDlg) Class AvgXML2Tree
Local aTree := {}, nInc, nPos

   If ::lTreeLoaded .Or. ::LoadTree()
      For nInc := 1 To Len(::aTree)
         If ((nPos := aScan(::aConds, {|x| x[1] == ::aTree[nInc][3]})) > 0 .And. !Eval(&("{|| " + ::aConds[nPos][2] + "}")))
            Loop
         EndIf
         aAdd(aTree, aClone(::aTree[nInc]))
      Next
      ::oTree := AvTree(aTree, ::aPos, ::aMenu, oDlg)
      ::oTree:bChange   := {|| Self:Click(Self:oTree:GetCargo()) }
      ::oTree:bLDblClick := {|| Self:Click(Self:oTree:GetCargo()) }
      If ValType(::oFont) == "O"
         ::oTree:oFont := ::oFont
      EndIf
      ::oWait := TScrollBox():New(oDlg, ::aPos[1], ::aPos[2], ::aPos[3] - ::aPos[1], ::aPos[4] - ::aPos[2],.T.,.F.,.T. )
      @ 05,05 SAY STR0037 OF ::oWait PIXEL//"Atualizando..."
      ::oWait:Hide()
   EndIf

Return ::oTree

Function Frm103GetEmb(oIMonitor)
Local oDlg
Local bOk := {|| If(ExistCpo("EEC", cEmb), (lOk := .T., oDlg:End()),) },;
      bCancel := {|| oDlg:End() }
Local lOk := .F., oEmb
Local cEmb := Space(AvSx3("EEC_PREEMB", AV_TAMANHO))

   If !Empty(oIMonitor:cProcess)
      cEmb := oIMonitor:cProcess
      lOk := .T.
   Else
   
      DEFINE MSDIALOG oDlg TITLE STR0038 FROM 1,1 To 100,350 OF oMainWnd Pixel//"Inclusão de arquivo"
    
       @ 05, 2 To 49, 174 Label STR0039 Pixel//"Indique o processo de embarque que será utilizado"
       @ 22,20 Say AvSx3("EEC_PREEMB", AV_TITULO) Pixel Of oDlg//"Processo"
       @ 21,60 MsGet oEmb Var cEmb  Size 70,07 Valid ExistCpo("EEC", cEmb) PICTURE AvSx3("EEC_PREEMB", AV_PICTURE) F3 "EEC" Pixel Of oDlg

      Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) Centered
   EndIf
   
   If !lOk
      cEmb := ""
   EndIf

Return cEmb

Function Frm103FLMan(cSrv, nOpc, cCont, cProcesso, cNomFile)
Local cDirOut := DIR_OUTBOUND
Local nHandler
Default cProcesso := ""
Default cSrv := ""

Do Case
   Case cSrv == "BK"
      If (nOpc == INCLUIR) .Or. (nOpc == ALTERAR)
         nHandler := EasyCreateFile(cDirOut + cNomFile + ".xml")
         FWrite(nHandler, XML_ISO_8859_1 + RemoveTags( cCont, {"ChargeCategory"})) 
         FClose(nHandler)
         EYM->(RecLock("EYM", .T.))
         EYM->EYM_FILIAL := xFilial("EYM")
         EYM->EYM_FILE   := cNomFile + ".xml"
         EYM->EYM_DATA   := dDataBase
         EYM->EYM_HORA   := Time()
         EYM->EYM_USER   := If(Type("cUser") == "C", cUser, SubStr(cUsuario, 7, 15))
         EYM->EYM_STATUS := ITNAOENVIADOS
         EYM->EYM_PROC   := cProcesso
         EYM->EYM_NAVIO  := EEC->EEC_EMBARC
         EYM->EYM_VIAGEM := EEC->EEC_VIAGEM
         EYM->EYM_ETD    := EEC->EEC_ETD
         EYM->EYM_SHIPID := cProcesso + cNomFile
         EYM->EYM_ST_MES := cOpcao
         EYM->(MsUnlock())
      EndIf

   Case cSrv == "SI"
      If (nOpc == INCLUIR) .Or. (nOpc == ALTERAR)
         nHandler := EasyCreateFile(cDirOut + cNomFile + ".xml")
         FWrite(nHandler, XML_ISO_8859_1 + RemoveTags(cCont, {"ChargeCategory", "HaulageDetails", "Documents"}))
         FClose(nHandler)
         EYN->(RecLock("EYN", .T.))
         EYN->EYN_FILIAL := xFilial("EYN")
         EYN->EYN_FILE   := cNomFile + ".xml"
         EYN->EYN_DATA   := dDataBase
         EYN->EYN_HORA   := Time()
         EYN->EYN_USER   := If(Type("cUser") == "C", cUser, SubStr(cUsuario, 7, 15))
         EYN->EYN_STATUS := ITNAOENVIADOS
         EYN->EYN_PROC   := cProcesso
         EYN->EYN_ID_SI  := cId
         EYN->(MsUnlock())
      EndIf
      
End Case

Return .T.

Static Function RemoveTags(cCont, aTags)
Local nInc
Local nPosI1, nPosI2, nPosF1, nPosF2
Local nLen := Len(cCont)

   cCont := StrTran(cCont, "&", "&amp;")

   For nInc := 1 To Len(aTags)
      If (nPosF1 := At("</" + aTags[nInc], cCont)) > 0
         nPosF2 := nPosF1
         While SubStr(cCont, nPosF2, 1) <> ">" .And. nPosF2 < nLen
            ++nPosF2
         EndDo
         nPosI2 := nPosF1 - 1
         If !SubStr(cCont, nPosI2, 1) == ">"
            While SubStr(cCont, nPosI2, 1) <> ">" .And. nPosI2 > 0
               If (SubStr(cCont, nPosI2, 1) == " ") .Or. (SubStr(cCont, nPosI2, 1) == "	")
                  --nPosI2
               ElseIf (SubStr(cCont, nPosI2 - 1, 2) == ENTER)
                  nPosI2 -= 2
               Else
                  Exit
               EndIf
            EndDo
            If !SubStr(cCont, nPosI2, 1) == ">"
               Loop
            EndIf
         EndIf
         nPosI1 := nPosI2
         While SubStr(cCont, nPosI1, 1) <> "<" .And. nPosI1 > 0
            --nPosI1
         EndDo
         If (nPosI1 == nPosI2) .Or. (nPosI2 == 0) .Or. (nPosF1 == nPosF2) .Or. (nPosF2 == 0)
            Loop
         EndIf
         If !(At(aTags[nInc], SubStr(cCont, nPosI1, nPosI2 - nPosI1)) > 0)
            cCont := SubStr(cCont, 1, nPosF2) + RemoveTags(SubStr(cCont, nPosF2 + 1), {aTags[nInc]})
            Loop
         EndIf
         cCont := SubStr(cCont, 1, nPosI2 - 1) + "/>" + RemoveTags(SubStr(cCont, nPosF2 + 1), {aTags[nInc]})
      EndIf
   Next

Return cCont


Function Frm103DesSta(cAlias)
Local cStatus := ""
Default cAlias := ""

   Do Case
      Case (cAlias)->&(cAlias + "_STATUS") == ITRECEBIDOS
         cStatus := STR0040//"Item Recebido"

      Case (cAlias)->&(cAlias + "_STATUS") == ITENVIADOS
         cStatus := STR0041//"Item Enviado"

      Case (cAlias)->&(cAlias + "_STATUS") == ITNAOENVIADOS
         cStatus := STR0042//"Item não Enviado"

      Case (cAlias)->&(cAlias + "_STATUS") == ITPROCESSADOS
         cStatus := STR0043//"Item processado"

   End Case

Return cStatus

Function AvUnZip(cFile, cDir, cDest, lInterface, nWait)
Local oProcess
Local lRet := .F.
Local bAction := {|| lRet := AuxUnZipFile(cFile, cDir, cDest, lInterface, nWait) }
Default lInterface := Type("oMainWnd") == "O"

   If lInterface
      MsAguarde(bAction, STR0022, STR0043)//"Aguarde..."###"Executando descompactador de arquivos."
   Else
      Eval(bAction)
   EndIf   
   
Return lRet

Static Function AuxUnZipFile(cFile, cDir, cDest, lInterface, nWait)
Local lRet := .T., lAVG_UNZIP :=.F.
Local cVBS := 'Set oUnzipFSO = CreateObject("Scripting.FileSystemObject")' + ENTER;
            + 'If Not oUnzipFSO.FolderExists(WScript.Arguments(1)) Then' + ENTER;
            + '   oUnzipFSO.CreateFolder(WScript.Arguments(1))' + ENTER;
            + 'End If' + ENTER;
            + 'With CreateObject("Shell.Application")' + ENTER;
            + '.NameSpace(WScript.Arguments(1)).Copyhere .NameSpace(WScript.Arguments(0)).Items' + ENTER;
            + 'End With' + ENTER
Local hFile
Local nResult, nSeconds
Local cNewFolder := StrTran(Upper(cFile), ".ZIP", "")

Default nWait := 3

   If !File(cDir + cFile)
      If lInterface
         MsgInfo(StrTran(STR0044, "###", cFile), STR0017)//"Arquivo '###' não foi encontrado."&&&"Atenção"
      EndIf
      lRet := .F.
   Else
      If Empty(cZipApp := EasyGParam("MV_AVG0150",, "AVG_UNZIP.VBS")) .Or. AllTrim(cZipApp) == "AVG_UNZIP.VBS"
         cZipApp := CriaTrab(, .F.) + ".VBS"
         lAVG_UNZIP := .T.
      EndIf
   
      If lAVG_UNZIP
         hFile := EasyCreateFile(cZipApp)
         FWrite(hFile, cVBS, Len(cVBS))
         FClose(hFile)
      EndIf

      If lAVG_UNZIP
         If CpyS2T(cZipApp, GetTempPath(), .F.) .And. CpyS2T(cDir + cFile, GetTempPath(), .F.)
            nResult := WaitRun("cscript.exe  " + GetTempPath() + cZipApp + " " + GetTempPath() + cFile + " " + GetTempPath() + cNewFolder)
            nSeconds := Seconds()
         EndIf
      Else
         nResult := WaitRun(cZipApp + " " + cFile + " " + cDest)
         nSeconds := Seconds()
      EndIf

      While (Seconds() - nSeconds) > nWait
         Loop
      EndDo
   
      lRet := lIsDir(GetTempPath() + cNewFolder)
   EndIf
   
   If !lRet .And. lInterface
      MsgInfo(StrTran(STR0045, "###", cFile), STR0017)//"Erro ao descompactar o arquivo '###'."&&&"Atenção"
   EndIf

   If lAVG_UNZIP
      FErase(cZipApp)
      FErase(GetTempPath() + cZipApp)
      FErase(GetTempPath() + cFile)
      MakeDir(cDest)
      CpyT2S(GetTempPath() + cNewFolder + "\*.xml", cDest, .F.)
      CpyT2S(GetTempPath() + cNewFolder + "\*.pdf", cDest, .F.)
      aDir := Directory(GetTempPath() + cNewFolder + "\*.*")
      aEval(aDir, {|x| FErase(GetTempPath() + cNewFolder + "\" + x[1]) })
      DirRemove(GetTempPath() + cNewFolder)
   EndIf

Return lRet

Class AvInterfPrefs

Data __aFonts

Method New() Constructor
Method AddFont(cIdentifier, cFont, nSize, lBold, lUnderline)
Method RetFont(cIdentifier)
Method EditPrefs()
Method MakeFontList(xFont)
Method MakeSizeList(xFont)
Method Refresh()

End Class

Method New() Class AvInterfPrefs
   ::__aFonts := {}
Return Self

Method AddFont(cIdentifier, cFont, cSize, lBold, lUnderline) Class AvInterfPrefs

   If ValType(cSize) == "N"
      cSize := Str(cSize)
   EndIf
   If ValType(lBold) <> "L"
      lBold := .F.
   EndIf
   If ValType(lUnderline) <> "L"
      lUnderline := .F.
   EndIf
   aAdd(::__aFonts, AvFont():New(cIdentifier, cFont, cSize, lBold, lUnderline))

Return Self

Method RetFont(cIdentifier) Class AvInterfPrefs
Local oFont, nPos

   If (nPos := aScan(::__aFonts, {|x| Upper(AllTrim(x:cIdentifier)) == Upper(AllTrim(cIdentifier)) })) > 0
      oFont := ::__aFonts[nPos]:Font()
   EndIf

Return oFont

Method EditPrefs() Class AvInterfPrefs
Local nInc, nPos

Local nLin := 08, nCol1 := 06, nCol2 := 26, nCol3 := 92, nCol4 := 120, nCol5 := 160, nCol6 := 190, nCol7 := 200

Local oSayF, oComboF, oSayT, oComboS, oCheckN, oSayE

Private aFonts := ::__aFonts

  DEFINE MSDIALOG oDlg TITLE "Fonte" FROM 0,0 TO 400,1000 OF oMainWnd PIXEL

   For nInc := 1 To Len(aFonts)
   
      cObjFontAtu := "aFonts[" + StrZero(nInc, 3)+"]"
      cObjSayFont := "oSayF"   + StrZero(nInc, 3)
      cArrFList   := "aFList"  + StrZero(nInc, 3)
      &cArrFList  := ::MakeFontList(aFonts[nInc])
      cVarFList   := "aFonts[" + StrZero(nInc, 3)+"]:cFont"
      cArrFTamF   := "aTamF"   + StrZero(nInc, 3)
      &cArrFTamF  := ::MakeSizeList(aFonts[nInc])
      cVarTamF    := "aFonts[" + StrZero(nInc, 3)+"]:cSize"
      cVarBold    := "aFonts[" + StrZero(nInc, 3)+"]:lBold"
      cVarUnderL  := "aFonts[" + StrZero(nInc, 3)+"]:lUnderLine"
      cAtuFont    := "{|| " + cObjSayFont + ":oFont:=" + cObjFontAtu + ":GerFont() , " + cObjSayFont + ":Refresh() }"
   
      @nLin+1, nCol1 SAY oSayF Var "" PIXEL OF oDlg
      oSayF:cCaption := aFonts[nInc]:cIdentifier
      nCol2 := SetDimensions(oSayF, nCol1,,, 10)
   
      @nLin, nCol2 COMBOBOX oComboF Var &(cVarFList) ITEMS &cArrFList PIXEL OF oDlg
      oComboF:bSetGet := &("{|U| If(PCount() == 0," + cVarFList + ", " + cVarFList + " := U ) }")
      oComboF:bChange := &cAtuFont
      nCol3 := SetDimensions(oComboF, nCol2,, .T., 10)

      @nLin+1, nCol3 SAY oSayT VAR "Tamanho" PIXEL OF oDlg
      nCol4 := SetDimensions(oSayT, nCol3)

      @nLin, nCol4 COMBOBOX oComboS Var &(cVarTamF) ITEMS &cArrFTamF PIXEL OF oDlg
      oComboS:bSetGet := &("{|U| If(PCount() == 0," + cVarTamF + ", " + cVarTamF + " := U ) }")
      oComboS:bChange := &cAtuFont
      nCol5 := SetDimensions(oComboS, nCol4,,.T.)

      @nLin+1,nCol5 CHECKBOX oCheckN Var &(cVarBold) PROMPT "Negrito" PIXEL OF oDlg
      oCheckN:bSetGet := &("{|U| If(PCount() == 0," + cVarBold + ", " + cVarBold + " := U ) }")
      oCheckN:bChange := &cAtuFont
      nCol6 := SetDimensions(oCheckN, nCol5)

      @nLin+1,nCol6 CHECKBOX oCheckN Var &(cVarUnderL) PROMPT "Sublinhado" PIXEL OF oDlg
      oCheckN:bSetGet := &("{|U| If(PCount() == 0," + cVarUnderL + ", " + cVarUnderL + " := U ) }")
      oCheckN:bChange := &cAtuFont
      nCol7 := SetDimensions(oCheckN, nCol6)
   
      @nLin+1, nCol7 SAY &(cObjSayFont) VAR "Exemplo" FONT &(cObjFontAtu + ":oFont") SIZE 200,200 PIXEL OF oDlg
   
      nLin += 20

   Next

   ACTIVATE MSDIALOG oDlg CENTERED
   
   ::Refresh()

Return Nil

Method MakeFontList(oFont) Class AvInterfPrefs
Local aFontList := &("GetFontList()")
Local nPos
Local cFontAtu

Begin Sequence

   aAdd(aFontList, FONTE_PADRAO)

   If ValType(oFont) == "O" .And. (nPos := aScan(aFontList, {|x| Upper(AllTrim(x)) == Upper(AllTrim(oFont:cFont)) })) > 0
      cFontAtu := aFontList[nPos]
      aAdd(aFontList, Nil)
      aIns(aFontList, 1)
      aFontList[1] := cFontAtu
   EndIf

End Sequence

Return aFontList

Method MakeSizeList(oFont) Class AvInterfPrefs
Local aSizeList := {"6","7","8","9","10","11","12","13","14","16", "18", "20", "22", "24", "26", "28", "30", FONTE_PADRAO}
Local cSizeAtu

Begin Sequence

   If ValType(oFont) == "O" .And. (nPos := aScan(aSizeList, {|x| Upper(AllTrim(x)) == Upper(AllTrim(oFont:cSize)) })) > 0
      cSizeAtu := aSizeList[nPos]
      aAdd(aSizeList, Nil)
      aIns(aSizeList, 1)
      aSizeList[1] := cSizeAtu
   EndIf

End Sequence

Return aSizeList

Method Refresh() Class AvInterfPrefs
Local nInc

   For nInc := 1 To Len(::__aFonts)
      ::__aFonts[nInc]:GerFont()
   Next

Return Nil

Static Function SetDimensions(oObj, nColAnt, nEspaco, lCombo, nLen)
Local nFator := 4
Default nColAnt := 1
Default nEspaco := 2
Default lCombo  := .F.
Default nLen    := 0

   If !__IsProp(oObj, "aItems")
      If nLen == 0
         nLen := Len(oObj:cCaption)
      EndIf
      oObj:nHeight := 22
   Else
      nFator += 14
      If nLen == 0
         nLen := Len(oObj:aItems[1])
      EndIf
   EndIf

   oObj:nWidth := nLen * nFator * 2

Return nColAnt + (nLen*nFator) + nEspaco

Static Function __IsProp(oObj, cProp)
Local lRet := aScan(ClassDataArr(oObj), {|x| If(ValType(x)=="A" .And. Len(x)>0 .And. ValType(x[1]) == "C", x[1] == Upper(cProp), .F.)} ) <> 0
Return lRet

Class AvFont

   Data cIdentifier
   Data cFont
   Data cSize
   Data lBold
   Data lUnderline
   Data oFont
   
   Method New(cIdentifier, cFont, cSize, lBold, lUnderLine) Constructor
   Method Font()
   Method GerFont()

End Class

Method New(cIdentifier, cFont, cSize, lBold, lUnderLine) Class AvFont
Default cIdentifier := FONTE_PADRAO
Default cFont       := FONTE_PADRAO
Default cSize       := FONTE_PADRAO
Default lBold       := .F.
Default lUnderLine  := .F.

   ::cIdentifier := cIdentifier
   ::cFont := cFont
   ::cSize := cSize
   ::lBold := lBold
   ::lUnderLine := lUnderLine
   
   ::GerFont()

Return ::oFont

Method Font() Class AvFont
Return ::oFont

Method GerFont() Class AvFont

   ::oFont := TFont():New(If(::cFont == FONTE_PADRAO, Nil, ::cFont), 0, If(::cSize == FONTE_PADRAO, Nil, (Val(::cSize)+2)*(-1)),, ::lBold,,,,,::lUnderLine)

Return ::oFont
