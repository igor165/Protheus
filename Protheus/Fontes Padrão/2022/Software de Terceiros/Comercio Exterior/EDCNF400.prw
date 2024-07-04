#INCLUDE "EDCNF400.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "AVERAGE.CH"   
#INCLUDE "TOPCONN.CH"
                       
#define GENERICO     "06"
#define NCM_GENERICA "99999999"

/*
Programa   : EDCNF400 
Objetivo   : Manutenção da rotina de Compras Nacionais  
Retorno    : lRet
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 15/10/10 
Obs.       : 
*/

*------------------*
Function EDCNF400(aCabx,nOpcao)
*------------------*
Local lRet := .T.
Local aOrd := {}
Local cAlias     := "ED8" 
Local cExpFilter := "" 
Local lTemFiltro := .F. 
Local lTop       := .F. 
Local lExpTop    := .T.

Private aColunas   := {{AvSx3("ED8_IMPORT",AV_TITULO),"ED8_IMPORT"}, {AvSx3("ED8_DESCIM",AV_TITULO),"ED8_DESCIM"},;
                       {AvSx3("ED8_PEDIDO",AV_TITULO),"ED8_PEDIDO"}, {AvSx3("ED8_POSDI" ,AV_TITULO),"ED8_POSDI" },;
                       {AvSx3("ED8_COD_I" ,AV_TITULO),"ED8_COD_I" }, {AvSx3("ED8_DESC"  ,AV_TITULO),"ED8_DESC"  },;
                       {AvSx3("ED8_FORN"  ,AV_TITULO),"ED8_FORN"  }, {AvSx3("ED8_LOJA"  ,AV_TITULO),"ED8_LOJA"  },;
                       {AvSx3("ED8_NF"    ,AV_TITULO),"ED8_NF"    }, {AvSx3("ED8_SERIE" ,AV_TITULO),"ED8_SERIE" },;
                       {AvSx3("ED8_EMISSA",AV_TITULO),"ED8_EMISSA"}, {AvSx3("ED8_AC"    ,AV_TITULO),"ED8_AC"    },;
                       {AvSx3("ED8_SEQSIS",AV_TITULO),"ED8_SEQSIS"}}

Private cCadastro := STR0001 // Manutenção de Compras Nacionais

Private aRotina := MenuDef()

// BAK - ExecAuto da Compras Nacionais  
Private aCabAuto := aCabx
Private nOpcAuto := nOpcao
Private lManNFAuto := Type("nOpcAuto") == "N" .And. Type("aCabAuto") == "A"
//

#IFDEF TOP
   lTop := .T.
#ELSE
   lTop := .F.
#ENDIF

IF AvFlags("SEQMI")            // GFP - 10/11/2011
   AADD(aColunas,{AvSx3("ED8_SEQMI",AV_TITULO),"ED8_SEQMI"})
ELSE
   AADD(aColunas,{AvSx3("ED8_SEQSIS",AV_TITULO),"ED8_SEQSIS"})
ENDIF

Begin Sequence
   
If !lManNFAuto 
   
   aOrd := SaveOrd("ED8")
   //Verifica se a tabela já possui filtro
   lTemFiltro := !Empty( (cAlias)->( DBFilter() ) )

   If !lTop  .Or.  lTemFiltro  // Caso a tabela ja esteja filtrada efetua o DBFilter() normalmente
      lExpTop := .F.
   EndIf

   If lExpTop
      cExpFilter := cAlias+"_DI_NUM == '" + space(AVSX3("ED8_DI_NUM",AV_TAMANHO)) + "'"
   Else
      cExpFilter := cAlias+"->"+cAlias + "_DI_NUM == '" + space(AVSX3("ED8_DI_NUM",AV_TAMANHO)) + "'"
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
   
   
   MBrowse(,,,,cAlias,aColunas)
   (cAlias)->( DBClearFilter() )
Else
   
    If nOpcAuto == 4
       If EasySeekAuto("ED8",aCabAuto,5)
          mBrowseAuto(nOpcAuto,aCabAuto,"ED8",.F.)
       EndIf
    EndIf

