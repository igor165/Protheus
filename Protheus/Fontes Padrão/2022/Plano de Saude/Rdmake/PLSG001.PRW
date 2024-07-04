
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSG001 Ё Autor Ё Angelo Sperandio       Ё Data Ё 10.02.05 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Ajusta valor de cobranca no BD7                            Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSG001()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

User Function PLSG001()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE nQtdLin     := 55
PRIVATE cNomeProg   := "PLSG001"
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := "Recalculo de campos no BD7"
PRIVATE cDesc1      := "Recalculo de campos no BD7"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BD6"
PRIVATE nRel        := "PLSG001"
PRIVATE nLi         := 999
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .F.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "                                                          ------------  Antes -----------  --------------  Apos ------------"
PRIVATE cCabec2     := "Chave BD7                              TPF BD6  Taxa BD6     % BD7      TPF BD7  Taxa BD7     % BD7        TPF BD7  Taxa BD7"
PRIVATE nColuna     := 03 // Numero da coluna que sera impresso as colunas
PRIVATE nCaracter   := 15
PRIVATE cPerg       := "PLG001"
PRIVATE nUsrVlr     := 0
PRIVATE nFamVlr     := 0
PRIVATE nFamBas     := 0
PRIVATE nFamIns     := 0
PRIVATE nSubVlr     := 0
PRIVATE nSubBas     := 0
PRIVATE nSubIns     := 0
PRIVATE nConVlr     := 0
PRIVATE nConBas     := 0
PRIVATE nConIns     := 0
PRIVATE nEmpVlr     := 0
PRIVATE nEmpBas     := 0
PRIVATE nEmpIns     := 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza SX1                                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
CriaSX1()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLastKey  == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetDefault(aReturn,cAlias)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
MsAguarde({|| G001Imp() }, cTitulo, "", .T.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё G001Imp  Ё Autor Ё Angelo Sperandio      Ё Data Ё 10.02.05 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Ajusta valor de cobranca no BD7                            Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
/*/

Static Function G001Imp()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cSQL
LOCAL nOrdSel    := aReturn[8] // Ordem selecionada...
LOCAL lRelGerado := .F.
LOCAL cChaveFam
LOCAL lFlag
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis de Parametros do relatorio (SX1)...                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cMes      
LOCAL cAno      
LOCAL cOpeDe    
LOCAL cOpeAte   
LOCAL cEmpDe    
LOCAL cEmpAte   
LOCAL cConDe    
LOCAL cConAte   
LOCAL cVerDe    
LOCAL cVerAte   
LOCAL cSubDe    
LOCAL cSubAte   
LOCAL cVesDe    
LOCAL cVesAte   
LOCAL cMatDe    
LOCAL cMatAte   
LOCAL cTipPre
LOCAL nPerIns
LOCAL nLisCid   
LOCAL cCliente
LOCAL cLoja
LOCAL lInterc := .F.
PRIVATE nLinPag
PRIVATE lLisCid
PRIVATE cCid
PRIVATE cGuia
PRIVATE aLog1 := {}                        

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca os parametros...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)                
cMes      := mv_par01
cAno      := mv_par02
cOpeDe    := mv_par03
cOpeAte   := mv_par04
cEmpDe    := mv_par05
cEmpAte   := mv_par06
cConDe    := mv_par07
cConAte   := mv_par08
cVerDe    := mv_par09
cVerAte   := mv_par10
cSubDe    := mv_par11
cSubAte   := mv_par12
cVesDe    := mv_par13
cVesAte   := mv_par14
cMatDe    := mv_par15
cMatAte   := mv_par16
nLinPag   := mv_par17
If  nLinPag == 0
    nLinPag := nQtdLin
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define query de acesso...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT "
cSQL += "COUNT(*) QTD "
cSQL += "FROM " + RetSQLName("BD6") + " WHERE "
cSQL += "BD6_OPEUSR >= '" + cOpeDe + "' AND BD6_OPEUSR <=  '" + cOpeAte + "' AND "
cSQL += "BD6_CODEMP >= '" + cEmpDe + "' AND BD6_CODEMP <=  '" + cEmpAte + "' AND "
cSQL += "BD6_CONEMP >= '" + cConDe + "' AND BD6_CONEMP <=  '" + cConAte + "' AND "
cSQL += "BD6_VERCON >= '" + cVerDe + "' AND BD6_VERCON <=  '" + cVerAte + "' AND "
cSQL += "BD6_SUBCON >= '" + cSubDe + "' AND BD6_SUBCON <=  '" + cSubAte + "' AND "
cSQL += "BD6_VERSUB >= '" + cVesDe + "' AND BD6_VERSUB <=  '" + cVesAte + "' AND "
cSQL += "BD6_MATRIC >= '" + cMatDe + "' AND BD6_MATRIC <=  '" + cMatAte + "' AND "
cSQL += "BD6_MESPAG  = '" + cMes   + "' AND "
cSQL += "BD6_ANOPAG  = '" + cAno   + "' AND "
cSQL += RetSQLName("BD6") + ".D_E_L_E_T_ = '' "

PLSQuery(cSQL,"Trb")                                                                         

If Trb->(Eof())
   Trb->(DbCloseArea())
   Help("",1,"REGNOIS")
   Return
Endif   
nQtdArq := Trb->QTD
nQtdLid := 0
Trb->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define query de acesso...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT "
cSQL += "BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_CODPRO,BD6_VLRTPF,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,"
cSQL += "BD6_TIPREG,BD6_DIGITO,BD6_DATPRO,BD6_QTDPRO,BD6_NUMIMP,BD6_CODRDA,BD6_DESPRO,BD6_NOMRDA,BD6_NOMUSR, "
cSQL += "BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_CID, "
cSQL += RetSQLName("BD6") + ".R_E_C_N_O_ BD6_RECNO "
cSQL += "FROM " + RetSQLName("BD6") + " WHERE "
cSQL += "BD6_OPEUSR >= '" + cOpeDe + "' AND BD6_OPEUSR <=  '" + cOpeAte + "' AND "
cSQL += "BD6_CODEMP >= '" + cEmpDe + "' AND BD6_CODEMP <=  '" + cEmpAte + "' AND "
cSQL += "BD6_CONEMP >= '" + cConDe + "' AND BD6_CONEMP <=  '" + cConAte + "' AND "
cSQL += "BD6_VERCON >= '" + cVerDe + "' AND BD6_VERCON <=  '" + cVerAte + "' AND "
cSQL += "BD6_SUBCON >= '" + cSubDe + "' AND BD6_SUBCON <=  '" + cSubAte + "' AND "
cSQL += "BD6_VERSUB >= '" + cVesDe + "' AND BD6_VERSUB <=  '" + cVesAte + "' AND "
cSQL += "BD6_MATRIC >= '" + cMatDe + "' AND BD6_MATRIC <=  '" + cMatAte + "' AND "
cSQL += "BD6_MESPAG  = '" + cMes   + "' AND "
cSQL += "BD6_ANOPAG  = '" + cAno   + "' AND "
cSQL += RetSQLName("BD6") + ".D_E_L_E_T_ = '' "
cSQL += "ORDER BY BD6_FILIAL,BD6_OPEUSR,BD6_CODEMP,BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_MATRIC,BD6_TIPREG,BD6_DIGITO,BD6_DATPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN"

PLSQuery(cSQL,"Trb")                                                                         

If Trb->(Eof())
   Trb->(DbCloseArea())
   Help("",1,"REGNOIS")
   Return
Endif   
BD7->(DBSetOrder(1))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processa arquivo de trabalho                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! Trb->(Eof())

   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Mensagem de processamento                                  			    Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   msProcTxt("Processando " + alltrim(str(nQtdLid)) + " de " + alltrim(str(nQtdArq)))
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posiciona BD6                                                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BD6->(dbGoTo(Trb->BD6_RECNO))
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posiciona BD7                                                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  ! BD7->(DbSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
       aadd(aLog1,{"BD7 nao encontrado","Chave BD6: ",BD6->(BD6_CODOPE+" "+BD6_CODLDP+" "+BD6_CODPEG+" "+BD6_NUMERO+" "+BD6_ORIMOV+" "+BD6_SEQUEN)})
       Trb->(dbSkip())
       msgstop("1")
       Loop
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Salta registros      		                                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  BD6->BD6_VLRTPF == 0
       Trb->(dbSkip())
       msgstop("2")
       Loop
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Inicializa variaveis 		                                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   aRecBD7  := {}
   nTotPer  := 0
   nTotTpf  := 0
   nTotBpf  := 0
   nTotTad  := 0
   nTotPag  := 0
   nQtdBD7  := 0
   lTemPerc := .T.
   lTemVlr  := .T.
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Processa BD7         		                                            Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   While ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
                             xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Salva valores                                                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If  BD7->BD7_PERCEN == 0
          lTemPerc := .F.
      Endif
      If  BD7->BD7_VLRPAG == 0
          lTemVlr  := .F.
      Endif
      nQtdBD7++
      
      nTotPer  += noround(BD7->BD7_PERCEN,4)
      nTotTpf  += BD7->BD7_VLRTPF
      nTotBpf  += BD7->BD7_VLRBPF
      nTotTad  += BD7->BD7_VLRTAD
      nTotPag  += noround(BD7->BD7_VLRPAG,2)
      aadd(aRecBD7,{BD7->(RecNo()),;
                    BD7->BD7_PERCEN,;
                    BD7->BD7_VLRTPF,;
                    BD7->BD7_VLRTAD,;
                    BD7->BD7_VLRPAG,;
                    BD7->BD7_VLRBPF})
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa proximo registro                                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BD7->(dbSkip())
   End         

   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se valores estao corretos                                       Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  nTotPer == 100                                    .and. ;
       noround(nTotTpf,2) == noround(BD6->BD6_VLRTPF,2) .and. ;
       noround(nTotTad,2) == noround(BD6->BD6_VLRTAD,2) .And. ;
       noround(nTotBPF,2) == noround(BD6->BD6_VLRBPF,2) .And. ;
       Trb->(dbSkip())
       msgstop("3")
       Loop    
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se pode ajustar o %                                             Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nDif := 100 - nTotPer
   If  nDif  <> 0 .and. ;
       lTemPerc   .and. ;
       abs(nDif)  < 1
       aRecBD7[1,2] += nDif
       nTotPer      := 100
   Endif
   If  nDif <> 0 .and. ;
       nQtdBD7 == 1
       aRecBD7[1,2] := 100
       nTotPer      := 100
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Verifica se eh possivel recalcular                                       Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  nTotPer <> 100 .and. ;
       ! lTemVlr
       aadd(aLog1,{"BD7 nao valorizado","Chave BD6: ",BD6->(BD6_CODOPE+" "+BD6_CODLDP+" "+BD6_CODPEG+" "+BD6_NUMERO+" "+BD6_ORIMOV+" "+BD6_SEQUEN)})
       Trb->(dbSkip())
       msgstop("4")
       Loop
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Ajusta valores                                                           Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
       lErroPerc := .F.
       lErroVlr  := .F.
       If  nTotPer <> 100
           lErroPerc := .T.
       Endif
       If  noround(nTotTpf,2) <> noround(BD6->BD6_VLRTPF,2) .or. ;
           noround(nTotTad,2) <> noround(BD6->BD6_VLRTAD,2) .oR. ;
           noround(nTotBPF,2) <> noround(BD6->BD6_VLRBPF,2)
           lErroVlr := .T.
       Endif
       If  lErroPerc .or. lErroVlr
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Percentual                                                               Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           If  lErroPerc
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Recalcula percentual                                                     Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               ntPerc := 0
               For i := 1 to len(aRecBD7)
                   If  nQtdBD7 == 1
                       aRecBD7[i,2] := 100                                // calcula percentual
                       ntPerc       := 100                                 // acumula percentual
                   Else           
                       aRecBD7[i,2] := noround(aRecBD7[i,5] / nTotPag,4)  // calcula percentual
                       ntPerc       += aRecBD7[i,2]                        // acumula percentual
                   Endif
               Next
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Ajusta diferenca de 100%                                                 Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               If  ntPerc <> 100
                   i := len(aRecBD7)
                   If  (aRecBD7[i,2] + 100 - ntPerc) > 0 // verifica se fica positivo
                       aRecBD7[i,2] += 100 - ntPerc          // ajusta percentual no ultimo registro
                   Else
                       For i := 1 to len(aRecBD7)
                           If  (aRecBD7[i,2] + 100 - ntPerc) > 0
                               aRecBD7[i,2] += 100 - ntPerc          // ajusta percentual no ultimo registro
                               Exit
                           Endif
                       Next
                   Endif
               Endif
           Endif
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Recalcula o valor/taxa da participacao financeira                        Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           ntVlr := 0
           ntTax := 0
           ntBas := 0
           For i := 1 to len(aRecBD7)
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Recalcula o valor da participacao financeira                             Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRecBD7[i,3] := noround(BD6->BD6_VLRTPF * aRecBD7[i,2] / 100,2)  // calcula valor participacao financeira
               ntVlr        += aRecBD7[i,3]                                   // acumula valor participacao financeira
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Recalcula o valor da taxa adm                                            Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRecBD7[i,4] := noround(BD6->BD6_VLRTAD * aRecBD7[i,2] / 100,2)  // calcula valor taxa adm
               ntTax        += aRecBD7[i,4]                                   // acumula valor taxa adm

               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Recalcula o valor da base PF                                             Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               aRecBD7[i,6] := noround(BD6->BD6_VLRBPF * aRecBD7[i,2] / 100,2)  // calcula valor base PF 
               ntBas        += aRecBD7[i,6]                                   // acumula valor base PF  
           Next
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Ajusta diferenca entre total e BD6                                       Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           If  ntVlr <> noround(BD6->BD6_VLRTPF,2)
               i := len(aRecBD7)
               If  (aRecBD7[i,3] +  BD6->BD6_VLRTPF - ntVlr) > 0           // ajusta valor no ultimo registro
                    aRecBD7[i,3] += BD6->BD6_VLRTPF - ntVlr                // ajusta valor no ultimo registro
               Else
                   For i := 1 to len(aRecBD7)
                       If  (aRecBD7[i,3] +  BD6->BD6_VLRTPF - ntVlr) > 0           // ajusta valor no ultimo registro
                            aRecBD7[i,3] += BD6->BD6_VLRTPF - ntVlr                // ajusta valor no ultimo registro
                           Exit
                       Endif
                   Next
               Endif
           Endif
           If  ntTax <> noround(BD6->BD6_VLRTAD,2)
               i := len(aRecBD7)
               If  (aRecBD7[i,4] +  BD6->BD6_VLRTAD - ntTax) > 0                // ajusta taxa no ultimo registro
                    aRecBD7[i,4] += BD6->BD6_VLRTAD - ntTax                     // ajusta taxa no ultimo registro
               Else
                   For i := 1 to len(aRecBD7)
                       If  (aRecBD7[i,4] +  BD6->BD6_VLRTAD - ntTax) > 0                // ajusta taxa no ultimo registro
                            aRecBD7[i,4] += BD6->BD6_VLRTAD - ntTax                     // ajusta taxa no ultimo registro
                            Exit
                       Endif
                   Next
               Endif
           Endif

           If  ntBas <> noround(BD6->BD6_VLRBPF,2)
               i := len(aRecBD7)
               If  (aRecBD7[i,6] +  BD6->BD6_VLRBPF - ntBas) > 0                // ajusta base no ultimo registro
                    aRecBD7[i,6] += BD6->BD6_VLRBPF - ntBas                     // ajusta base no ultimo registro
               Else
                   For i := 1 to len(aRecBD7)
                       If  (aRecBD7[i,6] +  BD6->BD6_VLRBPF - ntBas) > 0                // ajusta base no ultimo registro
                            aRecBD7[i,6] += BD6->BD6_VLRBPF - ntBas                     // ajusta base no ultimo registro
                            Exit
                       Endif
                   Next
               Endif
           Endif
           //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
           //Ё Atualiza cada BD7                                                        Ё
           //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
           For i := 1 to len(aRecBD7)
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Posiciona BD7                                                            Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               BD7->(dbGoTo(aRecBD7[i,1]))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Monta linha de detalhe - antes da alteracao dos campos                   Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               cLinha := BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC) + space(2) + ;
                         transform(BD6->BD6_VLRTPF,"@E 99,999.9999") + space(2) + ;
                         transform(BD6->BD6_VLRTAD,"@E 999.9999") + space(2) + ;
                         transform(BD7->BD7_PERCEN,"@E 999.9999") + space(2) + ;
                         transform(BD7->BD7_VLRTPF,"@E 99,999.9999") + space(2) + ;
                         transform(BD7->BD7_VLRTAD,"@E 999.9999") + space(2) 


//               cLinha += if(lErroPerc,transform(aRecBD7[i,2],"@E 99999.9999"),space(10)) + space(1) + ;
//                         transform(aRecBD7[i,3],"@E 999,999.9999") + space(1) + ;
//                         transform(aRecBD7[i,4],"@E 999,999.9999") + space(1) 
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Atualiza BD7                                                             Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               BD7->(RecLock("BD7",.F.))
               If  lErroPerc
                   BD7->BD7_PERCEN := aRecBD7[i,2]
               Endif
               BD7->BD7_VLRTPF := aRecBD7[i,3]
               BD7->BD7_VLRTAD := aRecBD7[i,4]
               BD7->BD7_VLRBPF := aRecBD7[i,6]
               BD7->(msUnLock())  
               
               //msgstop("Recno BD7 "+AllTrim(Str(BD7->(Recno())))+" BD7_VLRBPF "+Str(BD7->BD7_VLRBPF,17,2))
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Monta linha de detalhe - apos da alteracao dos campos                    Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               cLinha += if(lErroPerc,transform(BD7->BD7_PERCEN,"@E 999.9999"),space(10)) + space(2) + ;
                         transform(BD7->BD7_VLRTPF,"@E 99,999.9999") + space(2) + ;
                         transform(BD7->BD7_VLRTAD,"@E 999.9999") + space(1) 
               //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
               //Ё Imprime linha de detalhe                                                 Ё
               //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
               G001Linha(cLinha,1,0)
           Next
       Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acessa proximo registro                                                  Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   Trb->(dbSkip())
Enddo  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivo de trabalho                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Trb->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista log                                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  len(aLog1) > 0
    cLinha := replicate("'",132)
    G001Linha(cLinha,2,1)
    For i := 1 to len(aLog1)
        cLinha := aLog1[i,1] + space(2) + aLog1[i,2] + space(2) + aLog1[i,3]
        G001Linha(cLinha,1,0)
    Next
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё G001Linha Ё Autor Ё Angelo Sperandio     Ё Data Ё 23.01.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime linha de detalhe                                   Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Static Function G001Linha(cLinha,nAntes,nApos)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declara variaveis                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL i 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salta linhas antes                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For i := 1 to nAntes
    nli++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  nli > nLinPag
    nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    nli++
Endif    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime linha de detalhe                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ nLi, 0 pSay cLinha
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Salta linhas apos                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For i := 1 to nApos
    nli++
Next    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё CriaSX1  Ё Autor Ё Angelo Sperandio      Ё Data Ё 05/02/05 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Atualiza perguntas                                         Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё CriaSX1()                                                  Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function CriaSX1()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Iniciliza variaveis                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aRegs	:=	{}
//aadd(aRegs,{cPerg,"20","Lista CID","","","mv_chk","N",1,0,0,"C","","mv_par20","Sim" ,"","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
//aadd(aRegs,{cPerg,"21","Cliente","","","mv_chl","C",6,0,0,"G","","mv_par21","" ,"","","","","","","","","","","","","","","","","","","","","","","","SA1",""})
//aadd(aRegs,{cPerg,"22","Loja","","","mv_chm","C",2,0,0,"G","","mv_par22","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
//aadd(aRegs,{cPerg,"23","Emissao Tit De","","","mv_chn","D",8,0,0,"G","","mv_par23","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
//aadd(aRegs,{cPerg,"24","Emissao Tit Ate","","","mv_cho","D",8,0,0,"G","","mv_par24","" ,"","","","","","","","","","","","","","","","","","","","","","","","",""})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza SX1                                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//PlsVldPerg(aRegs)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Return
