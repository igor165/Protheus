#INCLUDE "EDCPF150.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]
                                   
/*
Funcao      : EDCPF150
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 18/08/2006
Obs         :
Revisão     :
*/
********************
Function EDCPF150
********************
lRet := EDCPF150R3(.T.)
RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCPF150R3 ³ Autor ³ Thomaz             ³ Data ³ 23.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório para o Posto Fiscal                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³ Uso - Drawback                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*------------------------*
Function EDCPF150R3(p_R4)
*------------------------*
Local nOpca:= 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}

Private dDtIniDi, dDtFimDi, cAc, lTop, dDtIniRe, dDtFimRe, cFilED0:= xFilial("ED0")
Private cFilEE9:= xFilial("EE9"), cFilSW8:= xFilial("SW8"), cFilED2:= xFilial("ED2")
Private aHeader[0],aCampos:={}, TB_Campos := {}, cFilSW6:= xFilial("SW6"), cMemoImp
Private cPictRe := AVSX3("EE9_RE", 06), cPictDt := AVSX3("EE9_DTAVRB", 06)
Private cPictDi := AVSX3("W6_DI_NUM", 06), cPictNF := AVSX3("W6_NF_ENT", 06)
Private cPictSeNf := AVSX3("W6_SE_NF", 06), cPictAc:= AVSX3("ED0_AC", 06)
Private mCartaG :="", aMemoCarta:= {}, aMemoTot:={}, cLocDt, cMemoTot:= ""
Private cFilSF1:= xFilial("SF1"), FileWork, cAtoCon, lImp:= .F., cFilED1:= xFilial("ED1")
Private cQuery1, cQuery2, cCond1:= "", cCond2:= "" //Usado no Rdmake EDCPF150_RDM
Private cFilSYT:= xFilial("SYT"), dData
Private lMultiFil  := VerSenha(115)  ;
                      .And.  Posicione("SX2",1,"ED1","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"ED2","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EDD","X2_MODO") == "C" ;
                      .And.  Posicione("SX2",1,"EE9","X2_MODO") == "E" ;
                      .And.  Posicione("SX2",1,"SW8","X2_MODO") == "E" ;
                      .And.  ED1->( FieldPos("ED1_FILORI") ) > 0  ;
                      .And.  ED2->( FieldPos("ED2_FILORI") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILIMP") ) > 0  ;
                      .And.  EDD->( FieldPos("EDD_FILEXP") ) > 0

Private aFil := IIF(lMultiFil,AvgSelectFil(.F.,,"ED0"),{cFilED0}) //AJP 27/06/2007
Private cFilED9:= xFilial("ED9")//AWR - 15/04/2009
Private lTemED9Cpos:=ED9->(FieldPOs("ED9_VAL_SE")) # 0 .AND. ED9->(FieldPOs("ED9_VALCOM")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_VALORI")) # 0 .AND. ED9->(FieldPOs("ED9_UMNCM" )) # 0 .AND.;
                     ED9->(FieldPOs("ED9_QTDNCM")) # 0 .AND. ED9->(FieldPOs("ED9_TX_USS")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DTAVRB")) # 0 .AND. ED9->(FieldPOs("ED9_ISENTO")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_SALISE")) # 0 .AND. ED9->(FieldPOs("ED9_FASEDR")) # 0 .AND.;
                     ED9->(FieldPOs("ED9_DT_INT")) # 0 .AND. SIX->(dbSeek("ED9"+"4"))//AWR - 15/04/2009

//JPA - 18/08/2006 - Relatório Personalizavel - Release 4
Private oReport
Private lR4   := If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()
PRIVATE lCposNFDesp :=    (SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;                   //NCF - Campos da Nota Fiscal de Despesas
                     .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                     .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)

oMainWnd:ReadClientCoords() 

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

While .T.

   If ! Pergunte("EDCPF1",.T.)
      Return .F.
   EndIf

   cAc      := mv_par01
   dDtIniDi := mv_par02
   dDtFimDi := mv_par03
   dDtIniRe := mv_par04
   dDtFimRe := mv_par05
   
   If !E_PERIODO_OK(@dDtIniDi,@dDtFimDi) .Or. !E_PERIODO_OK(@dDtIniRe,@dDtFimRe)
      Loop
   Endif

   If nOpca == 1
      If !PF150TELA()
         Exit
      Endif
   Else
      Loop
   Endif

EndDo

ED0->(DBSETORDER(1))

If Select("Work") <> 0
   Work->(E_ERASEARQ(FileWork))
Endif

Return

*-----------------------------*
Static Function EDCPF150GERA()
*-----------------------------*
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatório "
Local cDesc2         := STR0002 //"para o Posto Fiscal."
Local cDesc3         := ""
Private titulo       := STR0003 //"Relatório para o Posto Fiscal."
Private nLin         := 80, Cabec1 := "", Cabec2 := ""
Private cString      := "EE9", lEnd := .F.
Private lAbortPrint  := .F., limite := 80, tamanho := "P"
Private nomeprog     := "EDCPF150", nTipo := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administração"
Private nLastKey     := 0, cBtxt := Space(10), cBcont := 00
Private CONTFL       := 01, m_pag := 01
Private wnrel        := "EDCPF150" // Coloque aqui o nome do arquivo usado para impressao em disco

// ACSJ - 01/04/2005 - INICIO
PF150CriaWorks()             
// ----------------- - FIM
nTotal:=50
nCount:=0

If lTop//GERA WORK COM SELECT

   Processa({|| GeraQuery()     }, STR0006) //"Aguarde Pesquisando Dados"

ElseIf lR4//GERA WORK COM AS TABELAS

   Processa({|| PF150GeraWork() }, STR0006) //"Aguarde Pesquisando Dados"   

Endif

If lR4 

   IF Work->(EasyRecCount("Work")) = 0
      Help(" ",1,"AVG0005112") //"Não ha dados para a Impressao!
      Return .T.
   ELSE
      oReport:=ReportDef()
      oReport:PrintDialog()//LE WORK
   ENDIF
   
ELSE

   If lTop .AND. Work->(EasyRecCount("Work")) = 0
      Help(" ",1,"AVG0005112") //"Não ha dados para a Impressao!
      Return .T.
   ENDIF

   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

   If nLastKey = 27
      Return
   Endif

   SetDefault(aReturn,cString)

   nTipo := If(aReturn[4]==1,15,18)

   If lTop
      RptStatus({|| Imprime(wnRel,cString) } ,, "Imprimindo dados, Aguarde..")//LE WORK
   ELSE
      RptStatus({|| Imprime(wnRel,cString) } ,, "Imprimindo dados, Aguarde..")//LE TABELAS
   ENDIF

ENDIF

If Select("Work") <> 0         
   Work->(avzap())
ENDIF

Return .T.

*--------------------------------------*
Static Function Imprime(wnrel,cString)
*--------------------------------------*
//Colunas da Exp.
Local nCol1:=00, nCol2:=nCol1+09, nCol3:=nCol2+17, nCol4:=nCol3+15, aHawb:= {}, i
//Colunas da Imp.
Local nCol5:=00, nCol6:=nCol5+09, nCol7:=nCol6+14, nCol8:=nCol7+10, lCartaAc:= .F., lGerou:= .F.
Local nCol9:=nCol8+10, nCol10:=nCol9+11, nCol11:=nCol10+08, nCol12:=nCol11+07, lReturn:= .T.
Local nFilInd :=0 
Private nLin := 99

ED0->(DbSetOrder(2))
ED0->(DbSeek( (cFilED0+cAc),.t.))   //LRL 03/05/04
//ED0->( DBGotop() )                                                                   

SetRegua(nTotal)
nCount:=0

If Empty(cAc)
   bWhile:={|| cFilED0 == ED0->ED0_FILIAL}
Else
   bWhile:={|| cFilED0 == ED0->ED0_FILIAL .AND. cAc == ED0->ED0_AC}
   ED0->( DBSeek(cFilED0+cAc) )
Endif

If !lTop

   lCarta:= .T.

   Do While !ED0->(EOF()) .AND. Eval(bWhile)
      
      If Empty(ED0->ED0_AC)
         ED0->(dbSkip())
         Loop
      Endif
    
      For nFilInd :=1 to Len(aFil) //AJP 27/06/2007
         If lMultiFil
            cFilEE9 := aFil[nFilInd]
            cFilSW6 := aFil[nFilInd]
            cFilSW8 := aFil[nFilInd]
            cFilSF1 := aFil[nFilInd]
         EndIf
      
         EE9->(DbSetOrder(10))
         EE9->(DbSeek(cFilEE9+ED0->ED0_AC))
  
         Do While !EE9->(EOF()) .AND. cFilEE9 == EE9->EE9_FILIAL .AND. EE9->EE9_ATOCON == ED0->ED0_AC

         IF nCount > nTotal
            SetRegua(nTotal)
            nCount:=0
         ELSE 
            IncRegua()
            nCount++
         ENDIF
      
            If Empty(EE9->EE9_RE) .Or. ED0->ED0_MODAL == "2" //Isenção
               EE9->(dbSkip())
               Loop
            Endif

            If EE9->EE9_DTAVRB < dDtIniRe .Or. EE9->EE9_DTAVRB > dDtFimRe
               EE9->(dbSkip())
               Loop
            Endif

            If nLin >= 47 .And. lCarta .And. lImp
               EDCPF150CAB(EE9->EE9_ATOCON, lImp)
               lCartaAc:= .T.
               SYT->(DbSetOrder(1))
               SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))
               cLocDt:=Alltrim(Upper(Left(Alltrim(SYT->YT_CIDADE),1)))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData
               @ nLin,nCol3 PSAY __PrtRight(cLocDt) //Alinha à Direita
               nLin:=nLin+2
               For i:= 1 to Len(aMemoCarta)
                  @ nlin,nCol1 Psay __PrtLeft(aMemoCarta[i])
                  nLin:=nLin+1
               Next
               nLin:= nLin+2
               @ nLin,nCol1 PSAY __PrtLeft(STR0039+EE9->EE9_ATOCON) //'* "DRAWBACK" nº: '
               nLin:=nLin+2
         
               nImp:= 45
               @ nImp, nCol1 PSAY __PrtLeft(STR0023+Alltrim(EE9->EE9_ATOCON)+STR0024+dToc(ED0->ED0_DT_REG)) //"Observação - Segue em anexo cópia do Ato Conceesório nº "###" ,de "
               nImp:= nImp+2
               If Len(aMemoTot) > 0
                  @ nImp,nCol1 PSAY __PrtThinline()
               Endif
               nImp:= nImp+1
               For i:= 1 to Len(aMemoTot)
                  If aMemoTot[i] == Replicate("-",13)
                     cCarta:= Alltrim(cLocDt)
                     @ nImp,nCol1 Psay __PrtLeft(cCarta)
                     nImp:=nImp+1
                  Else
                     @ nImp,nCol1 Psay aMemoTot[i]
                     nImp:= nImp+1
                  Endif
               Next i
               nLin:= 99
               lCarta:= .F.
            Endif

            If nLin >= 58
               EDCPF150CAB(EE9->EE9_ATOCON, lImp)
            Endif

            @ nlin,nCol1 Psay STR0025 //" - R.E."
            @ nlin,nCol2 Psay Transf(EE9->EE9_RE, cPictRe)
         
            @ nlin,nCol3 Psay STR0026 //"Dt. Averbação"
            @ nlin,nCol4 Psay Transf(EE9->EE9_DTAVRB, cPictDt)
         
            nLin:=nLin+2
         
            lGerou:= .T.

            EE9->(dbSkip())
         EndDo

         nLin:= 99
         lCarta:= .T.
    
      IF lTemED9Cpos
         PF150ImpED9()//AWR - 15/04/2009
      ENDIF

      nLin:= 99
      lCarta:= .T.
    
         SW8->(dbSetOrder(5))
         SW8->(dbSeek(cFilSW8+ED0->ED0_AC))

         Do While !SW8->(EOF()) .AND. cFilSW8 == SW8->W8_FILIAL .AND. SW8->W8_AC == ED0->ED0_AC

         IF nCount > nTotal
            SetRegua(nTotal)
            nCount:=0
         ELSE 
            IncRegua()
            nCount++
         ENDIF

            SW6->(dbSetOrder(1))
            SW6->(dbSeek(cFilSW6+SW8->W8_HAWB))
     
            Do While !SW6->(EOF()) .AND. cFilSW6 == SW6->W6_FILIAL .AND. SW8->W8_HAWB == SW6->W6_HAWB

               If Empty(SW6->W6_DI_NUM)
                  SW6->(dbSkip())
                  Loop
               Endif

               If SW6->W6_DTREG_D < dDtIniDi .Or. SW6->W6_DTREG_D > dDtFimDi
                  SW6->(dbSkip())
                  Loop
               Endif

               SF1->(dbSetOrder(5))
               SF1->(dbSeek(cFilSF1+SW6->W6_HAWB))

               Do While !SF1->(EOF()) .AND. cFilSF1 == SF1->F1_FILIAL .AND. SF1->F1_HAWB == SW6->W6_HAWB
                  
                  //ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
                  If lCposNFDesp .AND. !ExistHAWBNFE(SF1->F1_HAWB)
                     SF1->(DbSkip())
                     Loop
                  EndIf
                     
                  nPos:=ASCAN(aHawb,{|x| x[1]==SW6->W6_HAWB .And. x[2]==SW6->W6_DI_NUM .And. x[3]==SW6->W6_DTREG_D .And. x[4]==SF1->F1_DOC .and. x[5]==SF1->F1_SERIE})

                  If nLin >= 47 .And. lCarta .And. lImp .And. !lCartaAc
                     EDCPF150CAB(SW8->W8_AC, lImp)
                     cLocDt:=Alltrim(Upper(Left(Alltrim(SYT->YT_CIDADE),1)))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData
                     @ nLin,nCol3 PSAY __PrtRight(cLocDt) //Alinha à Direita
                     nLin:=nLin+2
                     For i:= 1 to Len(aMemoCarta)
                        @ nlin,nCol1 Psay __PrtLeft(aMemoCarta[i])
                        nLin:=nLin+1
                     Next
                     nLin:= nLin+2
                     @ nLin,nCol1 PSAY __PrtLeft(STR0039+SW8->W8_AC) //'* "DRAWBACK" nº: '
                     nLin:=nLin+2
         
                     nImp:= 45
                     @ nImp, nCol1 PSAY __PrtLeft(STR0023+Alltrim(SW8->W8_AC)+STR0024+dToc(ED0->ED0_DT_REG)) //"Observação - Segue em anexo cópia do Ato Conceesório nº "###" ,de "
                     nImp:= nImp+2
                     If Len(aMemoTot) > 0
                        @ nImp,nCol1 PSAY __PrtThinline()
                     Endif
                     nImp:= nImp+1
                     For i:= 1 to Len(aMemoTot)
                        If aMemoTot[i] == Replicate("-",13)
                           cCarta:= Alltrim(cLocDt)
                           @ nImp,nCol1 Psay __PrtLeft(cCarta)
                           nImp:=nImp+1
                        Else
                           @ nImp,nCol1 Psay aMemoTot[i]
                           nImp:= nImp+1
                        Endif
                     Next i
                     nLin:= 99
                     lCarta:= .F.
                  Endif

                  If nLin >= 58
                     EDCPF150CAB(SW8->W8_AC, lImp)
                  Endif
                                                            
                  If nPos = 0

                     AADD(aHawb,{SW6->W6_HAWB,SW6->W6_DI_NUM,SW6->W6_DTREG_D,SF1->F1_DOC,SF1->F1_SERIE})
                   
                     @ nLin,nCol5 PSAY STR0027  //" - D.I.:"
                     @ nLin,nCol6 PSAY Transf(SW6->W6_DI_NUM, cPictDi)

                     @ nLin,nCol7 PSAY STR0028  //"Dt. D.I.:"
                     @ nLin,nCol8 PSAY Transf(SW6->W6_DTREG_D, cPictDt)

                     @ nlin,nCol9 Psay STR0029   //"Nro. N.F.:"
                     @ nlin,nCol10 Psay Transf(SF1->F1_DOC, cPictNF)
      
                     @ nlin,nCol11 Psay STR0030  //"Série:"
                     @ nlin,nCol12 Psay Transf(SF1->F1_SERIE, cPictSeNf)

                     nLin:= nLin+2

                  Endif
               
                  lGerou:= .T.
               
                  SF1->(dbSkip())
               EndDo
               SW6->(dbSkip())
            EndDo
            SW8->(dbSkip())
         EndDo
      Next
      ED0->(dbSkip())
   EndDo
