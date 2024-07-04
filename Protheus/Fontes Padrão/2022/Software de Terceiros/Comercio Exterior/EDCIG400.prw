#INCLUDE "EDCIG400.CH"
#INCLUDE "AVERAGE.CH"

#Define EXP              "E"
#Define IMP              "I"
#Define TAM_COL_PRODUTO  20

/*
Programa        : EDCIG400.PRW
Objetivo        : Manutenção de Itens Alternativos
Autor           : Gustavo Carreiro
Data/Hora       : 
Obs.            : 
*/


//***************************************************************************************************************//
//                                             REVISÃO                                                           //
//***************************************************************************************************************//
//Data            : 07/11/2006                                                                                   //
//Autor           : PLB - Pedro Baroni                                                                           //
//Objetivo        : Inclusão dos Campos 'Tipo do Item' e 'Pedido de Drawback', possibilitando que um item seja   //
//                  alternativo especificamente para um Pedido.                                                  //
//                  Inclusão de validação de Estrutura entre os Itens Alternativos e entre a necessidade gerada  //
//                  pela estrutura e a quantidade constante no Pedido mencionado.                                //
//***************************************************************************************************************//


//*************************************************************************************/
Function EDCIG400()
//*************************************************************************************/

 Private lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0
 Private cCadastro := STR0001,; //"Itens Alternativos"  // By JPP - 06/11/2007 - 14:00
         cFilED0 := xFilial("ED0") // By JPP - 06/11/2007 - 14:00 - Foi redefinida na função principal, pois também é utilizada na rotina cadastro de Itens Alternativos.
   If lTipoItem
      EDCIG400Cad()
   Else
      AxCadastro("ED7",STR0001) //"Itens Alternativos"
   EndIf

Return .T.


//*************************************************************************************/
Function EDCIG400Cad()
//*************************************************************************************/

 Private aRotina := MenuDef(ProcName())

    oMainWnd:ReadClientCoords()
    
    MBrowse(,,,,"ED7")
    
Return .T.                             

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Adriane Sayuri Kamiya
Data/Hora  : 23/01/07 - 14:58
*/
Static Function MenuDef(cOrigem)
Local aRotAdic := {}
Local aRotina
Default cOrigem  := AvMnuFnc()

cOrigem := Upper(AllTrim(cOrigem))
   
   Do Case
      Case cOrigem $ "EDCIG400CAD"
         aRotina :=  { {STR0002,"AxPesqui"  ,0,1},;  // "Pesquisar"
                       {STR0003,"IG400Manut",0,2},;  // "Visualizar"
                       {STR0004,"IG400Manut",0,3},;  // "Incluir"
                       {STR0005,"IG400Manut",0,4},;  // "Alterar"                    
                       {STR0006,"IG400Manut",0,5}}  // "Excluir"
                    
         // P.E. utilizado para adicionar itens no Menu da mBrowse
         If EasyEntryPoint("FAC120MNU")
            aRotAdic := ExecBlock("FAC120MNU",.f.,.f.)
            If ValType(aRotAdic) == "A"
               AEval(aRotAdic,{|x| AAdd(aRotina,x)})
            EndIf
         EndIf

      OtherWise
         aRotina := StaticCall(MATXATU,MENUDEF)
         
   End Case
Return aRotina

//****************************************//*******************************************/
Function IG400Manut(cAlias,nReg,nOpc)     //          Monta e exibe Capa (ED7)        */
//****************************************//*******************************************/
 Local   ni     := 1    ,;
         bOk            ,;
         bOkBar         ,;
         bCancel   
 Private oDlg              ,;
         aMostra := {}     ,;
         aGets[0]          ,;                   
         aTela[0][0]       ,;
         nVolta := 0       ,;
         aCampos := Array((cAlias)->( FCount() )) // ,;
         //cFilED0 := xFilial("ED0") // By JPP - 06/11/2007 - 14:00 - Foi redefinida na função principal, pois também é utilizada na rotina cadastro de Itens Alternativos.

   bOk     := {|| nVolta:=1, oDlg:End() }
   bOkBar  := {|| IIF(Obrigatorio(aGets,aTela) .And. IIF(nOpc==3 .Or. nOpc==4,IG400Valid("TUDO"),.T.),Eval(bOk),)}
   bCancel := {|| nVolta := 0, oDlg:End() }
    
   aMostra := { "ED7_TPITEM", "ED7_DE", "ED7_PARA", "ED7_DESCRI", "ED7_PD" }

   If  nOpc == 4  .Or.  nOpc == 5
      RecLock(cAlias,.F.)
   EndIf
   
   For ni := 1 to (cAlias)->(FCount())
      If nOpc == 3
         M->&((cAlias)->(FieldName(ni))):= CriaVar((cAlias)->(FieldName(ni)))
      Else
         M->&((cAlias)->(FieldName(ni))):= (cAlias)->(FieldGet(ni))
      Endif
   Next ni

   DEFINE MSDIALOG oDlg TITLE STR0001 FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL  // "Itens Alternativos"//oMainWnd:nTop + 130, oMainWnd:nLeft + 1 TO oMainWnd:nHeight-150, oMainWnd:nWidth-40 OF oMainWnd PIXEL  // "Itens Alternativos"
   
      oEnch:= MsMGet():New(cAlias,nReg,nOpc,,,,,PosDlg(oDlg),,,,,oDlg)
      oEnch:oBox:Align:= CONTROL_ALIGN_ALLCLIENT //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,bOkBar,bCancel,,)) //BCO 09/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   If  nOpc == 4  .Or.  nOpc == 5
      (cAlias)->( MSUnLock() )
   EndIf

   If nVolta == 1
      IG400Grava(cAlias,nOpc)
   EndIf                          