EndIf

End Sequence

RestOrd(aOrd)

Return lRet 


/*
Funcao     : MenuDef()
Parametros : cOrigem, lMBrowse
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 15/10/10 - 11:27
*/
*------------------------*
Static Function MenuDef()
*------------------------*         
Local aRotina  := { { STR0002, "AxPesqui" , 0 , 1},;  //"Pesquisar "
                    { STR0003, "NF400MAN" , 0 , 2},;  //"Visualizar"
                    { STR0004, "NF400MAN" , 0 , 3},;  //"Incluir   "
                    { STR0005, "NF400MAN" , 0 , 4},;  //"Alterar   "
                    { STR0006, "NF400MAN" , 0 , 5,3}} //"Cancelar  "   
//                 { STR0006, "NF400MAN" , 0 , 4,3}} //"Cancelar  "                     
                    	
Return aRotina 




/*
Funcao      : NF400MAN(cAlias,nReg,nOpcao)
Parametros  : cAlias:= alias arq.
              nReg:=num.registro
              nOpc:=opcao escolhida
Retorno     : lRet
Objetivos   : Executar enchoice - Rotina de Compras Nacionais
Autor       : Allan Oliveira Monteiro
Data/Hora   : 15/10/10 - 11:38
Obs.        :
*/
*------------------------------------*
Function NF400MAN(cAlias,nReg,nOpcao)
*------------------------------------*
Local lRet := .T.
Local aOrd:={} 
Local nInc 
Local oEncCapa, oDlg
Local bOk := {|| If(nOpc == 2,oDlg:End(),If( NF400VldGrv(),oDlg:End(),))  }
Local bCancel:= {|| If(MsgYesNo(STR0007,STR0008),lRet := .F. ,) , If(!lRet,oDlg:End(),)} //"Deseja Cancelar a Operação?","Aviso" 
Local aCpoShow:= {"ED8_AC", IF(AvFlags("SEQMI"),"ED8_SEQMI","ED8_SEQSIS")}  // GFP - 10/11/2011
Local aCampos := {"ED8_IMPORT", "ED8_DESCIM", "ED8_FORN", "ED8_LOJA", "ED8_NMFORN", "ED8_NF", "ED8_SERIE", "ED8_EMISSA", "ED8_PEDIDO", "ED8_POSDI",;
                  "ED8_AC", IF(AvFlags("SEQMI"),"ED8_SEQMI","ED8_SEQSIS"), "ED8_COD_I", "ED8_DESC", "ED8_NCM", "ED8_PESO", "ED8_UM", "ED8_QTD", "ED8_UMNCM", "ED8_QTDNCM",;
                  "ED8_MOEDA", "ED8_TX_MOE", "ED8_VALORI", "ED8_TX_USS", "ED8_VALEMB", "ED8_DT_INT"}

Local lManutNFAuto := Type("lManNFAuto") == "L" .And. lManNFAuto
Local lCompraNacio := AvFlags("SEQMI")
Private nOpc := nOpcao 
Private aTela[0][0],aGets[0] 
Private lAcMod := .T.


