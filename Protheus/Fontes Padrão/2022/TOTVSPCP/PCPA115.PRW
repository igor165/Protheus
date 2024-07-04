#INCLUDE "PROTHEUS.CH"
#INCLUDE "PCPA115.CH"
#INCLUDE "FWMVCDEF.CH"
 
Function PCPA115()
  Local oDlg1
  Local aCoors    := FWGetDialogSize( oMainWnd )
  Local aDesTab   := {STR0001,STR0002} //"Detalhes","Componentes"
  Private nLargura := aCoors[4]
  Private nHeight  := aCoors[3]
  Private oNumOp, oProduto, oQtde, oQtdePrd, oUnMed, oDtEnt
  Private cNumOp, cProduto, cQtde, cQtdePrd, cUnMed, dDtEnt
  Private oFontN
  Private cOpPesq   := CriaVar("H6_OP", .F.)
  Private oTree
  Private aCompon := {}
  Private oLbx

  DEFINE Font oFontN Name "Arial" Size 07,16

  DEFINE DIALOG oDlg1 TITLE STR0003 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL //"Controle Apontamento de Produção"
    
  If nHeight < 680
     nHeight := 680
  EndIf

  //-----------------
  //Painel principal
  //-----------------
  oScroll := TScrollArea():New(oDlg1,01,01,100,100)
  oScroll:Align := CONTROL_ALIGN_ALLCLIENT

  oPanelPrinc := TPanel():New( 01, 01, ,oDlg1, , , , , , nLargura/2, nHeight/2, .F.,.F. )
  oScroll:SetFrame( oPanelPrinc )

  oPanelPesq := TPanel():New( 01, 01, ,oPanelPrinc, , , , , , nLargura/2, ((nHeight/2) * 0.08), .F.,.F. )
  oPanelPesq:Align := CONTROL_ALIGN_TOP

  @ 15,((nLargura/2)-188) BUTTON oBtnApon PROMPT STR0004 SIZE 60,12 Font oFontN ACTION (APontaProd()) OF oPanelPesq PIXEL //"Apontar"
  @ 15,((nLargura/2)-126) BUTTON oBtnLeg PROMPT STR0005 SIZE 60,12 Font oFontN ACTION (AbreDlgLeg()) OF oPanelPesq PIXEL //"Legendas"
  @ 15,((nLargura/2)-64) BUTTON oBtnSair PROMPT STR0020 SIZE 60,12 Font oFontN  ACTION (oDlg1:End())  OF oPanelPesq PIXEL //"Sair"

  //pesquisa busca op para a tree
  @ 17,05 SAY oPesq VAR STR0006 + ": " Font oFontN OF oPanelPesq PIXEL //"Ordem"
  @ 15,35 MSGET cOpPesq SIZE 80,10 OF oPanelPesq F3 "SC2" VALID LoadTree() PIXEL

  oPanelDados := TPanel():New( ((nHeight/2) * 0.08), 01, ,oPanelPrinc, , , , , , nLargura/2, ((nHeight/2) * 0.92), .F.,.F. )
  oPanelDados:Align := CONTROL_ALIGN_CENTER
    
  //Inicia o Layer   1
  //Cria o layer pelo metodo construtor
  oLayer := FWLayer():New()

  //Inicia o 1o Layer
  oLayer:Init(oPanelDados,.T.)

  //Cria as colunas do Layer
  oLayer:addCollumn("ColunaDados",100,.F.)

  //Adiciona Janelas as colunas
  oLayer:addWindow("ColunaDados",'C1_Win01',STR0008,70,.T.,.T.,{|| },,{|| }) //"Dados"
    
  CriaTree()

  oLayer:addWindow("ColunaDados",'C1_Win02',STR0001,30,.T.,.T.,{|| },,{|| }) //"Detalhes"

  oPnlDetal := oLayer:getWinPanel("ColunaDados",'C1_Win02')

  oTFolder := TFolder():New(0,0,aDesTab,,oPnlDetal,,,,.T.,,300,150)
  oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
    
  oPnlFDet := oTFolder:aDialogs[1]

  @ 005,08 SAY STR0010 SIZE 45, 30 Font oFontN OF oPnlFDet PIXEL //"Número OP:"
  @ 003,55 MSGET oNumOp VAR cNumOp Font oFontN WHEN .F. SIZE 150,10 OF oPnlFDet PIXEL

  @ 005,210 SAY STR0011 SIZE 45, 30 Font oFontN OF oPnlFDet PIXEL //"Produto:"
  @ 003,260 MSGET oProduto VAR cProduto Font oFontN WHEN .F. SIZE 150,10 OF oPnlFDet PIXEL

  @ 020,08 SAY STR0012 SIZE 45, 30 Font oFontN OF oPnlFDet PIXEL //"Unid. Medida:"
  @ 018,55 MSGET oUnMed VAR cUnMed Font oFontN WHEN .F. SIZE 150,10 OF oPnlFDet PIXEL

  @ 020,210 SAY STR0013 SIZE 45, 30 Font oFontN OF oPnlFDet PIXEL //"Data Entrega:"
  @ 018,260 MSGET oDtEnt VAR dDtEnt Font oFontN Picture '99/99/9999' WHEN .F. SIZE 150,10 OF oPnlFDet PIXEL

  @ 035,08 SAY STR0014 SIZE 45, 30 Font oFontN OF oPnlFDet PIXEL //"Quantidade:"
  @ 033,55 MSGET oQtde VAR cQtde Font oFontN WHEN .F. SIZE 150,10 OF oPnlFDet PIXEL

  @ 035,210 SAY STR0015 SIZE 45, 30 Font oFontN OF oPnlFDet PIXEL //"Qtd. Produzida:"
  @ 033,260 MSGET oQtdePrd VAR cQtdePrd Font oFontN WHEN .F. SIZE 150,10 OF oPnlFDet PIXEL

  oPnlFCom := oTFolder:aDialogs[2]

  AADD(aCompon,{"","",Nil})
  @ 01,01 LISTBOX oLbx FIELDS HEADER STR0016, STR0017, STR0018 SIZE 230,95 OF oPnlFCom PIXEL //"Código","Descrição","Quantidade"
  oLbx:Align := CONTROL_ALIGN_ALLCLIENT
  oLbx:SetArray( aCompon )
  oLbx:bLine     := {|| {aCompon[oLbx:nAt,1], aCompon[oLbx:nAt,2],aCompon[oLbx:nAt,3]}}

  ACTIVATE MSDIALOG oDlg1

