#INCLUDE "TBICONN.CH"
#INCLUDE "PCPA107.CH"
#INCLUDE "PROTHEUS.CH"

/*Variáveis utilizadas para controle dos erros.*/
Static cErro := ""
Static oError
/*-------------------------------------------------------------------------//
//Programa: A107JobC1
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Job para processamento de solicitacoes de compra - SC1
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//Parametros JOB:
//             [1]  - Numero do calculo de MRP
//             [2]  - Tipo de calculo MRP
//             [3]  - Array com os periodos
//             [4]  - Array com as perguntas
//             [5]  - String com tipos a serem processados
//             [6]  - String com grupos a serem processados
//             [7]  - Alias da tabela a ser processada
//             [8]  - Almoxarifado de (utilizado para filtro)
//             [9]  - Almoxarifado ate(utilizado para filtro)
//             [10] - Query para filtragem de produtos no SB1
//             [11] - Indica a existencia de P.E. na filtragem (SQL)
//             [12] - Opcional vazio
//             [13] - Revisao vazio
//             [14] - Indica se gera log
//             [15] - Considera pre req. - MV_MRPSCRE
//             [16] - Indica se filtra locais da tabela SOQNNR
//             [17] - Data final para filtras os dados
//Uso:      PCPA107
//-------------------------------------------------------------------------*/
Function A107JobC1(cEmp,cFil,aParamJob,nTentativa)
Local cQuery      := ""
Local cA710Fil    := ""
Local nRecno      := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[5]
Local cStrGrupo   := aParamJob[6]
Local cAliasTop   := AllTrim(aParamJob[7])
Local cAlmoxd     := aParamJob[8]
Local cAlmoxa     := aParamJob[9]
Local cQueryB1    := aParamJob[10]
Local lA710Sql    := aParamJob[11]
Local cOpc711Vaz  := aParamJob[12]
Local cRev711Vaz  := aParamJob[13]
Local lLogMRP     := aParamJob[14]
Local lConsPreRe  := aParamJob[15]
Local dDatFim     := aParamJob[17]
Local aEmpresas   := aParamJob[18]
Local cMsg        := ""

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[4]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[19]
PRIVATE aAlmoxNNR  := aParamJob[16]
PRIVATE aFilAlmox  := aParamJob[20]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobC1"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC1"+cEmp+cFil, "10" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso

   PutGlbValue("A107JobC1"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC1"+cEmp+cFil, "20" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Processando thread
   cMsg := STR0147+" A107JobC1 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT SC1.C1_FILIAL, " +;
                    " SC1.C1_PRODUTO, " +;
                    " SC1.C1_OP, " +;
                    " SC1.C1_DATPRF, " +;
                    " SC1.C1_NUM, " +;
                    " SC1.C1_ITEM, " +;
                    " SC1.C1_QUANT, " +;
                    " SC1.C1_QUJE, " +;
                    " SC1.C1_SEQMRP, " +;
                    " SC1.R_E_C_N_O_ C1REC " +;
               " FROM " + RetSqlName("SC1") + " SC1, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE ((SC1.C1_FILIAL  = '" + xFilial("SC1") + "' " +;
                " AND  (SC1.C1_FILENT  = '" + xFilial("SC1") + "' " +;
                "  OR   SC1.C1_FILENT  = '')) " +;
                "  OR  (SC1.C1_FILIAL <> '" + xFilial("SC1") + "' " +;
                " AND   SC1.C1_FILENT  = '" + xFilial("SC1") + "')) " +;
                " AND SC1.C1_LOCAL    >= '" + cAlmoxd + "' " +;
                " AND SC1.C1_LOCAL    <= '" + cAlmoxa + "' " +;
                " AND SC1.C1_RESIDUO   = '" + CriaVar("C1_RESIDUO",.F.) + "' " +;
                " AND SC1.C1_DATPRF   <= '" + Dtos(dDatFim) + "' " +;
                " AND SC1.C1_QUANT     > SC1.C1_QUJE " +;
                " AND SC1.D_E_L_E_T_   = ' ' " +;
                " AND SC1.C1_PRODUTO   = SB1.B1_COD "

   If !lConsPreRe
      cQuery += "AND SC1.C1_ORIGEM <> 'MATA106' "
   EndIf

   If aAlmoxNNR # Nil
      cQuery += " AND SC1.C1_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "
   EndIf

   cQuery += cQueryB1

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC1", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   Endif

   cQuery += " ORDER BY " + SqlOrder(SC1->(IndexKey(2)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SC1->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

   dbSelectArea(cAliasTop)

   While !Eof()
      nRecno := C1REC

      //Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
      A107CriaLOG("006",C1_PRODUTO,{C1_DATPRF,C1_NUM,C1_ITEM,"SC1"},lLogMRP,c711NumMRP)

      //Marca o semaforo
      PCPA107LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil(C1_DATPRF,aPergs711),C1_PRODUTO,cOpc711Vaz,cRev711Vaz,"SC1",nRecno,C1_NUM,C1_ITEM,C1_OP,Max(0,C1_QUANT-C1_QUJE),"2",.F.,/*13*/,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC1"+cEmp+cFil, "30" )
   PutGlbValue("A107JobC1"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobC1 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf
//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobC1"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobC1 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobC7
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Job para processamento de pedidos de compra - SC7
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//Parametros JOB:
//             [1]  - Numero do calculo de MRP
//             [2]  - Tipo de calculo MRP
//             [3]  - Array com os periodos
//             [4]  - Array com as perguntas
//             [5]  - String com tipos a serem processados
//             [6]  - String com grupos a serem processados
//             [7]  - Alias da tabela a ser processada
//             [8]  - Almoxarifado de (utilizado para filtro)
//             [9]  - Almoxarifado ate(utilizado para filtro)
//             [10] - Query para filtragem de produtos no SB1
//             [11] - Indica a existencia de P.E. na filtragem (SQL)
//             [12] - Opcional vazio
//             [13] - Revisao vazio
//             [14] - Indica se gera log
//             [15] - Indica se filtra locais da tabela SOQNNR
//             [16] - Data final para filtras os dados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobC7(cEmp,cFil,aParamJob,nTentativa)
Local cQuery      := ""
Local cA710Fil    := ""
Local nRecno      := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[5]
Local cStrGrupo   := aParamJob[6]
Local cAliasTop   := AllTrim(aParamJob[7])
Local cAlmoxd     := aParamJob[8]
Local cAlmoxa     := aParamJob[9]
Local cQueryB1    := aParamJob[10]
Local lA710Sql    := aParamJob[11]
Local cOpc711Vaz  := aParamJob[12]
Local cRev711Vaz  := aParamJob[13]
Local lLogMRP     := aParamJob[14]
Local dDatFim     := aParamJob[16]
Local aEmpresas   := aParamJob[17]
Local cMsg        := ""
//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[4]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[18]
PRIVATE aAlmoxNNR  := aParamJob[15]
PRIVATE aFilAlmox  := aParamJob[19]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobC7"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC7"+cEmp+cFil, "10" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobC7"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC7"+cEmp+cFil, "20" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Processando thread
   cMsg := STR0147+" A107JobC7 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Iniciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   cQuery := " SELECT SC7.C7_FILIAL, " +;
                    " SC7.C7_PRODUTO, " +;
                    " SC7.C7_OP, " +;
                    " SC7.C7_DATPRF, " +;
                    " SC7.C7_NUM, " +;
                    " SC7.C7_ITEM, " +;
                    " SC7.C7_QUANT, " +;
                    " SC7.C7_QUJE, " +;
                    " SC7.R_E_C_N_O_ C7REC " +;
               " FROM " + RetSqlName("SC7")+ " SC7, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE ((SC7.C7_FILIAL  = '" + xFilial("SC7") + "' " +;
                " AND  (SC7.C7_FILENT  = '" + xFilial("SC7") + "' " +;
                "  OR   SC7.C7_FILENT  = '')) " +;
                "  OR  (SC7.C7_FILIAL <> '" + xFilial("SC7") + "' " +;
                " AND   SC7.C7_FILENT  = '" + xFilial("SC7") + "')) " +;
                " AND SC7.C7_LOCAL    >= '" + cAlmoxd + "' " +;
                " AND SC7.C7_LOCAL    <= '" + cAlmoxa + "' " +;
                " AND SC7.C7_DATPRF   <= '" + Dtos(dDatFim) + "' " +;
                " AND SC7.C7_QUJE      < SC7.C7_QUANT " +;
                " AND SC7.C7_RESIDUO   = '" + CriaVar("C7_RESIDUO", .F.) + "' " +;
                " AND SC7.D_E_L_E_T_   = ' ' " +;
                " AND SC7.C7_PRODUTO   = SB1.B1_COD "

   If aAlmoxNNR # Nil
      cQuery += " AND SC7.C7_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR  "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "
   EndIf

   cQuery += cQueryB1

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC7", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   EndIf

   cQuery += " ORDER BY " + SqlOrder(SC7->(IndexKey(2)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SC7->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

   dbSelectArea(cAliasTop)
   While !Eof()
      nRecno := C7REC

      //Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
      A107CriaLOG("006",C7_PRODUTO,{C7_DATPRF,C7_NUM,C7_ITEM,"SC7"},lLogMRP,c711NumMRP)

      //Marca o semaforo
      PCPA107LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil(C7_DATPRF,aPergs711),C7_PRODUTO,cOpc711Vaz,cRev711Vaz,"SC7",nRecno,C7_NUM,C7_ITEM,C7_OP,Max(0,C7_QUANT-C7_QUJE),"2",.F.,/*13*/,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151 + " A107JobC7.") //"Erro ao efetuar o processamento do JOB A107JobC7."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC7"+cEmp+cFil, "30" )
   PutGlbValue("A107JobC7"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobC7 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobC7"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobC7 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobIni
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Funcao utilizada para carregar os registros de saldo inicial
//Parametros:  01.cEmp         - Empresa
//             02.cFil         - Filial
//             03.aProdutos    - Array com os itens a serem calculados
//             04.cThread      - Numero da Thread em execucao
//             05.aBkPeriodos  - Array contendo os periodos a processar
//             06.aBkPergs711  - Array contendo as perguntas selecionadas
//             07.c711BkNumMrp - Numero do MRP
//             08.cStrTipo     - String dos tipos de itens
//             09.cStrGrupo    - String com os grupos de itens
//             10.cTxtEstSeg   - Mensagem do estoque de segunranca
//             11.cRev711Vaz   - Revisão vazio
//             12.lExistBB1    - Indica se existe BB1
//             13.lExistBB2    - Indica se existe BB2
//             14.lM710NOPC    - Indica se usa opcional
//             15.lLogMRP      - Indica se o log do mrp está ligado
//             16.cTxtPontPed  - Ponto de pedido
//             17.aAlmoxNNRl   - Array com os locais selecionados
//             18.nBkTipo      - Tipo de periodo
//             19.aPicture     - Array com as pictures
//             20.cSelOpc      - Indica o valor do parâmetro MV_SELEOPC
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobIni(cEmp,cFil,aProdutos,cThread,aBkPeriodos,aBkPergs711,c711BkNumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,cRev711Vaz,lExistBB1,lExistBB2,lM710NOPC,lLogMRP,cTxtPontPed,aAlmoxNNRl,nBkTipo,aPicture,cSelOpc,aEmpresas,nUsed)
Local nX          := 0
Local nz          := 0
Local nSaldo      := 0
Local nEstSeg     := 0
Local nQtdAviso   := 0
Local cMsgAviso   := ""
Local nPontoPed   := 0
Local nQtdPontP   := 0
Local cMsgPontP   := ""
Local cRevisao    := ""
Local aOpc        := {}
Local cHora

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

//Carrega Variaveis Private
Private aPeriodos    := aBkPeriodos
Private aPergs711    := aBkPergs711
Private aAlmoxNNR    := aAlmoxNNRl
Private aFilAlmox    := Nil
Private cAlmoxd      := aPergs711[8]
Private cAlmoxa      := aPergs711[9]
Private c711NumMrp   := c711BkNumMrp
Private cMT710B2     := Nil
Private cAliasSOR    := "SOR"
Private cAliasSOT    := "SOT"
Private cPictLOCAL   := aPicture[1]
Private cPictQATU    := aPicture[2]
Private cPictQNPT    := aPicture[3]
Private cPictQTNP    := aPicture[4]
Private cPictQTDE    := aPicture[5]
Private cPictSALDO   := aPicture[6]
PRIVATE cPictB2Local := aPicture[1]
PRIVATE cPictB2Qatu  := aPicture[2]
PRIVATE cPictB2QNPT  := aPicture[3]
PRIVATE cPictB2QTNP  := aPicture[4]
PRIVATE cPictD7QTDE  := aPicture[5]
PRIVATE cPictDDSaldo := aPicture[6]
Private nTipo        := nBkTipo
Private lVerSldSOR   := .T.
Private nUsado       := nUsed

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("c107P"+cEmp+cFil+cThread, "1" )
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("c107P"+cEmp+cFil+cThread, "10" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'EST')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("c107P"+cEmp+cFil+cThread, "2" )
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut("Erro ao efetuar a conexão.")
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("c107P"+cEmp+cFil+cThread, "20" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   ConOut(dtoc(Date())+" "+Time()+" "+"PCPA107: Iniciando job Saldo Inicial. Empresa '"+cEmp+"', Filial '"+cFil+"'.")
   //Processamento
   dbSelectArea("SB1")
   SB1->(dbSetOrder(1))
   For nX :=1 To Len(aProdutos)
      If SB1->(dbSeek(xFilial("SB1")+aProdutos[nX]))
         If lExistBB1
            aFilAlmox := RetExecBlock("A710FILALM",{SB1->B1_COD,cAlmoxd,cAlmoxa},"A",Nil,Nil,Nil,lExistBB1)
         EndIf
         If lExistBB2
            cMT710B2 := RetExecBlock("MT710B2",{SB1->B1_COD,cAlmoxd,cAlmoxa},"C", Nil,Nil,Nil,lExistBB2)
         EndIf

         If ValType(aFilAlmox) == "A" .And. aScan(aFilAlmox, {|z| ValType(z) # "C"}) > 0
            aFilAlmox := Nil
         EndIf

         //Inicializa variaveis de saldo
         nSaldo   := 0
         nEstSeg:= 0

         //Obtem saldo e estoque de seguranca
         A107DSaldo(SB1->B1_COD,@nSaldo,@aFilAlmox,/*04*/,/*05*/,@nEstSeg,"SB1",aEmpresas,.F.)

         //Ponto de Entrada MA710NOPC para indicar saldo por opcional
         If lM710NOPC
            aOpc := ExecBlock('M710NOPC',.F.,.F.,{SB1->B1_COD,nSaldo})
            If ValType(aOpc) == 'A'
               For nz := 1 to Len(aOpc)
                  //Avalia o LOG do MRP para o evento 001 - Saldo em estoque inicial menor que zero
                  A107CriaLOG("001",SB1->B1_COD,{aOPc[nz,2]},lLogMRP,c711NumMrp)
                  cRevisao := If(A107TrataRev() .And. Len(aOpc[nz]) >= 3, aOpc[nz, 3], cRev711Vaz)
                  A107CriSOR(SB1->B1_COD,/*02*/,cRevisao,/*04*/,"001",aOPc[nz,2],"1","SB1",/*09*/,cStrTipo,cStrGrupo,.F.,aOPc[nz,1],/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
               Next nz
            Else
               //Avalia o LOG do MRP para o evento 001 - Saldo em estoque inicial menor que zero
               A107CriaLOG("001",SB1->B1_COD,{nSaldo},lLogMRP,c711NumMrp)
               A107CriSOR(SB1->B1_COD,IIF(cSelOpc == 'S',SB1->B1_OPC,CriaVar("B1_OPC")),cRev711Vaz,/*04*/,"001",nSaldo,"1","SB1",/*09*/,cStrTipo,cStrGrupo,.F.,IIF(cSelOpc == 'S',SB1->B1_MOPC,CriaVar("B1_MOPC")),/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
            EndIf
         Else
            // Avalia o LOG do MRP para o evento 001 - Saldo em estoque inicial menor que zero
            A107CriaLOG("001",SB1->B1_COD,{nSaldo},lLogMRP,c711NumMrp)
            A107CriSOR(SB1->B1_COD,IIF(cSelOpc == 'S',SB1->B1_OPC,CriaVar("B1_OPC")),cRev711Vaz,/*04*/,"001",nSaldo,"1","SB1",.T.,cStrTipo,cStrGrupo,.F.,IIF(cSelOpc == 'S',SB1->B1_MOPC,CriaVar("B1_MOPC")),/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
         EndIf
      EndIf
   Next nX
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("c107P"+cEmp+cFil+cThread, "30" )
  PutGlbValue("c107P"+cEmp+cFil+cThread+"ERRO", cErro )
  GlbUnLock()
  Return
EndIf

ConOut(dtoc(Date())+" "+Time()+" "+"PCPA107: Termino job Saldo Inicial. Empresa '"+cEmp+"', Filial '"+cFil+"'.")

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("c107P"+cEmp+cFil+cThread,"3")
GlbUnLock()

Return

/*------------------------------------------------------------------------//
//Programa: A107JobC2
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Job para processamento de ordens de producao - SC2
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//             lUsaMOpc - Parâmetro de utilização de opcionais
//Parametros JOB:
//             [1]  - Numero do calculo de MRP
//             [2]  - Tipo de calculo MRP
//             [3]  - Array com os periodos
//             [4]  - String com tipos a serem processados
//             [5]  - String com grupos a serem processados
//             [6]  - Alias da tabela a ser processada
//             [7]  - Almoxarifado de (utilizado para filtro)
//             [8]  - Almoxarifado ate(utilizado para filtro)
//             [9]  - Query para filtragem de produtos no SB1
//             [10] - Indica a existencia de P.E. na filtragem (SQL)
//             [11] - Indica se considera OPs suspensas
//             [12] - Indica se considera OPs sacramentadas
//             [13] - Indica se gera log
//             [14] - Array com as perguntas
//             [15] - Indica se filtra locais da tabela SOQNNR
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobC2(cEmp,cFil,aParamJob,nTentativa,lUsaMOpc)
Local cQuery      := ""
Local cA710Fil    := ""
Local mOpc        := ""
Local cOpc        := ""
Local nRecno      := 0
Local lPerdInf    := .F.
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[4]
Local cStrGrupo   := aParamJob[5]
Local cAliasTop   := AllTrim(aParamJob[6])
Local cAlmoxd     := aParamJob[7]
Local cAlmoxa     := aParamJob[8]
Local cQueryB1    := aParamJob[9]
Local lA710Sql    := aParamJob[10]
Local lConsSusp   := aParamJob[11]
Local lConsSacr   := aParamJob[12]
Local lLogMRP     := aParamJob[13]
Local dDatFim     := aParamJob[16]
Local aEmpresas   := aParamJob[17]
Local cMsg        := ""


Local aAreaC2     := {}

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[14]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[18]
PRIVATE aAlmoxNNR  := aParamJob[15]
PRIVATE aFilAlmox  := aParamJob[19]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobC2"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107JobC2"+cEmp+cFil, "10" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv( cEmp, cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   PRIVATE lMopcGRV		:= SuperGetMv("MV_MOPCGRV",.F.,.F.) // Parametro criado para definir se gravas os opcionais somente no Produto Pai ( Seq pai igual a branco/vazio).
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobC2"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0152) //"Erro ao efetuar a conexão."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107JobC2"+cEmp+cFil, "20" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   //Processando thread
   cMsg := STR0147+" A107JobC2 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT SC2.C2_FILIAL, " +;
                    " SC2.C2_DATRF, " +;
                    " SC2.C2_LOCAL, " +;
                    " SC2.C2_PRODUTO, " +;
                    " SC2.C2_STATUS, " +;
                    " SC2.C2_DATPRF, " +;
                    " SC2.C2_OPC, " +;
                    " SC2.C2_NUM, " +;
                    " SC2.C2_ITEM, " +;
                    " SC2.C2_SEQUEN, " +;
                    " SC2.C2_ITEMGRD, " +;
                    " SC2.C2_PEDIDO, " +;
                    " SC2.C2_ITEMPV, " +;
                    " SC2.C2_QUANT, " +;
                    " SC2.C2_QUJE, " +;
                    " SC2.C2_PERDA, " +;
                    " SC2.C2_REVISAO, " +;
                    " SC2.R_E_C_N_O_ C2REC " +;
               " FROM " + RetSqlName("SC2")+" SC2, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE SC2.C2_FILIAL  = '" + xFilial("SC2") + "' " +;
                " AND SC2.C2_DATRF   = '" + Space(Len(DTOS(SC2->C2_DATRF))) + "' " +;
                " AND SC2.C2_LOCAL  >= '" + cAlmoxd + "' " +;
                " AND SC2.C2_LOCAL  <= '" + cAlmoxa + "' " +;
                " AND SC2.C2_DATPRF <= '" + Dtos(dDatFim) + "' " +;
                " AND SC2.D_E_L_E_T_ = ' ' " +;
                " AND SC2.C2_PRODUTO = SB1.B1_COD "

   //Inclui condicao se nao considera OPs Suspensas
   If !lConsSusp
      cQuery += " AND SC2.C2_STATUS <> 'U' "
   EndIf

   //Inclui condicao se nao considera OPs Sacramentadas
   If !lConsSacr
      cQuery += " AND SC2.C2_STATUS <> 'S' "
   EndIf

   If aAlmoxNNR # Nil
      cQuery += " AND SC2.C2_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "

   EndIf

   cQuery += cQueryB1

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC2", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   Endif

   cQuery += " ORDER BY " + SqlOrder(SC2->(IndexKey(2)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SC2->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})

   dbSelectArea(cAliasTop)

   lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)

   While !Eof()
      nRecno := C2REC

      //Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
      A107CriaLOG("006",C2_PRODUTO,{C2_DATPRF,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,"","SC2"},lLogMRP,c711NumMRP)

      SC2->(DbGoTo(nRecno))

      if ! lMopcGRV
         cOpc := SC2->C2_OPC
         mOpc := SC2->C2_MOPC
      Else
         If !Empty(SC2->C2_SEQPAI) .AND. (SC2->C2_SEQPAI) <> '000'
            aAreaC2 := SC2->(GetArea())
            SC2->(DbSetOrder(1))
            If dbSeek(xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM)
               mOpc := SC2->C2_MOPC
            EndIf
            SC2->(RestArea(aAreaC2))
         Else
            mOpc := SC2->C2_MOPC
         EndIf
      EndIf

      //Marca o semaforo
      PCPA107LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil(C2_DATPRF,aPergs711),C2_PRODUTO,cOpc,C2_REVISAO,"SC2",nRecno,C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD,/*08*/,If(!Empty(C2_PEDIDO),C2_PEDIDO+"/"+C2_ITEMPV,""),Max(0,C2_QUANT-C2_QUJE-If(lPerdInf,0,C2_PERDA)),"2",.F.,.T.,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,mOpc,/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC2"+cEmp+cFil, "30" )
   PutGlbValue("A107JobC2"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobC7 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobC2"+cEmp+cFil,"3")
GlbUnLock()
cMsg := STR0148+" A107JobC7 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
Return

/*------------------------------------------------------------------------//
//Programa: A107JobD4
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Job para processamento de empenhos - SD4
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//Parametros JOB:
//             [1]  - Numero do calculo de MRP
//             [2]  - Tipo de calculo MRP
//             [3]  - Array com os periodos
//             [4]  - Array com as perguntas
//             [5]  - String com tipos a serem processados
//             [6]  - String com grupos a serem processados
//             [7]  - Alias da tabela a ser processada
//             [8]  - Almoxarifado de (utilizado para filtro)
//             [9]  - Almoxarifado ate(utilizado para filtro)
//             [10] - Query para filtragem de produtos no SB1
//             [11] - Indica a existencia de P.E. na filtragem (SQL)
//             [12] - Revisao vazio
//             [13] - Indica se gera log
//             [14] - Indica se filtra locais da tabela SOQNNR
//             [15] - Array de grupos selecionados em tela
//             [16] - Valor do parâemtro MV_MRPCINQ
//             [17] - Data final para filtras os dados
//Uso:      PCPA104
//------------------------------------------------------------------------*/
Function A107JobD4(cEmp,cFil,aParamJob,nTentativa)
Local cQuery      := ""
Local cTmp        := ""
Local nRecno      := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[5]
Local cStrGrupo   := aParamJob[6]
Local cAliasTop   := AllTrim(aParamJob[7])
Local cAlmoxd     := aParamJob[8]
Local cAlmoxa     := aParamJob[9]
Local cQueryB1    := aParamJob[10]
Local lA710Sql    := aParamJob[11]
Local cRev711Vaz  := aParamJob[12]
Local lLogMRP     := aParamJob[13]
Local A711Grupo   := aParamJob[15]
Local lMRPCINQ    := aParamJob[16]
Local dDatFim     := aParamJob[17]
Local aEmpresas   := aParamJob[18]
Local lAllGrp     := Ascan(A711Grupo,{|x| x[1] == .F.}) == 0
Local cMsg        := ""
Local oTeste

Local aAreaC2 := {}

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[4]
PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[19]
PRIVATE aAlmoxNNR  := aParamJob[14]
PRIVATE aFilAlmox  := aParamJob[20]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobD4"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107JobD4"+cEmp+cFil, "10" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   PRIVATE lMopcGRV		:= SuperGetMv("MV_MOPCGRV",.F.,.F.) // Parametro criado para definir se gravas os opcionais somente no Produto Pai ( Seq pai igual a branco/vazio).
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobD4"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0152) //"Erro ao efetuar a conexão."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107JobD4"+cEmp+cFil, "20" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   //"Processando thread"
   cMsg := STR0147+" A107JobD4 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT SD4.D4_FILIAL, "
   cQuery +=        " SD4.D4_COD, "
   cQuery +=        " SD4.D4_OP, "
   cQuery +=        " SD4.D4_OPORIG, "
   cQuery +=        " SD4.D4_DATA, "
   cQuery +=        " SD4.D4_TRT, "
   cQuery +=        " SD4.D4_QUANT, "
   cQuery +=        " SB1.B1_GRUPO, "
   cQuery +=        " SD4.R_E_C_N_O_ D4REC "
   cQuery +=   " FROM " + RetSqlName("SD4")+" SD4, " + RetSqlName("SB1")+" SB1 "
   cQuery +=  " WHERE SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
   cQuery +=    " AND SD4.D4_QUANT  <> 0 "
   cQuery +=    " AND SD4.D4_LOCAL  >= '" + cAlmoxd + "' "
   cQuery +=    " AND SD4.D4_LOCAL  <= '" + cAlmoxa + "' "
   cQuery +=    " AND SD4.D4_DATA   <= '" + Dtos(dDatFim) + "' "
   cQuery +=    " AND SD4.D_E_L_E_T_ = ' ' "
   cQuery +=    " AND SD4.D4_COD     = SB1.B1_COD "

   If !(aPergs711[13]==1)
      cQuery += " AND (SD4.D4_QUANT-SD4.D4_QSUSP) <> 0 "
   EndIf

   If aAlmoxNNR # Nil
      cQuery += " AND SD4.D4_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "

   EndIf

   cQuery += cQueryB1

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"SD4", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   Endif

   cQuery += " ORDER BY " + SqlOrder(SD4->(IndexKey(1)))
   cQuery := ChangeQuery(cQuery)

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SD4->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
   dbSelectArea(cAliasTop)

   While !(cAliasTop)->(Eof())
      If (!lAllGrp .And. !lMRPCINQ .And. !(cAliasTop)->B1_GRUPO $ cStrGrupo)
         dbSkip()
         Loop
      Else
         nRecno := (cAliasTop)->(D4REC)
      EndIf

      //Posiciona na OP geradora do EMPENHO
      If !Empty((cAliasTop)->D4_OPORIG)
         SC2->(dbSetOrder(1))
         SC2->(dbSeek(xFilial("SC2")+(cAliasTop)->D4_OPORIG))
      Else
         SC2->(dbSetOrder(1))
         SC2->(dbSeek(xFilial("SC2")+(cAliasTop)->D4_OP))
      EndIf
      dbSelectArea(cAliasTop)

      //Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso em atraso
      A107CriaLOG("006",(cAliasTop)->(D4_COD),{(cAliasTop)->(D4_DATA),(cAliasTop)->(D4_OP),(cAliasTop)->(D4_TRT),"SD4"},lLogMRP,c711NumMRP)

      If lMopcGRV
         mOpc := ''
         If !Empty(SC2->C2_SEQPAI) .AND. (SC2->C2_SEQPAI) <> '000'
            aAreaC2 := SC2->(GetArea())
            SC2->(DbSetOrder(1))
            If dbSeek(xFilial("SC2")+SC2->C2_NUM+SC2->C2_ITEM)
               mOpc := SC2->C2_MOPC
            EndIf
            SC2->(RestArea(aAreaC2))
         Else
            mOpc := SC2->C2_MOPC
         EndIf
      Endif

      //Marca o semaforo
      PCPA104LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil((cAliasTop)->(D4_DATA),aPergs711),(cAliasTop)->(D4_COD),/*03*/,If(!Empty((cAliasTop)->(D4_OPORIG)) .And. !(SC2->(Eof())),SC2->C2_REVISAO,cRev711Vaz),If((cAliasTop)->(D4_QUANT)>0,"SD4","ENG"),nRecno,(cAliasTop)->(D4_OP),/*08*/,(cAliasTop)->(D4_OP),Abs((cAliasTop)->(D4_QUANT)),If((cAliasTop)->(D4_QUANT)>0,"3","2"),.F.,.T.,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,IIF(lMopcGRV,cMopc,SC2->C2_MOPC),/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
      If ValType(oError) != "U"
         Exit
      EndIf
   End

   dbSelectArea(cAliasTop)
   //dbCloseArea()

END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobD4"+cEmp+cFil, "30" )
   PutGlbValue("A107JobD4"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobD4 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobD4"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobD4 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
Return

/*------------------------------------------------------------------------//
//Programa: A107JobC6
//Autor:    Lucas Konrad França
//Data:     13/11/2014
//Descricao:   Job para processamento de pedidos de venda - SC6
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//             lUsaMOpc - Parâmetro de utilização de opcionais
//Parametros JOB:
//             [1]  - Numero do calculo de MRP
//             [2]  - Tipo de calculo MRP
//             [3]  - Array com os periodos
//             [4]  - Array com as perguntas
//             [5]  - String com tipos a serem processados
//             [6]  - String com grupos a serem processados
//             [7]  - Alias da tabela a ser processada
//             [8]  - Almoxarifado de (utilizado para filtro)
//             [9]  - Almoxarifado ate(utilizado para filtro)
//             [10] - Query para filtragem de produtos no SB1
//             [11] - Indica a existencia de P.E. na filtragem (SQL)
//             [12] - Considera pedido de venda bloqueado credito
//             [13] - Dados para bloqueio 1
//             [14] - Dados para bloqueio 2
//             [15] - Indica se processa dados do SC4
//             [16] - Revisao vazio
//             [17] - Indica se gera log
//             [18] - Indica se considera pedidos de venda no MRP
//             [19] - Indica se filtra locais da tabela SOQNNR
//             [20] - Data final para filtras os dados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobC6(cEmp,cFil,aParamJob,nTentativa,lUsaMOpc)
Local cQuery      := ""
Local cA710Fil    := ""
Local mOpc        := ""
Local nRecno      := 0
Local i           := 0
Local aPedidosAc  := {{}}
Local nAchouPed   := 0
Local nQtdPed     := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[5]
Local cStrGrupo   := aParamJob[6]
Local cAliasTop   := AllTrim(aParamJob[7])
Local cAlmoxd     := aParamJob[8]
Local cAlmoxa     := aParamJob[9]
Local cQueryB1    := aParamJob[10]
Local lA710Sql    := aParamJob[11]
Local lPedBloc    := aParamJob[12]
Local cComp1      := aParamJob[13]
Local cComp2      := aParamJob[14]
Local lProcSC4    := aParamJob[15]
Local cRev711Vaz  := aParamJob[16]
Local lLogMRP     := aParamJob[17]
Local lCarteira   := aParamJob[18]
Local dDatFim     := aParamJob[20]
Local aEmpresas   := aParamJob[21]
Local cMsg        := ""
Local cQueryDef   := ""
Local lValido     := .T.

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[4]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[22]
PRIVATE aAlmoxNNR  := aParamJob[19]
PRIVATE aFilAlmox  := aParamJob[23]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobC6"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC6"+cEmp+cFil, "10" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobC6"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC6"+cEmp+cFil, "20" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //"Processando thread"
   cMsg := STR0147+" A107JobC6 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT SC6.C6_BLQ, "
   cQuery +=        " SC6.C6_ITEM, "
   cQuery +=        " SC6.C6_FILIAL, "
   cQuery +=        " SC6.C6_QTDVEN, "
   cQuery +=        " SC6.C6_QTDENT, "
   cQuery +=        " SC6.C6_LOCAL, "
   cQuery +=        " SC6.C6_PRODUTO, "
   cQuery +=        " SC6.C6_TES, "
   cQuery +=        " SC6.C6_ENTREG, "
   cQuery +=        " SC6.C6_NUM, "
   cQuery +=        " SC6.C6_OP, "
   cQuery +=        " SC6.C6_OPC, "
   cQuery +=        " SC6.C6_REVISAO, "
   cQuery +=        " SC6.C6_DATFAT, "
   cQuery +=        " SC6.R_E_C_N_O_ C6REC "
   cQuery +=   " FROM " + RetSqlName("SC6") + " SC6, " + RetSqlName("SB1") + " SB1," + RetSqlName("SF4") + " SF4 "
   cQuery +=  " WHERE SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
   cQuery +=    " AND SC6.C6_LOCAL  >= '" + cAlmoxd + "' "
   cQuery +=    " AND SC6.C6_LOCAL  <= '" + cAlmoxa + "' "
   cQuery +=    " AND (SC6.C6_BLQ    = '" + cComp1 + "' "
   cQuery +=    "  OR  SC6.C6_BLQ    = '" + cComp2 + "') "
   cQuery +=    " AND SC6.D_E_L_E_T_ = ' ' "
   cQuery +=    " AND SC6.C6_PRODUTO = SB1.B1_COD "
   cQuery +=    " AND SF4.F4_FILIAL  = '" + xFilial("SF4") + "' "
   cQuery +=    " AND SF4.F4_CODIGO  = SC6.C6_TES "
   cQuery +=    " AND SF4.F4_ESTOQUE = 'S' "
   cQuery +=    " AND SF4.D_E_L_E_T_ = ' ' "

   If !lPedBloc
      cQuery += " AND SC6.C6_OP <> '02' "
   EndIf

   If aAlmoxNNR # Nil
      cQuery += " AND SC6.C6_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "

   EndIf

   cQuery += cQueryB1

   cQueryDef := cQuery

   cQuery += " AND SC6.C6_QTDENT < SC6.C6_QTDVEN "

   If lCarteira
      cQuery += " AND SC6.C6_ENTREG <= '" + Dtos(dDatFim) + "' "
   Else
      If !Empty(aPergs711[5]) .And. !Empty(aPergs711[6])
         cQuery += "AND (SC6.C6_ENTREG >= '"+Dtos(aPergs711[5])+"' AND SC6.C6_ENTREG <= '"+Iif(aPergs711[6]<dDatFim,Dtos(aPergs711[6]),Dtos(dDatFim))+"')"
      ElseIf Empty(aPergs711[5]) .And. !Empty(aPergs711[6])
         cQuery += "AND SC6.C6_ENTREG <= '"+Iif(aPergs711[6]<dDatFim,Dtos(aPergs711[6]),Dtos(dDatFim))+"'"
      ElseIf !Empty(aPergs711[5]) .And. Empty(aPergs711[6])
         cQuery += "AND (SC6.C6_ENTREG >= '"+Dtos(aPergs711[5])+"' AND SC6.C6_ENTREG <= '"+Dtos(dDatFim)+"')"
      Else
         cQuery += "AND SC6.C6_ENTREG <= '"+Dtos(dDatFim)+"'"
      EndIf
   EndIf

   If aPergs711[30] == 1
      cQuery += "UNION"
      cQuery += cQueryDef

      If !Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
         cQuery += "AND (SC6.C6_DATFAT >= '"+Dtos(aPergs711[33])+"' AND SC6.C6_DATFAT <= '"+Iif(aPergs711[34]<dDatFim,Dtos(aPergs711[34]),Dtos(dDatFim))+"')"
      ElseIf Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
         cQuery += "AND SC6.C6_DATFAT <= '"+Iif(aPergs711[34]<dDatFim,Dtos(aPergs711[34]),Dtos(dDatFim))+"'"
      ElseIf !Empty(aPergs711[33]) .And. Empty(aPergs711[34])
         cQuery += "AND (SC6.C6_DATFAT >= '"+Dtos(aPergs711[33])+"' AND SC6.C6_DATFAT <= '"+Dtos(dDatFim)+"')"
      Else
         cQuery += "AND SC6.C6_DATFAT <= '"+Dtos(dDatFim)+"'"
      EndIf

      cQuery += " AND SC6.C6_QTDENT = SC6.C6_QTDVEN "

   EndIf

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC6", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   Endif

   cQuery += " ORDER BY " + SqlOrder(SC6->(IndexKey(2)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SC6->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
   dbSelectArea(cAliasTop)

   While !(cAliasTop)->(Eof())
      nRecno := C6REC

      //Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso em atraso
      If lCarteira .And. C6_QTDENT < C6_QTDVEN
         A107CriaLOG("006",C6_PRODUTO,{C6_ENTREG,C6_NUM,C6_ITEM,"SC6"},lLogMRP,c711NumMRP)

         SC6->(DbGoTo(nRecno))
         mOpc := SC6->C6_MOPC

         //Marca o semaforo
         PCPA107LCK(.T.)

         //Cria os registros nas tabelas
         A107CriSOQ(A107NextUtil(C6_ENTREG,aPergs711),C6_PRODUTO,C6_OPC,C6_REVISAO,"SC6",nRecno,C6_NUM,C6_ITEM,/*09*/,Max(0,C6_QTDVEN-C6_QTDENT),"3",.F.,.T.,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SC6->C6_MOPC,/*26*/,/*27*/,aEmpresas)

         //Libera semaforo
         UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
      EndIf

      dbSelectArea(cAliasTop)

      lValido := .T.
      If aPergs711[30] == 1
         If C6_QTDENT > 0
            If C6_QTDENT < C6_QTDVEN
               If !Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
                  If !((cAliasTop)->(C6_DATFAT) >= aPergs711[33] .And. (cAliasTop)->(C6_DATFAT) <= Iif(aPergs711[34]<dDatFim,aPergs711[34],dDatFim))
                     lValido := .F.
                  EndIf
               EndIf
               If !Empty(aPergs711[33]) .And. Empty(aPergs711[34])
                  If !((cAliasTop)->(C6_DATFAT) >= aPergs711[33] .And. (cAliasTop)->(C6_DATFAT) <= dDatFim)
                     lValido := .F.
                  EndIf
               EndIf
               If Empty(aPergs711[33]) .And. !Empty(aPergs711[34])
                  If !((cAliasTop)->(C6_DATFAT) <= Iif(aPergs711[34]<dDatFim,aPergs711[34],dDatFim))
                     lValido := .F.
                  EndIf
               EndIf
            EndIf
         Else
            lValido := .F.
         EndIf
      EndIf

      //Array utilizado na integracao com previsao de venda - Subtrai quantidade dos pedidos ja colocados
      If lProcSC4
         //Incrementa array com totais de pedidos por periodo
         If Len(aPedidosAc[Len(aPedidosAc)]) > 4095
            AADD(aPedidosAc,{})
         EndIf

         nQtdPed := 0

         If aPergs711[17] == 1 //Se subtrai os pedidos de venda colocados da previsão.
            nQtdPed += C6_QTDVEN-C6_QTDENT
         EndIf

         //Se subtrai os pedidos de venda faturados da previsão E
         //o pedido está em uma data válida para subtrair (parâmetros 33 e 34).
         If aPergs711[30] == 1 .And. lValido
            nQtdPed += C6_QTDENT
         EndIf

         SC6->(DbGoTo(nRecno))

         For i := 1 to Len(aPedidosAc)
            nAchouPed := ASCAN(aPedidosAc[i],{ |x| x[1] == C6_PRODUTO+Iif(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC) .And. x[2] == A650DTOPER(C6_ENTREG,aPeriodos,nTipo)})

            If nAchouPed != 0
               aPedidosAc[i,nAchouPed,3] += nQtdPed
               Exit
            EndIf
         Next i

         If nAchouPed ==0
            AADD(aPedidosAc[Len(aPedidosAc)],{C6_PRODUTO+Iif(Empty(SC6->C6_MOPC),SC6->C6_OPC,SC6->C6_MOPC),A650DTOPER(C6_ENTREG,aPeriodos,nTipo),nQtdPed})
         EndIf
      EndIf

      (cAliasTop)->(dbSkip())
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobC6"+cEmp+cFil, "30" )
   PutGlbValue("A107JobC6"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobC6 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//Processa em conjunto PREVISAO DE VENDAS
If lProcSC4
   cAliasTop := "BUSCASC4"
   A107JobC4(cEmp,cFil,{c711NumMRP,nTipo,aPeriodos,cStrTipo,cStrGrupo,cAliasTop,cAlmoxd,cAlmoxa,cQueryB1,ACLONE(aPergs711),.F.,aPedidosAC,cRev711Vaz,aAlmoxNNR,lA710Sql,dDatFim,aEmpresas,nUsado,aFilAlmox},nTentativa,lUsaMOpc)
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobC6"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobC6 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobAFJ
//Autor:    Lucas Konrad França
//Data:     14/11/2014
//Descricao:   Job para processamento de empenhos para projeto - AFJ
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//Parametros JOB:
//            [1]  - Numero do calculo de MRP
//            [2]  - Tipo de calculo MRP
//            [3]  - Array com os periodos
//            [4]  - String com tipos a serem processados
//            [5]  - String com grupos a serem processados
//            [6]  - Alias da tabela a ser processada
//            [7]  - Query para filtragem de produtos no SB1
//            [8]  - Indica a existencia de P.E. na filtragem (SQL)
//            [9]  - Opcional vazio
//            [10] - Revisao vazio
//            [11] - Indica se gera log
//            [12] - Array com as perguntas
//            [13] - Data final para filtras os dados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobAFJ(cEmp,cFil,aParamJob,nTentativa)
Local nRecno      := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[4]
Local cStrGrupo   := aParamJob[5]
Local cAliasTop   := AllTrim(aParamJob[6])
Local cQueryB1    := aParamJob[7]
Local lA710Sql    := aParamJob[8]
Local cOpc711Vaz  := aParamJob[9]
Local cRev711Vaz  := aParamJob[10]
Local lLogMRP     := aParamJob[11]
Local dDatFim     := aParamJob[13]
Local aEmpresas   := aParamJob[14]
Local cMsg        := ""

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[12]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[15]
PRIVATE aAlmoxNNR  := aParamJob[16]
PRIVATE aFilAlmox  := aParamJob[17]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobAFJ"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobAFJ"+cEmp+cFil, "10" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobAFJ"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobAFJ"+cEmp+cFil, "20" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //"Processando thread"
   cMsg := STR0147+" A107JobAFJ "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT AFJ.AFJ_FILIAL, " +;
                    " AFJ.AFJ_COD, " +;
                    " AFJ.AFJ_DATA, " +;
                    " AFJ.AFJ_PROJET, " +;
                    " AFJ.AFJ_QEMP, " +;
                    " AFJ.AFJ_QATU, " +;
                    " AFJ.R_E_C_N_O_ AFJREC" +;
               " FROM " + RetSqlName("AFJ") + " AFJ, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE AFJ.AFJ_FILIAL  = '" + xFilial("AFJ") + "' " +;
                " AND AFJ.AFJ_QATU    < AFJ.AFJ_QEMP " +;
                " AND AFJ.AFJ_DATA   <= '" + Dtos(dDatFim) + "' " +;
                " AND AFJ.D_E_L_E_T_  = ' ' " +;
                " AND AFJ.AFJ_COD     = SB1.B1_COD "
   cQuery += cQueryB1

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"AFJ", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   Endif

   cQuery += " ORDER BY " + SqlOrder(AFJ->(IndexKey(2)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(AFJ->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
   dbSelectArea(cAliasTop)

   While !Eof()
      nRecno := AFJREC

      //Avalia o LOG do MRP para o evento 006 - Documento planejado em atraso
      A107CriaLOG("006",AFJ_COD,{AFJ_DATA,AFJ_PROJET,"","AFJ"},lLogMRP,c711NumMRP)

      //Marca o semaforo
      PCPA107LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil(AFJ_DATA,aPergs711),AFJ_COD,cOpc711Vaz,cRev711Vaz,"AFJ",nRecno,AFJ_PROJET,/*08*/,/*09*/,AFJ_QEMP-AFJ_QATU,"3",.F.,/*13*/,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobAFJ"+cEmp+cFil, "30" )
   PutGlbValue("A107JobAFJ"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobAFJ "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobAFJ"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobAFJ "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobC4
//Autor:    Lucas Konrad França
//Data:     14/11/2014
//Descricao:   Job para processamento de previsoes de venda - SC4
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//             lUsaMOpc - Parâmetro de utilização de opcionais
//Parametros JOB:
//            [1]  - Numero do calculo de MRP
//            [2]  - Tipo de calculo MRP
//            [3]  - Array com os periodos
//            [4]  - String com tipos a serem processados
//            [5]  - String com grupos a serem processados
//            [6]  - Alias da tabela a ser processada
//            [7]  - Almoxarifado de (utilizado para filtro)
//            [8]  - Almoxarifado ate(utilizado para filtro)
//            [9]  - Query para filtragem de produtos no SB1
//            [10] - Array com perguntas utilizadas
//            [11] - Indica se a chamada ocorreu atraves de JOB
//            [12] - Array com dados dos pedidos existentes
//            [13] - Revisao vazio
//            [14] - Indica se filtra locais da tabela SOQNNR
//            [15] - Indica a existencia de P.E. na filtragem (SQL)
//            [16] - Data final para filtras os dados
//Uso:      P107JCTB
//          PCPA107
//------------------------------------------------------------------------*/
Function A107JobC4(cEmp,cFil,aParamJob,nTentativa,lUsaMOpc)
Local cQuery      := ""
Local cA710Fil    := ""
Local mOpc        := ""
Local nRecno      := 0
Local i           := 0
Local nAchouPed   := 0
Local nQuantPrev  := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[4]
Local cStrGrupo   := aParamJob[5]
Local cAliasTop   := AllTrim(aParamJob[6])
Local cAlmoxd     := aParamJob[7]
Local cAlmoxa     := aParamJob[8]
Local cQueryB1    := aParamJob[9]
Local lInJob      := aParamJob[11]
Local aPedidosAC  := aParamJob[12]
Local cRev711Vaz  := aParamJob[13]
Local lA710SQL    := aParamJob[15]
Local dDatFim     := aParamJob[16]
Local aEmpresas   := aParamJob[17]
Local cMsg        := ""

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[10]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[18]
PRIVATE aAlmoxNNR  := aParamJob[14]
PRIVATE aFilAlmox  := aParamJob[19]

// So inicializa ambiente se foi acionado por job
// So atualiza status de variavel global se foi acionado por job
If lInJob
   BEGIN SEQUENCE
      //STATUS 1 - Iniciando execucao do Job
      PutGlbValue("A107JobC4"+cEmp+cFil,"1")
      GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      ConOut(Replicate("-",65))
      ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
      ConOut(cErro)
      ConOut(Replicate("-",65))
      PutGlbValue("A107JobC4"+cEmp+cFil, "10" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
      //Seta job para nao consumir licensas
      RpcSetType(3)

      //Seta job para empresa filial desejada
      RpcSetEnv( cEmp, cFil,,,'PCP')
      PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
      //STATUS 2 - Conexao efetuada com sucesso
      PutGlbValue("A107JobC4"+cEmp+cFil,"2")
      GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      ConOut(Replicate("-",65))
      ConOut(STR0152) //"Erro ao efetuar a conexão."
      ConOut(cErro)
      ConOut(Replicate("-",65))
      PutGlbValue("A107JobC4"+cEmp+cFil, "20" )
      GlbUnLock()
      Return
   EndIf
EndIf

BEGIN SEQUENCE
   //"Processando thread"
   cMsg := STR0147+" A107JobC4 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT SC4.C4_FILIAL, " +;
                    " SC4.C4_QUANT, " +;
                    " SC4.C4_PRODUTO, " +;
                    " SC4.C4_DATA, " +;
                    " SC4.C4_OPC, " +;
                    " SC4.C4_REVISAO, " +;
                    " SC4.C4_DOC, " +;
                    " SC4.R_E_C_N_O_ C4REC " +;
               " FROM " + RetSqlName("SC4") + " SC4, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE SC4.C4_FILIAL  = '" + xFilial("SC4") + "' " +;
                " AND SC4.C4_DATA   >= '" + DTOS(aPergs711[05]) + "' " +;
                " AND SC4.C4_DATA   <= '" + DTOS(aPergs711[06]) + "' " +;
                " AND SC4.C4_LOCAL  >= '" + cAlmoxd + "' " +;
                " AND SC4.C4_LOCAL  <= '" + cAlmoxa + "' " +;
                " AND SC4.C4_DOC    >= '" + aPergs711[23] + "' " +;
                " AND SC4.C4_DOC    <= '" + aPergs711[24] + "' " +;
                " AND SC4.C4_DATA   <= '" + Dtos(dDatFim) + "' " +;
                " AND SC4.D_E_L_E_T_ = ' ' " +;
                " AND SC4.C4_PRODUTO = SB1.B1_COD "

   If aAlmoxNNR # Nil
      cQuery += " AND SC4.C4_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "

   EndIf

   cQuery += cQueryB1

   If lA710SQL
      cA710Fil := ExecBlock("A710SQL", .F., .F., {"SC4", cQuery})
      If ValType(cA710Fil) == "C"
         cQuery := cA710Fil
      Endif
   Endif

   cQuery += " ORDER BY " + SqlOrder(SC4->(IndexKey(1)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SC4->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
   dbSelectArea(cAliasTop)

   While !Eof()
      nRecno := C4REC

      //Quantidade Original da previsao de vendas
      nQuantPrev := C4_QUANT

      //Subtrai quantidade dos pedidos ja colocados ou faturados
      If aPergs711[17] == 1 .Or. aPergs711[30] == 1
         nAchouPed := 0
         SC4->(dbGoto(nRecno))
         For i := 1 to Len(aPedidosAc)
            nAchouPed:=ASCAN(aPedidosAc[i],{ |x| x[1] == C4_PRODUTO+Iif(Empty(SC4->C4_MOPC),SC4->C4_OPC,SC4->C4_MOPC) .And. x[2] == A650DTOPER(C4_DATA,aPeriodos,nTipo)})
            If nAchouPed != 0
               Exit
            EndIf
         Next i

         If nAchouPed > 0
            If aPedidosAc[i,nAchouPed,3] > nQuantPrev
               aPedidosAc[i,nAchouPed,3]-=nQuantPrev
               nQuantPrev:=0
            Else
               nQuantPrev:=nQuantPrev - aPedidosAc[i,nAchouPed,3]
               aPedidosAc[i,nAchouPed,3]:=0
            EndIf
         EndIf
      EndIf

      If nQuantPrev > 0
         SC4->(dbGoto(nRecno))
         mOpc := SC4->C4_MOPC

         //Marca o semaforo
         PCPA107LCK(.T.)

         //Cria os registros nas tabelas
         A107CriSOQ(A107NextUtil(C4_DATA,aPergs711),C4_PRODUTO,C4_OPC,If(A107TrataRev(),C4_REVISAO,cRev711Vaz),"SC4",nRecno,C4_DOC,/*08*/,/*09*/,nQuantPrev,"3",.F.,.T.,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SC4->C4_MOPC,/*26*/,/*27*/,aEmpresas)

         //Libera semaforo
         UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)
      EndIf

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   //So atualiza status de variavel global se foi acionado por job
   If lInJob
      PutGlbValue("A107JobC4"+cEmp+cFil, "30" )
      PutGlbValue("A107JobC4"+cEmp+cFil+"ERRO", cErro )
      GlbUnLock()
   EndIf
   cMsg := STR0148+" A107JobC4 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//So atualiza status de variavel global se foi acionado por job
If lInJob
   //STATUS 3 - Processamento efetuado com sucesso
   PutGlbValue("A107JobC4"+cEmp+cFil,"3")
   GlbUnLock()
EndIf

cMsg := STR0148+" A107JobC4 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobHC
//Autor:    Lucas Konrad França
//Data:     14/11/2014
//Descricao:   Job para processamento de plano mestre de producao - SHC
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//             lUsaMOpc    - Parâmetro de utilização de opcionais
//Parametros JOB:
//            [1]  - Numero do calculo de MRP
//            [2]  - Tipo de calculo MRP
//            [3]  - Array com os periodos
//            [4]  - String com tipos a serem processados
//            [5]  - String com grupos a serem processados
//            [6]  - Query para filtragem de produtos no SB1
//            [7]  - Alias da tabela a ser processada
//            [8]  - Array com perguntas utilizadas
//            [9]  - Revisao vazio
//            [10] - Data final para filtras os dados
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobHC(cEmp,cFil,aParamJob,nTentativa,lUsaMOpc)
Local nRecno      := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[4]
Local cStrGrupo   := aParamJob[5]
Local cAliasTop   := AllTrim(aParamJob[6])
Local cQueryB1    := aParamJob[7]
Local cRev711Vaz  := aParamJob[9]
Local dDatFim     := aParamJob[10]
Local aEmpresas   := aParamJob[11]
Local mOpc        := ""
Local cMsg        := ""

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE aPeriodos  := aParamJob[3]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPergs711  := aParamJob[8]
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[12]
PRIVATE aAlmoxNNR  := aParamJob[13]
PRIVATE aFilAlmox  := aParamJob[14]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobHC"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobHC"+cEmp+cFil, "10" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv( cEmp, cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobHC"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobHC"+cEmp+cFil, "20" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //"Processando thread"
   cMsg := STR0147+" A107JobHC "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   cQuery := " SELECT SHC.HC_FILIAL, " +;
                    " SHC.HC_DATA, " +;
                    " SHC.HC_PRODUTO, " +;
                    " SHC.HC_REVISAO, " +;
                    " SHC.HC_DOC, " +;
                    " SHC.HC_QUANT, " +;
                    " SHC.HC_OPC, " +;
                    " SHC.R_E_C_N_O_ HCREC " +;
               " FROM " + RetSqlName("SHC") + " SHC, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE SHC.HC_FILIAL  = '" + xFilial("SHC") + "' " +;
                " AND SHC.HC_STATUS  = '" + Space(LEN(SHC->HC_STATUS)) + "' " +;
                " AND SHC.HC_OP      = '" + Space(Len(SHC->HC_OP)) + "' " +;
                " AND SHC.HC_DATA   >= '" + DTOS(aPergs711[05]) + "' " +;
                " AND SHC.HC_DATA   <= '" + DTOS(aPergs711[06]) + "' " +;
                " AND SHC.HC_DATA   <= '" + DTOS(dDatFim) + "' " +;
                " AND SHC.HC_DOC    >= '" + aPergs711[23] + "' " +;
                " AND SHC.HC_DOC    <= '" + aPergs711[24] + "' " +;
                " AND SHC.D_E_L_E_T_ = ' ' " +;
                " AND SHC.HC_PRODUTO = SB1.B1_COD "
   cQuery += cQueryB1
   cQuery += " ORDER BY " + SqlOrder(SHC->(IndexKey(1)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SHC->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
   dbSelectArea(cAliasTop)

   While !Eof()
      nRecno := HCREC

      SHC->(dbGoTo(nRecno))
      mOpc := SHC->HC_MOPC

      //Marca o semaforo
      PCPA107LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil(HC_DATA,aPergs711),HC_PRODUTO,HC_OPC,If(A107TrataRev(),HC_REVISAO,cRev711Vaz),"SHC",nRecno,HC_DOC,/*08*/,/*09*/,HC_QUANT,"2",.F.,.T.,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,mOpc,/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobHC"+cEmp+cFil, "30" )
   PutGlbValue("A107JobHC"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobHC "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobHC"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobHC "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobB8
//Autor:    Lucas Konrad França
//Data:     14/11/2014
//Descricao:   Job para processamento de lotes vencidos
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             aParamJob   - Array com parametros para JOB
//             nTentativa  - Numero da tentativa para chamada do JOB
//Parametros JOB:
//            [1]  - Numero do calculo de MRP
//            [2]  - Tipo de calculo MRP
//            [3]  - Array com os periodos
//            [4]  - String com tipos a serem processados
//            [5]  - String com grupos a serem processados
//            [6]  - Alias da tabela a ser processada
//            [7]  - Query para filtragem de produtos no SB1
//            [8]  - Array com perguntas utilizadas
//            [9]  - Revisao vazio
//            [10] - Indica se filtra locais da tabela SOQNNR
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobB8(cEmp,cFil,aParamJob,nTentativa)
Local nRecno      := 0
Local c711NumMRP  := aParamJob[1]
Local nTipo       := aParamJob[2]
Local cStrTipo    := aParamJob[4]
Local cStrGrupo   := aParamJob[5]
Local cAliasTop   := AllTrim(aParamJob[6])
Local cQueryB1    := aParamJob[7]
Local cRev711Vaz  := aParamJob[9]
Local aEmpresas   := aParamJob[11]
Local cMsg        := ""

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

PRIVATE cAliasSOR  := "SOR"
PRIVATE cAliasSOT  := "SOT"
PRIVATE aPeriodos  := aParamJob[3]
PRIVATE aPergs711  := aParamJob[8]
PRIVATE nQuantPer  := Len(aPeriodos)
PRIVATE lVerSldSOR := .T.
PRIVATE nUsado     := aParamJob[12]
PRIVATE aAlmoxNNR  := aParamJob[10]
PRIVATE aFilAlmox  := aParamJob[13]

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107JobB8"+cEmp+cFil,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobB8"+cEmp+cFil, "10" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'PCP')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107JobB8"+cEmp+cFil,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobB8"+cEmp+cFil, "20" )
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //"Processando thread"
   cMsg := STR0147+" A107JobB8 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Inciando o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

   cQuery := " SELECT SB8.B8_FILIAL, " +;
                    " SB8.B8_DTVALID, " +;
                    " SB8.B8_PRODUTO, " +;
                    " SB8.B8_LOTECTL, " +;
                    " SB8.B8_NUMLOTE, " +;
                    " SB8.B8_SALDO, " +;
                    " SB8.R_E_C_N_O_ B8REC " +;
               " FROM " + RetSqlName("SB8") + " SB8, " + RetSqlName("SB1") + " SB1 " +;
              " WHERE SB8.B8_FILIAL  = '" + xFilial("SB8") + "' " +;
                " AND SB8.B8_SALDO   > 0 " +;
                " AND SB8.B8_LOCAL   >= '" + aPergs711[8] + "' " +;
                " AND SB8.B8_LOCAL   <= '" + aPergs711[9] + "' " +;
                " AND SB8.B8_LOCAL   <> '" + AlmoxCQ() + "' " +;
                " AND SB8.B8_DTVALID  < '" + DTOS(aPeriodos[Len(aPeriodos)])+ "' " +;
                " AND SB8.D_E_L_E_T_  = ' ' " +;
                " AND SB8.B8_PRODUTO  = SB1.B1_COD "

   If aPergs711[22] == 1
      cQuery += " AND SB8.B8_LOCAL <> '" + AlmoxCQ() + "' "
   EndIf

   If aAlmoxNNR # Nil
      cQuery += " AND SB8.B8_LOCAL IN (SELECT NR_LOCAL FROM SOQNNR "
      cQuery += " WHERE  NR_EMP = '"+cEmpAnt +"'"
      cQuery += " AND  NR_FILIAL = '"+cFILAnt +"'"
      cQuery += " ) "

   EndIf

   cQuery += cQueryB1
   cQuery += " ORDER BY " + SqlOrder(SB8->(IndexKey(1)))
   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTop,.T.,.T.)
   aEval(SB8->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasTop,x[1],x[2],x[3],x[4]),Nil)})
   dbSelectArea(cAliasTop)

   While !Eof()
      nRecno := B8REC

      //Marca o semaforo
      PCPA107LCK(.T.)

      //Cria os registros nas tabelas
      A107CriSOQ(A107NextUtil(B8_DTVALID+1,aPergs711),B8_PRODUTO,/*03*/,cRev711Vaz,"SB8",nRecno,If(Rastro(B8_PRODUTO,"L"),AllTrim(B8_LOTECTL),AllTrim(B8_LOTECTL)+"/"+AllTrim(B8_NUMLOTE)),/*08*/,/*09*/,B8_SALDO,/*11*/,.F.,.T.,/*14*/,.T.,.T.,aPeriodos,nTipo,c711NumMRP,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,/*25*/,/*26*/,/*27*/,aEmpresas)

      //Libera semaforo
      UnLockByName("SOQUSO"+cEmpAnt+cFilAnt,.T.,.T.,.T.)

      dbSelectArea(cAliasTop)
      dbSkip()
   End

   dbSelectArea(cAliasTop)
   dbCloseArea()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107JobB8"+cEmp+cFil, "30" )
   PutGlbValue("A107JobB8"+cEmp+cFil+"ERRO", cErro )
   GlbUnLock()
   cMsg := STR0148+" A107JobB8 "+StrZero(nTentativa,2,0) + ", " +;
           STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
   Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107JobB8"+cEmp+cFil,"3")
GlbUnLock()

cMsg := STR0148+" A107JobB8 "+StrZero(nTentativa,2,0) + ", " +;
        STR0149+"'" + AllTrim(cEmp) + "', "+STR0150+ " '" + AllTrim(cFil) + "'."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX, Empresa 'AA' filial 'AA'"

Return

/*------------------------------------------------------------------------//
//Programa: A107JobNes
//Autor:    Lucas Konrad França
//Data:     19/11/2014
//Descricao:   Funcao utilizada para executar o calculo da necessidade em mult-thread.
//Parametros:  01.cEmp         - Empresa
//             02.cFil         - Filial
//             03.aThreads     - Array com os itens a serem calculados
//             04.cThread      - Numero da Thread em execucao
//             05.aBkPeriodos  - Array contendo os periodos a processar
//             06.aBkPergs711  - Array contendo as perguntas selecionadas
//             07.aAlmoxNNRl   - Array com os locais selecionados
//             08.c711BkNumMrp - Numero do MRP
//             09.aFilAlmoxl   - Array de PE de filtro de locais
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107JobNes(cEmp,cFil,aThreads,cThread,aBkPeriodos,aBkPergs711,aAlmoxNNRl,c711BkNumMrp,aFilAlmoxl,lCalcFirst,aEmpresas)
Local nX    := 0

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

Private aPeriodos    := aBkPeriodos
Private aPergs711    := aBkPergs711
Private aAlmoxNNR    := aAlmoxNNRl
Private c711NumMrp   := c711BkNumMrp
Private aFilAlmox    := aFilAlmoxl
PRIVATE lVerSldSOR   := .F.

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("c107P"+cEmp+cFil+cThread,"1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("c107P"+cEmp+cFil+cThread,"10")
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'EST')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("c107P"+cEmp+cFil+cThread,"2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("c107P"+cEmp+cFil+cThread,"20")
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   ConOut(dtoc(Date())+" "+Time()+" "+"PCPA107: Iniciando job Calculo Necessidade "+" - "+cThread+" Empresa '"+cEmp+"' Filial '"+cFil+"'.")

   //Processamento
   For nX := 1 To Len(aThreads)
      A107Recalc(aThreads[nX,1],aThreads[nX,2],aThreads[nX,3],/*04*/,/*05*/,/*06*/,aThreads[nX,4],aThreads[nX,5],aEmpresas)
   Next nX

   ConOut(dtoc(Date())+" "+Time()+" "+"PCPA107: Termino job Calculo Necessidade "+" - "+cThread+" Empresa '"+cEmp+"' Filial '"+cFil+"'.")
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("c107P"+cEmp+cFil+cThread,"30")
   PutGlbValue("c107P"+cEmp+cFil+cThread+"ERRO", cErro )
   GlbUnLock()
   Return
EndIf

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("c107P"+cEmp+cFil+cThread,"3")
GlbUnLock()

Return

/*------------------------------------------------------------------------//
//Programa: A107ProdPr
//Autor:    Lucas Konrad França
//Data:     19/02/2015
//Descricao:   Função para verificar onde cada produto é produzido para o MRP Multi-empresa.
//Parametros:  01.aEmpresas    - Empresas que participam do MRP, já ordenadas por prioridade.
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107ProdPr(aEmpresas)
Local cQuery  := ""
Local nI      := 0
Local aTabSg1 := {}
Local cFilSb1 := ""
//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

Conout("Iniciando o processamento do JOB A107ProdPr.")

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107ProdPr","1")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107ProdPr","10")
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(aEmpresas[1,1],aEmpresas[1,2],,,'EST')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107ProdPr","2")
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0152) //"Erro ao efetuar a conexão."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107ProdPr","20")
   GlbUnLock()
   Return
EndIf

BEGIN SEQUENCE

   cQuery := " DELETE FROM ITPROD "
   TCSQLExec(cQuery)

   aAdd(aTabSg1,{RetSqlName("SG1"),xFilial("SG1"),aEmpresas[1,1],aEmpresas[1,2]})
   cFilSb1 := xFilial("SB1")
   For nI := 2 To Len(aEmpresas)
      RpcClearEnv()
      RpcSetType(3)
      RpcSetEnv(aEmpresas[nI,1],aEmpresas[nI,2])
      PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
      aAdd(aTabSg1,{RetSqlName("SG1"),xFilial("SG1"),aEmpresas[nI,1],aEmpresas[nI,2]})
   Next nI

   cQuery := " INSERT INTO ITPROD (COD, EMPRESA, FILIAL, R_E_C_N_O_)"
   cQuery += " SELECT SB1.B1_COD, "
   For nI := 1 To Len(aEmpresas)
      If nI != 1
         cQuery += " ELSE "
      EndIf

      cQuery += " CASE WHEN (SELECT COUNT(*) "
      cQuery +=              " FROM " + aTabSg1[nI,1]
      cQuery +=             " WHERE " + AllTrim(aTabSg1[nI,1]) + ".G1_COD     = SB1.B1_COD "
      cQuery +=               " AND " + AllTrim(aTabSg1[nI,1]) + ".G1_FILIAL  = '" + aTabSg1[nI,2] + "' "
      cQuery +=               " AND " + AllTrim(aTabSg1[nI,1]) + ".D_E_L_E_T_ = ' ' ) > 0 "
      cQuery +=      " THEN '" + aTabSg1[nI,3] + "' "

   Next nI

   For nI := 1 To Len(aEmpresas)
      cQuery += " END "
   Next nI
   cQuery += " AS EMPRESA, "

   For nI := 1 To Len(aEmpresas)
      If nI != 1
         cQuery += " ELSE "
      EndIf

      cQuery += " CASE WHEN (SELECT COUNT(*) "
      cQuery +=              " FROM " + aTabSg1[nI,1]
      cQuery +=             " WHERE " + AllTrim(aTabSg1[nI,1]) + ".G1_COD     = SB1.B1_COD "
      cQuery +=               " AND " + AllTrim(aTabSg1[nI,1]) + ".G1_FILIAL  = '" + aTabSg1[nI,2] + "' "
      cQuery +=               " AND " + AllTrim(aTabSg1[nI,1]) + ".D_E_L_E_T_ = ' ' ) > 0 "
      cQuery +=      " THEN '" + aTabSg1[nI,4] + "' "

   Next nI

   For nI := 1 To Len(aEmpresas)
      cQuery += " END "
   Next nI

   cQuery += " AS FILIAL, "
   cQuery += " SB1.R_E_C_N_O_ "

   cQuery +=   " FROM " + RetSqlName("SB1") + " SB1 "
   cQuery +=  " WHERE SB1.D_E_L_E_T_ = ' ' "
   cQuery +=    " AND SB1.B1_FILIAL = '" + cFilSb1 + "' "
   cQuery +=    " AND ("
   For nI := 1 to Len(aEmpresas)
      cQuery += " EXISTS ( SELECT 1 "
      cQuery +=            " FROM " + aTabSg1[nI,1]
      cQuery +=          "  WHERE " + AllTrim(aTabSg1[nI,1]) + ".G1_COD = SB1.B1_COD "
      cQuery +=             " AND " + AllTrim(aTabSg1[nI,1]) + ".D_E_L_E_T_ = ' ' "
      cQuery +=             " AND " + AllTrim(aTabSg1[nI,1]) + ".G1_FILIAL  = '" + aTabSg1[nI,2] + "'  "
      If nI == Len(aEmpresas)
         cQuery += " ) "
      Else
         cQuery += ") OR "
      EndIf
   Next nI
   cQuery += " ) "

   TCSQLExec(cQuery)
END SEQUENCE
If ValType(oError) != "U"
   ConOut(Replicate("-",65))
   ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
   ConOut(cErro)
   ConOut(Replicate("-",65))
   PutGlbValue("A107ProdPr", "30" )
   PutGlbValue("A107ProdPrERRO", cErro )
   GlbUnLock()
   Return
EndIf

PutGlbValue("A107ProdPr","3")
GlbUnLock()

cMsg := STR0148+" A107ProdPr."
Conout(cMsg) //"Finalizado o processamento do JOB: XXX."

Return

/*------------------------------------------------------------------------//
//Programa: A107PPEstS
//Autor:    Lucas Konrad França
//Data:     25/05/2015
//Descricao:   Funcao utilizada para carregar os registros de estoque de segurança e ponto de pedido
//             Deve ser executada somente após a finalização do job A107JobIni
//Parametros:  01.cEmp         - Empresa
//             02.cFil         - Filial
//             03.aBkPeriodos  - Array contendo os periodos a processar
//             04.aBkPergs711  - Array contendo as perguntas selecionadas
//             05.c711BkNumMrp - Numero do MRP
//             06.cStrTipo     - String dos tipos de itens
//             07.cStrGrupo    - String com os grupos de itens
//             08.cTxtEstSeg   - Mensagem do estoque de segunranca
//             09.lExistBB1    - Indica se existe BB1
//             10.lExistBB2    - Indica se existe BB2
//             11.cTxtPontPed  - Ponto de pedido
//             12.aAlmoxNNRl   - Array com os locais selecionados
//             13.nBkTipo      - Tipo de periodo
//             14.aPicture     - Array com as pictures
//             15.aEmpresas    - Array com as empresas do processamento
//             16.lVerGrupo    - Indica se utiliza filtro por grupo
//             17.lVerTipo     - Indica se utiliza filtro por Tipo
//Uso:      PCPA107
//------------------------------------------------------------------------*/
Function A107PPEstS(cEmp,cFil,aBkPeriodos,aBkPergs711,c711BkNumMrp,cStrTipo,cStrGrupo,cTxtEstSeg,lExistBB1,lExistBB2,cTxtPontPed,aAlmoxNNRl,nBkTipo,cRev711Vaz,aPicture,aEmpresas,lVerGrupo,lVerTipo,nUsed,aBkEmpCent,cDadosProd)
Local nX          := 0
Local nI          := 0
Local nz          := 0
Local nSaldo      := 0
Local nSldGeral   := 0
Local nSldEmp     := 0
Local nEstSeg     := 0
Local nQtdAviso   := 0
Local nTamFil     := 0
Local nRecSOR     := 0
Local nPontoPed   := 0
Local nQtdPontP   := 0
Local nQtdES      := 0
Local nRecOrig    := 0
Local nSldEmpBkp  := 0
Local nQtdTran    := 0
Local cMsgAviso   := ""
Local cMsgPontP   := ""
Local cRevisao    := ""
Local cQuery      := ""
Local cAliasEst   := "VEREST"
Local cEmprBkp    := ""
Local cFiliBkp    := ""
Local cAlias      := GetNextAlias()
Local aOpc        := {}
Local aEmp        := {}
Local aProdutos   := {}
Local lMRPCINQ    := .F.
Local lSbz        := .F.
Local lAchou      := .F.
Local lOpcOK      := .T.
Local nPPAux      := 0
Local aCriSOV     := {}

//Variáveis para tratar as exceções
Private bErrorBlock := ErrorBlock({|e| a107errblk(e)}) //ErrorBlock( bError )

//Carrega Variaveis Private
Private aPeriodos    := aBkPeriodos
Private aPergs711    := aBkPergs711
Private aAlmoxNNR    := aAlmoxNNRl
Private aFilAlmox    := Nil
Private cAlmoxd      := aPergs711[8]
Private cAlmoxa      := aPergs711[9]
Private c711NumMrp   := c711BkNumMrp
Private cMT710B2     := Nil
Private cAliasSOR    := "SOR"
Private cAliasSOT    := "SOT"
Private cPictLOCAL   := aPicture[1]
Private cPictQATU    := aPicture[2]
Private cPictQNPT    := aPicture[3]
Private cPictQTNP    := aPicture[4]
Private cPictQTDE    := aPicture[5]
Private cPictSALDO   := aPicture[6]
PRIVATE cPictB2Local := aPicture[1]
PRIVATE cPictB2Qatu  := aPicture[2]
PRIVATE cPictB2QNPT  := aPicture[3]
PRIVATE cPictB2QTNP  := aPicture[4]
PRIVATE cPictD7QTDE  := aPicture[5]
PRIVATE cPictDDSaldo := aPicture[6]
Private nTipo        := nBkTipo
PRIVATE lVerSldSOR   := .T.
Private nUsado       := nUsed
Private aEmpCent     := aBkEmpCent
PRIVATE cEmpBkp      := ""
PRIVATE cFilBkp      := ""

BEGIN SEQUENCE
   //STATUS 1 - Iniciando execucao do Job
   PutGlbValue("A107PPEstS", "1" )
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0153) //"Erro ao iniciar a execucao do Job."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107PPEstS", "10" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'EST')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107PPEstS", "2" )
   GlbUnLock()
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut("Erro ao efetuar a conexão.")
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107PPEstS", "20" )
  GlbUnLock()
  Return
EndIf

BEGIN SEQUENCE
   lMRPCINQ := SuperGetMV("MV_MRPCINQ",.F.,.F.)
   nTamFil  := TamSX3("OQ_FILEMP")[1]

   ConOut(dtoc(Date())+" "+Time()+" "+"PCPA107: Iniciando job Estoque de segurança/Ponto de pedido.")
   cEmpBkp := aEmpresas[1,1]
   cFilBkp := aEmpresas[1,2]
   //Processamento
   For nI := 1 To Len(aEmpresas)
      If cDadosProd == "SBZ" .And. (AllTrim(aEmpresas[nI,1]) != AllTrim(cEmpAnt) .Or. AllTrim(aEmpresas[nI,2]) != AllTrim(cFilAnt))
         A107AltEmp(aEmpresas[nI,1], aEmpresas[nI,2])
      EndIf
      If Select(cAlias) > 0
         (cAlias)->(dbCloseArea())
      EndIf

      aProdutos := {}

      cQuery := " SELECT SB1.B1_COD "
      cQuery +=   " FROM " + RetSqlName("SB1") + " SB1 "

      If cDadosProd == "SBZ"
         cQuery += " LEFT OUTER JOIN "+RetSqlName("SBZ")+" SBZ "
         cQuery += " ON  BZ_FILIAL = '"+xFilial("SBZ")+"' "
         cQuery += " AND BZ_COD    = B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
         cQuery += " WHERE SB1.B1_FILIAL = '"+xFilial("SB1") + "' "
         cQuery +=   " AND ISNULL(BZ_FANTASM, B1_FANTASM) <> 'S' "
         cQuery +=   " AND ISNULL(BZ_MRP,     B1_MRP    ) IN (' ','S') "
         cQuery +=   " AND SB1.D_E_L_E_T_ = ' ' "
         cQuery +=   " AND ( ISNULL(BZ_ESTSEG, B1_ESTSEG) <> 0 "
         cQuery +=      " OR ISNULL(BZ_ESTFOR, B1_ESTFOR) <> ' ' "
         cQuery +=      " OR ISNULL(BZ_EMIN  , B1_EMIN  ) <> 0 ) "
      Else
         cQuery +=  " WHERE (SB1.B1_ESTSEG <> 0 "
         cQuery +=     " OR  SB1.B1_ESTFOR <> ' ' "
         cQuery +=     " OR  SB1.B1_EMIN   <> 0 )"
         cQuery +=    " AND SB1.B1_FILIAL   = '"+xFilial("SB1")+"' "
         cQuery +=    " AND SB1.B1_MRP     IN (' ','S')"
         cQuery +=    " AND SB1.B1_FANTASM <> 'S' "
         cQuery +=    " AND SB1.D_E_L_E_T_ = ' ' "
      EndIf


      If !lVerTipo
        cQuery += " AND SB1.B1_TIPO IN (SELECT TP_TIPO FROM SOQTTP) "
      EndIf
      If !lVerGrupo .And. lMRPCINQ
        cQuery += " AND SB1.B1_GRUPO IN (SELECT GR_GRUPO FROM SOQTGR) "
      EndIf

      cQuery += " AND SB1.B1_MSBLQL <> '1' "

      If ExistBlock("A710SQL")
         cA710Fil := ExecBlock("A710SQL", .F., .F., {"SB1", cQuery})
         If ValType(cA710Fil) == "C"
            cQuery := cA710Fil
         Endif
      Endif

      cQuery := ChangeQuery(cQuery)

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

      While !(cAlias)->(Eof())
         aAdd(aProdutos,(cAlias)->(B1_COD))
         (cAlias)->(dbSkip())
      End
      (cAlias)->(dbCloseArea())
      If cDadosProd == "SBZ"
         dbSelectArea("SBZ")
         SBZ->(dbSetOrder(1))
         cEmp := aEmpresas[nI,1]
         cFil := aEmpresas[nI,2]
      EndIf

      dbSelectArea("SB1")
      SB1->(dbSetOrder(1))

      For nX := 1 To Len(aProdutos)
         lSbz := .F.
         If SB1->(dbSeek(xFilial("SB1")+aProdutos[nX]))
            If cDadosProd == "SBZ"
               If SBZ->(dbSeek(xFilial("SBZ")+aProdutos[nX]))
                  aEmp := {Nil,Nil}
                  lSbz := .T.
               Else
                  aEmp := a107EstSeg(SB1->B1_COD,aEmpresas,.T.)
               EndIf
            Else
               aEmp := a107EstSeg(SB1->B1_COD,aEmpresas,.T.)
            EndIf
            If (aEmp[1] != Nil .And. AllTrim(aEmp[1]) != AllTrim(cEmpAnt)) .Or. (aEmp[2] != Nil .And. AllTrim(aEmp[2]) != AllTrim(cFilAnt))
              A107AltEmp(aEmp[1], aEmp[2])
              dbSelectArea("SB1")
              SB1->(dbSetOrder(1))
              SB1->(dbSeek(xFilial("SB1")+aProdutos[nX]))
            EndIf
            cFiliBkp := cFilAnt
            cEmprBkp := cEmpAnt
            If lExistBB1
               aFilAlmox := RetExecBlock("A710FILALM",{SB1->B1_COD,cAlmoxd,cAlmoxa},"A",Nil,Nil,Nil,lExistBB1)
            EndIf
            If lExistBB2
               cMT710B2 := RetExecBlock("MT710B2",{SB1->B1_COD,cAlmoxd,cAlmoxa},"C", Nil,Nil,Nil,lExistBB2)
            EndIf

            If ValType(aFilAlmox) == "A" .And. aScan(aFilAlmox, {|z| ValType(z) # "C"}) > 0
               aFilAlmox := Nil
            EndIf

            //Inicializa variaveis de saldo
            nSaldo   := 0
            nEstSeg  := 0

            //Obtem saldo e estoque de seguranca
            A107DSaldo(SB1->B1_COD,@nSaldo,@aFilAlmox,/*04*/,/*05*/,@nEstSeg,"SB1",Iif(lSbz,{{cEmpAnt,cFilAnt}},aEmpresas),.T.,lSbz)

            //Verifica o saldo existente na própria empresa
            dbSelectArea("SOR")
            SOR->(dbSetOrder(1))
            If SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+SB1->B1_COD))
               dbSelectArea("SOT")
               SOT->(dbSetOrder(1))
               If SOT->(dbSeek(xFilial("SOT")+STR(SOR->(Recno()),10,0)+"001"))
                  nSldEmp := SOT->OT_QTSALD
                  nRecOrig := SOT->(Recno())
               Else
                  nSldEmp := 0
               EndIf
            Else
               nSldEmp := 0
            EndIf

            If aPergs711[31] == 1
               //nPontoPed := SB1->B1_EMIN
               nPontoPed := RetFldProd(aProdutos[nX],"B1_EMIN")
            EndIf

            If aPergs711[26] == 3
               nEstSeg := CalcEstSeg( RetFldProd(SB1->B1_COD,"B1_ESTFOR") )
            EndIf

            //Checa informacoes para inclusao no tree
            nQtdAviso := 0
            cMsgAviso := ""

            If nPontoPed > 0 .Or. nEstSeg > 0
               lOpcOK := A107VLOPC(SB1->B1_COD, "", {}, "", "", , ,.F. , 1 )
            Else
               lOpcOK := .T.
            EndIf

            //Caso o estoque de seguranca esteja preenchido
            If QtdComp(nEstSeg,.T.) > QtdComp(0,.T.)
               If lOpcOk
                  nQtdAviso := nEstSeg
                  cMsgAviso := cTxtEstSeg
               EndIf
            EndIf

            // Checa informacoes para inclusao no tree
            nQtdPontP := 0
            cMsgPontP := ""

            nSldGeral  := a107SldSum(SB1->B1_COD, "001",.T.)
            nSldEmpBkp := nSldEmp
            If nSldEmp > 0
               If nSldEmp >= nQtdAviso .And. nQtdAviso > 0
                  If QtdComp(nQtdAviso,.T.) > QtdComp(0,.T.)
                     A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nQtdAviso,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
                     If aPergs711[26] == 1
                        A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",-nQtdAviso,"1","SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
                     EndIf
                     nSldEmp   -= nQtdAviso
                     nQtdAviso := 0
                  EndIf
               Else
                  If QtdComp(nQtdAviso,.T.) > QtdComp(0,.T.)
                     A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nSldEmp,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
                     If aPergs711[26] == 1
                        A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",-nSldEmp,"1","SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
                     Else
                        A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",nQtdAviso-nSldEmp,"6","SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
                     EndIf
                     nQtdAviso -= nSldEmp
                     nSldEmp   := 0
                  EndIf
               EndIf
            EndIf

            If !lSbz .And. nQtdAviso > 0 .And. nRecOrig > 0 .And. nSldGeral > nSldEmpBkp
               //nQtdAviso -= A107TraPrd(cEmpAnt, cFilAnt, SB1->B1_COD, nQtdAviso, "001", nRecOrig, .T., .T., cMsgAviso, cStrTipo, cStrGrupo)
               nQtdTran := A107TraPrd(cEmpAnt, cFilAnt, SB1->B1_COD, nQtdAviso, "001", nRecOrig, .T., .T., cMsgAviso, cStrTipo, cStrGrupo)
               If cFiliBkp != cFilAnt .Or. cEmprBkp != cEmpAnt
                  a107AltEmp(cEmpAnt,cFilAnt)
               EndIf
               //If aPergs711[26] == 1
                  If nQtdAviso > 0
                     A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nQtdAviso,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
                     nRecSOR := A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",Iif(aPergs711[26]==3,nQtdAviso,-nQtdAviso),Iif(aPergs711[26]==3,"6","1"),"SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
                     SOR->(dbGoTo(nRecSOR))
                     //SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+SB1->B1_COD))

                     dbSelectArea("SOT")
                     SOT->(dbSetOrder(1))
                     If SOT->(dbSeek(xFilial("SOT")+STR(SOR->(Recno()),10,0)+"001"))
                        lAchou := .F.
                        SOV->(dbSetOrder(1))
                        //Busca o registro na SOV. Se encontrar, é porque já foi incluido o registro pela função A107JobIni, e não inclui novamente.
                        If SOV->(dbSeek(xFilial("SOV")+PadR(AllTrim(Str(SOT->(Recno()))),10)+"N"))
                           While SOV->OV_FILIAL == xFilial("SOV") .And. ;
                                 SOV->OV_RECSOT == SOT->(Recno()) .And. ;
                                 SOV->OV_TRANS  == "N"
                              If SOV->OV_QUANT == nQtdAviso
                                 lAchou := .T.
                                 If nQtdTran > 0 .And. aPergs711[26]==3
                                    RecLock("SOV",.F.)
                                       SOV->OV_QUANT := SOV->OV_QUANT - nQtdTran
                                    MsUnLock()
                                 EndIf
                                 Exit
                              EndIf
                              SOV->(dbSkip())
                           End
                        EndIf
                        If !lAchou
                           a107CriSOV(SOT->(Recno()),nQtdAviso-nQtdTran,SB1->(B1_COD),"N")
                        EndIf
                     EndIf

                  EndIf
                  nQtdAviso := 0
               //EndIf
            EndIf

            If nQtdAviso > 0 .And. !lSbz
               For nZ := 1 To Len(aEmpresas)
                  If AllTrim(aEmpresas[nZ,1]) == AllTrim(cEmprBkp) .And. AllTrim(aEmpresas[nZ,2]) == AllTrim(cFiliBkp)
                     Loop
                  EndIf
                  cQuery := " SELECT SOT.R_E_C_N_O_ RECSOT "
                  cQuery +=   " FROM " + RetSqlName("SOT") + " SOT, "
                  cQuery +=              RetSqlName("SOR") + " SOR "
                  cQuery +=  " WHERE SOT.OT_RGSOR  = SOR.R_E_C_N_O_ "
                  cQuery +=    " AND SOR.OR_PROD   = '" + aProdutos[nX] + "' "
                  cQuery +=    " AND SOR.OR_EMP    = '" + aEmpresas[nZ,1] + "' "
                  cQuery +=    " AND SOR.OR_FILEMP = '" + aEmpresas[nZ,2] + "' "
                  cQuery +=    " AND SOT.OT_QTSALD > 0 "
                  cQuery +=    " AND SOT.OT_PERMRP = '001' "

                  cQuery := ChangeQuery(cQuery)

                  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasEst,.T.,.T.)
                  If (cAliasEst)->(!Eof())
                     SOT->(dbGoTo((cAliasEst)->(RECSOT)))
                     If SOT->OT_QTSALD >= nQtdAviso
                        If AllTrim(cEmpAnt) != AllTrim(aEmpresas[nZ,1]) .Or. AllTrim(cFilAnt) != AllTrim(aEmpresas[nZ,2])
                           A107AltEmp(aEmpresas[nZ,1], aEmpresas[nZ,2])
                           dbSelectArea("SB1")
                           SB1->(dbSetOrder(1))
                           SB1->(dbSeek(xFilial("SB1")+aProdutos[nX]))
                        EndIf

                        If QtdComp(nQtdAviso,.T.) > QtdComp(0,.T.)
                           A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nQtdAviso,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
                           A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",-nQtdAviso,"1","SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
                           nQtdAviso := 0
                        EndIf
                     Else
                        If SOT->OT_QTSALD > 0
                           nQtdES := SOT->OT_QTSALD
                           If AllTrim(cEmpAnt) != AllTrim(aEmpresas[nZ,1]) .Or. AllTrim(cFilAnt) != AllTrim(aEmpresas[nZ,2])
                              A107AltEmp(aEmpresas[nZ,1], aEmpresas[nZ,2])
                              dbSelectArea("SB1")
                              SB1->(dbSetOrder(1))
                              SB1->(dbSeek(xFilial("SB1")+aProdutos[nX]))
                           EndIf

                           If QtdComp(nQtdAviso,.T.) > QtdComp(0,.T.)
                              A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nQtdES,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
                              A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",-nQtdES,"1","SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
                              nQtdAviso -= nQtdES
                           EndIf
                        EndIf
                     EndIf
                  EndIf
                  If Select(cAliasEst) > 0
                     (cAliasEst)->(dbCloseArea())
                  EndIf
                  If nQtdAviso <= 0
                     Exit
                  EndIf
               Next nZ
            EndIf

            If AllTrim(cEmpAnt) != AllTrim(cEmprBkp) .Or. AllTrim(cFilAnt) != AllTrim(cFiliBkp)
               A107AltEmp(cEmprBkp, cFiliBkp)
               dbSelectArea("SB1")
               SB1->(dbSetOrder(1))
               SB1->(dbSeek(xFilial("SB1")+aProdutos[nX]))
            EndIf
            //Caso o ponto de pedido esteja preenchido
            If QtdComp(nPontoPed,.T.) > QtdComp(0,.T.)
               If lOpcOK
                  nQtdPontP:= nPontoPed
                  cMsgPontP:= cTxtPontPed
               EndIf
            EndIf
            /* mesmo que tenha saldo para atender o ponto de pedido, precisa criar as tabelas do MRP da quantidade do ponto de pedido.
            Isso porquê, caso exista alguma saída do produto, o MRP irá considerar corretamente as quantidades de estoque de segurança e ponto de pedido.
            If !lSbz
               If nSldGeral >= nQtdPontP
                  nQtdPontP := 0
                  nSldGeral -= nQtdPontP
               Else
                  nQtdPontp -= nSldGeral
                  nSldGeral := 0
               EndIf
            EndIf*/

			aCriSOV := {}

			//Monta no tree
            If QtdComp(nQtdAviso,.T.) > QtdComp(0,.T.)
               A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgAviso,/*08*/,/*09*/,nQtdAviso,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas)
               nRecSOR := A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",Iif(aPergs711[26]==3,nQtdAviso,-nQtdAviso),Iif(aPergs711[26]==3,"6","1"),"SB1",.T.,cStrTipo,cStrGrupo,.F.,SB1->B1_MOPC,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)

               If SOT->(dbSeek(xFilial("SOT")+STR(nRecSOR,10,0)+"001"))
                  lAchou := .F.
                  SOV->(dbSetOrder(1))
                  //Busca o registro na SOV. Se encontrar, é porque já foi incluido o registro pela função A107JobIni, e não inclui novamente.
                  If SOV->(dbSeek(xFilial("SOV")+PadR(AllTrim(Str(SOT->(Recno()))),10)+"N"))
                     While SOV->OV_FILIAL == xFilial("SOV") .And. ;
                           SOV->OV_RECSOT == SOT->(Recno()) .And. ;
                           SOV->OV_TRANS  == "N"
                        If SOV->OV_QUANT == nQtdAviso
                        	lAchou := .T.
                        	Exit
                        EndIf
                        SOV->(dbSkip())
                     End
                  EndIf
                  If !lAchou
					aAdd(aCriSOV,{SOT->(Recno()),nQtdAviso,SB1->(B1_COD),"N"})
                     //a107CriSOV(SOT->(Recno()),nQtdAviso,SB1->(B1_COD),"N")
                  EndIf
               EndIf
            EndIf
            //    Monta no tree
            If QtdComp(nQtdPontP,.T.) > QtdComp(0,.T.)
               A107CriSOQ(aPeriodos[1],SB1->B1_COD,SB1->B1_OPC,IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU )/*SB1->B1_REVATU*/,"SB1",SB1->(Recno()),cMsgPontP,/*08*/,/*09*/,nQtdPontP,/*11*/,.F.,.F.,"SB1",.T.,/*16*/,/*17*/,/*18*/,/*19*/,cStrTipo,cStrGrupo,/*22*/,/*23*/,/*24*/,SB1->B1_MOPC,/*26*/,/*27*/,aEmpresas,lSbz)
               //A107CriSOR(SB1->B1_COD,SB1->B1_OPC,cRev711Vaz,/*04*/,"001",nQtdPontP+1,"6","SB1",.T.,cStrTipo,cStrGrupo,.F.,/*13*/,/*14*/,/*15*/,/*16*/,/*17*/,/*18*/,aEmpresas)
               nPPAux := nQtdPontP
               If !lSbz
                  If nSldGeral >= nQtdPontP
                     nPPAux := 0
                  Else
                     nPPAux -= nSldGeral
                  EndIf
               EndIf
               If QtdComp(nPPAux,.T.) > QtdComp(0,.T.)
                  SOR->(dbSetOrder(1))
                  If SOR->(dbSeek(xFilial("SOR")+cEmpAnt+PadR(cFilAnt,nTamFil)+SB1->(B1_COD)))
                     If SOT->(dbSeek(xFilial("SOT")+STR(SOR->(Recno()),10,0)+"001"))
						If SOT->OT_QTSALD < (nQtdPontP+1)
							a107CriSOV(SOT->(Recno()), ((nQtdPontP+1)-SOT->OT_QTSALD),SB1->(B1_COD),"N")
							aCriSOV := {}
						EndIf
                     EndIf
                  EndIf
               EndIf
            EndIf

			If Len(aCriSOV) > 0
				a107CriSOV(aCriSOV[1][1],aCriSOV[1][2],aCriSOV[1][3],aCriSOV[1][4])
			EndIf

            If cEmp != cEmpAnt .Or. cFil != cFilAnt
            	A107AltEmp(cEmp,cFil)
            EndIf
         EndIf
      Next nX
      If cDadosProd != "SBZ"
         //Se não utiliza a SBZ, não é necessário processar todas as empresas.
         Exit
      EndIf
   Next nI
END SEQUENCE
If ValType(oError) != "U"
  ConOut(Replicate("-",65))
  ConOut(STR0151) //"Erro ao efetuar o processamento do Job."
  ConOut(cErro)
  ConOut(Replicate("-",65))
  PutGlbValue("A107PPEstS", "30" )
  PutGlbValue("A107PPEstSERRO", cErro )
  GlbUnLock()
  Return
EndIf

ConOut(dtoc(Date())+" "+Time()+" "+"PCPA107: Termino job Estoque de segurança/Ponto de pedido.")

//STATUS 3 - Processamento efetuado com sucesso
PutGlbValue("A107PPEstS","3")
GlbUnLock()

Return

Function a107errblk(e)
   conout(Replicate("-",70) + CHR(10) + AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10) + Replicate("-",70))
   If ValType(oError) == "U"
   	oError := e
   EndIf
   cErro += AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10)
Return .F.

/*-------------------------------------------------------------------------//
//Programa: A107IntPPI
//Autor:    Lucas Konrad França
//Data:     30/11/2015
//Descricao:   Job para integração das Ordens de produção geradas pelo MRP com o PC-Factory.
//Parametros:  cEmp        - Empresa
//             cFil        - Filial
//             cNumMrp     - Número de processamento do MRP.
//             cParInt     - Parâmetro de integração do PPI.
//             cUsuario    - Código do usuario que está processando o MRP.
//             aXml        - Array contendo os XMLs a serem processados.
//             lExclusao   - Indica que será processada a exclusão de registros. Necessário passar os
//                           XML's através do parâmetro aXml.
//Uso:      PCPA107
//-------------------------------------------------------------------------*/
Function A107IntPPI(cEmp,cFil,cNumMRP,cParInt,cUsuario,aXml,lExclusao)

   Local cQuery    := ""
   Local cQueryCnt := ""
   Local cAliasC2  := "GETC2MRP"
   Local cFiltro   := ""
   Local nCount    := 0
   Local nTotal    := 0

   Default aXml      := {}
   Default lExclusao := .F.

   Private cIntgPPI := cParInt

   //Variáveis para tratar as exceções
   Private bError      := { |e| oError := e }
   Private bErrorBlock := ErrorBlock( bError )
   Private oError

   //STATUS 1 - Iniciando execucao do Job
   BEGIN SEQUENCE
   PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil),"1")
   GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      ConOut(Replicate("-",65))
      ConOut("Erro ao iniciar a execucao do Job: A107IntPPI" + cEmp+cFil)
      ConOut(oError:Description + oError:ErrorStack)
      ConOut(Replicate("-",65))
      PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil), "10" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
   //Seta job para nao consumir licensas
   RpcSetType(3)

   //Seta job para empresa filial desejada
   RpcSetEnv(cEmp,cFil,,,'EST')
   PRIVATE lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)
   //STATUS 2 - Conexao efetuada com sucesso
   PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil),"2")
   GlbUnLock()
   END SEQUENCE
   If ValType(oError) != "U"
      ConOut(Replicate("-",65))
      ConOut("Erro ao efetuar a conexão. Job: A107IntPPI" + cEmp+cFil)
      ConOut(oError:Description + oError:ErrorStack)
      ConOut(Replicate("-",65))
      PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil), "20" )
      GlbUnLock()
      Return
   EndIf

   BEGIN SEQUENCE
   //Carrega as variáveis private utilizadas.
   If lExclusao
      INCLUI    := .F.
      ALTERA    := .F.
   Else
      INCLUI    := .T.
      ALTERA    := .F.
   EndIf
   __cUserId := cUsuario
   SetFunName("PCPA107")

	PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil)+"COUNT", "0" )
	GlbUnLock()

   If lExclusao
      PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil)+"TOTAL", cValToChar(Len(aXml)) )
      GlbUnLock()

      For nCount := 1 To Len(aXml)
         mata650PPI(aXml[nCount,1], aXml[nCount,2], .T., .T., .T., .F.)
         delClassIntF()
         PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil)+"COUNT", cValToChar(nCount) )
         GlbUnLock()
      Next nCount
   Else
      //Verifica se existe algum filtro para a tabela na SOE
      dbSelectArea("SOE")
      SOE->(dbSetOrder(1))
      If SOE->(dbSeek(xFilial("SOE")+"SC2"))
         cFiltro := SOE->OE_FILTRO
         //Troca as aspas duplas por simples.
         cFiltro := StrTran(cFiltro,'"',"'")
      EndIf

      dbSelectArea("SC2")

      //Buscas as OP's que foram criadas pelo MRP.
      cQuery := " SELECT SC2.R_E_C_N_O_ RECSC2 "
      cQuery +=   " FROM " + RetSqlName("SC2") + " SC2 "
      cQuery +=  " WHERE SC2.D_E_L_E_T_ = ' ' "
      cQuery +=    " AND SC2.C2_FILIAL  = '" + xFilial("SC2") + "' "
      cQuery +=    " AND SC2.C2_SEQMRP  = '" + cNumMRP + "' "
      If !Empty(cFiltro)
         cQuery += " AND (" + AllTrim(cFiltro) + ") "
      EndIf

      cQuery := ChangeQuery(cQuery)

      cQueryCnt := " SELECT COUNT(*) TOTAL FROM (" + cQuery + ") t"
      cQueryCnt := ChangeQuery(cQueryCnt)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCnt),cAliasC2,.T.,.T.)
      nTotal := (cAliasC2)->(TOTAL)
      PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil)+"TOTAL", cValToChar(nTotal) )
      GlbUnLock()
      (cAliasC2)->(dbCloseArea())

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasC2,.T.,.T.)

      While (cAliasC2)->(!Eof())
         SC2->(dbGoTo((cAliasC2)->(RECSC2)))

         mata650PPI(, , .T., .T., .F., .F.)
         delClassIntF()
         nCount++
         PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil)+"COUNT", cValToChar(nCount) )
         GlbUnLock()
         (cAliasC2)->(dbSkip())
      End

      (cAliasC2)->(dbCloseArea())
   EndIf

   END SEQUENCE
   If ValType(oError) != "U"
      ConOut(Replicate("-",65))
      ConOut("Erro ao efetuar o processamento do Job: A107IntPPI" + cEmp+cFil)
      ConOut(oError:Description + oError:ErrorStack)
      ConOut(Replicate("-",65))
      PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil), "30" )
      PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil)+"ERRO", oError:Description + oError:ErrorStack )
      GlbUnLock()
      Conout("Finalizando o processamento do Job A107IntPPI"+cEmp+cFil+" com erros.")
      Return
   EndIf

   //STATUS 3 - Processamento efetuado com sucesso
   PutGlbValue("A107IntPPI"+cEmp+AllTrim(cFil),"3")
   GlbUnLock()
   Conout("Finalizando o processamento do Job A107IntPPI"+cEmp+cFil)
Return