Begin Sequence

   aOrd := SaveOrd({"ED8","SJ5"}) 
   
   If lCompraNacio
      aAdd(aCampos,"ED8_SEQMI")
   EndIf
   
   //FSM - 05/10/2011 - Inclusão do campo Modelo da Nota Fiscal
   If ED8->(FieldPos("ED8_MOD_NF")) > 0
      aAdd(aCampos,"ED8_MOD_NF")
   EndIf 

   If nOpc == INCLUIR
   
      For nInc := 1 TO ED8->(FCount())
         M->&(ED8->(FIELDNAME(nInc))) := CRIAVAR(ED8->(FIELDNAME(nInc)))
      Next nInc

      M->ED8_MOEDA := EasyGParam("MV_SIMB1",,"R$") 
      M->ED8_TX_MOE:= 1
      M->ED8_TX_USS:= BuscaTaxa(M->ED8_MOEDA,dDataBase) 
      
   Else
     
      RegToMemory("ED8",.T.) // Para criar os virtuais 
      For nInc := 1 TO ED8->(FCount())
         M->&(ED8->(FieldName(nInc))) := ED8->(FieldGet(nInc))
      Next nInc

   EndIf
   
   If lManutNFAuto
      M->ED8_AC     := aCabAuto[aScan(aCabAuto, {|x| "ED8_AC" == AllTrim(Upper(x[1]))})][2]
      M->ED8_SEQSIS := aCabAuto[aScan(aCabAuto, {|x| "ED8_SEQSIS" == AllTrim(Upper(x[1]))})][2]
      If lCompraNacio
         M->ED8_SEQMI := aCabAuto[aScan(aCabAuto, {|x| "ED8_SEQMI" == AllTrim(Upper(x[1]))})][2]
      EndIf
   EndIf  
   
   If !Empty(M->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),M->ED8_SEQMI,M->ED8_SEQSIS)) .And. nOpc == 4  // GFP - 10/11/2011
      If !lManutNFAuto
         MsgInfo(STR0011,STR0008)//"O ato concessório está preenchido. Retire o conteúdo do Ato Concessório e grave a Compra Nacional, em seguida execute a operação","Aviso"
      EndIf
   EndIf
   
   If !lManutNFAuto
      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         oEncCapa := MsMGet():New(cAlias, nReg, nOpc,,,,aCampos,PosDlg(oDlg),If(!Empty(M->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),AvKey(M->ED8_SEQMI,"ED4_SEQMI"),AvKey(M->ED8_SEQSIS,"ED4_SEQSIS"))) .And. nOpc == 4,aCpoShow,))
         //EnChoice(cAlias,nReg,nOpc,,,,aCampos,PosDlg(oDlg))
         oDlg:lMaximized:=.T.
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel) CENTERED
   Else
      lRet := EnchAuto(cAlias,aCabAuto,{|| lRet := NF400VldGrv() },nOpcAuto,aCampos)   
   EndIf 
   
   If lRet .And. nOpc <> 2
      If Empty(M->ED8_AC)
         If lCompraNacio .And. !Empty(M->ED8_PEDIDO)
            M->ED8_SEQMI := ""
         Else
            M->ED8_SEQSIS := ""
         EndIf
         //!Empty(IF(AvFlags("SEQMI"),M->ED8_SEQMI := "" ,M->ED8_SEQSIS := "")) //M->ED8_SEQSIS := ""   GFP - 10/11/2011
      EndIf
      NF400Grava(nOpc)
   EndIf

End Sequence 

RestOrd(aOrd)

Return lRet


/*
Funcao     : NF400VldGrv()
Parametros : cCampo - Campo do SX3
Retorno    : lRet
Objetivos  : Efetuar as validações necessarias dos campos antes da gravação
Autor      : Allan Oliveira Monteiro 
Data/Hora  : 18/10/10 - 14:23
*/
/********************/
Function NF400VldGrv()
/********************/
Local aOrd := {}   //RRC - 22/05/2012 - Guarda a ordem da tabela correspondente  
Local cChave := "" //RRC - 24/05/2012 - Chave de busca na tabela ED4 (Saldo dos Itens a Importar)
Local lRet := .T.
Local lSemVerif := IsInCallStack("EasyDesEDC")
Local lTpOcor   := EDD->(FIELDPOS("EDD_CODOCO")) > 0 .And. EDD->(FIELDPOS("EDD_DESTIN")) > 0 //AOM - 22/06/2012 - Campos para gravação de Itens comprados na Anterioridade

// BAK - Reapuracao Compras Nacionais  
Local lManutNFAuto  := Type("lManNFAuto") == "L" .And. lManNFAuto