Return .T.

//**********************************//*************************************************/
Function IG400Valid(cOpcao)         //               Rotina de Validação              */
//**********************************//*************************************************/
// Alteração: Alessandro Jose Porta (02/09/2009)
// Objetivo : Possibilitar que os produtos possuam UM diferentes, desde exista uma relação entre elas.
//            Para isso foi criado o bUM, e o ponto de entrada para alterar a bUM
/* AJP 02/09/09
 Local aProdDe   := {}  ,;
       aProdPara := {}  ,;
       cFilSB1   := xFilial("SB1")
*/
 Local cFilSB1   := xFilial("SB1")       

 Private cOpcaoRdm := cOpcao

 Private lRet      := .T.,;        
         aProdDe   := {},; //AJP 02/09/09
         aProdPara := {},; //AJP 02/09/09
         bUM       := {||aProdDe[1] != aProdPara[1]}  //AJP 02/09/2009

   Begin Sequence
      
      //AJP 02/09/2009
      If EasyEntryPoint("EDCIG400")
         ExecBlock("EDCIG400",.F.,.F.,"INI_IG400VALID")
      Endif
      //FIM AJP 02/09/2009
   
      Do Case

         Case cOpcao == "ED7_DE"
            If !Empty(M->ED7_DE)
               If !Empty(M->ED7_PARA)
                  If M->ED7_DE == M->ED7_PARA
                     MsgStop(STR0015)  //"Os produtos não podem posuir o mesmo código."
                     lRet := .F.
                     Break
                  EndIf
                  If lTipoItem
                     If !Empty(M->ED7_PD)  .And.  !ExistChav("ED7",M->ED7_TPITEM+M->ED7_PARA+M->ED7_PD)
                        lRet := .F.
                        Break
                     EndIf
                  Else
                     If !ExistChav("ED7",M->ED7_PARA+M->ED7_DE)
                        lRet := .F.
                        Break
                     EndIf
                  EndIf
               EndIf
               If !ExistCpo("SB1",M->ED7_DE)
                  lRet := .F.
                  Break
               EndIf
            EndIf

         Case cOpcao == "ED7_PARA"
            If !Empty(M->ED7_PARA)
               If !Empty(M->ED7_DE)
                  If M->ED7_DE == M->ED7_PARA
                     MsgStop(STR0015)  //"Os produtos não podem posuir o mesmo código."
                     lRet := .F.
                     Break
                  EndIf
               EndIf
               If !ExistCpo("SB1",M->ED7_PARA)
                  lRet := .F.
                  Break
               EndIf
               If lTipoItem
                  If !Empty(M->ED7_PD)  .And.  !ExistChav("ED7",M->ED7_TPITEM+M->ED7_PARA+M->ED7_PD)
                     lRet := .F.
                     Break
                  EndIf
               Else
                  If !ExistChav("ED7",M->ED7_PARA)
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

         Case cOpcao == "ED7_PD"
            If !Empty(M->ED7_PD)
               If !ExistCpo("ED0",M->ED7_PD)
                  lRet := .F.
                  Break
               EndIf
               If M->ED7_TPITEM == EXP
                  ED0->( DBSetOrder(1) )
                  ED0->( DBSeek(cFilED0+M->ED7_PD) )
                  If ED0->ED0_MODAL != "1"  // Suspensão
                     MsgStop(STR0007)  //"Para produtos a exportar somente é permitido Pedido de Drawback da modalidade Suspensão."
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

         Case cOpcao == "TUDO"
            If !ExistChav("ED7",M->ED7_TPITEM+M->ED7_PARA+M->ED7_PD)
               lRet := .F.
               Break
            EndIf
            aOrd := SaveOrd({"ED7"})
            ED7->( DBSetOrder(2) )
            ED7->( DBSeek(cChave := xFilial("ED7")+M->ED7_TPITEM+M->ED7_PARA) )
            Do While ED7->( !EoF()  .And.  ED7_FILIAL+ED7_TPITEM+ED7_DE == cChave )
               If ED7->ED7_PARA == M->ED7_DE
                  MsgStop(STR0036+AllTrim(ED7->ED7_PARA)+STR0037+AllTrim(ED7->ED7_DE)+".")  //"Não é possível gravar os dados pois já existe relacionamento entre os itens, onde o item " ### " está cadastrado como Alternativo para o item " ###
                  RestOrd(aOrd,.T.)
                  lRet := .F.
                  Break
               EndIf
               ED7->( DBSkip() )
            EndDo
            RestOrd(aOrd,.T.)
            SB1->( DBSetOrder(1) )
            If SB1->( DBSeek(cFilSB1+M->ED7_DE) )
               aProdDe   := {SB1->B1_UM, SB1->B1_POSIPI}
            EndIf
            If SB1->( DBSeek(cFilSB1+M->ED7_PARA) )
               aProdPara := {SB1->B1_UM, SB1->B1_POSIPI}
            EndIf
            If Len(aProdDe) == Len(aProdPara)
               If M->ED7_TPITEM == EXP               
                  If Eval(bUm)