Return Nil

Static Function CriaTree()

  oPanelTree := oLayer:getWinPanel("ColunaDados",'C1_Win01')

  oTree := DbTree():New( 0, 0, nLargura/2, nHeight, oPanelTree , , , .T. )

  oTree:Align    := CONTROL_ALIGN_ALLCLIENT
  oTree:bChange := {|| ChangeTree()}

Return Nil

Static Function ChangeTree()
  Local cChave  := ""
  Local cTamOrd := TamSX3("H6_OP")[1]
  Local nTamOper:= TamSx3('C2_OPERAC')[1]
  Local lOperacao := .F.
  Local cOperac := ""

  LimpaGets()

  cChave := oTree:GetCargo()
  If Padr(cChave,3) == "OPE" .And. Len(AllTrim(SubStr( cChave, 4))) > cTamOrd
     cOperac := AllTrim(cChave)
     cOperac := SubStr(cOperac, len(cOperac)-(nTamOper - 1) , nTamOper)
     lOperacao := .T.
  EndIf
  cChave := AllTrim(substr( cChave, 4, cTamOrd))

  SC2->(dbSetOrder(1))
  If SC2->(dbSeek(xFilial("SC2")+cChave))
     cNumOp   := AllTrim(SC2->C2_NUM) + AllTrim(SC2->C2_ITEM) + AllTrim(SC2->C2_SEQUEN)
     oNumOp:CtrlRefresh()
     cProduto := AllTrim(SC2->C2_PRODUTO)
     SB1->(dbSetOrder(1))
     If SB1->(dbSeek(xFilial('SB1')+SC2->C2_PRODUTO))
        cProduto := cProduto + ' - ' + SB1->B1_DESC     
     EndIf
     oProduto:CtrlRefresh()
     cQtde    := SC2->C2_QUANT
     oQtde:CtrlRefresh()
     cQtdePrd := SC2->C2_QUJE
     oQtdePrd:CtrlRefresh()
     cUnMed   := AllTrim(SC2->C2_UM)
     oUnMed:CtrlRefresh()
     dDtEnt   := DtoC(SC2->C2_DATPRF)
     oDtEnt:CtrlRefresh()
  EndIf

  LoadCompon(cOperac,lOperacao)    

Return Nil

Static Function APontaProd()
  Local lIntSFC := FindFunction('ExisteSFC') .And. ExisteSFC("SC2")
  Local lRet    := .F.

  If lIntSFC
     lRet := APOSFCA316()
  EndIf

  If lRet
  LoadTree()
  EndIf

Return Nil

Static Function APOSFCA316()
  Local cTamOrd := TamSX3("H6_OP")[1]
  Local cTamOpe := TamSX3("H6_OPERAC")[1]
  Local cTamSpl := TamSX3("CYY_IDATQO")[1]
  Local cChave  := oTree:GetCargo()
  Local cOrdPrd := AllTrim(SubStr( cChave, 4, cTamOrd))
  Local cOpeOrd := AllTrim(SubStr( cChave, (4+cTamOrd), cTamOpe))
  Local cSplOrd := AllTrim(SubStr( cChave, (4+cTamOrd+cTamOpe), cTamSpl))
  Local oModel  := FWLoadModel( "SFCA316" ) //Carrega o modelo do programa
  Local nValue  := 0
  
  oModel:SetOperation( MODEL_OPERATION_INSERT ) //Operação de inclusão de apontamento
      
  If !oModel:Activate() //Ativa o modelo.
     Help( ,, 'Help',, oModel:GetErrorMessage()[6], 1, 0 ) //Se der erro na ativação, retorna msg.
     Return .F.
  EndIf

  If !oModel:SetValue("CYVMASTER","CYV_NRORPO",cOrdPrd) //Seta valor da OP
     Help( ,, 'Help',, SFCXMKERR(oModel)[2], 1, 0 ) //Se der erro de validação, exibe msg e retorna
     Return .F.
  EndIf
  
  If !oModel:SetValue("CYVMASTER","CYV_CDAT",cOpeOrd) // Seta valor da operação
     Help( ,, 'Help',, SFCXMKERR(oModel)[2], 1, 0 ) //Se der erro de validação, exibe msg e retorna
     Return .F.
  EndIf

  If !oModel:SetValue("CYVMASTER","CYV_IDATQO",cSplOrd) // Seta valor do split
     Help( ,, 'Help',, SFCXMKERR(oModel)[2], 1, 0 ) //Se der erro de validação, exibe msg e retorna
     Return .F.
  EndIf
      
  //Executa o programa de apontamento, passando o oModel com os valores a ser utilizado.
  nValue := FWExecView(,'SFCA316', MODEL_OPERATION_INSERT, , { || .T. }, , ,,,,,oModel )