Begin Sequence   

   lRet := Obrigatorio(aGets,aTela)

   ED8->(DbSetOrder(5))
   If lRet .And. nOpc == 3 .And. ED8->(DbSeek(xFilial("ED8")+ AvKey(M->ED8_PEDIDO,"ED8_PEDIDO") + AvKey(M->ED8_POSDI,"ED8_POSDI")))
      MsgInfo(STR0025,STR0008)//"O pedido informado jà existe em outro processo. Informar um novo pedido.","Aviso"
      lRet := .F.
   EndIf

   // GFP - 10/11/2011
   IF AvFlags("SEQMI")
      ED4->(DbSetOrder(8))  //ED4_FILIAL+ED4_AC+ED4_SEQMI
   ELSE
      ED4->(DbSetOrder(2))  //ED4_FILIAL+ED4_AC+ED4_SEQSIS
   ENDIF
   // GFP - 10/11/2011 - Incluido SEQMI no indice
   If !Empty(M->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),AvKey(M->ED8_SEQMI,"ED4_SEQMI"),AvKey(M->ED8_SEQSIS,"ED4_SEQSIS"))) .And. ;
      ED4->(DbSeek(xFilial("ED4") + AvKey(M->ED8_AC,"ED4_AC") + IF(AvFlags("SEQMI"),AvKey(M->ED8_SEQMI,"ED4_SEQMI"),AvKey(M->ED8_SEQSIS,"ED4_SEQSIS"))))
      If Empty(M->ED8_COD_I)
         If lManutNFAuto
            EasyHelp(STR0013)
         Else
            MsgInfo(STR0013,STR0008)//"Preencher o Item na pasta 'Cadastrais' antes de informar o Ato Concessório." ,"Aviso"
         EndIf
         lRet := .F.   
      ElseIf AllTrim(M->ED8_COD_I) <> AllTrim(ED4->ED4_ITEM)
         If lManutNFAuto
            EasyHelp(STR0014)
         Else
            MsgInfo(STR0014,STR0008)//"O item do Ato Concessório deve ser o mesmo que o informado na pasta 'Cadastrais'.","Aviso"
         EndIf
         lRet := .F.
      EndIf
   EndIf 
   
   If !lSemVerif .And. ((nOpc == 4 .And. Empty(M->ED8_AC)) .Or. nOpc == 5) .And. !Empty(ED8->ED8_AC) .And. !EasyGParam("MV_EDC0009",,.F.)
         
         If AVFLAGS("SEQMI")
            EDD->( dbSetOrder(4) ) 
         Else
            EDD->( dbSetOrder(2) )
         EndIf
         EDD->(dbSeek(xFilial("EDD")+AvKey("","EDD_HAWB")+AvKey("","EDD_INVOIC")+Avkey(ED8->ED8_PEDIDO,"EDD_PO_NUM")+Avkey(ED8->ED8_POSDI,"EDD_POSICA")+AvKey("","EDD_PGI_NU")))
         Do While !EDD->( EoF() ) .AND. EDD->( EDD_FILIAL+EDD_HAWB+EDD_INVOIC+EDD_PO_NUM+EDD_POSICA+EDD_PGI_NU )  ==;
                                           xFilial("EDD")+AvKey("","EDD_HAWB")+AvKey("","EDD_INVOIC")+Avkey(ED8->ED8_PEDIDO,"EDD_PO_NUM")+Avkey(ED8->ED8_POSDI,"EDD_POSICA")+AvKey("","EDD_PGI_NU")
   
           If (!Empty(EDD->EDD_PREEMB) .Or. !Empty(EDD->EDD_PEDIDO) .Or. (lTpOcor .And. !Empty(EDD->EDD_CODOCO)) ) //AOM - 23/11/2011 - Tratamento para considerar Vendas para exportadores.
              If !lManutNFAuto
                 MsgStop(STR0015)//"Comprovação não pode ser estornada pois mantém associação de anterioridade com exportação ou Vendas para Exportadores"
              Else
                 EasyHelp(STR0015)//"Comprovação não pode ser estornada pois mantém associação de anterioridade com exportação ou Vendas para Exportadores"
              EndIf
              M->ED8_AC     := ED8->ED8_AC
              M->ED8_SEQSIS := ED8->ED8_SEQSIS
              If AVFLAGS("SEQMI")
                 M->ED8_SEQMI := ED8->ED8_SEQMI
              EndIf
              lRet := .F.
              Break
           EndIf
   
           EDD->( dbSkip() )
         EndDo
      EndIf
      
      If nOpc == 3 .Or. nOpc == 4 //Caso insira ou altere um Ato Concessório
         DbSelectArea("ED4")
         aOrd := SaveOrd({"ED0","ED4"})
         If AvFlags("SEQMI") 
            ED4->(DbSetOrder(8)) 
            cChave := "M->ED8_AC+M->ED8_SEQMI" //Busca pela chave ED4_AC+ED4_SEQMI
         Else
            ED4->(DbSetOrder(2)) 
            cChave := "M->ED8_AC+M->ED8_SEQSIS"//Busca pela chave ED4_AC+ED4_SEQSIS
         EndIf 
         If !Empty(M->ED8_SEQMI) .Or. !Empty(M->ED8_SEQSIS) //Se escolher um Ato manualmente, é preciso informar a sequência 
            //RRC - 15/05/2012 - Não permite associação de um Ato Concessório de saldo inferior ou igual a 0      
            If ED4->(DbSeek(xFilial("ED4") + &(cChave))) .And. (ED4->ED4_QT_LI <= 0 .Or. !NF400VerSal())
               If !lManutNFAuto
                  MsgInfo(STR0016,STR0008) //"Ato Concessório não será associado pois não possui saldo suficiente para a operação","Aviso"
               Else
                  EasyHelp(STR0016,STR0008) //"Ato Concessório não será associado pois não possui saldo suficiente para a operação","Aviso"
               EndIf
               M->ED8_AC := space(AvSX3("ED8_AC",3))
               If AvFlags("SEQMI")
                  M->ED8_SEQMI  := space(AvSX3("ED8_SEQMI",3))
               Else
                  M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3))
               EndIf
            EndIf 
         EndIf           

         //RRC - 16/05/2012 - Não permite associar um Ato Concessório de Isenção a uma Compra Nacional
         DbSelectArea("ED0")
         ED0->(DbSetOrder(2))     
         //É preciso que o Ato informado seja válido, pois será utilizado na verificação do tipo (Isenção ou Suspensão)
         If !Empty(M->ED8_AC) .And. ED0->(DbSeek(xFilial("ED0") + M->ED8_AC)) .And. ED0->ED0_MODAL == "2" .And. Empty(M->ED8_DI_NUM)
            If !lManutNFAuto
               MsgInfo(STR0017,STR0008)//"Ato Concessório informado está classificado com a modalidade Isenção, só será permitido a associação com um Ato Concessório de Suspensão","Aviso"     
            Else
               EasyHelp(STR0017,STR0008)//"Ato Concessório informado está classificado com a modalidade Isenção, só será permitido a associação com um Ato Concessório de Suspensão","Aviso"     
            EndIf
            M->ED8_AC := space(AvSX3("ED8_AC",3))
            If AvFlags("SEQMI")
               M->ED8_SEQMI := space(AvSX3("ED8_SEQMI",3))
            Else
               M->ED8_SEQSIS := space(AvSX3("ED8_SEQSIS",3))
            EndIf
         EndIf
      
         RestOrd(aOrd,.T.)     
      EndIf     