Else

   Work->(dbGotop())
   cAtoCon:= Work->ATOCON
   cTipo  := Work->TIPO
   lCarta := .T.
   
   SetRegua(Work->(EasyRecCount("Work")))
   
   Do While !Work->(EOF())
   
      IncRegua()
   
      If nLin >= 47 .And. lCarta .And. lImp
         EDCPF150CAB(Work->ATOCON, lImp)
         SYT->(DbSetOrder(1))
         SYT->(DbSeek(cFilSYT+Work->IMPORT))
         cLocDt:=Alltrim(Upper(Left(Alltrim(SYT->YT_CIDADE),1)))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData
         @ nLin,nCol3 PSAY __PrtRight(cLocDt) //Alinha à Direita
         nLin:=nLin+2
         For i:= 1 to Len(aMemoCarta)
            @ nlin,nCol1 Psay __PrtLeft(aMemoCarta[i])
            nLin:=nLin+1
         Next
         nLin:= nLin+2
         @ nLin,nCol1 PSAY __PrtLeft(STR0039+Work->ATOCON) //'* DRAWBACK nº: '
         nLin:=nLin+2
         
         nImp:= 45
         @ nImp, nCol1 PSAY __PrtLeft(STR0023+Alltrim(Work->ATOCON)+STR0024+dToc(Work->DT_AC)) //"Observação - Segue em anexo cópia do Ato Conceesório nº "###" ,de "
         nImp:= nImp+2
         If Len(aMemoTot) > 0
            @ nImp,nCol1 PSAY __PrtThinline()
         Endif
         nImp:= nImp+1
         For i:= 1 to Len(aMemoTot)
            If aMemoTot[i] == Replicate("-",13)
               cCarta:= Alltrim(cLocDt)
               @ nImp,nCol1 Psay __PrtLeft(cCarta)
               nImp:=nImp+1
            Else
               @ nImp,nCol1 Psay aMemoTot[i]
               nImp:= nImp+1
            Endif
         Next i
         nLin:= 99
         lCarta:= .F.
      Endif
      
      lGerou:= .T.

      If nLin >= 58
         EDCPF150CAB(WORK->ATOCON, lImp)
      Endif
      
      If Work->TIPO == "E"
         @ nLin,nCol1 PSAY STR0025 //" - R.E."
         @ nLin,nCol2 PSAY Transf(Work->DI_NUM, cPictRe)
         
         @ nLin,nCol3 PSAY STR0026 //"Dt. Averbação"
         @ nLin,nCol4 PSAY Transf(Work->DTREG_D, cPictDt)
      Else
         @ nLin,nCol5 PSAY IIF(Work->TIPO=="X",STR0046, STR0027) //" - D.I.:"
         @ nLin,nCol6 PSAY Transf(Work->DI_NUM, cPictDi)
         
         @ nLin,nCol7 PSAY STR0028 //"Dt. D.I.:"
         @ nLin,nCol8 PSAY Transf(Work->DTREG_D, cPictDt)
         
         @ nlin,nCol9 Psay STR0029 //"Nro. N.F.:"
         @ nlin,nCol10 Psay Transf(Work->NF_ENT, cPictNF)
         
         @ nlin,nCol11 Psay STR0030 //"Série:"
         @ nlin,nCol12 Psay Transf(Work->SE_NF, cPictSeNf)
      Endif
      
      nLin:=nLin+2

      Work->(dbSkip())
      
      If cAtoCon <> Work->ATOCON
         cAtoCon:= Work->ATOCON
         lCarta:= .T.
         nLin:= 99
         cTipo:= Work->TIPO
      ElseIf cTipo <> Work->TIPO
         cTipo:= Work->TIPO
         nLin:= 99
      Endif
   EndDo