Return Iif(nValue==0,.T.,.F.)

Static Function AbreDlgLeg()
  Local oDlgLeg

  DEFINE MSDIALOG oDlgLeg FROM  65,65 TO 280,400 TITLE  STR0023 PIXEL //"Legendas - Controle Apontamento de Produção"
  @ 05 , 5 BITMAP NAME "FOLDER7"     SIZE 12,11 of OdlgLeg PIXEL
  @ 20 , 5 BITMAP NAME "FOLDER10"    SIZE 12,11 of OdlgLeg PIXEL
  @ 35 , 5 BITMAP NAME "FOLDER12"    SIZE 12,11 of OdlgLeg PIXEL
  @ 50 , 5 BITMAP NAME "BR_VERMELHO" SIZE 8,8 of OdlgLeg PIXEL
  @ 65 , 5 BITMAP NAME "BR_VERDE"    SIZE 8,8 of OdlgLeg PIXEL
  @ 80 , 5 BITMAP NAME "BR_AZUL"     SIZE 8,8 of OdlgLeg PIXEL
  @ 05 , 19 SAY  STR0024 SIZE 115, 7 OF OdlgLeg PIXEL //"Ordem Não Liberada para Apontamento"
  @ 20 , 19 SAY  STR0025 SIZE 115, 7 OF OdlgLeg PIXEL //"Ordem Liberada para Apontamento"
  @ 35 , 19 SAY  STR0007 SIZE 115, 7 OF OdlgLeg PIXEL //"Ordem com Apontamento"
  @ 50 , 19 SAY  STR0026 SIZE 115, 7 OF OdlgLeg PIXEL //"Operação Não Liberada para Apontamento"
  @ 65 , 19 SAY  STR0027 SIZE 115, 7 OF OdlgLeg PIXEL //"Operação Liberada para Apontamento"
  @ 80 , 19 SAY  STR0009 SIZE 115, 7 OF OdlgLeg PIXEL //"Operação com Apontamento"
  DEFINE SBUTTON FROM 90, 135 TYPE 1 ENABLE ACTION (OdlgLeg:End()) OF OdlgLeg
  ACTIVATE MSDIALOG OdlgLeg CENTERED

Return Nil

Static Function LoadTree()
  Local cChave     := ""
  Local cDescOrd   := ""
  Local cTamOrd    := TamSX3("H6_OP")[1]
  Local cTamProd   := TamSX3("C2_PRODUTO")[1]
  Local cFolderA   := ""
  Local cFolderB   := ""
  Local nStatus    := 1 // 1- não disponível, 2 - disponível, 3 - apontada

  If Empty(cOpPesq)
     Help( ,, 'Help',, STR0022, 1, 0 ) //"Favor Informar uma Ordem para Pesquisa!"
     LimpaDados()
     Return Nil
  Endif

  LimpaGets()

  oTree:BeginUpdate()
  oTree:Reset()

  SC2->(dbSetOrder(1))
  If SC2->(dbSeek(xFilial("SC2")+AllTrim(cOpPesq)))
     cChave   := "ORD" + PADR(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),cTamOrd)
     cDescOrd := SC2->C2_NUM + ' - ' + SC2->C2_ITEM + ' - ' + SC2->C2_SEQUEN + ' - ' + PADR(AllTrim(SC2->C2_PRODUTO), cTamProd) + Space(90)
     
     If !ValProdOrd(SC2->C2_NUM, SC2->C2_ITEM, SC2->C2_SEQUEN)
        cFolderA := "FOLDER7"
        cFolderB := "FOLDER8"
        nStatus  := 1
     Else
        If !Empty(SC2->C2_DATRF) .OR. SC2->C2_QUJE > 0
           cFolderA := "FOLDER12"
           cFolderB := "FOLDER13"
           nStatus  := 3
        Else
           cFolderA := "FOLDER10"
           cFolderB := "FOLDER11"
           nStatus  := 2        
        EndIf           
     EndIf
        
     oTree:AddTree(cDescOrd,.T.,cFolderA,cFolderB,,,(cChave+Space(10)))

     LoadTreeOp(SC2->C2_ROTEIRO, SC2->C2_PRODUTO, cChave, nStatus)

     LoadTreeRE(SC2->C2_NUM,SC2->C2_ITEM,SC2->C2_SEQUEN, cChave)
  EndIf

  oTree:EndUpdate()
  oTree:PTRefresh()

  If oTree:TreeSeek(cChave)
     oTree:EndTree()
     ChangeTree()
  Else
     Help( ,, 'Help',, STR0006 + ' ' + cOpPesq + ' ' + STR0021 + '.', 1, 0 ) //"Ordem","Não Encontrada"
     LimpaDados()
  EndIf

Return .T.