//                  If aProdDe[1] != aProdPara[1] //AJP 02/09/2009
                     MsgInfo(STR0009+AllTrim(M->ED7_DE)+" ("+aProdDe[1]+")"+STR0010+AllTrim(M->ED7_PARA)+" ("+aProdPara[1]+").")  //"O produto " ### " precisa possuir a mesma Unidade de Medida do produto " ###
                     lRet := .F.
                  Break
                  ElseIf aProdDe[2] != aProdPara[2]
                     MsgInfo(STR0009+AllTrim(M->ED7_DE)+" ("+Transform(aProdDe[2],AVSX3("B1_POSIPI",AV_PICTURE))+")"+STR0011+AllTrim(M->ED7_PARA)+" ("+Transform(aProdPara[2],AVSX3("B1_POSIPI",AV_PICTURE))+").")  //"O produto " ### " precisa possuir a mesma N.C.M. do produto " ###
                     lRet := .F.
                  Break
                  EndIf
               EndIf
            EndIf
            If M->ED7_TPITEM == EXP
               If !Empty(M->ED7_PD)  .And.  ED0->( DBSetOrder(1), DBSeek(cFilED0+M->ED7_PD) .And. ED0_MODAL != "1" )  // Suspensão
                  MsgStop(STR0007)  //"Para produtos a exportar somente é permitido Pedido de Drawback da modalidade Suspensão."
                  lRet := .F.
                  Break
               EndIf
               If Empty(M->ED7_PD)
                  Processa({|| ( lRet:=AvCompEstr(M->ED7_DE,M->ED7_PARA,"",.T.,.T.,"CADASTRO") ) },STR0008)  //"Comparando Estruturas..."
               Else
                  Processa({|| ( lRet:=AvCompEstr(M->ED7_DE,M->ED7_PARA,M->ED7_PD,.F.,.T.,"CADASTRO") ) },STR0008)  //"Comparando Estruturas..."
               EndIf
               If !lRet
                  Break
               EndIf

            EndIf

      EndCase
   
   End Sequence

   If EasyEntryPoint("EDCIG400")
      ExecBlock("EDCIG400",.F.,.F.,"VALIDA_ESTRU")
   Endif

Return lRet


//**********************************//*************************************************/
Function IG400Grava(cAlias,nOpc)    //       Gravaçao ou Exclusao dos registros       */
//**********************************//*************************************************/

 Local lTip := .T.  ,;
       ni   := 1

   If nOpc == 3
      lTip := .T.
   Else
      lTip := .F.
   EndIf

   Begin TransAction
      If nOpc == 3  .Or.  nOpc == 4
         RecLock(cAlias,lTip)
         For ni := 1 to (cAlias)->(FCount())
            (cAlias)->&( FieldName(ni) ) := M->&((cAlias)->( FieldName(ni) ))
         Next ni
         (cAlias)->&(cAlias+"_FILIAL") := xFilial("ED7")
         (cAlias)->(MSUnlock())

      ElseIf nOpc == 5

         (cAlias)->( RecLock(cAlias,lTip), DBDelete(), MSUnlock() )  

      EndIf
   End TransAction

Return .T.
          