Endif

If lGerou
   If aReturn[5] = 1
      Set Printer To
      Commit
      Ourspool(wnrel)
   Endif
Else
   Help(" ",1,"AVG0005112")//"Não há Dados para Impressão!"
   lReturn:= .F.
Endif

MS_FLUSH()
 
Return lReturn

*-----------------------------------------------------------*
Static Function PF150ImpED9()//AWR - 15/04/2009 LE TABELAS NO DBF
*-----------------------------------------------------------*
LOCAL I
ED9->(DbSetOrder(3))
ED9->(DbSeek(cFilED9+ED0->ED0_AC))

Do While !ED9->(EOF()) .AND. cFilED9 == ED9->ED9_FILIAL .AND. ED9->ED9_AC == ED0->ED0_AC

   IF nCount > nTotal
      SetRegua(nTotal)
      nCount:=0
   ELSE 
      IncRegua()
      nCount++
   ENDIF

   If Empty(ED9->ED9_RE) .Or. ED0->ED0_MODAL == "2" //Isenção
      ED9->(dbSkip())
      Loop
   Endif

   If ED9->ED9_DTAVRB < dDtIniRe .Or. ED9->ED9_DTAVRB > dDtFimRe
      ED9->(dbSkip())
      Loop
   Endif

   If nLin >= 47 .And. lCarta .And. lImp
      EDCPF150CAB(ED9->ED9_AC, lImp)
      lCartaAc:= .T.
      SYT->(DbSetOrder(1))
      SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))
      cLocDt:=Alltrim(Upper(Left(Alltrim(SYT->YT_CIDADE),1)))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData
      @ nLin,nCol3 PSAY __PrtRight(cLocDt) //Alinha à Direita
      nLin:=nLin+2
      For i:= 1 to Len(aMemoCarta)
         @ nlin,nCol1 Psay __PrtLeft(aMemoCarta[i])
         nLin:=nLin+1
      Next
      nLin:= nLin+2
      @ nLin,nCol1 PSAY __PrtLeft(STR0039+ED9->ED9_AC) //'* "DRAWBACK" nº: '
      nLin:=nLin+2

      nImp:= 45
      @ nImp, nCol1 PSAY __PrtLeft(STR0023+Alltrim(ED9->ED9_AC)+STR0024+dToc(ED0->ED0_DT_REG)) //"Observação - Segue em anexo cópia do Ato Conceesório nº "###" ,de "
      nImp:= nImp+2
      If Len(aMemoTot) > 0
         @ nImp,nCol1 PSAY __PrtThinline()
      Endif
      nImp:= nImp+1
      For i:= 1 to Len(aMemoTot)
         If aMemoTot[i] == Replicate("-",13)
            cCarta:= Alltrim(cLocDt)
            @ nImp,nCol1 Psay __PrtLeft(cCarta)
            nImp:=nImp+1
         Else
            @ nImp,nCol1 Psay aMemoTot[i]
            nImp:= nImp+1
         Endif
      Next i
      nLin:= 99
      lCarta:= .F.
   Endif

   If nLin >= 58
      EDCPF150CAB(ED9->ED9_AC, lImp)
   Endif

   @ nlin,nCol1 Psay STR0025 //" - R.E."
   @ nlin,nCol2 Psay Transf(ED9->ED9_RE, cPictRe)

   @ nlin,nCol3 Psay STR0026 //"Dt. Averbação"
   @ nlin,nCol4 Psay Transf(ED9->ED9_DTAVRB, cPictDt)

   nLin:=nLin+2

   lGerou:= .T.

   ED9->(dbSkip())