Static Function LoadTreeRE(cOrdPrd,cItem,cSequen,cChavePai)
  Local cQuery     := ""
  Local cChave     := ""
  Local cAliasOrd  := GetNextAlias()
  Local cDescOrd   := ""
  Local cTamOrd    := TamSX3("H6_OP")[1]
  Local cTamProd   := TamSX3("C2_PRODUTO")[1]
  Local cFolderA   := ""
  Local cFolderB   := ""
  Local nStatus    := 1
  Default lAutoMacao := .F.

  cQuery += "SELECT "
  cQuery += "  SC2.C2_NUM ORDEM, "
  cQuery += "  SC2.C2_ITEM ITEM, "
  cQuery += "  SC2.C2_SEQUEN SEQUEN, "
  cQuery += "  SC2.C2_SEQPAI SEQPAI, "
  cQuery += "  SC2.C2_PRODUTO PRODUTO, "
  cQuery += "  SC2.C2_ROTEIRO ROTEIRO, "
  cQuery += "  SC2.C2_QUJE QTDPROD, "
  cQuery += "  SC2.C2_DATRF DATFIM "  
  cQuery += "FROM " + RetSQLName( 'SC2' ) + " SC2 "
  cQuery += "WHERE SC2.D_E_L_E_T_ = ' ' "
  cQuery += "  AND SC2.C2_FILIAL  = '"+xFilial("SC2")+"'"
  cQuery += "  AND SC2.C2_NUM     = '"+cOrdPrd+"' "
  cQuery += "  AND SC2.C2_ITEM    = '"+cItem+"' "
  cQuery += "  AND SC2.C2_SEQPAI  = '"+cSequen+"' "
  cQuery += "  ORDER BY SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasOrd, .T., .F. )

  (cAliasOrd)->(dbGotop())
  While !(cAliasOrd)->(Eof())
     cChave   := "ORD" + PADR((cAliasOrd)->(ORDEM+ITEM+SEQUEN),cTamOrd)
     cDescOrd := (cAliasOrd)->ORDEM + ' - ' + (cAliasOrd)->ITEM + ' - ' + (cAliasOrd)->SEQUEN + ' - ' + PADR(AllTrim((cAliasOrd)->PRODUTO), cTamProd)

     If !ValProdOrd((cAliasOrd)->ORDEM, (cAliasOrd)->ITEM, (cAliasOrd)->SEQUEN)
        cFolderA := "FOLDER7"
        cFolderB := "FOLDER8"
        nStatus  := 1
     Else
        If !Empty((cAliasOrd)->DATFIM) .OR. (cAliasOrd)->QTDPROD > 0
           cFolderA := "FOLDER12"
           cFolderB := "FOLDER13"
           nStatus  := 3
        Else
           cFolderA := "FOLDER10"
           cFolderB := "FOLDER11"
           nStatus  := 2        
        EndIf           
     EndIf

      IF !lAutoMacao
         If oTree:TreeSeek(cChavePai)
            oTree:AddItem(cDescOrd, cChave, cFolderA,cFolderB,,, 2)
         EndIf

         LoadTreeOp((cAliasOrd)->ROTEIRO, (cAliasOrd)->PRODUTO, cChave, nStatus)

         LoadTreeRE((cAliasOrd)->ORDEM,(cAliasOrd)->ITEM,(cAliasOrd)->SEQUEN,cChave)
      ENDIF

     (cAliasOrd)->(dbSkip())
  End
  (cAliasOrd)->(dbCloseArea())

Return Nil


Static Function LoadCompon(cOperac,lOperacao)
  Local cTamOrd   := TamSX3("H6_OP")[1]
  Local cChave    := ""
  Local cQuery    := ""
  Local cAliasSD4 := GetNextAlias()
  Default lAutoMacao := .F.

  aCompon   := {}

  IF !lAutoMacao
     cChave := oTree:GetCargo()
  ENDIF
  cChave := AllTrim(SubStr( cChave, 4, cTamOrd))

  cQuery := " SELECT SD4.D4_COD CODIGO, "
  cQuery += "        SB1.B1_DESC DESCRI, "
  cQuery += "        SD4.D4_QTDEORI QTDE "
  cQuery += "   FROM " + RetSqlName("SD4") + " SD4, "
  cQuery +=              RetSqlName("SB1") + " SB1 "
  cQuery += "  WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
  cQuery += "    AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
  cQuery += "    AND SD4.D_E_L_E_T_ = ' ' "
  cQuery += "    AND SB1.D_E_L_E_T_ = ' ' "
  cQuery += "    AND SD4.D4_COD     = SB1.B1_COD "
  If lOperacao
    cQuery += "    AND SD4.D4_OPERAC     = '" + cOperac + "' "
  EndIf
  cQuery += "    AND SD4.D4_OP      = '" + cChave + "' "
  cQuery += "  ORDER BY 1 "

  cQuery := ChangeQuery(cQuery)

  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasSD4, .T., .F. )

  While (cAliasSD4)->(!Eof())
     aAdd(aCompon,{(cAliasSD4)->CODIGO, (cAliasSD4)->DESCRI, (cAliasSD4)->QTDE})
     (cAliasSD4)->(dbSkip())
  End
  (cAliasSD4)->(dbCloseArea())
   IF !lAutoMacao
      If Len(aCompon) >= 1
         oLbx:SetArray( aCompon )
         oLbx:bLine := {|| {aCompon[oLbx:nAt,1], aCompon[oLbx:nAt,2],aCompon[oLbx:nAt,3]}}
         oLbx:Refresh()
      Else
         AADD(aCompon,{"","",Nil})
         oLbx:SetArray( aCompon )
         oLbx:bLine := {|| {aCompon[oLbx:nAt,1], aCompon[oLbx:nAt,2],aCompon[oLbx:nAt,3]}}
         oLbx:Refresh()
      EndIf
   ENDIF