//*****************************************************************************************************************/
// Compara Estrutura entre Produtos e entre Pedido e Produtos                                                     //
//*****************************************************************************************************************/
Function AvCompEstr(cProdPri,cProdAlt,cPedido,lBlock,lShowMsg,cChamada,lNeces)
//*****************************************************************************************************************/

 Local aOrd      := {}              ,;
       aRec      := {}              ,;
       aMsg      := {}              ,;
       aDifEstru := {}              ,;
       aEstPed   := {}              ,;  // Estrutura do Produto no Pedido
       aEstPri   := {}              ,;  // Estrutura do Produto Principal (está no pedido) De
       aPriAux   := {}              ,;
       aEstAlt   := {}              ,;  // Estrutura do Produto Alternativo (está no RE)   Para
       aAltAux   := {}              ,;
       aItemUMDif:= {}              ,;  // array contendo diferença de Unidade de Medida de um Item em um Pedido
       cAliasED1 := ""              ,;
       cAliasED2 := ""              ,;
       cFilED0   := xFilial("ED0")  ,;
       cFilED1   := xFilial("ED1")  ,;
       cFilED2   := xFilial("ED2")  ,;
       cFilSG1   := xFilial("SG1")  ,;
       cItem     := ""              ,;
       cUM       := ""              ,;
       cProdED2  := ""              ,;
       cSeqED2   := ""              ,;
       FileWork  := ""              ,;
       lCompPed  := .F.             ,;
       lRet      := .T.             ,;
       ni        := 1               ,;
       nPos      := 0               ,;
       nQuant    := 0               ,;
       nRecPri   := 0


 Private cFilSB1 := xFilial("SB1")  ,;  // Usada na Função AvEstrut2
         nEstru    := 0             ,;  // Usada na Função AvEstrut2
         cAliasSB1 := "SB1"             // Usada na Função AvEstrut2


   If cPedido == NIL
      cPedido := ""
   EndIf
   If cChamada == NIL  .Or.  Empty(cChamada)  .Or.  cChamada == "CADASTRO"
      cChamada  := "CADASTRO"
      cAliasED1 := "ED1"
      cAliasED2 := "ED2"
   ElseIf cChamada == "PEDIDO"
      cAliasED1 := "WorkED1"
      cAliasED2 := "WorkED2"
   EndIf
   lCompPed := Len(cPedido) > 0  // Quando a chamada é pelo pedido pode ser feito na inclusao do mesmo, neste caso não havera numero de pedido

   If lBlock == NIL  // Padrao(.F.): não retornar falso caso haja alguma divergencia
      lBlock := .F.  //       (.T.): retornar falso caso haja alguma divergência
   EndIf
   If lShowMsg == NIL  // Padrão(.T.): exibir as mensagens e retornar a variavel lógica lRet
      lShowMsg := .T.  //       (.F.): nao exibe as mensagens e retorna o array com as divergencias
   EndIf
   If lNeces == NIL    // Padrão(.T.): comparar estrutura do pedido e necessidade gerada na estrutura
      lNeces := .T.    //       (.F.): compara somente as estruturas no cadastro
   EndIf

   aOrd := SaveOrd({"ED0",cAliasED1,cAliasED2,"SG1"})
   aRec := { {"ED0",ED0->( RecNo() ) } ,;
             {cAliasED1,(cAliasED1)->( RecNo() ) } ,;
             {cAliasED2,(cAliasED2)->( RecNo() ) } ,;
             {"SG1",SG1->( RecNo() ) } }

   Begin Sequence
      If !EasyGParam("MV_EDC0004",,.T.) // By JPP - 06/11/2007 - 11:30 - Quando o parametro MV_EDC0004 for Falso, a rotina de comparação de estrutura está desligada, para satisfazer as necessidade de alguns clientes.
         lRet := .T.
         aMsg := {}
         Return IIF(lShowMsg,lRet,aMsg)
      EndIf
         
      SG1->( DBSetOrder(1) )
      If SG1->( DBSeek(cFilSG1+cProdPri) )
         AADD(aEstPri,{"PRODUTO",cProdPri,1})
         Do While !SG1->( EoF() )  .And.  cFilSG1+cProdPri == SG1->( G1_FILIAL+G1_COD )
            AADD(aEstPri,{ "ITEM", SG1->G1_COMP, SG1->G1_QUANT, SG1->G1_TRT, SG1->G1_PERDA } ) //MCF - 22/01/2015
            SG1->( DBSkip() )
         EndDo
      EndIf
      If SG1->( DBSeek(cFilSG1+cProdAlt) )
         AADD(aEstAlt,{"PRODUTO",cProdAlt,1})
         Do While !SG1->( EoF() )  .And.  cFilSG1+cProdAlt == SG1->( G1_FILIAL+G1_COD )
            AADD(aEstAlt,{ "ITEM", SG1->G1_COMP, SG1->G1_QUANT, SG1->G1_TRT, SG1->G1_PERDA } ) //MCF - 22/01/2015
            SG1->( DBSkip() )
         EndDo
      EndIf

      If Len(aEstPri) < 2  .Or.  Len(aEstAlt) < 2  // Precisa possuir pelo menos duas posições 'um produto e um item'
         MsgInfo(STR0012)  //"Um dos Produtos não possui estrutura. Verifique o Cadastro de Estruturas."
         lRet := .F.
         Break
      EndIf

      ASort(aEstPri,,,{|x,y| x[1] > y[1] })
      ASort(aEstAlt,,,{|x,y| x[1] > y[1] })

      If lCompPed
   
         If cChamada != "PEDIDO"
            ED0->( DBSetOrder(1) )
         EndIf
         If cAliasED1 == "WorkED1"
            (cAliasED1)->( DBSetOrder(6) )
         Else
            (cAliasED1)->( DBSetOrder(1) )
         EndIf
         (cAliasED2)->( DBSetOrder(2) )
         If IIF(cChamada!="PEDIDO",ED0->( DBSeek(cFilED0+cPedido) ),.T.)  .And.  (cAliasED1)->( DBSeek(IIF(cAliasED1=="ED1",cFilED1+cPedido,"")+cProdPri) )  ;
            .And.  SG1->( DBSeek(cFilSG1+cProdPri) )
            Do While !(cAliasED1)->( EoF() )  .And.  IIF(cAliasED1=="ED1",ED1->(ED1_FILIAL+ED1_PD) == ED0->ED0_FILIAL+cPedido,.T.) ;
                     .And. (cAliasED1)->ED1_PROD == cProdPri
               If (nPos := AScan(aEstPed,{ |x| x[1]=="PRODUTO" } ) ) == 0
                  AADD(aEstPed,{"PRODUTO",(cAliasED1)->ED1_PROD,(cAliasED1)->ED1_QTD,(cAliasED1)->ED1_UMPROD})
               Else
                  aEstPed[nPos][3] += (cAliasED1)->ED1_QTD
               EndIf
               (cAliasED2)->( DBSeek(IIF(cAliasED2=="ED2",cFilED2+cPedido,"")+cProdPri+(cAliasED1)->ED1_SEQ) )
               Do While !(cAliasED2)->( EoF() )  .And.  IIF(cAliasED2=="ED2",ED2->(ED2_FILIAL+ED2_PD) == ED1->ED1_FILIAL+cPedido,.T.)  ;
                        .And.  (cAliasED2)->( ED2_PROD+ED2_SEQ ) == cProdPri+(cAliasED1)->ED1_SEQ
                  If !Empty((cAliasED2)->ED2_MARCA)
                     If (nPos := AScan(aEstPed,{ |x| x[1]=="ITEM" .And. x[2]==(cAliasED2)->ED2_ITEM .And. x[4]==(cAliasED2)->ED2_UMITEM } ) ) == 0
                        If (nPos := AScan(aEstPed,{ |x| x[1]=="ITEM" .And. x[2]==(cAliasED2)->ED2_ITEM } ) ) > 0
                           If AScan(aItemUMDif,{ |x| x[1]==(cAliasED2)->ED2_ITEM .And. ;
                                    ( ( x[2]==aEstPed[nPos][4] .And.  x[3]==(cAliasED2)->ED2_UMITEM  ) .Or. ;
                                      ( x[2]==(cAliasED2)->ED2_UMITEM  .And.  x[3]==aEstPed[nPos][4] ) ) }) == 0
                              AAdd(aItemUMDif,{(cAliasED2)->ED2_ITEM,aEstPed[nPos][4],(cAliasED2)->ED2_UMITEM})
                           EndIf
                        EndIf
                        AADD(aEstPed,{"ITEM",(cAliasED2)->ED2_ITEM,(cAliasED2)->ED2_QTD,(cAliasED2)->ED2_UMITEM})
                     Else
                        aEstPed[nPos][3] += (cAliasED2)->ED2_QTD
                     EndIf
                  EndIf
                  (cAliasED2)->( DBSkip() )
               EndDo
               (cAliasED1)->( DBSkip() )
            EndDo

            If Len(aEstPed) > 1    // e necessario possuir produto a exportar e pelo menos um item a importar, por isso '>1'
               ASort(aEstPed,,,{|x,y| x[1] > y[1] })

               aPriAux  := AClone(aEstPri)
               ASize(aEstPri,1)  // Mantem apenas o produto
               aAltAux := AClone(aEstAlt)
               ASize(aEstAlt,1)  // Mantem apenas o produto
               //Limpa 
               For ni := 1  to  Len(aEstPed)
                  If (nPos := AScan(aPriAux,{|x| x[1] == "ITEM" .And. x[2]==aEstPed[ni][2]}) ) > 0
                     AADD(aEstPri,aPriAux[nPos])
                  EndIf
                  If (nPos := AScan(aAltAux,{|x| x[1] == "ITEM" .And. x[2]==aEstPed[ni][2]}) ) > 0
                     AADD(aEstAlt,aAltAux[nPos])
                  EndIf
               Next ni

               For ni := 2  to  Len(aEstPri)
                  IncProc(STR0027+AllTrim(aEstPri[1][2])+STR0014+AllTrim(aEstPri[ni][2]))  //"Produto: " ### " - Componente: " ###
                  If (nPos := AScan(aEstAlt,{|x|x[1]=="ITEM" .And. x[2]==aEstPri[ni][2]}) ) > 0
                     If aEstPri[ni][3] != aEstAlt[nPos][3]
                        AAdd(aDifEstru,{aEstPri[ni][2],STR0028,AllTrim(Transform(aEstPri[ni][3],AVSX3("G1_QUANT",AV_PICTURE))),AllTrim(Transform(aEstAlt[nPos][3],AVSX3("G1_QUANT",AV_PICTURE)))})  //"Quantidade do Componente é diferente entre as Estruturas"
                     EndIf
                     If aEstPri[ni][4] != aEstAlt[nPos][4]
                        AAdd(aDifEstru,{aEstPri[ni][2],STR0029,AllTrim(Transform(aEstPri[ni][4],AVSX3("G1_PERDA",AV_PICTURE))),AllTrim(Transform(aEstAlt[nPos][4],AVSX3("G1_PERDA",AV_PICTURE)))})  //"Índice de Perda do Componente é diferente entre as Estruturas"
                     EndIf
                  Else
                     AAdd(aDifEstru,{aEstPri[ni][2],STR0030+AllTrim(aEstPri[1][2]),"",""})  //"Componente existe somente na Estrutura do Produto " ###
                  EndIf
               Next ni

               // Verifica itens que existem em aEstAlt e não existem em aEstPri
               For ni := 2  to Len(aEstAlt)
                  If AScan(aEstPri,{|x|x[1]=="ITEM" .And. x[2]==aEstAlt[ni][2]}) == 0
                     AAdd(aDifEstru,{aEstAlt[ni][2],STR0030+AllTrim(aEstAlt[1][2]),"",""})  //"Componente existe somente na Estrutura do Produto " ###
                  EndIf
               Next ni

               If Len(aDifEstru) >  0
                  ASort(aDifEstru,,,{|x,y| x[1] < y[1] } )
                  If lShowMsg
                     AADD(aMsg,{STR0016,.T.})  //"Não é possível gravar as informações pois o(s) seguinte(s) item(ns) possui(em) divergência(s) no Cadastro de Estruturas:"
                  EndIf
                  AADD(aMsg,{ENTER,.T.})
                  nTamPri := Len(STR0031)+Len(AllTrim(aEstPri[1][2]))
                  nTamAlt := Len(STR0032)+Len(AllTrim(aEstAlt[1][2]))
                  If nTamPri > nTamAlt
                     nTamanho := nTamPri
                  Else
                     nTamanho := nTamAlt
                  EndIf
                  If nTamanho < TAM_COL_PRODUTO
                     nTamanho := TAM_COL_PRODUTO
                  EndIf 
                  AADD(aMsg, {EECMontaMsg({"ED2_ITEM",{,"C",STR0024,70,.T.,},{,"C",STR0031+AllTrim(aEstPri[1][2]),nTamanho,.T.,},{,"C",STR0032+AllTrim(aEstAlt[1][2]),nTamanho,.T.,}},aDifEstru),.F.})  //"Divergência"  "Prod.Princ.: " ###  "Prod.Alter.: " ### 
                  If lShowMsg
                     EECView(aMsg,STR0017)  //"Atenção"
                     If lBlock
                        lRet := .F.
                        Break 
                     ElseIf !( lRet := MsgYesNo(STR0035) )  //"Deseja continuar a operação?"
                        Break
                     EndIf
                     aMsg      := {}
                  EndIf
                  aDifEstru := {}
               EndIf

               If lNeces
                  nEstru  := 0  //Usado na Função AvEstrut2
                  FileWork  := AVEstrut2(aEstPed[1][2],aEstPed[1][3],"WorkEstru")
                  IndRegua("WorkEstru", FileWork+TEOrdBagExt(), "COMP")
                  SET INDEX TO (FileWork+TEOrdBagExt())

                  If WorkEstru->(EasyRecCount() ) > 0
                     WorkEstru->( DBSetOrder(1) )
                     WorkEstru->( DBGoTop() )
                     cItem   := WorkEstru->COMP
                     nRecPri := WorkEstru->( RecNo() )
                     WorkEstru->( DBSkip() )
                     Do While !WorkEstru->( EoF() )
                        If cItem == WorkEstru->COMP
                           nQuant := WorkEstru->QUANT
                           RecLock("WorkEstru",.F.)
                           WorkEstru->( DBDelete(), MSUnLock() )
                           WorkEstru->( DBGoTo(nRecPri) )
                           WorkEstru->QUANT += nQuant
                        Else
                           cItem   := WorkEstru->COMP
                           nRecPri := WorkEstru->( RecNo() )
                        EndIf
                        WorkEstru->( DBSkip() )
                     EndDo

                     ProcRegua(WorkEstru->(EasyRecCount() ) + Len(aEstPed) - 1 )
                     WorkEstru->( DBGoTop() )
                     Do While !WorkEstru->( EoF() )
                        IncProc(STR0013+STR0014+AllTrim(WorkEstru->COMP))  //"Cadastro de Estrutura" " - Componente: " ###
                        If ( nPos := AScan(aItemUMDif,{|x| x[1]==WorkEstru->COMP}) ) > 0
                           For ni := nPos  to  Len(aItemUMDif)
                              If aItemUMDif[ni][1] == WorkEstru->COMP
                                 AAdd(aDifEstru,{aItemUMDif[ni][1],STR0034+AllTrim(aItemUMDif[ni][2])+" e "+AllTrim(aItemUMDif[ni][3]),"",""})    //"Componente existe no Pedido com unidades de medida diferentes: " ### " e " ###
                              Else
                                 Exit
                              EndIf
                           Next ni
                        Else
                           If (nPos := AScan(aEstPed,{|x|x[1]=="ITEM" .And. x[2]==WorkEstru->COMP }) ) > 0
                              If WorkEstru->QUANT != aEstPed[nPos][3]
                                 AAdd(aDifEstru,{WorkEstru->COMP,STR0019,AllTrim(Transform(WorkEstru->QUANT,AVSX3("G1_QUANT",AV_PICTURE))),AllTrim(Transform(aEstPed[nPos][3],AVSX3("G1_QUANT",AV_PICTURE)))})  //"Qtd. do Componente difere entre o Pedido e a necessidade da Estrutura."
                              EndIf
                              cUM := Posicione("SB1",1,cFilSB1+WorkEstru->COMP,"B1_UM")
                              If cUM != aEstPed[nPos][4]
                                 AAdd(aDifEstru,{WorkEstru->COMP,STR0033,AllTrim(cUM),AllTrim(aEstPed[nPos][4])})  //"Unidade de Medida do Componente difere entre o Pedido e a Estrutura."
                              EndIf
                           Else
                              AAdd(aDifEstru,{WorkEstru->COMP,STR0020+AllTrim(WorkEstru->CODIGO)+STR0021,"",""})  //"Componente existe na Estrutura do Produto " ### " e não existe no Pedido."
                           EndIf
                        EndIf
                        WorkEstru->( DBSkip() )
                     EndDo

                     WorkEstru->( DBSetOrder(1) )
                     For ni := 2  to Len(aEstPed)
                        IncProc(STR0022+STR0014+AllTrim(aEstPed[ni][2]))  //"Pedido de Drawback" " - Componente: " ###
                        If !WorkEstru->( DBSeek(aEstPed[ni][2]) )
                           AAdd(aDifEstru,{aEstPed[ni][2],STR0023+aEstPed[1][2],"",""})  //"Componente existe no Pedido e não existe na Estrutura no Produto " ###
                        EndIf
                     Next ni
         
                     If Len(aDifEstru) >  0
                        ASort(aDifEstru,,,{|x,y| x[1] < y[1] } )
                        If lShowMsg
                           AADD(aMsg,{STR0018,.T.})  //"O(s) seguinte(s) item(ns) possui(em) divergência(s) entre o Cadastro de Estruturas e o Pedido de Drawback:"
                        EndIf
                        AADD(aMsg,{ENTER,.T.})
                        AADD(aMsg, {EECMontaMsg({"ED2_ITEM",{,"C",STR0024,70,.T.,},{,"C",STR0025,15,.T.,},{,"C",STR0026,15,.T.,}},aDifEstru),.F.})  //"Divergência"  "Neces.Estrut."  "Pedido"
                        If lShowMsg
                           EECView(aMsg,STR0017)  //"Atenção"
                           If lBlock
                              lRet := .F.
                           ElseIf ( lRet := MsgYesNo(STR0035) )  //"Deseja continuar a operação?"
                              aMsg := {}
                           EndIf
                        EndIf
                        aDifEstru := {}
                     EndIf

                  EndIf

                  DBSelectArea("ED7")
                  WorkEstru->( E_EraseArq(FileWork) )

               EndIf

            EndIf

         EndIf

      Else
   
            ProcRegua( Len(aEstPri) + Len(aEstAlt) - 2 )
            For ni := 2  to  Len(aEstPri)
               IncProc(STR0027+AllTrim(aEstPri[1][2])+STR0014+AllTrim(aEstPri[ni][2]))  //"Produto: " ### " - Componente: " ###
               If (nPos := AScan(aEstAlt,{|x|x[1]=="ITEM" .And. x[2]==aEstPri[ni][2] .And. x[4]==aEstPri[ni][4]}) ) > 0 //MCF 22/01/2015
                  If aEstPri[ni][3] != aEstAlt[nPos][3]
                     AAdd(aDifEstru,{aEstPri[ni][2],STR0028,AllTrim(Transform(aEstPri[ni][3],AVSX3("G1_QUANT",AV_PICTURE))),AllTrim(Transform(aEstAlt[nPos][3],AVSX3("G1_QUANT",AV_PICTURE)))})  //"Quantidade do Componente é diferente entre as Estruturas"
                  EndIf
                  If aEstPri[ni][4] != aEstAlt[nPos][4]
                     AAdd(aDifEstru,{aEstPri[ni][2],STR0029,AllTrim(Transform(aEstPri[ni][4],AVSX3("G1_PERDA",AV_PICTURE))),AllTrim(Transform(aEstAlt[nPos][4],AVSX3("G1_PERDA",AV_PICTURE)))})  //"Índice de Perda do Componente é diferente entre as Estruturas"
                  EndIf
               Else
                  AAdd(aDifEstru,{aEstPri[ni][2],STR0030+AllTrim(aEstPri[1][2]),"",""})  //"Componente existe somente na Estrutura do Produto " ###
               EndIf
            Next ni

            // Verifica itens que existem em aEstAlt e não existem em aEstPri
            For ni := 2  to Len(aEstAlt)
               IncProc(STR0027+AllTrim(aEstAlt[1][2])+STR0014+AllTrim(aEstAlt[ni][2]))  //"Produto: " ### " - Componente: " ###
               If AScan(aEstPri,{|x|x[1]=="ITEM" .And. x[2]==aEstAlt[ni][2]}) == 0
                  AAdd(aDifEstru,{aEstAlt[ni][2],STR0030+AllTrim(aEstAlt[1][2]),"",""})  //"Componente existe somente na Estrutura do Produto " ###
               EndIf
            Next ni

            If Len(aDifEstru) >  0
               ASort(aDifEstru,,,{|x,y| x[1] < y[1] } )
               If lShowMsg
                  AADD(aMsg,{STR0016,.T.})  //"Não é possível gravar as informações pois o(s) seguinte(s) item(ns) possui(em) divergência(s) no Cadastro de Estruturas:"
               EndIf
               AADD(aMsg,{ENTER,.T.})
               nTamPri := Len(STR0031)+Len(AllTrim(aEstPri[1][2]))
               nTamAlt := Len(STR0032)+Len(AllTrim(aEstAlt[1][2]))
               If nTamPri > nTamAlt
                  nTamanho := nTamPri
               Else
                  nTamanho := nTamAlt
               EndIf
               If nTamanho < TAM_COL_PRODUTO
                  nTamanho := TAM_COL_PRODUTO
               EndIf 
               AADD(aMsg, {EECMontaMsg({"ED2_ITEM",{,"C",STR0024,70,.T.,},{,"C",STR0031+AllTrim(aEstPri[1][2]),nTamanho,.T.,},{,"C",STR0032+AllTrim(aEstAlt[1][2]),nTamanho,.T.,}},aDifEstru),.F.})  //"Divergência"  "Prod.Princ.: " ###  "Prod.Alter.: " ### 
               If lShowMsg
                  EECView(aMsg,STR0017)  //"Atenção"
                  If lBlock
                     lRet := .F.
                  Else
                     lRet := MsgYesNo(STR0035)  //"Deseja continuar a operação?"
                  EndIf
               EndIf
            EndIf
   
      EndIf

   End Sequence

   RestOrd(aOrd)
   ED0->( DBGoTo(aRec[ASCan(aRec,{|x|x[1]=="ED0"})][2]) )
   (cAliasED1)->( DBGoTo(aRec[ASCan(aRec,{|x|x[1]==cAliasED1})][2]) )
   (cAliasED2)->( DBGoTo(aRec[ASCan(aRec,{|x|x[1]==cAliasED2})][2]) )
   SG1->( DBGoTo(aRec[ASCan(aRec,{|x|x[1]=="SG1"})][2]) )