EndDo

RETURN .T.
*--------------------------------*
Static Function GeraQuery()
*--------------------------------*
Local cCondDel1:=" AND ED0.D_E_L_E_T_ <>'*' AND SW6.D_E_L_E_T_ <>'*' AND SW8.D_E_L_E_T_ <>'*' AND SF1.D_E_L_E_T_ <>'*' "
Local cCondDel2:=" AND ED0.D_E_L_E_T_ <>'*' AND EE9.D_E_L_E_T_ <>'*' "
Local nFilInd := 0
Local cAS400Del1:=" AND ED0.@DELETED@ <>'*' AND SW6.@DELETED@ <>'*' AND SW8.@DELETED@ <>'*' AND SF1.@DELETED@ <>'*' "
Local cAS400Del2:=" AND ED0.@DELETED@ <>'*' AND EE9.@DELETED@ <>'*' "
// ACSJ - 01/04/2005
// PF150CriaWorks() -- Função chamada antes da verificação da variavel lTop

ProcRegua(nTotal)
nCount:=0

ED0->(dbSetOrder(2))
ED0->(dbSeek(cFilED0+cAc))

If Empty(cAc)
   cWhere:= " AND (ED0.ED0_AC <> '' OR ED0.ED0_AC <> ' ')"
Else
   cWhere:= " AND ED0.ED0_AC = '"+cAc+"'"
Endif

If lMultiFil               
   cFil := ""
   For nFilInd :=1 to len(aFil)
      If nFilInd > 1
         cFil += ","
      Endif
      cFil += aFil[nFilInd]
   Next
   cCond1:=" ED0.ED0_FILIAL='"+ cFilED0+ "' "+cWhere+" AND ED0.ED0_AC = SW8.W8_AC "
   cCond1+=" AND SW8.W8_FILIAL In ("+ cFil+ ") AND SW8.W8_HAWB = SW6.W6_HAWB AND SW6.W6_FILIAL In ("+ cFil+ ") "
   //ISS - 13/12/10 - Alteração da condição usada quando o ambiente estiver com o tratamento de NFD, assim evitando o uso delas.
   If lCposNFDesp 
      cCond1+=" AND SW6.W6_HAWB = SF1.F1_HAWB AND SF1.F1_TIPO_NF <> '' AND SF1.F1_FILIAL In ("+ cFil+ ") "
   Else
   cCond1+=" AND SW6.W6_HAWB = SF1.F1_HAWB AND SF1.F1_FILIAL In ("+ cFil+ ") "
   EndIf
Else
   cCond1:=" ED0.ED0_FILIAL='"+ cFilED0+ "' "+cWhere+" AND ED0.ED0_AC = SW8.W8_AC "
   cCond1+=" AND SW8.W8_FILIAL='"+ cFilSW8+ "' AND SW8.W8_HAWB = SW6.W6_HAWB AND SW6.W6_FILIAL='"+ cFilSW6+ "' "
      If lCposNFDesp 
      cCond1+=" AND SW6.W6_HAWB = SF1.F1_HAWB AND SF1.F1_TIPO_NF <> '' AND SF1.F1_FILIAL='"+ cFilSF1+ "' "
   Else
   cCond1+=" AND SW6.W6_HAWB = SF1.F1_HAWB AND SF1.F1_FILIAL='"+ cFilSF1+ "' "
   EndIf
EndIf