Return Nil

Static Function LimpaGets()

  cNumOp := ""
  oNumOp:CtrlRefresh()
  
  cProduto := ""
  oProduto:CtrlRefresh()

  cQtde := ""
  oQtde:CtrlRefresh()

  cQtdePrd := ""
  oQtdePrd:CtrlRefresh()
  
  cUnMed := ""
  oUnMed:CtrlRefresh()

  dDtEnt := ""
  oDtEnt:CtrlRefresh()

Return Nil

Static Function LimpaDados()

  oTree:Reset()
  LimpaGets()
  aCompon := {}
  AADD(aCompon,{"","",Nil})
  oLbx:SetArray( aCompon )
  oLbx:bLine := {|| {aCompon[oLbx:nAt,1], aCompon[oLbx:nAt,2],aCompon[oLbx:nAt,3]}}
  oLbx:Refresh() 

Return Nil

Static Function ValProdOrd(cOrdPrd, cItem, cSequen)
  Local cQuery    := ""
  Local cAliasOrd := GetNextAlias()
  Local lRet      := .T.

  cQuery += "SELECT "
  cQuery += "  SC2.C2_NUM ORDEM, "
  cQuery += "  SC2.C2_ITEM ITEM, "
  cQuery += "  SC2.C2_SEQUEN SEQUEN, "
  cQuery += "  SC2.C2_SEQPAI SEQPAI, "
  cQuery += "  SC2.C2_QUJE QTDPROD, "
  cQuery += "  SC2.C2_DATRF DATFIM "  
  cQuery += "FROM " + RetSQLName( 'SC2' ) + " SC2 "
  cQuery += "WHERE SC2.D_E_L_E_T_ = ' ' "
  cQuery += "  AND SC2.C2_FILIAL  = '"+xFilial("SC2")+"'"
  cQuery += "  AND SC2.C2_NUM     = '"+cOrdPrd+"' "
  cQuery += "  AND SC2.C2_ITEM    = '"+cItem+"' "
  cQuery += "  AND SC2.C2_SEQPAI  = '"+cSequen+"' "
  cQuery += "  ORDER BY SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasOrd, .T., .F. )

  (cAliasOrd)->(dbGotop())
  While !(cAliasOrd)->(Eof())
     If (cAliasOrd)->QTDPROD = 0
        lRet := .F.
        Exit
     EndIf
     (cAliasOrd)->(dbSkip())
  End
  (cAliasOrd)->(dbCloseArea())

Return lRet

Static Function ValOperSFC(cOrdPrd, cOpSFC, cSplit, lSplitIni)
  Local cQuery    := ""
  Local cAliasQry := GetNextAlias()
  Local nProd     := 0
  
  cQuery := "SELECT "
  cQuery += "  CYV.CYV_QTATAP QTDPROD, "
  cQuery += "  CYV.CYV_LGRPEO REPEST, "
  cQuery += "  CYV.CYV_TPSTRP REPINI "
  cQuery += "FROM " + RetSQLName( 'CYV' ) + " CYV "
  cQuery += "  INNER JOIN " + RetSQLName( 'CY9' ) + " CY9 "
  cQuery += "    ON CY9.CY9_FILIAL = '"+xFilial("CY9")+"' AND CY9.CY9_NRORPO = CYV.CYV_NRORPO AND CY9.CY9_IDAT = CYV.CYV_IDAT AND CY9.D_E_L_E_T_ = ' ' "
  cQuery += "WHERE CYV.CYV_FILIAL = '"+xFilial("CYV")+"' "
  cQuery += "  AND CYV.CYV_NRORPO = '" + cOrdPrd + "' "
  cQuery += "  AND CYV.CYV_IDAT   = '" + cOpSFC + "' "
  cQuery += "  AND CYV.CYV_IDATQO = '" + cSplit + "' "
  cQuery += "  AND CYV.D_E_L_E_T_ = ' ' "
  cQuery += "ORDER BY CYV.CYV_DTRPBG,CYV.CYV_HRRPBG "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )

  (cAliasQry)->(dbGotop())
  While !(cAliasQry)->(Eof())
     If (cAliasQry)->REPEST = "F" .AND. (cAliasQry)->QTDPROD > 0
        nProd := nProd + (cAliasQry)->QTDPROD
     EndIf

     If (cAliasQry)->REPEST = "F" .AND. (cAliasQry)->REPINI = "1"
        lSplitIni := .T.
     EndIf

     (cAliasQry)->(dbSkip())
  End
  (cAliasQry)->(dbCloseArea())

Return nProd

Static Function ValOper(cOrdPrd, cOperac, cAponTot, cDesdobr)
  Local cQuery    := ""
  Local cAliasQry := GetNextAlias()
  Local nProd     := 0

  cQuery += "SELECT "
  cQuery += "  SH6.H6_QTDPROD QTDPROD, "
  cQuery += "  SH6.H6_PT APONTOT "
  cQuery += "FROM " + RetSQLName( 'SH6' ) + " SH6 "
  cQuery += "WHERE SH6.D_E_L_E_T_ = ' ' "
  cQuery += "  AND SH6.H6_FILIAL  = '"+xFilial("SH6")+"'"
  cQuery += "  AND SH6.H6_OP      = '"+cOrdPrd+"' "
  cQuery += "  AND SH6.H6_OPERAC  = '"+cOperac+"' "
  If !Empty(cDesdobr)
     cQuery += "  AND SH6.H6_DESDOBR  = '"+cDesdobr+"' "
  EndIf
  cQuery += "  ORDER BY SH6.H6_DATAINI,H6_HORAINI "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )

  (cAliasQry)->(dbGotop())
  While !(cAliasQry)->(Eof())
     nProd := nProd + (cAliasQry)->QTDPROD
     If (cAliasQry)->APONTOT = "T"
        cAponTot := .T.
     EndIf
     (cAliasQry)->(dbSkip())
  End
  (cAliasQry)->(dbCloseArea())  