End Sequence

Return lRet



/*
Funcao      : NF400Grava
Parametros  : nOpc      :=opcao escolhida
Retorno     : lRet
Objetivos   : Gravação da rotina de Compras Nacionais
Autor       : Allan Oliveira Monteiro
Data/Hora   : 18/10/10 - 14:21
Obs.        :
*/
/*************************/
Function NF400Grava(nOpc)
/*************************/
Local lRet  := .T.
Local lSeek
Local aEst , aBxa 
Local aOrd := SaveOrd({"ED0"}) //RRC - Guarda a ordem da tabela correspondente

// BAK - 29/09/2011
Local lManutNFAuto  := Type("lManNFAuto") == "L" .And. lManNFAuto
//Inclusão ou Alteração
If nOpc == 3 .OR. nOpc == 4

   If nOpc == 4 
      ED8->(DbSetOrder(5))
      If ED8->(DbSeek(xFilial("ED8") + AvKey(M->ED8_PEDIDO,"ED8_PEDIDO") + AvKey(M->ED8_POSDI,"ED8_POSDI")))
         If !Empty(ED8->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),ED8->ED8_SEQMI,ED8->ED8_SEQSIS))  //GFP - 10/11/2011
            aBxa := AC400EstSld(ED8->ED8_QTD, ED8->ED8_UM, ED8->ED8_PESO , ED8->ED8_VALORI, ED8->ED8_MOEDA, ED8->ED8_AC, IF(AvFlags("SEQMI"),ED8->ED8_SEQMI,ED8->ED8_SEQSIS),.T.,.T.,.T.,{{ED8->ED8_UMNCM,ED8->ED8_QTDNCM}},ED8->ED8_TX_MOE,ED8->ED8_TX_USS,.T.)
            If ValType(aBxa) <> "U" 
               
               // GFP - 10/11/2011
               IF AvFlags("SEQMI")
                  ED4->(DbSetOrder(8))  //ED4_FILIAL+ED4_AC+ED4_SEQMI
               ELSE
                  ED4->(DbSetOrder(2))  //ED4_FILIAL+ED4_AC+ED4_SEQSIS
               ENDIF
               
               If ED4->(DbSeek(xFilial("ED4") + AvKey(ED8->ED8_AC,"ED4_AC") + IF(AvFlags("SEQMI"),AvKey(ED8->ED8_SEQMI,"ED4_SEQMI"),AvKey(ED8->ED8_SEQSIS,"ED4_SEQSIS"))))
                  MN400GrvAnt(2,/*Hawb*/,ED8->ED8_PEDIDO,/*Invoice*/,ED8->ED8_COD_I,ED8->ED8_POSDI,/*PGI*/,ED8->ED8_QTD,/*DataReg*/)
               EndIf
            Else
               lRet := .F.
               If lManutNFAuto
                  EasyHelp(STR0009)
               Else
                  MsgInfo(STR0009,STR0008)//"O estorno da Compra Nacional não foi concluida com Sucesso. Verifique os dados da Compra." ,"Aviso"
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
    
   If lRet .And. !Empty(M->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),M->ED8_SEQMI,M->ED8_SEQSIS))  // GFP - 10/11/2011
    
      aEst:= AC400BxSld(M->ED8_QTD, M->ED8_UM, M->ED8_PESO , M->ED8_VALORI, M->ED8_MOEDA, M->ED8_AC, IF(AvFlags("SEQMI"),M->ED8_SEQMI,M->ED8_SEQSIS),.T.,.T.,.T.,{{M->ED8_UMNCM,M->ED8_QTDNCM}},M->ED8_TX_MOE,M->ED8_TX_USS,.T.)
   
      If ValType(aEst) <> "U"
         If !Empty(M->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),M->ED8_SEQMI,M->ED8_SEQSIS))
            
            // GFP - 10/11/2011
            IF AvFlags("SEQMI")
               ED4->(DbSetOrder(8))  //ED4_FILIAL+ED4_AC+ED4_SEQMI
            ELSE
               ED4->(DbSetOrder(2))  //ED4_FILIAL+ED4_AC+ED4_SEQSIS
            ENDIF

            If ED4->(DbSeek(xFilial("ED4") + AvKey(M->ED8_AC,"ED4_AC") + IF(AvFlags("SEQMI"),AvKey(M->ED8_SEQMI,"ED4_SEQMI"),AvKey(M->ED8_SEQSIS,"ED4_SEQSIS"))))
               MN400GrvAnt(1,/*Hawb*/,M->ED8_PEDIDO,/*Invoice*/,M->ED8_COD_I,M->ED8_POSDI,/*PGI*/,M->ED8_QTD,M->ED8_EMISSA)
            EndIf
            
            //RRC - 22/05/2012 - Tratamento dos campos "ED8_VL_AC", "ED8_QT_AC" e "ED8_QT_AC2"
            DbSelectArea("ED0")
            ED0->(DbSetOrder(1)) 
            If ED0->(DbSeek(xFilial("ED0") + ED4->ED4_PD))
               If ED0->ED0_TIPOAC<>GENERICO .Or. ED4->ED4_NCM<>NCM_GENERICA 
                  M->ED8_VL_AC  := M->ED8_VALEMB
                  M->ED8_QT_AC  := AVTransUnid(M->ED8_UM,ED4->ED4_UMITEM,M->ED8_COD_I,M->ED8_QTD,.T.)
                  M->ED8_QT_AC2 := M->ED8_QTDNCM
               EndIf
            EndIf              
         EndIf
                    
      Else
         lRet := .F.
         If lManutNFAuto
            EasyHelp(STR0010)
         Else
            MsgInfo(STR0010,STR0008)//"A Baixa da Compra Nacional não foi concluida com Sucesso. Verifique os dados da Compra.","Aviso"
         EndIf
      EndIf
   
   ElseIf Empty(M->ED8_AC) .Or. Empty(IF(AvFlags("SEQMI"),M->ED8_SEQMI,M->ED8_SEQSIS))  
      //RRC - 22/05/2012 - Caso desassocie um Ato Concessório, deve zerar os campos "ED8_VL_AC", "ED8_QT_AC" e "ED8_QT_AC2"
	  M->ED8_VL_AC  := 0 
	  M->ED8_QT_AC  := 0 
      M->ED8_QT_AC2 := 0 
   EndIf
    
   
   If lRet
      ED8->(DbSetOrder(5))
      lSeek:= ED8->(DbSeek(xFilial("ED8") + AvKey(M->ED8_PEDIDO,"ED8_PEDIDO") + AvKey(M->ED8_POSDI,"ED8_POSDI"))) 
      If ED8->(RecLock("ED8",!lSeek))
         AVReplace("M","ED8")
         ED8->(MSUNLOCK())
      EndIf
   EndIf