cQuery1 := " SELECT DISTINCT ED0.ED0_FILIAL, ED0.ED0_PD, ED0.ED0_AC, ED0.ED0_IMPORT, ED0.ED0_DT_REG, "
cQuery1 += " SW8.W8_FILIAL, SW8.W8_AC, SW8.W8_HAWB, SW6.W6_FILIAL, SW6.W6_HAWB, SW6.W6_DI_NUM, "
cQuery1 += " SW6.W6_DTREG_D, SF1.F1_FILIAL, SF1.F1_HAWB, SF1.F1_DOC, SF1.F1_SERIE FROM "
cQuery1 += RetSqlName('ED0')+ " ED0, " +RetSqlName('SW6')+" SW6, "+RetSqlName('SW8')+" SW8, "
cQuery1 += RetSqlName('SF1')+" SF1 WHERE " +cCond1+" "
      
If EasyEntryPoint("EDCPF150")
   ExecBlock("EDCPF150",.F.,.F.,"QUERY")
Endif

cQuery1 +=If(TcSrvType()<>"AS/400",cCondDel1,cAS400Del1)
      
If !Empty(dDtIniDi)
   cQuery1 += " AND SW6.W6_DTREG_D >= '"+DTOS(dDtIniDi)+"'"
Endif

If !Empty(dDtFimDi)
   cQuery1 += " AND SW6.W6_DTREG_D <= '"+DTOS(dDtFimDi)+"'"
Endif

cQuery1:=ChangeQuery(cQuery1)
TcQuery cQuery1 ALIAS "TRB1" NEW
TCSETFIELD("TRB1","W6_DTREG_D","D")
TCSETFIELD("TRB1","ED0_DT_REG","D")

dbSelectArea("TRB1")
Do While !TRB1->(EOF())

   Work->(RecLock("Work",.T.))
   Work->ATOCON := TRB1->ED0_AC
   Work->DI_NUM := TRB1->W6_DI_NUM
   Work->DTREG_D:= TRB1->W6_DTREG_D   
   Work->PED    := TRB1->ED0_PD
   Work->IMPORT := TRB1->ED0_IMPORT                   
   Work->DT_AC  := TRB1->ED0_DT_REG
   Work->TIPO   := "I"
   Work->NF_ENT := TRB1->F1_DOC
   Work->SE_NF  := TRB1->F1_SERIE

   If EasyEntryPoint("EDCPF150")
      ExecBlock("EDCPF150",.F.,.F.,"GRV_NOTA")
   Endif

   IF nCount > nTotal
      ProcRegua(nTotal)
      nCount:=0
   ELSE 
      IncProc("1/2-Lendo A.C.:"+Work->ATOCON)
      nCount++
   ENDIF

   TRB1->(dbSkip())
EndDo

TRB1->(dbCloseArea())
DBSELECTAREA("Work")
//Exportação
      
cCond2:=" ED0.ED0_FILIAL='" + cFilED0+ "' "+cWhere+" AND ED0.ED0_MODAL = '1' "
cCond2+=" AND ED0.ED0_AC = EE9.EE9_ATOCON AND ED0.ED0_FILIAL = '" + cFilED0+ "' "
cCond2+=" AND EE9.EE9_FILIAL='" + cFilEE9+ "' "

cQuery2 := " SELECT DISTINCT ED0.ED0_FILIAL, ED0.ED0_PD, ED0.ED0_AC, ED0.ED0_MODAL, ED0.ED0_IMPORT, "
cQuery2 += " ED0.ED0_DT_REG, EE9.EE9_FILIAL, EE9.EE9_RE, EE9.EE9_DTAVRB, EE9.EE9_ATOCON FROM "
cQuery2 += RetSqlName('EE9')+ " EE9, "+RetSqlName('ED0')+" ED0 WHERE "+cCond2+" "
                  
cQuery2 +=If(TcSrvType()<>"AS/400",cCondDel2,cAS400Del2)
      
If !Empty(dDtIniRe)
   cQuery2 += " AND EE9.EE9_DTAVRB >= '"+DTOS(dDtIniRe)+"'"
Endif

If !Empty(dDtFimRe)
   cQuery2 += " AND EE9.EE9_DTAVRB <= '"+DTOS(dDtFimRe)+"'"
Endif

cQuery2:=ChangeQuery(cQuery2)
TcQuery cQuery2 ALIAS "TRB2" NEW
TCSETFIELD("TRB2","EE9_DTAVRB","D")
TCSETFIELD("TRB2","ED0_DT_REG","D")

dbSelectArea("TRB2")
Do While !TRB2->(EOF())
   Work->(RecLock("Work",.T.))
   Work->ATOCON := TRB2->ED0_AC
   Work->DI_NUM := TRB2->EE9_RE
   Work->DTREG_D:= TRB2->EE9_DTAVRB
   Work->PED    := TRB2->ED0_PD
   Work->IMPORT := TRB2->ED0_IMPORT
   Work->DT_AC  := TRB2->ED0_DT_REG
   Work->TIPO   := "E"
   Work->(msUnlock())
   IF nCount > nTotal
      ProcRegua(nTotal)
      nCount:=0
   ELSE 
      IncProc("1/2-Lendo A.C.:"+Work->ATOCON)
      nCount++
   ENDIF

   TRB2->(dbSkip())
EndDo
TRB2->(dbCloseArea())
DBSELECTAREA("Work")


IF lTemED9Cpos//AWR - 15/04/2009  \/ \/ \/ \/ \/ \/ \/

   cQuery2 := " SELECT  "

   If TcSrvType() = "AS/400"
      cQuery2 += " ED9.@RECNO@    REGISTRO "
   ELSE
      cQuery2 += " ED9.R_E_C_N_O_ REGISTRO "
   ENDIF
   cQuery2 += " FROM "+RetSqlName('ED9')+ " ED9 WHERE ED9.ED9_FILIAL = '"+ xFilial("ED9") +"' "

   If Empty(cAc)
      cQuery2+= " AND ED9.ED9_AC <> ' ' "
   Else
      cQuery2+= " AND ED9.ED9_AC = '"+cAc+"' "
   Endif

   If !Empty(dDtIniRe)
      cQuery2 += " AND ED9.ED9_DTAVRB >= '"+DTOS(dDtIniRe)+"'"
   Endif
   
   If !Empty(dDtFimRe)
      cQuery2 += " AND ED9.ED9_DTAVRB <= '"+DTOS(dDtFimRe)+"'"
   Endif
   
   cQuery2 += If(TcSrvType() = "AS/400"," AND ED9.@DELETED@ <> '*' "," AND ED9.D_E_L_E_T_ <> '*' ")
   
   cQuery2:=ChangeQuery(cQuery2)
   TcQuery cQuery2 ALIAS "QRY_ED9" NEW

   ED0->(DBSETORDER(2))
   Do While !QRY_ED9->(EOF())
    
      ED9->(DBGOTO(QRY_ED9->REGISTRO))
      IF !ED0->(DBSEEK(cFilED0+ED9->ED9_AC))
         QRY_ED9->(dbSkip())
         LOOP
      ENDIF
      Work->(DBAPPEND())
      Work->ATOCON := ED9->ED9_AC
      Work->DI_NUM := ED9->ED9_RE
      Work->DTREG_D:= ED9->ED9_DTAVRB
      Work->PED    := ED0->ED0_PD
      Work->IMPORT := ED0->ED0_IMPORT
      Work->DT_AC  := ED0->ED0_DT_REG
      Work->TIPO   := "E"

      IF nCount > nTotal
         ProcRegua(nTotal)
         nCount:=0
      ELSE 
         IncProc("1/2-Lendo A.C.:"+Work->ATOCON)
         nCount++
      ENDIF

      QRY_ED9->(dbSkip())
   EndDo
   QRY_ED9->(dbCloseArea())
   DBSELECTAREA("Work")
   ED0->(DBSETORDER(1))
  