Return nProd

Static Function LoadTreeOp(cRoteiro, cProduto, cChave, nStatus)
  Local lIntSFC   := FindFunction('ExisteSFC') .And. ExisteSFC("SC2")

  If Empty(cRoteiro)
     cRoteiro := "01"
  EndIf

  If lIntSFC
     LoadCYY(cChave, nStatus)
  Else     
     If !LoadSH8(cProduto, cChave, nStatus)
        LoadSHYSG2(cRoteiro, cProduto, cChave, nStatus)
     EndIf        
  EndIf

Return Nil

Static Function LoadSHYSG2(cRoteiro, cProduto, cChave, nStatus)
  Local cAliasSG2 := GetNextAlias()
  Local cAliasSHY := GetNextAlias()
  Local cQuerySG2 := ""
  Local cQuerySHY := ""
  Local cDescOpe  := ""
  Local nCont     := 0
  Local cOrdPrd   := AllTrim(SubStr(cChave,4,len(cChave)-3))
  Local lAponTot  := .F.
  Local nRet      := 0
  Local nAponProd := 0

  cQuerySHY := "SELECT "
  cQuerySHY += "  SHY.HY_OPERAC CODIGO, "
  cQuerySHY += "  SHY.HY_DESCRI DESCR "
  cQuerySHY += "FROM " + RetSQLName( 'SHY' ) + " SHY "
  cQuerySHY += "WHERE SHY.D_E_L_E_T_ = ' ' "
  cQuerySHY += "  AND SHY.HY_FILIAL  = '"+xFilial("SHY")+"' "
  cQuerySHY += "  AND SHY.HY_OP      = '" + cOrdPrd + "' "
  cQuerySHY += "  AND SHY.HY_ROTEIRO = '" + cRoteiro + "' "
  cQuerySHY += "  ORDER BY SHY.HY_OPERAC "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuerySHY), cAliasSHY, .T., .F. )

  (cAliasSHY)->(dbGotop())
  While !(cAliasSHY)->(Eof())
     cChaveOpe2 := "OPE" + SubStr(cChave,4,len(cChave)-3) + AllTrim((cAliasSHY)->CODIGO)
     cDescOpe   := AllTrim((cAliasSHY)->CODIGO) + ' - ' + AllTrim((cAliasSHY)->DESCR)
     If nCont = 0
        If oTree:TreeSeek(cChave)
           cChaveOpe1 := "OPE" + SubStr(cChave,4,len(cChave)-3)
           oTree:AddItem(STR0019, cChaveOpe1, 'ENGRENAGEM', 'ENGRENAGEM',,, 2) //"Operações"
        EndIf
     EndIf
     If oTree:TreeSeek(cChaveOpe1)
        lAponTot := .F.
        nRet     := ValOper(cOrdPrd, AllTrim((cAliasSHY)->CODIGO), @lAponTot)
        cDescOpe := cDescOpe + " / " + STR0015 + CVALTOCHAR(nRet) //"Qtd. Produzida:"
        If nStatus = 1
           oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
        Else
           If nCont = 0
              If nRet > 0
                 If lAponTot
                    cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                 EndIF
                 oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
              Else
                 oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
              EndIF
           Else              
              If nAponProd > 0
                 If nRet > 0
                    If lAponTot
                       cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                    EndIF
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                 EndIF
              Else
                 If nRet > 0
                    If lAponTot
                       cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                    EndIF                 
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
                 EndIF
              EndIf
           EndIf
        EndIf           
     EndIf     
     nAponProd := nRet
     nCont := nCont + 1
     (cAliasSHY)->(dbSkip())
  End
  (cAliasSHY)->(dbCloseArea())

  If nCont = 0
     cQuerySG2 := "SELECT "
     cQuerySG2 += "  SG2.G2_OPERAC CODIGO, "
     cQuerySG2 += "  SG2.G2_DESCRI DESCR "
     cQuerySG2 += "FROM " + RetSQLName( 'SG2' ) + " SG2 "
     cQuerySG2 += "WHERE SG2.D_E_L_E_T_ = ' ' "
     cQuerySG2 += "  AND SG2.G2_FILIAL  = '"+xFilial("SG2")+"'"
     cQuerySG2 += "  AND SG2.G2_CODIGO  = '"+cRoteiro+"'"
     cQuerySG2 += "  AND SG2.G2_PRODUTO = '"+cProduto+"'"
     cQuerySG2 += "  ORDER BY SG2.G2_OPERAC "
     dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuerySG2), cAliasSG2, .T., .F. )

     (cAliasSG2)->(dbGotop())
     While !(cAliasSG2)->(Eof())
        cChaveOpe2 := "OPE" + SubStr(cChave,4,len(cChave)-3) + AllTrim((cAliasSG2)->CODIGO)
        cDescOpe  := AllTrim((cAliasSG2)->CODIGO) + ' - ' + AllTrim((cAliasSG2)->DESCR)
        If nCont = 0
           If oTree:TreeSeek(cChave)
              cChaveOpe1 := "OPE" + SubStr(cChave,4,len(cChave)-3)
              oTree:AddItem(STR0019, cChaveOpe1, 'ENGRENAGEM', 'ENGRENAGEM',,, 2) //"Operações"
           EndIf
        EndIf
        If oTree:TreeSeek(cChaveOpe1)
           lAponTot := .F.
           nRet     := ValOper(cOrdPrd, AllTrim((cAliasSG2)->CODIGO), @lAponTot)
           cDescOpe := cDescOpe + " / " + STR0015 + CVALTOCHAR(nRet) //"Qtd. Produzida:"
           If nStatus = 1
              oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
           Else
              If nCont = 0
                 If nRet > 0
                    If lAponTot
                       cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                    EndIF
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                 EndIF
              Else              
                 If nAponProd > 0
                    If nRet > 0
                       If lAponTot
                          cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                       EndIF
                       oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                    Else
                       oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                    EndIF
                 Else
                    If nRet > 0
                       If lAponTot
                          cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                       EndIF                 
                       oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                    Else
                       oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
                    EndIF
                 EndIf
              EndIf                               
           EndIf  
        EndIf
        nAponProd := nRet
        nCont := nCont + 1
        (cAliasSG2)->(dbSkip())
     End
     (cAliasSG2)->(dbCloseArea())  
  EndIf