Return IIF(lShowMsg,lRet,aMsg)

//***********************************************************************************************/
//                             IG400BuscaItem - BUSCA ITEM PRINCIPAL                            */
//***********************************************************************************************/
// cTipo        = Importacao/Exportação                                                         */ 
// cAlternativo = Código do Produto/Item Alternativo                                            */ 
// cPedido      = Pedido de Drawback                                                            */ 
// cAto         = Ato Concessorio                                                               */
//***********************************************************************************************/
Function IG400BuscaItem(cTipo,cAlternativo,cPedido,cAto) 
//***********************************************************************************************/

 Local lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0
 Local aAlias     := {}  ,;
       aOrd       := {}  ,;
       cPrincipal := ""

 Default cTipo        := "I"
 Default cAlternativo := ""
 Default cPedido      := ""
 Default cAto         := ""

   If Empty(cAlternativo)
      Return cAlternativo
   EndIf

If lTipoItem

   aAlias := {"ED0","ED7"}
   aOrd := SaveOrd(aAlias)

   If Empty(cPedido)  .And. !Empty(cAto)
      ED0->( DBSetOrder(2) )
      If ED0->( DBSeek(xFilial("ED0")+cAto) )
         cPedido := ED0->ED0_PD
      EndIf
   EndIf

   ED7->( DBSetOrder(1) )

   If !Empty(cPedido)
      If ED7->( DBSeek(xFilial("ED7")+cTipo+cAlternativo+cPedido) )
         cPrincipal := ED7->ED7_DE
      EndIf
   EndIf

   If Empty(cPrincipal)
      If ED7->( DBSeek(xFilial("ED7")+cTipo+cAlternativo))//+Space(Len(ED7->ED7_PD))) )  //WFS 20/12/2013
         cPrincipal := ED7->ED7_DE
      EndIf
   EndIf

   If Empty(cPrincipal)
      cPrincipal := cAlternativo
   EndIf

   RestOrd(aOrd,.T.)