ENDIF//AWR - 15/04/2009 /\ /\ /\ /\ /\ /\ /\

//IF EasyGParam("MV_EDCDIE",,.F.) //Alcir Alves - define se virá dados das DI´s externas  - NOPADO POR AOM - 04/11/10
If Empty(cAc)
   cWhere:= " (ED0.ED0_AC <> '' OR ED0.ED0_AC <> ' ')"
Else
   cWhere:= " ED0.ED0_AC = '"+cAc+"'"
Endif
   cQuery2 := " SELECT ED8.ED8_AC,ED8.ED8_DI_NUM,ED8.ED8_DTREG,ED0.ED0_PD,ED0.ED0_IMPORT,ED0.ED0_DT_REG,ED8.ED8_NF,ED8.ED8_SERIE "
cQuery2 += " FROM "+RetSqlName('ED0')+" ED0,"+RetSqlName('ED8')+" ED8 WHERE "+cwhere+" AND ED8.ED8_AC=ED0.ED0_AC "
cQuery2 += " AND ED0.D_E_L_E_T_ <>'*' AND ED8.D_E_L_E_T_ <>'*'
If !Empty(dDtIniRe)
   cQuery2 += " AND ED8.ED8_DTREG >= '"+DTOS(dDtIniRe)+"'"
Endif
If !Empty(dDtFimRe)
   cQuery2 += " AND ED8.ED8_DTREG <= '"+DTOS(dDtFimRe)+"'"
Endif
cQuery2:=ChangeQuery(cQuery2)
TcQuery cQuery2 ALIAS "TRB2" NEW
TCSETFIELD("TRB2","ED8_DTREG","D")
TCSETFIELD("TRB2","ED0_DT_REG","D")
dbSelectArea("TRB2")
Do While !TRB2->(EOF())
   Work->(RecLock("Work",.T.))
   Work->ATOCON := TRB2->ED8_AC
   Work->DI_NUM := TRB2->ED8_DI_NUM
   Work->DTREG_D:= TRB2->ED8_DTREG
   Work->PED    := TRB2->ED0_PD
   Work->IMPORT := TRB2->ED0_IMPORT
   Work->DT_AC  := TRB2->ED0_DT_REG
   Work->NF_ENT := TRB2->ED8_NF
   Work->SE_NF  := TRB2->ED8_SERIE
   Work->TIPO   := "X"
   Work->(msUnlock())
      IF nCount > nTotal
         ProcRegua(nTotal)
         nCount:=0
      ELSE 
         IncProc("1/2-Lendo A.C.:"+Work->ATOCON)
         nCount++
      ENDIF

   TRB2->(dbSkip())
EndDo
TRB2->(dbCloseArea())
   
   DBSELECTAREA("Work")
   
//endif

Return .T.

*----------------------------*
Function PF150Mensagem()
*----------------------------*
Local lRet:= .T.

lImp:= .T.

If AV_ESC_OBS("0",,,,,)
   PF150Carta()
Else
   lRet:= .F.
Endif

Return lRet

*----------------------------*
Static Function PF150Carta()
*----------------------------*
Local nOpc := 0, lRet := .F., mCartaRod:= ""
Local cTit , oDlg2, nVolta, cAss, cAss1
Local cNome:="",cCargo:="", i, z

cLocDt:=""

cTit := STR0031 //"Relatório para o Posto Fiscal"

mCartaG:= Chr(13)+Chr(10)+Space(25)+STR0031+Chr(13)+Chr(10)+Chr(13)+Chr(10) //"Relatório para o Posto Fiscal"

ED0->(DbSetOrder(2))
ED0->(DbSeek(cFilED0+cAc))

If !Empty(cAc)
   SYT->(DbSetOrder(1))
   SYT->(DbSeek(cFilSYT+ED0->ED0_IMPORT))
Endif

If SELECT("WORK_MEN") # 0

   Work_Men->(dbGotop())

   Do While !Work_Men->(EOF()) .AND. Work_Men->WKORDEM<'zzzzz'
      mCartaG += Chr(13)+Chr(10)+Work_Men->WKOBS+Chr(13)+Chr(10)
      Work_Men->(dbSkip())
   EndDo

EndIf
	  
aMeses:= {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"}
dData := StrZero(Day(dDataBase),2)+STR0032+Lower(aMeses[Month(dDataBase)])+STR0032+Str(Year(dDataBase),4)+"." //" de "###" de "

cLocDt:= If(!Empty(cAc) .And. !Empty(SYT->YT_CIDADE),(Alltrim(Upper(Left(Alltrim(SYT->YT_CIDADE),1)))+Alltrim(Lower(Right(SYT->YT_CIDADE,19)))+", "+dData), Replicate("-",13)) //",")
cAss  := EasyGParam("MV_ASSRUD1",,"")
cAss1 := EasyGParam("MV_ASSRUD2",,"")

mCartaRod += Chr(13)+Chr(10)+Chr(13)+Chr(10)+cLocDt
mCartaRod += Chr(13)+Chr(10)+Space(01)+STR0033 //"Local e Data"
mCartaRod += Chr(13)+Chr(10)+Chr(13)+Chr(10)+cAss+Chr(13)+Chr(10)+Replicate("-",45)
mCartaRod += Chr(13)+Chr(10)+Space(01)+STR0034+Chr(13)+Chr(10) //"Assinatura Autorizada"
mCartaRod += Chr(13)+Chr(10)+cAss1+Chr(13)+Chr(10)+Replicate("-",45)+Chr(13)+Chr(10)

//Nome completo do Usuário
PswOrder(2)
If PswSeek(cUserName,.T.)
   cNome := PswRet()[1][4]  //Retorna nome completo do usuário
   cCargo:= PswRet()[1][13] //Retorna Cargo
EndIf

mCartaRod += cNome+Chr(13)+Chr(10)+cCargo

//Para a Impressão do Rodapé
cMemoAgr:= ""
cMemoAgr +=STR0035+Chr(13)+Chr(10) //"Sendo o que se apresentava para o momento, agradecemos desde já e colocamo-nos"
cMemoAgr +=STR0036 //"à disposição para quaisquer esclarecimentos que se fizerem necessários."

mCartaTot:=cMemoAgr+mCartaRod
mMemotot:= mCartaG+mCartaRod
nConcat:= Len(Alltrim(mCartaRod))

DEFINE MSDIALOG oDlg2 TITLE cTit ;
   From 00,00 to 36,100 OF oMainWnd

DEFINE FONT oFont2 NAME "Courier New" SIZE 0,16
   oDlg2:SetFont(oFont2)
   
   @ 12,00 GET mMemotot SIZE 396 ,255 Pixel OF oDlg2 HSCROLL

   ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nVolta:=1,oDlg2:End()},;
                                                 {||oDlg2:End()})

   mMemotot:= Substr(mMemotot,1, (Len(Alltrim(mMemotot))-nConcat))
   mCartaAuxG:= STRTRAN(mMemotot,STR0031, "") //"Relatório para o Posto Fiscal"
   
   For i:=1 to MLCOUNT(mCartaTot,80)
      Aadd(aMemoTot, Alltrim(Memoline(mCartaTot,80, i)))
   Next i

   For z:=1 to MLCOUNT(mCartaAuxG,80)
      Aadd(aMemoCarta, Alltrim(Memoline(mCartaAuxG,80, z)))
   Next z
   
   If nVolta == 1
      EDCPF150GERA()
      lRet := .T.
   Else
      lRet := .F.
   Endif