Return Nil

Static Function LoadSH8(cProduto, cChave, nStatus)
  Local cAliasSH8 := GetNextAlias()
  Local cQuerySH8 := ""
  Local cDescOpe  := ""
  Local nCont     := 0
  Local cOrdPrd   := AllTrim(SubStr(cChave,4,len(cChave)-3))
  Local lRet      := .F.
  Local nRet      := 0
  Local nAponProd := 0
  Local lAponTot  := .F.
  Local cOperac   := ""
  Local lLiberado := .F.

  cQuerySh8 := "SELECT "
  cQuerySh8 += "  SH8.H8_OPER CODIGO, "
  cQuerySh8 += "  SG2.G2_DESCRI DESCR, "
  cQuerySh8 += "  SH8.H8_RECURSO RECURSO, "
  cQuerySh8 += "  SH8.H8_DESDOBR DESDOBR " 
  cQuerySh8 += "FROM " + RetSQLName( 'SH8' ) + " SH8 "
  cQuerySh8 += "  INNER JOIN " + RetSQLName( 'SG2' ) + " SG2 ON SG2.G2_FILIAL = '"+xFilial("SG2")+"' AND SG2.G2_PRODUTO = '" + cProduto + "' AND SG2.G2_CODIGO = SH8.H8_ROTEIRO AND SG2.G2_OPERAC = SH8.H8_OPER AND SG2.D_E_L_E_T_ = ' ' "
  cQuerySh8 += "WHERE SH8.D_E_L_E_T_ = ' ' "
  cQuerySh8 += "  AND SH8.H8_FILIAL = '"+xFilial("SH8")+"' "
  cQuerySh8 += "  AND SH8.H8_OP     = '" + cOrdPrd + "' "
  cQuerySh8 += "ORDER BY SH8.H8_OPER, SH8.H8_DESDOBR "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuerySH8), cAliasSH8, .T., .F. )

  (cAliasSH8)->(dbGotop())
  While !(cAliasSH8)->(Eof())
     cChaveOpe2 := "OPE" + substr(cChave, 4, len(cChave)-3) + AllTrim((cAliasSH8)->CODIGO) + (cAliasSH8)->DESDOBR
     cDescOpe   := AllTrim((cAliasSH8)->CODIGO) + ' - ' + AllTrim((cAliasSH8)->DESCR) + " / " + STR0031 + " " + AllTrim((cAliasSH8)->RECURSO) + " / " + STR0032 + " " + (cAliasSH8)->DESDOBR //"Recurso:","Desdobr.:"
     If nCont = 0
        lRet := .T.
        If oTree:TreeSeek(cChave)
           cChaveOpe1 := "OPE" + substr( cChave, 4, len(cChave)-4 )
           oTree:AddItem(STR0019, cChaveOpe1, 'ENGRENAGEM', 'ENGRENAGEM',,, 2) //"Operações"
        EndIf
     EndIf
     If oTree:TreeSeek(cChaveOpe1)
        lAponTot := .F.
        nRet     := ValOper(cOrdPrd, AllTrim((cAliasSH8)->CODIGO), @lAponTot, (cAliasSH8)->DESDOBR)
        cDescOpe := cDescOpe + " / " + STR0015 + CVALTOCHAR(nRet) //"Qtd. Produzida:"
        If cOperac != (cAliasSH8)->CODIGO
           cOperac    := (cAliasSH8)->CODIGO
           lLiberado := .F.
        EndIf                
        If nStatus = 1
           oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
        ElseIf nStatus = 3
           If lAponTot
              cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
           EndIF        
           oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
        Else
           If nCont = 0
              If nRet > 0
                 If lAponTot
                    cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                 EndIF
                 oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
              Else
                 oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
              EndIF
              lLiberado := .T.
           Else              
              If nAponProd > 0
                 If nRet > 0
                    If lAponTot
                       cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                    EndIF
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                 EndIF
                 lLiberado := .T.
              Else
                 If lLiberado
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
                 EndIf
              EndIf
           EndIf                               
        EndIf 
     EndIf
     nAponProd := nRet
     nCont  := nCont + 1
     (cAliasSH8)->(dbSkip())
  End
  (cAliasSH8)->(dbCloseArea())