//Exclusão   
ElseIf nOpc == 5 

   ED8->(DbSetOrder(5))
   If ED8->(DbSeek(xFilial("ED8") + AvKey(M->ED8_PEDIDO,"ED8_PEDIDO") + AvKey(M->ED8_POSDI,"ED8_POSDI")))
      If !Empty(ED8->ED8_AC) .And. !Empty(IF(AvFlags("SEQMI"),ED8->ED8_SEQMI,ED8->ED8_SEQSIS))   // GFP - 10/11/2011
         aBxa := AC400EstSld(ED8->ED8_QTD, ED8->ED8_UM, ED8->ED8_PESO , ED8->ED8_VALORI, ED8->ED8_MOEDA, M->ED8_AC, IF(AvFlags("SEQMI"),M->ED8_SEQMI,M->ED8_SEQSIS),.T.,.T.,.T.,{{ED8->ED8_UMNCM,ED8->ED8_QTDNCM}},ED8->ED8_TX_MOE,ED8->ED8_TX_USS,.T.)
         If ValType(aBxa) <> "U" 
            MN400GrvAnt(2,/*Hawb*/,ED8->ED8_PEDIDO,/*Invoice*/,ED8->ED8_COD_I,ED8->ED8_POSDI,/*PGI*/,ED8->ED8_QTD,/*DataReg*/)
         Else
            lRet := .F.
            If lManutNFAuto
               EasyHelp(STR0009)
            Else
               MsgInfo(STR0009,STR0008)//"O estorno da Compra Nacional não foi concluida com Sucesso. Verifique os dados da Compra."
            EndIf
         EndIf
      EndIf
   EndIf
   
   If lRet
     If ED8->(RecLock("ED8",.F.))
        ED8->(DbDelete())
        ED8->(MSUNLOCK())
      EndIf
   EndIf