Return(lRet)

*--------------------------*
Static Function PF150TELA()
*--------------------------*
Local oDlg, nOp:=0, lRetorno:= .T.

DEFINE MSDIALOG oDlg TITLE STR0037 ; //"Mensagens/Impressão"
   FROM 12,05 To 20,55 OF GetwndDefault()

   @30,(oDlg:nClientWidth-4)/2-120 BUTTON STR0038 SIZE 34,11 OF oDlg PIXEL ; //"Mensagens"
              ACTION(PF150Mensagem(),oDlg:End()) //18/02/04

   @30,(oDlg:nClientWidth-4)/2-80 BUTTON STR0045 SIZE 34,11 OF oDlg PIXEL; //"Impressão"
              ACTION(EDCPF150GERA(),oDlg:End())  //18/02/04
   
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOp:=1,oDlg:End()},;
                                                 {||oDlg:End()}) CENTERED

   If nOp = 1 .Or. nOp = 0
      lRetorno:= .F.
   EndIf

Return lRetorno

*-------------------------------*
Static Function PF150CriaWorks()
*-------------------------------*
aEstru := {}
AADD(aEstru,{"ATOCON" , AVSX3("ED2_AC", 02)    , AVSX3("ED2_AC", 03)    , AVSX3("ED2_AC", 04)})
AADD(aEstru,{"DI_NUM" , AVSX3("W6_DI_NUM", 02) , AVSX3("W6_DI_NUM", 03) , AVSX3("W6_DI_NUM", 04)})
AADD(aEstru,{"DTREG_D", AVSX3("W6_DTREG_D", 02), AVSX3("W6_DTREG_D", 03), AVSX3("W6_DTREG_D", 04)})
AADD(aEstru,{"NF_ENT" , AVSX3("F1_DOC", 02)    , AVSX3("F1_DOC", 03)    , AVSX3("F1_DOC", 04)})
AADD(aEstru,{"SE_NF"  , AVSX3("F1_SERIE", 02)  , AVSX3("F1_SERIE", 03)  , AVSX3("F1_SERIE", 04)})
AADD(aEstru,{"IMPORT" , AVSX3("ED0_IMPORT", 02), AVSX3("ED0_IMPORT", 03), AVSX3("ED0_IMPORT", 04)})
AADD(aEstru,{"PED"    , AVSX3("ED0_PD", 02)    , AVSX3("ED0_PD", 03)    , AVSX3("ED0_PD", 04)})
AADD(aEstru,{"DT_AC"  , AVSX3("ED0_DT_REG", 02), AVSX3("ED0_DT_REG", 03), AVSX3("ED0_DT_REG", 04)})
AADD(aEstru,{"TIPO"   , "C", 1, 0 })

FileWork:=E_CriaTrab(,aEstru,"Work")
IndRegua("Work",FileWork+TEORDBAGEXT(),"ATOCON+DTOS(DTREG_D)+DI_NUM+TIPO")

Return .T.

*--------------------------------------*
Static Function EDCPF150CAB(cAto, lCab)
*--------------------------------------*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If DTOC(dDtIniDi) <> "01/01/50" .And. DTOC(dDtFimDi) <> "31/12/99"
   cabec1 := STR0008+dToc(dDtIniDi)+STR0009+dtoc(dDtFimDi)+Space(35)+STR0007//"Período D.I. de "###" até " ### Drawback
ElseIf DTOC(dDtIniDi) <> "01/01/50" .And. DTOC(dDtFimDi) = "31/12/99"
   cabec1 := STR0010+dToc(dDtIniDi)+Space(45)+STR0007 //"Período D.I. desde "### Drawback
ElseIf DTOC(dDtIniDi) = "01/01/50" .And. DTOC(dDtFimDi) <> "31/12/99"
   cabec1 := STR0011+dToc(dDtFimDi)+Space(47)+STR0007 //"Período D.I. até "###Drawback
Else
   cabec1 := STR0012+Space(36)+STR0007 //Período D.I. de   /  /  até   /  /  "###Drawback
Endif

If DTOC(dDtIniRe) <> "01/01/50" .And. DTOC(dDtFimRe) <> "31/12/99"
   cabec2 := STR0040+dToc(dDtIniRe)+STR0009+dtoc(dDtFimRe)+Space(10) //"Período R.E. de "###" até "
ElseIf DTOC(dDtIniRe) <> "01/01/50" .And. DTOC(dDtFimRe) = "31/12/99"
   cabec2 := STR0041+dToc(dDtIniRe)+Space(20) // "Período R.E. desde "
ElseIf DTOC(dDtIniRe) = "01/01/50" .And. DTOC(dDtFimRe) <> "31/12/99"
   cabec2 := STR0042+dToc(dDtFimRe)+Space(22) //"Período R.E. até "
Else
   cabec2 := STR0043+Space(13) //Período R.E. de   /  /  até   /  /  "
Endif

If !lCab
   Cabec2+= STR0044+Alltrim(cAto) //"Ato Concessório: "
Endif

Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
nLin:= 09

Return .T.
//*******************************
// FUNCTION PF150GERAWORK
//*******************************
// Grava dados para envio ao posto fiscal quando code base
// ------------------------------
// Alexandre Caetano Sciancalepre Jr. (ACSJ)
// 01 de Abril de 2005
// ------------------------------
*--------------------------------*
Function PF150GeraWork()              
*--------------------------------*

ED0->( dbSetOrder(2) )
ED0->( dbSeek(cFilED0) )

If Empty(cAc)
   cCond1 := " .not. empty(ED0->ED0_AC)"
Else
   cCond1 := " ED0->ED0_AC = cAc"
   ED0->( dbSeek(cFilED0+cAc) )
Endif 

SW8->( DBSetOrder(5) )
SW6->( DBSetOrder(1) )
SF1->( DBSetOrder(5) )
ED9->( DBSetOrder(3) )
ProcRegua(nTotal)
nCount:=0