Else

   cPrincipal := BuscaItemGen(cAlternativo)

EndIf

Return cPrincipal

//***********************************************************************************************/
//                          IG400AllItens - BUSCA TODOS ITENS PRINCIPAIS                        */
//***********************************************************************************************/
// cTipo        = Importacao/Exportação                                                         */ 
// cAlternativo = Código do Produto/Item Alternativo                                            */ 
//***********************************************************************************************/
Function IG400AllItens(cTipo,cItem,cPedido,lPrincipal)
//***********************************************************************************************/

 Local lTipoItem := ED7->( FieldPos("ED7_TPITEM") ) > 0  .And.  ED7->( FieldPos("ED7_PD") ) > 0
 Local nOrd       := 0  ,;
       nRec       := 0  ,;
       aPrincipal := {} ,;
       cChave     := ""

 Default cTipo      := ""
 Default cItem      := ""
 Default lPrincipal := .F.
 If cPedido == NIL  .Or.  Empty(cPedido)
    cPedido := ""
 EndIf

   Begin Sequence

      If lTipoItem   
    
         If Empty(cTipo)  .Or.  Empty(cItem)
            Break
         EndIf

         nOrd := ED7->( IndexOrd() )
         nRec := ED7->( RecNo() )

         If lPrincipal

            ED7->( DBSetOrder(2) )

            If !Empty(cPedido)
               cChave := xFilial("ED7")+cTipo+cItem+cPedido
               ED7->( DBSeek(cChave) )
               Do While ED7->( !EoF()  .And.  ED7_FILIAL+ED7_TPITEM+ED7_DE+ED7_PD == cChave )
                  AAdd(aPrincipal,{ED7->ED7_PARA,ED7->ED7_PD})
                  ED7->( DBSkip() )
               EndDo
               cChave := xFilial("ED7")+cTipo+cItem+Space(Len(ED7->ED7_PD))
               ED7->( DBSeek(cChave) )
               Do While ED7->( !EoF()  .And.  ED7_FILIAL+ED7_TPITEM+ED7_DE+ED7_PD == cChave )
                  AAdd(aPrincipal,{ED7->ED7_PARA,ED7->ED7_PD})
                  ED7->( DBSkip() )
               EndDo
            Else
               cChave := xFilial("ED7")+cTipo+cItem
               ED7->( DBSeek(cChave) )
               Do While ED7->( !EoF()  .And.  ED7_FILIAL+ED7_TPITEM+ED7_DE == cChave )
                  AAdd(aPrincipal,{ED7->ED7_PARA,ED7->ED7_PD})
                  ED7->( DBSkip() )
               EndDo
            EndIf

         Else
         
            ED7->( DBSetOrder(1) )

            cChave := xFilial("ED7")+cTipo+cItem
            ED7->( DBSeek(cChave) )
            Do While ED7->( !EoF()  .And.  ED7_FILIAL+ED7_TPITEM+ED7_PARA == cChave )
               AAdd(aPrincipal,{ED7->ED7_DE,ED7->ED7_PD})
               ED7->( DBSkip() )
            EndDo

         EndIf

         If Len(aPrincipal) > 0
            ASort(aPrincipal,,,{|x,y| x[2]>y[2] })
         EndIf

         ED7->( DBSetOrder(nOrd) )
         If nRec > 0
            ED7->( DBGoTo(nRec) )
         EndIf

      Else
      
         AADD(aPrincipal,{BuscaItemGen(cItem),""})
      
      EndIf

   End Sequence

Return aPrincipal