EndIf

RestOrd(aOrd,.T.)
Return lRet

/*
Funcao      : NF400VerSal()
Parametros  : 
Retorno     : lRet
Objetivos   : Verificar se existe saldo suficiente para associação de Ato Concessório a Compra Nacional
Autor       : Rafael Ramos Capuano
Data/Hora   : 17/05/12 - 11:06
Obs.        :
*/               
*------------------------------------*
Function NF400VerSal()
*------------------------------------*  

Local aOrd := SaveOrd({"ED0","ED4"}) //RRC - Guarda a ordem das tabelas correspondentes
Local nQtdAux  := 0
Local nPesoAux := 0 
Local cMsg     := "" 
Local lRet := .T.
Local lManutNFAuto := Type("lManNFAuto") == "L" .And. lManNFAuto

DbSelectArea("ED4")
If AvFlags("SEQMI")
   ED4->(DbSetOrder(8))
   ED4->(DbSeek(xFilial("ED4")+M->ED8_AC+M->ED8_SEQMI))
Else    
   ED4->(DbSetOrder(2))
   ED4->(DbSeek(xFilial("ED4")+M->ED8_AC+M->ED8_SEQSIS))
EndIf

DbSelectArea("ED0")
ED0->(DbSetOrder(1)) 
ED0->(DbSeek(xFilial("ED0")+ED4->ED4_PD))
  
   If ED0->ED0_TIPOAC <> GENERICO .Or. ED4->ED4_NCM <> NCM_GENERICA 
      If AvVldUn(ED4->ED4_UMITEM) // MPG - 06/02/2018
         nQtdAux := M->ED8_QTD * M->ED8_PESO
	  Else
   	     nQtdAux := AVTransUnid(M->ED8_UMNCM,ED4->ED4_UMITEM,ED4->ED4_ITEM,M->ED8_QTDNCM,.F.)
	  EndIf
   EndIf  
   
   If ED0->ED0_TIPOAC <> GENERICO .Or. ED4->ED4_NCM <> NCM_GENERICA 
      If ED4->ED4_QT_LI < nQtdAux  
         If !lManutNFAuto
            cMsg += STR0018 + ENTER
         Else
            EasyHelp(STR0018,STR0008) //"Quantidade da LI inferior a quantidade a dar baixa.","Aviso"
         EndIf
         lRet := .F.
      EndIf
   EndIf
   
   If ED4->ED4_QT_DI < nQtdAux 
      If !lManutNFAuto
         cMsg += STR0019 + ENTER
      Else 
         EasyHelp(STR0019,STR0008) //"Quantidade da DI inferior a quantidade a dar baixa.","Aviso"
      EndIf
      lRet := .F.
   Endif
   				   
   nPesoAux:=IIf( AvVldUn(ED4->ED4_UMNCM) ,M->ED8_QTD * M->ED8_PESO,M->ED8_QTDNCM) // MPG - 06/02/2018
   If ED4->ED4_SNCMLI < nPesoAux
      If !lManutNFAuto
	     cMsg += STR0020 + ENTER
      Else
         EasyHelp(STR0020,STR0008) //"Saldo da LI inferior a quantidade a dar baixa.","Aviso"
      EndIf
      lRet := .F.
   EndIf  
   
   If ED4->ED4_SNCMDI < nPesoAux 
      If !lManutNFAuto
         cMsg += STR0021 + ENTER
      Else
         EasyHelp(STR0021,STR0008) //"Saldo da DI inferior a quantidade a dar baixa.","Aviso"
      EndIf         
      lRet := .F.
   EndIf  
   
   If lRet == .F. .And. !lManutNFAuto
      EECView(cMsg, STR0008) //"cMsg","Aviso"
   EndIf
      
   If (ED4->ED4_VL_LI < M->ED8_VALEMB) .And. !MsgYesNo(STR0022+Chr(13)+Chr(10)+; //"Não há saldo de valor suficiente para fazer esta comprovação. Deseja continuar?"
	  STR0023+Alltrim(TransForm(M->ED8_VALEMB,AvSX3("ED8_VALEMB",6)))+Chr(13)+Chr(10)+; //"Valor da Comprovação: US$ "
	  STR0024+AllTrim(TransForm(ED4->ED4_VL_LI,AvSX3("ED4_VL_LI",6)))) //"Saldo de Valor: US$ "    
   EndIf              
                                                                                      
RestOrd(aOrd,.T.)
Return lRet      

Return lRet