Do While .not. ED0->( Eof() ) .and. ED0->ED0_FILIAL = cFilED0
   
   If &cCond1

      If SW8->( DBSeek(cFilSW8+ED0->ED0_AC) ) 
      
         Do While !SW8->(EOF()) .AND. cFilSW8 == SW8->W8_FILIAL .AND. SW8->W8_AC == ED0->ED0_AC
   
            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc("1/2-Lendo A.C.:"+ED0->ED0_AC)
               nCount++
            ENDIF

            IF SW6->( DBSeek(cFilSW6+SW8->W8_HAWB) ) 

               If Empty(SW6->W6_DI_NUM)
                  SW8->(dbSkip())
                  Loop
               Endif

               If SW6->W6_DTREG_D < dDtIniDi .Or. SW6->W6_DTREG_D > dDtFimDi
                  SW8->(dbSkip())
                  Loop
               Endif

               SF1->( DBSeek(cFilSF1+SW6->W6_HAWB) )
               
               Do While !SF1->(EOF()) .AND. cFilSF1 == SF1->F1_FILIAL .AND. SF1->F1_HAWB == SW6->W6_HAWB
                  
                  //ISS - 13/12/10 - Verificação se o HAWB corrente possui alguma nota gerada, e não apenas notas de despesas (NFD)
                  If lCposNFDesp .AND. !ExistHAWBNFE(SF1->F1_HAWB)
                     SF1->(DbSkip())
                     Loop                                                                
                  EndIf
                  
                  Work->(DBAPPEND())
                  Work->ATOCON := ED0->ED0_AC
                  Work->DI_NUM := SW6->W6_DI_NUM
                  Work->DTREG_D:= SW6->W6_DTREG_D   
                  Work->PED    := ED0->ED0_PD
                  Work->IMPORT := ED0->ED0_IMPORT                                                              
                  Work->DT_AC  := ED0->ED0_DT_REG
                  Work->TIPO   := "I"
                  Work->NF_ENT := SF1->F1_DOC
                  Work->SE_NF  := SF1->F1_SERIE

                  If EasyEntryPoint("EDCPF150")
                     ExecBlock("EDCPF150",.F.,.F.,"GRV_NOTA")
                  Endif

                  SF1->(dbSkip())
                                 
               ENDDO

            ENDIF

            SW8->(dbSkip())

         EndDO

      Endif

      If lTemED9Cpos .AND. ED9->( DBSeek(cFilED9+ED0->ED0_AC) )//AWR - 15/04/2009
   
         Do While !ED9->(EOF()) .AND. cFilED9 == ED9->ED9_FILIAL .AND. ED9->ED9_AC == ED0->ED0_AC

            IF nCount > nTotal
               ProcRegua(nTotal)
               nCount:=0
            ELSE 
               IncProc("1/2-Lendo A.C.:"+ED0->ED0_AC)
               nCount++
            ENDIF

            If Empty(ED9->ED9_RE) .Or. ED0->ED0_MODAL == "2" //Isenção
               ED9->(dbSkip())
               Loop
            Endif

            If ED9->ED9_DTAVRB < dDtIniRe .Or. ED9->ED9_DTAVRB > dDtFimRe
               ED9->(dbSkip())
               Loop
            Endif
                  
            Work->(DBAPPEND())
            Work->ATOCON := ED9->ED9_AC
            Work->DI_NUM := ED9->ED9_RE
            Work->DTREG_D:= ED9->ED9_DTAVRB
            Work->PED    := ED0->ED0_PD
            Work->IMPORT := ED0->ED0_IMPORT
            Work->DT_AC  := ED0->ED0_DT_REG
            Work->TIPO   := "E"

            ED9->(dbSkip())

         EndDO
    
      Endif

   Endif

   If !Empty(cAc)
      IF ED0->ED0_AC # cAc
         EXIT
      ENDIF
   ENDIF
   
   ED0->( Dbskip() )

Enddo

ED9->( DBSetOrder(1) )

Return .t.

//JPA - 18/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************                     
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas1 := {"EDO", "SW6"}
aTabelas2 := {"ED0", "SW6"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EDCPF150", STR0003, "EDCPF1"  , {|oReport| ReportPrint(oReport)}, STR0001 + STR0002)

//Define os objetos com as seções do relatório
oSecao2 := TRSection():New(oReport,"D.I.",aTabelas2,aOrdem)
oSecao1 := TRSection():New(oReport,"R.E.",aTabelas1,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, "DI_NUM" , "Work", STR0025, cPictRe, 16, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "DTREG_D", "Work", STR0026, cPictDt, 10, /*lPixel*/, /*{|| code-block de impressao }*/)
                                                    
//Definição das colunas de impressão da seção 2 
TRCell():New(oSecao2, "DI_NUM" , "Work", IIF(Work->TIPO=="X",STR0046, STR0027), cPictDi  , 16, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao2, "DTREG_D", "Work", STR0028                              , cPictDt  , 10, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao2, "NF_ENT" , "Work", STR0029                              , cPictNF  , 10, /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao2, "SE_NF"  , "Work", STR0030                              , cPictSeNf, 6, /*lPixel*/, /*{|| code-block de impressao }*/)

// Pula uma página ao quebrar uma seção
oReport:Section("D.I."):SetPageBreak(.T.)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("R.E.")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("R.E."),"ED0",2,{|| xFilial("ED0")})
TRPosition():New(oReport:Section("R.E."),"SW6",1,{|| xFilial("SW6")+SW8->W8_HAWB})

TRPosition():New(oReport:Section("D.I."),"ED0",2,{|| xFilial("ED0")})
TRPosition():New(oReport:Section("D.I."),"SW6",1,{|| xFilial("SW6")+SW8->W8_HAWB})

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("R.E."):Init()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->(dbGoTop())

//Laço principal
Do While Work->(!EoF()) .And. !oReport:Cancel() 

   oReport:IncMeter()                  //Incrementa a barra de progresso
   oReport:SetMsgPrint("2/2-Lendo R.E.: "+Work->DI_NUM)
   IF Work->TIPO = "E"
   
      oReport:Section("R.E."):PrintLine() //Impressão da linha

   ENDIF
   
   Work->( dbSkip() )
EndDo
//Fim da impressão da seção 2
oReport:Section("R.E."):Finish()
     
//Inicio da impressão da seção 2.
oReport:Section("D.I."):Init()
oReport:SetMeter(Work->(EasyRecCount("Work")))
Work->(dbGoTop())

Do While Work->(!EoF()) .And. !oReport:Cancel()
   
   oReport:IncMeter()                  //Incrementa a barra de progresso
   oReport:SetMsgPrint("2/2-Lendo D.I.: "+Work->DI_NUM)
   IF Work->TIPO # "E"
   
      oReport:Section("D.I."):PrintLine() //Impressão da linha

   ENDIF
   
   Work->( dbSkip() )
EndDo

//Fim da impressão da seção 2
oReport:Section("D.I."):Finish()                                

return .T.