Return lRet

Static Function LoadCYY(cChave, nStatus)
  Local cAliasCYY := GetNextAlias()
  Local cQueryCYY := ""
  Local cDescOpe  := ""
  Local nCont     := 0
  Local cOrdPrd   := AllTrim(SubStr(cChave,4,len(cChave)-3))
  Local cOpSFC    := ""
  Local lSplitIni := .F.
  Local lLiberado := .F.
  Local lApontI   := .F.
  Local lApontII  := .F.

  cQueryCYY := "SELECT "
  cQueryCYY += "  CY9.CY9_CDAT CODIGO, "
  cQueryCYY += "  CY9.CY9_DSAT DESCR, "
  cQueryCYY += "  CYY.CYY_IDAT OPSFC, "
  cQueryCYY += "  CYY.CYY_IDATQO SPLIT, "
  cQueryCYY += "  CYY.CYY_CDMQ MAQUINA, "
  cQueryCYY += "  CYY.CYY_TPSTAT STATUS "
  cQueryCYY += "FROM " + RetSQLName( 'CYY' ) + " CYY "
  cQueryCYY += "  INNER JOIN " + RetSQLName( 'CY9' ) + " CY9 "
  cQueryCYY += "    ON CY9.CY9_FILIAL = '"+xFilial("CY9")+"' AND CY9.CY9_NRORPO = CYY.CYY_NRORPO AND CY9.CY9_IDAT = CYY.CYY_IDAT AND CY9.D_E_L_E_T_ = ' ' "
  cQueryCYY += "WHERE CYY.CYY_FILIAL = '"+xFilial("CYY")+"' "
  cQueryCYY += "  AND CYY.CYY_NRORPO = '" + cOrdPrd + "' "
  cQueryCYY += "  AND CYY.D_E_L_E_T_ = ' ' "
  cQueryCYY += "ORDER BY  CYY.CYY_IDAT,CYY.CYY_IDATQO "
  dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQueryCYY), cAliasCYY, .T., .F. )

  (cAliasCYY)->(dbGotop())
  While !(cAliasCYY)->(Eof())
     cChaveOpe2 := "OPE" + substr(cChave, 4, len(cChave)-3) + AllTrim((cAliasCYY)->CODIGO) + (cAliasCYY)->SPLIT
     cDescOpe   := AllTrim((cAliasCYY)->CODIGO) + ' - ' + AllTrim((cAliasCYY)->DESCR) + " / " + STR0028 + " " + AllTrim((cAliasCYY)->MAQUINA) + " / " + STR0029 + " " + (cAliasCYY)->SPLIT //"Máquina:","Split:"
     If nCont = 0
        If oTree:TreeSeek(cChave)
           cChaveOpe1 := "OPE" + substr( cChave, 4, len(cChave)-4 )
           oTree:AddItem(STR0019, cChaveOpe1, 'ENGRENAGEM', 'ENGRENAGEM',,, 2) //"Operações"
        EndIf
     EndIf
     If oTree:TreeSeek(cChaveOpe1)
        lSplitIni := .F.
        nRet := ValOperSFC(cOrdPrd, (cAliasCYY)->OPSFC, (cAliasCYY)->SPLIT, @lSplitIni)
        cDescOpe := cDescOpe + " / " + STR0015 + CVALTOCHAR(nRet) //"Qtd. Produzida:"
        If cOpSFC != (cAliasCYY)->OPSFC
           cOpSFC    := (cAliasCYY)->OPSFC
           lLiberado := .F.
           lApontII  := lApontI
           lApontI   := .F.
        EndIf        
        If nStatus = 1
           oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
        Else
           If nCont = 0
              If lSplitIni
                 cDescOpe := cDescOpe + " / " + STR0030 //"Iniciado"
              EndIf           
              If nRet > 0
                 If (cAliasCYY)->STATUS = "5"
                    cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                 EndIF
                 oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                 lApontI := .T.
              Else
                 oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
              EndIF
              lLiberado := .T.
           Else              
              If nAponProd > 0
                 If lSplitIni
                    cDescOpe := cDescOpe + " / " + STR0030 //"Iniciado"
                 EndIf
                 If nRet > 0
                    If (cAliasCYY)->STATUS = "5"
                       cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                    EndIF
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                    lApontI := .T.
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                 EndIF
                 lLiberado := .T.
              Else
                 If nRet > 0
                    If (cAliasCYY)->STATUS = "5"
                       cDescOpe := cDescOpe + " / " + STR0033 //"Finalizado"
                    EndIF
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_AZUL',,,, 2)
                    lApontI := .T.
                 ElseIf lLiberado .OR. lApontII
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERDE',,,, 2)
                 Else
                    oTree:AddItem(cDescOpe, cChaveOpe2, 'BR_VERMELHO',,,, 2)
                 EndIf
              EndIf
           EndIf
        EndIf  
     EndIf
     nAponProd := nRet
     nCont     := nCont + 1
     (cAliasCYY)->(dbSkip())
  End
  (cAliasCYY)->(dbCloseArea())

Return Nil
