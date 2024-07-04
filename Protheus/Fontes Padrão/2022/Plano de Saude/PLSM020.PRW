#INCLUDE "Plsm020.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

#Define __NTAM1  15
#Define __NTAM2  50
#Define __NTAM3  20
#Define __NTAM4  15
#Define __NTAM5  40
#Define __NTAM6  5
#Define __NTAM7  5
#Define __NTAM8  16
#Define __NTAM9  5
#Define __NTAM10 30
#Define _LF Chr(13)+Chr(10) // Quebra de linha.
#Define _BL 50
#Define PLSMONEY "@E 99,999,999,999.99"

#Define LEG_ABERTO "BR_BRANCO"
#Define LEG_PARCIAL "BR_AZUL"
#Define LEG_BAIXADO "BR_PRETO"

STATIC objCENFUNLGP := CENFUNLGP():New()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLPOSFIN³ Autor ³ Tulio Cesar            ³ Data ³ 13.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe dialogo com posicao financeira de um usuario.        ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLPOSFIN(cMatric,lDlg,lDebDlg,lRetDados)
   LOCAL oBotao01  := nil
   LOCAL oBotao02  := nil
   LOCAL oBotao03  := nil
   LOCAL nRecBA1 	:= BA1->(Recno())
   LOCAL nOrdBA1 	:= BA1->(IndexOrd())
   LOCAL nRecBA3 	:= BA3->(Recno())
   LOCAL nOrdBA3 	:= BA3->(IndexOrd())
   LOCAL aTrbSE1 	:= {}
   LOCAL aCliente 	:= {}
   LOCAL _cNivel  	:= ''
   LOCAL _cChave 	:= ''
   LOCAL cChvBBT 	:= ''
   LOCAL cChvSE1 	:= ''
   LOCAL _cChavSE1	:= ''
   LOCAL n         := 0
   LOCAL nContCli  := 0
   LOCAL cSqlFilial:= ""
   LOCAL bPonto    := { || If(ExistBLock("PLSAUTF2"),ExecBLock("PLSAUTF2",.F.,.F.),.T.) }
   LOCAL nVlrToA   := 0
   LOCAL nVlrToB   := 0
   LOCAL nVlrToD   := 0
   LOCAL aCodCli   := {}
   LOCAL nPosEmi   := .F.
   LOCAL cMVPLSEXTP:= GetNewPar("MV_PLSEXTP","")
   LOCAL cMVPLTITAB:= GetNewPar("MV_PLTITAB","")
   LOCAL cMVPLTITBX:= GetNewPar("MV_PLTITBX","")
   LOCAL nPosVenc  := 0
   LOCAL nPosPrefixo := 0
   LOCAL nPosNumero := 0
   LOCAL nPosStatus := .F.

   LOCAL nPosCmpAtr:= 0
   LOCAL nPosCmpEmi:= 0
   LOCAL nPosCmpVen:= 0
   LOCAL nPosCmpBai:= 0

   PRIVATE oFolder
   PRIVATE oL1
   PRIVATE oD1
   PRIVATE oL2
   PRIVATE oD2
   PRIVATE oTreeUsr
   PRIVATE oTreeCon
   PRIVATE oDlgFin
   PRIVATE aCabFin := PLSCPOSSE1("A", .T.)
   PRIVATE aDadFin := {}
   PRIVATE oBrwFin

   PRIVATE aCabFinB := PLSCPOSSE1("A", .T.)
   PRIVATE aDadFinB := {}
   PRIVATE oBrwFinB := nil
   PRIVATE aTrbSE1B := {}

   PRIVATE aCabFinT := PLSCPOSSE1("A", .T.)
   PRIVATE aDadFinT := {}
   PRIVATE oBrwFinT := nil
   PRIVATE aTrbSE1T := {}

   PRIVATE cTitulo := STR0001 //"Posicao Financeira"
   PRIVATE lOK     := .T.
   PRIVATE nOrdSE1 := GETMV("MV_PLORDE1")
   PRIVATE nDiasDB := GETMV("MV_PLDIADB")
   PRIVATE aCols   := {}
   PRIVATE aHeader := {}
   PRIVATE aVetTrab:= {}
   PRIVATE cCodCli := ""
   PRIVATE cLojCli := ""
   PRIVATE cNome	:= ""
   PRIVATE cTxtNiv	:= ""
   PRIVATE nPos1   := 005
   PRIVATE nPos2   := 0
   PRIVATE nPos3   := 0
   PRIVATE nPos4   := 0
   PRIVATE nPos5   := 0
   PRIVATE nPos6   := 0
   PRIVATE oFontTit:= nil
   PRIVATE oSay    := nil

   DEFAULT lDlg    := .T.
   DEFAULT lDebDlg := .T.
   DEFAULT lRetDados := .F.

   nPosEmi := Ascan(aCabFin, {|x| Alltrim(x[2]) == "E1_EMISSAO"} )
   nPosPrefixo := Ascan(aCabFin, {|x| Alltrim(x[2]) == "E1_PREFIXO"})
   nPosNumero := Ascan(aCabFin, {|x| Alltrim(x[2]) == "E1_NUM"})
   nPosStatus := Ascan(aCabFin, {|x| Alltrim(x[2]) == "STATUS"})

   DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

   //Retina o digito verificador da matricula.
   cMatric := Subs(cMatric,1,14)

   //Executa funcao para validacao de usuario generica...
   If ! PLVLDUSU(cMatric)

      Help("",1,"PLPOSFIN")
      BA1->(DbGoto(nRecBA1))
      BA1->(DbSetOrder(nOrdBA1))
      BA3->(DbGoto(nRecBA3))
      BA3->(DbSetOrder(nOrdBA3))
      Return(.F.)

   Endif

   //Deve se remontar o matric para sempre ser pela matricula nova. Havia casos que vinha pela antiga e gerava problema
   cMatric := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)

   //A consulta ira considerar o nivel de cobranca agora, ao invez da matricula da familia.
   aCliente := PLSRETNCB(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,NIL)
   If Len(aCliente) > 0 .and. aCliente[1]

      _cNivel := aCliente[5]
      If _cNivel == "1" // Empresa
         _cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP
         cChvSE1 := BA3->BA3_CODINT+BA3->BA3_CODEMP
         cChvBBT := "BBT->(BBT_CODOPE+BBT_CODEMP)"
      Elseif _cNivel == "2" //Nivel contrato
         _cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON
         cChvSE1 := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON
         cChvBBT := "BBT->(BBT_CODOPE+BBT_CODEMP+BBT_CONEMP+BBT_VERCON)"

      Elseif _cNivel == "3"  //Nivel subcontrato
         _cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB
         cChvSE1 := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_CONEMP+BA3->BA3_VERCON+BA3->BA3_SUBCON+BA3->BA3_VERSUB
         cChvBBT := "BBT->(BBT_CODOPE+BBT_CODEMP+BBT_CONEMP+BBT_VERCON+BBT_SUBCON+BBT_VERSUB)"

      Elseif _cNivel == "4" //Nivel familia
         _cChave := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
         cChvSE1 := BA3->BA3_CODINT+BA3->BA3_CODEMP+BA3->BA3_MATRIC
         cChvBBT := "BBT->(BBT_CODOPE+BBT_CODEMP+BBT_MATRIC)"

      Elseif _cNivel == "5" //Usuario
      Endif

      //Verifica a qtde Dias Inadimplencia ou Num Titulos Abertos...
      nDiasDB := PLSDIAIN(_cNivel, cMatric)
      nVlrToA := 0
      nVlrToB := 0
      nVlrToD := 0

      //Verifica se houve faturas no mes... atualiza o valor do flag...
      BBT->(DbSetOrder(Val(_cNivel)))
      If BBT->(MsSeek(xFilial("BBT")+_cNivel+_cChave))

         nRecBBT := BBT->(Recno())

         If ExistBlock( "PLSXFILI" )
            cSqlFilial := ExecBlock( "PLSXFILI", .F., .F., {"SE1"} )
         Else
            cSqlFilial := xFilial("SE1")
         EndIf

         While ! BBT->(Eof()) .and. (_cNivel+&cChvBBT) == _cNivel+_cChave

            SE1->(DbSetOrder(1))
            If SE1->( msSeek( cSqlFilial + BBT->(BBT_PREFIX + BBT_NUMTIT + BBT_PARCEL + BBT_TIPTIT) ) )

               //Tratamento ponto de entrada PLSAUTF2
               If ! Eval(bPonto)
                  BBT->(DbSkip())
                  Loop
               Endif

               //Salva codigo do cliente
               cCodCli := SE1->E1_CLIENTE
               cLojCli := SE1->E1_LOJA

               If Ascan(aCodCli, {|x| Alltrim(x[1]) == Alltrim(cCodCli)} ) == 0
                  aadd(aCodCli,{cCodCli,cLojCli})
               Endif

               //demais titulos
               If empty(cMVPLSEXTP) .or. allTrim(SE1->E1_TIPO) $ allTrim(cMVPLSEXTP)

                  Aadd( aDadFinT, Array(Len(aCabFinT)+1) )
                  Aadd( aTrbSE1T, SE1->(Recno()) )

                  For n := 1 To Len(aCabFinT)
                     If(SE1->(FieldPos(aCabFinT[n][2]))) > 0
                        aDadFinT[Len(aDadFinT)][n] := SE1->(FieldGet(FieldPos(aCabFinT[n][2])))
                     else
                        aDadFinT[Len(aDadFinT)][n] := ""
                     Endif
                  Next

                  //Incluindo a coluna de dia de atraso de titulos
                  nPosCmpAtr:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_ATRPLS"})
                  nPosCmpEmi:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_EMISSAO"})
                  nPosCmpVen:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_VENCREA"})
                  nPosCmpBai:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_BAIXA"})


                  If nPosCmpAtr > 0 .and. nPosCmpVen > 0 .and.  nPosCmpBai > 0
                     nQtdDiasatr :=0
                     If (!Empty(SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpBai][2]))))) // Se há baixas !!!
                        If SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2]))) >= SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpBai][2])))
                           nQtdDiasatr :=0
                        Else
                           nQtdDiasatr := SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpBai][2])))- SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2])))
                        Endif
                     Else
                        IF SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2])))< DatE() // Não baixas ainda
                           nQtdDiasatr := Date()-SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2])))
                        Else
                           nQtdDiasatr :=0
                        Endif
                     Endif

                     aDadFinT[Len(aDadFinT)][nPosCmpAtr] := nQtdDiasatr
                  Endif

                  If nPosStatus > 0
                     aDadFinT[Len(aDadFinT)][nPosStatus] := GetStatusTit()
                  EndIf

                  // Nao deletado.
                  aDadFinT[Len(aDadFinT)][Len(aCabFinT)+1] := .f.

                  nVlrToD += SE1->E1_VALOR

               endIf

               // Titulos em aberto.
               If SE1->E1_SALDO > 0 .and. ( empty(cMVPLTITAB) .or. ! (allTrim(SE1->E1_TIPO) $ allTrim(cMVPLTITAB)) )

                  Aadd( aDadFin, Array(Len(aCabFin)+1) )

                  nPosVenc := Ascan(aCabFin, {|x| Alltrim(x[2]) == Alltrim("E1_VENCREA")} )
                  // Adiciono outros campos no vetor do recno, para fazer a ordenação
                  Aadd( aTrbSE1, {  SE1->(Recno()) ,;
                     SE1->(FieldGet(FieldPos(aCabFin[nPosPrefixo][2]))),;
                     SE1->(FieldGet(FieldPos(aCabFin[nPosNumero][2]))),;
                     SE1->E1_EMISSAO,;
                     SE1->E1_VENCREA })

                  For n := 1 To Len(aCabFin)
                     If(SE1->(FieldPos(aCabFin[n][2]))) > 0
                        aDadFin[Len(aDadFin)][n] := SE1->(FieldGet(FieldPos(aCabFin[n][2])))
                     else
                        aDadFin[Len(aDadFin)][n] := ""
                     Endif
                  Next

                  //Incluindo a coluna de dia de atraso de titulos
                  nPosCmpAtr:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_ATRPLS"})
                  nPosCmpEmi:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_EMISSAO"})
                  nPosCmpVen:= Ascan(aCabFin,{|x| AllTrim(x[2])== "E1_VENCREA"})
                  nPosCmpBai:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_BAIXA"})


                  If nPosCmpAtr > 0 .and. nPosCmpVen > 0 .and.  nPosCmpBai > 0
                     nQtdDiasatr :=0
                     If (!Empty(SE1->(FieldGet(FieldPos(aCabFin[nPosCmpBai][2]))))) // Se há baixas !!!
                        If SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2]))) >= SE1->(FieldGet(FieldPos(aCabFin[nPosCmpBai][2])))
                           nQtdDiasatr :=0
                        Else
                           nQtdDiasatr := SE1->(FieldGet(FieldPos(aCabFin[nPosCmpBai][2])))- SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2])))
                        Endif
                     Else
                        IF SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2])))< DatE()
                           nQtdDiasatr := Date()-SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2])))
                        Else
                           nQtdDiasatr :=0
                        Endif
                     Endif


                     aDadFin[Len(aDadFin)][nPosCmpAtr] := nQtdDiasatr
                  Endif

                  If nPosStatus > 0
                     aDadFin[Len(aDadFin)][nPosStatus] := GetStatusTit()
                  EndIf

                  // Nao deletado.
                  aDadFin[Len(aDadFin)][Len(aCabFin)+1] := .F.

                  nVlrToA += SE1->E1_VALOR

               endIf

               // Titulos baixados.
               if ! empty(SE1->E1_BAIXA) .and. ( empty(cMVPLTITBX) .or. ! (allTrim(SE1->E1_TIPO) $ allTrim(cMVPLTITBX)) )

                  Aadd( aDadFinB, Array(Len(aCabFinB)+1) )
                  Aadd( aTrbSE1B, SE1->(Recno()) )

                  For n := 1 To Len(aCabFinB)
                     If(SE1->(FieldPos(aCabFinB[n][2]))) > 0
                        aDadFinB[Len(aDadFinB)][n] := SE1->(FieldGet(FieldPos(aCabFinB[n][2])))
                     else
                        aDadFinB[Len(aDadFinB)][n] := ""
                     Endif
                  Next

                  //Incluindo a coluna de dia de atraso de titulos
                  nPosCmpAtr:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_ATRPLS"})
                  nPosCmpEmi:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_EMISSAO"})
                  nPosCmpVen:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_VENCREA"})
                  nPosCmpBai:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_BAIXA"})

                  If nPosCmpAtr > 0 .and. nPosCmpVen > 0 .and.  nPosCmpBai > 0
                     nQtdDiasatr :=0
                     If (!Empty(SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpBai][2]))))) // Se há baixas !!!
                        If SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2]))) >= SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpBai][2])))
                           nQtdDiasatr :=0
                        Else
                           nQtdDiasatr := SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpBai][2])))- SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2])))
                        Endif
                     Else
                        IF SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2])))< DatE()
                           nQtdDiasatr := Date()-SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2])))
                        Else
                           nQtdDiasatr :=0
                        Endif
                     Endif


                     aDadFinB[Len(aDadFinB)][nPosCmpAtr] := nQtdDiasatr
                  Endif

                  If nPosStatus > 0
                     aDadFinB[Len(aDadFinB)][nPosStatus] := GetStatusTit()
                  EndIf

                  // Nao deletado.
                  aDadFinB[Len(aDadFinB)][Len(aCabFinB)+1] := .F.

                  nVlrToB += SE1->E1_VALOR

               Endif

               //Verifica inadimplencia
               nDiasVenc := dDataBase - SE1->E1_VENCREA

               If nDiasVenc >= nDiasDB .And. SE1->E1_SALDO > 0
                  lOK := .F.
               Endif

            Endif

            BBT->( dbSkip() )
         Enddo

         If _cNivel == "1" // Empresa
            _cChavSE1 := "SE1->E1_CODINT+SE1->E1_CODEMP"
         Elseif _cNivel == "2" //Nivel contrato
            _cChavSE1 :=	"SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_CONEMP+SE1->E1_VERCON"
         Elseif _cNivel == "3"  //Nivel subcontrato
            _cChavSE1 := "SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_CONEMP+SE1->E1_VERCON+SE1->E1_SUBCON+SE1->E1_VERSUB"
         Elseif _cNivel == "4" //Nivel familia
            _cChavSE1 := "SE1->E1_CODINT+SE1->E1_CODEMP+SE1->E1_MATRIC"
         EndIf

         // Todos os titulos do cliente
         SE1->( dbSetorder(02) )

         For nContCli := 1 to  Len(aCodCli)

            cCodCli := aCodCli[nContCli,1]
            cLojCli := aCodCli[nContCli,2]

            SE1->( msSeek(cSqlFilial+cCodCli+cLojCli))

            While ! SE1->( Eof() ) .and. SE1->E1_CLIENTE+SE1->E1_LOJA == cCodCli+cLojCli

               //Tratamento ponto de entrada PLSAUTF2
               If ! Eval(bPonto)
                  SE1->(DbSkip())
                  Loop
               Endif

               //demais titulos
               if (aScan(aTrbSE1T, SE1->(recno())) == 0) .and. ( empty(cMVPLSEXTP) .or. allTrim(SE1->E1_TIPO) $ allTrim(cMVPLSEXTP))

                  Aadd( aTrbSE1T, SE1->(Recno()) )
                  Aadd( aDadFinT, Array(Len(aCabFinT)+1) )

                  For n := 1 To Len(aCabFinT)
                     If(SE1->(FieldPos(aCabFinT[n][2]))) > 0
                        aDadFinT[Len(aDadFinT)][n] := SE1->(FieldGet(FieldPos(aCabFinT[n][2])))
                     else
                        aDadFinT[Len(aDadFinT)][n] := ""
                     Endif
                  Next

                  //Incluindo a coluna de dia de atraso de titulos
                  nPosCmpAtr:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_ATRPLS"})
                  nPosCmpEmi:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_EMISSAO"})
                  nPosCmpVen:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_VENCREA"})
                  nPosCmpBai:= Ascan(aCabFinT,{|x| AllTrim(x[2]) == "E1_BAIXA"})

                  If nPosCmpAtr > 0 .and. nPosCmpVen > 0 .and.  nPosCmpBai > 0
                     nQtdDiasatr :=0
                     If (!Empty(SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpBai][2]))))) // Se há baixas !!!
                        If SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2]))) >= SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpBai][2])))
                           nQtdDiasatr :=0
                        Else
                           nQtdDiasatr := SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpBai][2])))- SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2])))
                        Endif
                     Else
                        IF SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2])))< DatE()
                           nQtdDiasatr := Date()-SE1->(FieldGet(FieldPos(aCabFinT[nPosCmpVen][2])))
                        Else
                           nQtdDiasatr :=0
                        Endif
                     Endif


                     aDadFinT[Len(aDadFinT)][nPosCmpAtr] := nQtdDiasatr
                  Endif

                  If nPosStatus > 0
                     aDadFinT[Len(aDadFinT)][nPosStatus] := GetStatusTit()
                  EndIf

                  // Nao deletado.
                  aDadFinT[Len(aDadFinT)][Len(aCabFinT)+1] := .F.

                  nVlrToD += SE1->E1_VALOR

               endIf

               //Posicionado esse título, verificamos:
               //Se a chave da SE1 posicionada aqui é igual a chave da SE1 posicionada anteriormente,
               //Para que não seja inserido no array, dados de outros contratos/Subcontratos/familia
               If &_cChavSE1 == cChvSE1

                  //titulos em aberto
                  If (aScan(aTrbSE1,{ |x| x[1] == SE1->(Recno())}) == 0) .and. SE1->E1_SALDO > 0 .and. ( empty(cMVPLTITAB) .or. ! (allTrim(SE1->E1_TIPO) $ allTrim(cMVPLTITAB)) )

                     Aadd( aDadFin, Array(Len(aCabFin)+1) )
                     Aadd( aTrbSE1, {  SE1->(Recno()) ,;
                        SE1->(FieldGet(FieldPos(aCabFin[nPosPrefixo][2]))),;
                        SE1->(FieldGet(FieldPos(aCabFin[nPosNumero][2]))),;
                        SE1->E1_EMISSAO,;
                        SE1->E1_VENCREA })

                     For n := 1 To Len(aCabFin)
                        If(SE1->(FieldPos(aCabFin[n][2]))) > 0
                           aDadFin[Len(aDadFin)][n] := SE1->(FieldGet(FieldPos(aCabFin[n][2])))
                        else
                           aDadFin[Len(aDadFin)][n] := ""
                        Endif
                     Next

                     //Incluindo a coluna de dia de atraso de titulos
                     nPosCmpAtr:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_ATRPLS"})
                     nPosCmpEmi:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_EMISSAO"})
                     nPosCmpVen:= Ascan(aCabFin,{|x| AllTrim(x[2])== "E1_VENCREA"})
                     nPosCmpBai:= Ascan(aCabFin,{|x| AllTrim(x[2]) == "E1_BAIXA"})

                     If nPosCmpAtr > 0 .and. nPosCmpVen > 0 .and.  nPosCmpBai > 0
                        nQtdDiasatr :=0
                        If (!Empty(SE1->(FieldGet(FieldPos(aCabFin[nPosCmpBai][2]))))) // Se há baixas !!!
                           If SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2]))) >= SE1->(FieldGet(FieldPos(aCabFin[nPosCmpBai][2])))
                              nQtdDiasatr :=0
                           Else
                              nQtdDiasatr := SE1->(FieldGet(FieldPos(aCabFin[nPosCmpBai][2])))- SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2])))
                           Endif
                        Else
                           IF SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2])))< DatE()
                              nQtdDiasatr := Date()-SE1->(FieldGet(FieldPos(aCabFin[nPosCmpVen][2])))
                           Else
                              nQtdDiasatr :=0
                           Endif
                        Endif


                        aDadFin[Len(aDadFin)][nPosCmpAtr] := nQtdDiasatr
                     Endif

                     If nPosStatus > 0
                        aDadFin[Len(aDadFin)][nPosStatus] := GetStatusTit()
                     EndIf

                     // Nao deletado.
                     aDadFin[Len(aDadFin)][Len(aCabFin)+1] := .F.

                     //Adiciona o valor no total dos títulos em aberto
                     nVlrToA += SE1->E1_VALOR

                  endIf

                  // Titulos baixados.
                  If (aScan(aTrbSE1B, SE1->(Recno())) == 0) .and. ! empty(SE1->E1_BAIXA) .and. SE1->E1_CODEMP == BA1->BA1_CODEMP .and. ( empty(cMVPLTITBX) .or. ! (allTrim(SE1->E1_TIPO) $ allTrim(cMVPLTITBX)) )

                     Aadd( aTrbSE1B, SE1->(Recno()) )
                     Aadd( aDadFinB, Array(Len(aCabFinB)+1) )

                     For n := 1 To Len(aCabFinB)
                        If(SE1->(FieldPos(aCabFinB[n][2]))) > 0
                           aDadFinB[Len(aDadFinB)][n] := SE1->(FieldGet(FieldPos(aCabFinB[n][2])))
                        else
                           aDadFinB[Len(aDadFinB)][n] := ""
                        Endif
                     Next

                     //Incluindo a coluna de dia de atraso de titulos
                     nPosCmpAtr:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_ATRPLS"})
                     nPosCmpEmi:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_EMISSAO"})
                     nPosCmpVen:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_VENCREA"})
                     nPosCmpBai:= Ascan(aCabFinB,{|x| AllTrim(x[2]) == "E1_BAIXA"})

                     If nPosCmpAtr > 0 .and. nPosCmpVen > 0 .and.  nPosCmpBai > 0
                        nQtdDiasatr :=0
                        If (!Empty(SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpBai][2]))))) // Se há baixas !!!
                           If SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2]))) >= SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpBai][2])))
                              nQtdDiasatr :=0
                           Else
                              nQtdDiasatr := SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpBai][2])))- SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2])))
                           Endif
                        Else
                           IF SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2])))< DatE()
                              nQtdDiasatr := Date()-SE1->(FieldGet(FieldPos(aCabFinB[nPosCmpVen][2])))
                           Else
                              nQtdDiasatr :=0
                           Endif
                        Endif


                        aDadFinB[Len(aDadFinB)][nPosCmpAtr] := nQtdDiasatr
                     Endif

                     If nPosStatus > 0
                        aDadFinB[Len(aDadFinB)][nPosStatus] := GetStatusTit()
                     EndIf

                     // Nao deletado.
                     aDadFinB[Len(aDadFinB)][Len(aCabFinB)+1] := .F.

                     //Adiciona o valor no total dos títulos em aberto
                     nVlrToB += SE1->E1_VALOR

                  endIf

               endIf

               SE1->( dbSkip() )
            Enddo

         next

      Endif

   Endif

   //Caso lDlg .T. - Sempre exibe o dialogo...
   If ! lDlg
      If  lOK
         BA1->(DbGoto(nRecBA1))
         BA1->(DbSetOrder(nOrdBA1))
         BA3->(DbGoto(nRecBA3))
         BA3->(DbSetOrder(nOrdBA3))
         Return(lOK)
      Else
         If ! lDebDlg
            BA1->(DbGoto(nRecBA1))
            BA1->(DbSetOrder(nOrdBA1))
            BA3->(DbGoto(nRecBA3))
            BA3->(DbSetOrder(nOrdBA3))
            Return(lOK)
         Endif
      Endif
   Endif

   If lRetDados
      Return {aDadFin, aDadFinB, aDadFinT}
   EndIf

   //Remonta titulo...
   cTitulo += IF(lOK,"",STR0002)//" - Em Debito"
   //Define Dialogo...
   aSize := MsAdvSize()
   aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
   aObjects := {}
   AAdd( aObjects, { 100, 90, .t., .f. } )
   AAdd( aObjects, { 100, 100, .t., .t.,.f. } )
   aPosObj := MsObjSize( aInfo, aObjects )


   aInfo2 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
   aObjects2 := {}
   AAdd( aObjects2, { 100, 90, .t., .f. } )
   AAdd( aObjects2, { 100, 100, .t., .t.,.t. } )
   aPosObj2 := MsObjSize( aInfo2, aObjects2 )

   DEFINE MSDIALOG oDlgFin TITLE cTitulo FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel

   //Monta Dados do Titular e Depedentes...
   PLDADUSR(cMatric,oDlgFin,oTreeUsr,oTreeCon,aCliente,aPosObj)

   @ aPosObj2[2][1],aPosObj2[2][2] FOLDER oFolder SIZE aPosObj2[2][3],aPosObj2[2][4] OF oDlgFin PIXEL	PROMPTS	STR0047,STR0003,STR0004 //Tit. abertos"###### //"Tit. Baixados"###"Demais Titulos"

   //Monta Browse Financeiro...
   // Titulos em aberto
   If ValType(aDadFin) == "A"

      If Len(aDadFin) > 0

         //Se existir o campo de emissão a ordenação será feita por ele
         If nPosEmi > 0
            ASORT(aDadFin,,, { | x,y | x[nPosEmi] < y[nPosEmi] })
            ASORT(aTrbSE1,,, { | x,y | x[4] < y[4] }) // Orderna o vetor que contem o recno
            //Se existir o campo de vencimento a ordenação será feita por ele
         ElseIf nPosVenc > 0
            aSort(aDadFin,,,{|x,y| x[nPosPrefixo]+x[nPosNumero]+dTos(x[nPosVenc]) > y[nPosPrefixo]+y[nPosNumero]+dTos(y[nPosVenc]) })
            aSort(aTrbSE1,,,{|x,y| x[2]+x[3]+dTos(x[5]) > y[2]+y[3]+dTos(y[5]) }) //Ordena o vetor que contem o recno
         EndIf

         oBrwFin := TPLSBRW():New(005,005,aPosObj[2][4]*0.99,aPosObj[2][3]*0.4,nil,oFolder:aDialogs[1],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFin,aDadFin,.T.,"SE1",K_Visualizar,STR0005,{{"E1_VENCREA",">=",(dDataBase-nDiasDB)}}) //"Movimentacao Financeira"
         @ aPosObj[2][3]*0.4+15,151 SAY oSay PROMPT "Valor Total         " SIZE 220,010 OF oFolder:aDialogs[1] PIXEL
         @ aPosObj[2][3]*0.4+15,230 SAY oSay PROMPT Round(nVlrToA,2)  PICTURE PLPMONEY_M   SIZE 220,010 OF oFolder:aDialogs[1] PIXEL FONT oFontTit COLOR CLR_HBLUE

         If nPosStatus > 0
            PrintLegStatus(aPosObj, @oFolder, 1)
         EndIf

      Endif

   Endif

   // Titulos baixados.
   If ValType(aDadFinB) == "A"

      If Len(aDadFinB) > 0

         //Se existir o campo de emissão a ordenação será feita por ele
         If nPosEmi > 0
            ASORT(aDadFinB,,, { | x,y | x[nPosEmi] < y[nPosEmi] })
         ElseIf nPosVenc > 0 //Se existir o campo de vencimento a ordenação será feita por ele
            aSort(aDadFinB,,,{|x,y| x[nPosPrefixo]+x[nPosNumero]+dTos(x[nPosVenc]) > y[nPosPrefixo]+y[nPosNumero]+dTos(y[nPosVenc]) })
         EndIf

         oBrwFinB := TPLSBRW():New(005,005,aPosObj[2][4]*0.99,aPosObj[2][3]*0.4,nil,oFolder:aDialogs[2],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFinB,aDadFinB,nil,"SE1",K_Visualizar,STR0005,nil) //"Movimentacao Financeira"
         @ aPosObj[2][3]*0.4+15,151 SAY oSay PROMPT "Valor Total         " SIZE 220,010 OF oFolder:aDialogs[2] PIXEL
         @ aPosObj[2][3]*0.4+15,230 SAY oSay PROMPT Round(nVlrToB,2)  PICTURE PLPMONEY_M   SIZE 220,010 OF oFolder:aDialogs[2] PIXEL FONT oFontTit COLOR CLR_HBLUE

         If nPosStatus > 0
            PrintLegStatus(aPosObj, @oFolder, 2)
         EndIf

      Endif

   Endif

   // Todos os titulos do cliente - demais titulos
   If ValType(aDadFinT) == "A"

      If Len(aDadFinT) > 0

         //Se existir o campo de emissão a ordenação será feita por ele
         If nPosEmi > 0
            aSort(aDadFinT,,, { | x,y | x[nPosEmi] < y[nPosEmi] })
            //Se existir o campo de vencimento a ordenação será feita por ele
         ElseIf nPosVenc > 0
            aSort(aDadFinT,,,{|x,y| x[nPosPrefixo]+x[nPosNumero]+dTos(x[nPosVenc]) > y[nPosPrefixo]+y[nPosNumero]+dTos(y[nPosVenc]) })
         EndIf

         oBrwFinT := TPLSBRW():New(005,005,aPosObj[2][4]*0.99,aPosObj[2][3]*0.4,nil,oFolder:aDialogs[3],nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFinT,aDadFinT,.T.,"SE1",K_Visualizar,STR0005,{{"E1_SALDO","==",0}}) //"Movimentacao Financeira"
         @ aPosObj[2][3]*0.4+15,151 SAY oSay PROMPT "Valor Total         " SIZE 220,010 OF oFolder:aDialogs[3] PIXEL
         @ aPosObj[2][3]*0.4+15,230 SAY oSay PROMPT Round(nVlrToD,2)  PICTURE PLPMONEY_M   SIZE 220,010 OF oFolder:aDialogs[3] PIXEL FONT oFontTit COLOR CLR_HBLUE

         If nPosStatus > 0
            PrintLegStatus(aPosObj, @oFolder, 3)
         EndIf

      Endif

   Endif

   //Chama ponto de entrada PLSPFFOL
   If ExistBlock("PLSPFFOL")
      ExecBlock("PLSPFFOL",.F.,.F.)
   EndIf

   //Monta Botao de OK padrao...
   oBotao01 := TButton():New(aPosObj[2][3]*0.95,010, STR0006, , {|| oDlgFin:End() }, 038, 013 ,,,,.T.) //"Fechar"
   oBotao01:cToolTip := STR0006 //"Fechar"

   If  ValType(aDadFin) == "A" .and. Len(aDadFin) > 0

      oBotao02 := TButton():New(aPosObj[2][3]*0.95, 060, STR0007, ,{|| M020DET(oFolder:nOption,cMatric,oBrwFin,oBrwFinB,oBrwFinT,_cNivel) }, 038, 013 ,,,,.T.) //"Composicao"

      oBotao02:cToolTip := STR0008 //"Composicao de Cobranca"

   Endif

   If  ValType(aDadFin) == "A" .and. Len(aDadFin) > 0

      If IsInCallStack('PLSCALLCENTER')

         If Len(aTrbSE1) > 0

            SE1->(DbGoto(aTrbSE1[oBrwFin:Linha()][1]))
            oBotao03 := TButton():New(aPosObj[2][3]*0.95,110, STR0009, ,{|| IF(ExistBlock("PLSBOL"),; //"Imprimir"
               ExecBlock("PLSBOL",.F.,.F.,{aTrbSE1[oBrwFin:Linha()][1], oBrwFin:aCols,oBrwFin:aHeader}),;
               PLSR580(SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_CODINT,SE1->E1_CODINT,SE1->E1_CODEMP,SE1->E1_CODEMP,SE1->E1_CONEMP,SE1->E1_CONEMP,SE1->E1_SUBCON,SE1->E1_SUBCON,SE1->E1_MATRIC,SE1->E1_MATRIC,SE1->E1_MESBASE,SE1->E1_ANOBASE,SE1->E1_MESBASE,SE1->E1_ANOBASE)) }, 038, 013 ,,,,.T.)
         Endif
      Else
         oBotao03 := TButton():New(aPosObj[2][3]*0.95,110, STR0009, ,{|| IF(ExistBlock("PLSBOL"),; //"Imprimir"
            ExecBlock("PLSBOL",.F.,.F.,{aTrbSE1[oBrwFin:Linha()][1],oBrwFin:aCols,oBrwFin:aHeader}),PLSR580()) }, 038, 013 ,,,,.T.)
      Endif

      oBotao03:cToolTip := STR0010 //"Imprimir segunda via de boleto"
   Endif

   //Legenda
   If  ValType(aDadFin) == "A" .and. Len(aDadFin) > 0
      @ 212,230 BITMAP oL2 RESNAME 'BR_VERMELHO' OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
      @ 212,240 Say oD2 PROMPT  'vencido a mais de ' + alltrim(str(nDiasDB)) + ' dias' OF oFolder:aDialogs[1] SIZE 120,10 PIXEL
      @ 212,330 BITMAP oL1 RESNAME 'BR_VERDE' OF oFolder:aDialogs[1] SIZE 20,20 NOBORDER WHEN .F. PIXEL
      @ 212,340 Say oD1 PROMPT  'vencido a menos de ' + alltrim(str(nDiasDB)) + ' dias / a vencer' OF oFolder:aDialogs[1] SIZE 120,10 PIXEL
   Endif

   //-------------------------------------------------------------------
   //  LGPD
   //-------------------------------------------------------------------
   objCENFUNLGP:useLogUser()

   //Ativa o Dialogo...
   ACTIVATE MSDIALOG oDlgFin

   BA1->(DbGoto(nRecBA1))
   BA1->(DbSetOrder(nOrdBA1))
   BA3->(DbGoto(nRecBA3))
   BA3->(DbSetOrder(nOrdBA3))

Return(lOK)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLDEMTIT³ Autor ³ Angelo Sperandio       ³ Data ³ 16.10.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe demais titulos                                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLDEMTIT(cCodCli,cLojCli,nTit,cMatric)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Salva variaveis                                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL saCols    := aCols
   LOCAL saHeader  := aHeader
   LOCAL saVetTrab := aVetTrab
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Parametros: cCodCli - Codigo do Cliente                             ³
   //³             cLojCli - Loja do Cliente                               ³
   //³             nTit    - tipo de titulo: 1-Titulos Baixados            ³
   //³                                       2-Demais Titulos Em Aberto    ³
   //³                                       3-Demais Titulos Baixados     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL oBotao01
   LOCAL oBotao02

   LOCAL oBotao03
   LOCAL oBotao04
   LOCAL oBotao05
   LOCAL oBotao06
   LOCAL oBotao07
   LOCAL oBotao08
   Local cFor
   LOCAL cSqlFilial:= ""
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis...                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PRIVATE oDlgFin1
   PRIVATE aCabFin1 := PLSCPOSSE1("A")
   PRIVATE aDadFin1 := {}
   PRIVATE oBrwFin1
   PRIVATE aCols    := {}
   PRIVATE aHeader  := {}
   PRIVATE aVetTrab := {}
   PRIVATE cTitulo1
   PRIVATE cTitulo2

   If ExistBlock( "PLSXFILI" )
      cSqlFilial := ExecBlock( "PLSXFILI", .F., .F., {"SE1"} )
   Else
      cSqlFilial := xFilial("SE1")
   EndIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta titulo do dialogo                                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Do Case
      Case nTit == 1
         cTitulo1 := STR0011 // //"Titulos Baixados"
         cFor     := 'SE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) == "' + cSqlFilial + cMatric + '" .and. SE1->E1_SALDO == 0'
      Case nTit == 2
         cTitulo1 := STR0012 // //"Demais Titulos em Aberto"
         cFor     := 'SE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) <> "' + cSqlFilial + cMatric + '" .and. SE1->E1_SALDO >  0'
      Case nTit == 3
         cTitulo1 := STR0013 // //"Demais Titulos Baixados"
         cFor     := 'SE1->(E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) <> "' + cSqlFilial + cMatric + '" .and. SE1->E1_SALDO == 0'
   EndCase
   If  nTit <> 1
      cTitulo1 += " - Cliente: " + cCodCli + "-" + cLojCli + " " + SA1->(Posicione("SA1",1,xFilial("SA2")+cCodCli+cLojCli,"A1_NOME"))
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta aCols e aHeader dos Dados Financeiros...                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SE1->(dbSetOrder(2))
   If  SE1->(MsSeek(cSqlFilial+cCodCli+cLojCli))
      Store COLS "SE1" TO aDadFin1 FROM aCabFin1 While SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA) == cSqlFilial+cCodCli+cLojCli For &(cFor)
   Endif
   If  len(aDadFin1) == 0
      msginfo(STR0014) // //"Titulos nao encontrados"
      Return()
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define Dialogo...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DEFINE MSDIALOG oDlgFin1 TITLE cTitulo1 FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Browse Financeiro...                      ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   TGroup():New(003,003,176,355,STR0015,, , ,.T.)  // //"Titulo(s)"
   If  nTit == 2
      oBrwFin1 := TPLSBESP():New(013,008,340,160,nil,oDlgFin1,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFin1,aDadFin1,.T.,"SE1",K_Visualizar,STR0005,{{"E1_VENCREA",">=",(dDataBase-nDiasDB)}}) //"Movimentacao Financeira"
   Else
      oBrwFin1 := TPLSBESP():New(013,008,340,160,nil,oDlgFin1,nil,nil,nil,nil,nil,.T.,nil,.T.,nil,aCabFin1,aDadFin1,.T.,"SE1",K_Visualizar,STR0005,{{"E1_VENCREA",">=","E1_BAIXA","A"}}) //"Movimentacao Financeira"
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Botao de OK padrao...                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   oBotao01 := SButton():New(180, 005, 1, {|| oDlgFin1:End() },,.T.)
   oBotao01:cToolTip := STR0006 // //"Fechar"

   If  nTit == 2
      oBotao02 := SButton():New(180, 035, 6, {|| IF(ExistBlock("PLSBOL"),ExecBlock("PLSBOL",.F.,.F.),PLSR580()) },,.T.)
      oBotao02:cToolTip := STR0010 // //"Imprimir segunda via de boleto"
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Legenda                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If  nTit == 2
      @ 180,230 BITMAP oL2 RESNAME 'BR_VERMELHO' OF oDlgFin1 SIZE 20,20 NOBORDER WHEN .F. PIXEL
      @ 180,240 Say    oD2 PROMPT  'vencido a mais de ' + alltrim(str(nDiasDB)) + ' dias'             OF oDlgFin1 SIZE 120,10 PIXEL
      @ 190,230 BITMAP oL1 RESNAME 'BR_VERDE'    OF oDlgFin1 SIZE 20,20 NOBORDER WHEN .F. PIXEL
      @ 190,240 Say    oD1 PROMPT  'vencido a menos de ' + alltrim(str(nDiasDB)) + ' dias / a vencer' OF oDlgFin1 SIZE 120,10 PIXEL
   Else
      @ 180,230 BITMAP oL2 RESNAME 'BR_VERMELHO' OF oDlgFin1 SIZE 20,20 NOBORDER WHEN .F. PIXEL
      @ 180,240 Say    oD2 PROMPT  'pago com atraso' OF oDlgFin1 SIZE 120,10 PIXEL
      @ 190,230 BITMAP oL1 RESNAME 'BR_VERDE'    OF oDlgFin1 SIZE 20,20 NOBORDER WHEN .F. PIXEL
      @ 190,240 Say    oD1 PROMPT  'pago no prazo'   OF oDlgFin1 SIZE 120,10 PIXEL
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ativa o Dialogo...                              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   ACTIVATE MSDIALOG oDlgFin1
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Restaura variaveis                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aCols    := saCols
   aHeader  := saHeader
   aVetTrab := saVetTrab
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(lOK)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLDADUSR³ Autor ³ Tulio Cesar            ³ Data ³ 19.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe dados resumidos de um contrato.                      ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "DBTREE.CH"

Function PLDADUSR(cMatric,oDlg,oTreeUsr,oTreeCnt,aCliente,aPosObj)
   LOCAL aRetCli 	 := {}
   LOCAL cCodCli
   LOCAL cLoja
   Local nInd
   LOCAL nCont   	 := 1
   LOCAL aRetPto
   LOCAL aSize 	 := {}
   LOCAL aInfo 	 := {}
   LOCAL aObjects 	 := {}
   LOCAL cMvPLCDTGP := GETMV("MV_PLCDTGP")
   DEFAULT aCliente := {}
   DEFAULT aPosObj	 := {}
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa funcao para validacao de usuario generica...                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ! PLVLDUSU(cMatric)
      Return
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Informacoes do Titular e seus depedentes...                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Len(aPosObj) == 0
      aSize := MsAdvSize()
      aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
      aObjects := {}
      AAdd( aObjects, { 100, 90, .t., .f. } )
      AAdd( aObjects, { 100, 100, .t., .t.,.f. } )
      aPosObj := MsObjSize( aInfo, aObjects )
   Endif

   TGroup():New(aPosObj[1][1],aPosObj[1][2],aPosObj[1][3],aPosObj[1][4]*0.60,STR0016,, , ,.T.) // //"Usuario(s)"

   DEFINE DBTREE oTreeUsr FROM aPosObj[1][1]+10,aPosObj[1][2]+5 TO aPosObj[1][3]-10,aPosObj[1][4]*0.58 CARGO OF oDlg ON RIGHT CLICK M100Edit(oTreeUsr:GetCargo())
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta DbTree para o titular e seus depedentes...                    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BA1->(DbSetOrder(2))

   If BA1->(MsSeek(xFilial("BA1")+cMatric))
      While ! BA1->(Eof()) .And. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cMatric
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Monta DbTree de acordo com bloqueio/desbloqueio...                  ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         If Empty(BA1->BA1_MOTBLO)
            IF BA1->BA1_TIPREG == cMvPLCDTGP
               DBADDTREE oTreeUsr PROMPT BA1->BA1_NOMUSR+"("+AllTrim(Str(Calc_Idade(dDataBase,BA1->BA1_DATNAS),3))+")"+Space(150) RESOURCE "GROUP" CARGO "BA1/"+StrZero(BA1->(Recno()),6)+STR0017 // //"/Usuario"
            Else
               DBADDTREE oTreeUsr PROMPT BA1->BA1_NOMUSR+"("+AllTrim(Str(Calc_Idade(dDataBase,BA1->BA1_DATNAS),3))+")"+Space(150) RESOURCE "DEPENDENTES" CARGO "BA1/"+StrZero(BA1->(Recno()),6)+STR0017 // //"/Usuario"
            Endif
         Else
            DBADDTREE oTreeUsr PROMPT BA1->BA1_NOMUSR+"("+AllTrim(Str(Calc_Idade(dDataBase,BA1->BA1_DATNAS),3))+")"+Space(150) RESOURCE "GROUP" CARGO "BA1/"+StrZero(BA1->(Recno()),6)+STR0017 // //"/Usuario"
         Endif
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Monta opcionais do plano para o usuario...                          ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         aRet := PLOPCUSR(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG))
         If Len(aRet) > 0
            DBADDTREE oTreeUsr PROMPT STR0018+Space(300) RESOURCE "PLNPROP" CARGO "BA1/"+StrZero(BA1->(Recno()),6)+STR0017          //### //"Opcionais "###"/Usuario"
            For nInd := 1 To Len(aRet)
               DBADDITEM oTreeUsr PROMPT PLVALSTR(aRet[nInd,1])+" - "+PLVALSTR(aRet[nInd,2])+" - "+PLVALSTR(aRet[nInd,3]) CARGO " "
            Next
            DBENDTREE oTreeUsr
         Endif
         DBENDTREE oTreeUsr
         BA1->(DbSkip())
      Enddo

   Endif

   BA1->(DbSetOrder(2))
   BA1->(MsSeek(xFilial("BA1")+cMatric))

   BA3->(DbSetOrder(1))
   BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Informacoes do Contrato.                                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   TGroup():New(aPosObj[1][1],aPosObj[1][4]*0.61,aPosObj[1][3],aPosObj[1][4],STR0019,, , ,.T.) // //"Informacoes do Contrato"

   //DEFINE DBTREE oTreeCon FROM 013,170 TO 070,345 CARGO OF oDlg ON RIGHT CLICK M100Edit(oTreeCon:GetCargo())
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta DbTree para o plano de saude...                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BI3->(DbSetOrder(1))

   IF BI3->(MsSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)))
      //   DBADDTREE oTreeCon PROMPT LEFT("PRODUTO PRINCIPAL - "+BA3->BA3_CODPLA+" - "+BI3->BI3_DESCRI+Space(100),100) RESOURCE "EDITABLE","EDITABLE" CARGO "BI3/"+StrZero(BI3->(Recno()),6)+"/Produto Saude"
      //   DBENDTREE oTreeCon
      @ (aPosObj[1][1]+10),aPosObj[1][4]*0.62 Say oD2 PROMPT  'Produto Principal: ' OF oDlg SIZE 200,10 PIXEL
      If ! ExistBlock("PLM020PR")
         @ (aPosObj[1][1]+10),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT  BA3->BA3_CODPLA+" - "+BI3->BI3_DESCRI OF oDlg SIZE 200,10 PIXEL
      Else
         aRetPto := ExecBlock("PLM020PR",.F.,.F.,{BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG)})
         If Len(aRetPto) >= 1
            @ (aPosObj[1][1]+10),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT  aRetPto[1] OF oDlg SIZE 200,10 PIXEL
         Endif
      Endif
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta DbTree para o cliente...                                      ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //aRetCli := PLSAVERNIV(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->BA3_MATRIC,IF(BA3->BA3_TIPOUS=="1","F","J"),BA3->BA3_CONEMP,BA3->BA3_VERCON,BA3->BA3_SUBCON,BA3->BA3_VERSUB)

   If Len(aCliente) > 0 .and. aCliente[1]
      //   DBADDTREE oTreeCon PROMPT Left("RESPONSAVEL/CLIENTE"+Space(050),050) RESOURCE "RESPONSA","RESPONSA" CARGO strzero(nCont,12)

      cCodCli := aCliente[2]
      cLoja   := aCliente[3]
      cNome   := aCliente[4]
      _cNivel	:= aCliente[5]

      If _cNivel == "1" // Empresa
         cTxtNiv := STR0020 // //"Empresa"

      Elseif _cNivel == "2" //Nivel contrato
         cTxtNiv := STR0021 // //"Contrato"

      Elseif _cNivel == "3"  //Nivel subcontrato
         cTxtNiv := STR0022 // //"Subcontrato"

      Elseif _cNivel == "4" //Nivel familia
         cTxtNiv := STR0023 // //"Familia"

      Endif

      @ (aPosObj[1][1]+20),aPosObj[1][4]*0.62 Say oD2 PROMPT	'Resp. Financeiro : ' OF oDlg SIZE 100,10 PIXEL
      @ (aPosObj[1][1]+20),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT 	cCodCLi+"."+cLoja+" - "+cNome OF oDlg SIZE 200,10 PIXEL

      @ (aPosObj[1][1]+30),aPosObj[1][4]*0.62 Say oD2 PROMPT	'Nivel de cobrança: ' OF oDlg SIZE 100,10 PIXEL
      @ (aPosObj[1][1]+30),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT	cTxtNiv OF oDlg SIZE 200,10 PIXEL


      If _cNivel < '4'
         BG9->( dbSetorder(01) )
         BG9->( dbSeek(xFilial("BG9")+BA1->BA1_CODINT + BA1->BA1_CODEMP) )

         BQC->( dbSetorder(01) )
         BQC->( dbSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)) )

         @ (aPosObj[1][1]+40),aPosObj[1][4]*0.62 Say oD2 PROMPT	'Empresa          : ' OF oDlg SIZE 100,10 PIXEL
         @ (aPosObj[1][1]+40),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT	BG9->BG9_CODIGO+" - "+BG9->BG9_DESCRI OF oDlg SIZE 200,10 PIXEL

         @ (aPosObj[1][1]+50),aPosObj[1][4]*0.62 Say oD2 PROMPT	'Contrato / Versao: ' OF oDlg SIZE 100,10 PIXEL
         @ (aPosObj[1][1]+50),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT	BA1->BA1_CONEMP +"."+ BA1->BA1_VERCON OF oDlg SIZE 200,10 PIXEL

         @ (aPosObj[1][1]+60),aPosObj[1][4]*0.62 Say oD2 PROMPT	'Subcontrato      : ' OF oDlg SIZE 100,10 PIXEL
         @ (aPosObj[1][1]+60),(aPosObj[1][4]*0.62)+70 Say oD2 PROMPT	BQC->BQC_SUBCON +"."+ BQC->BQC_VERSUB+" - "+BQC->BQC_DESCRI   OF oDlg SIZE 200,10 PIXEL

      Endif

      //   DBADDITEM oTreeCon PROMPT cCodCli+"-"+cLoja+"   -   "+cNome RESOURCE "RESPONSA" CARGO "SA1/"+StrZero(SA1->(Recno()),6)+"/Cliente"
      //   DBENDTREE oTreeCon
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                                    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLHISMOV³ Autor ³ Tulio Cesar            ³ Data ³ 19.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe historico de movimentacoes de procedimentos.         ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLHISMOV(cMatric,cFilBD6,cFilBE4,lAllFami,aRecnosBD6,aOpcFase)
   LOcal aArea	  := GetArea()
   LOCAL bEdit   := { || nil }
   LOCAL bEdit2  := { || nil }
   LOCAL oFolder
   LOCAL _aTela  := {}
   LOCAL _aGets  := {}
   LOCAL aRetPtoEn

   LOCAL nOrdBD6 := BD6->(IndexOrd())
   LOCAL nRecBD6 := BD6->(Recno())

   LOCAL nOrdBE4 := BE4->(IndexOrd())
   LOCAL nRecBE4 := BE4->(Recno())
   LOCAL nCnt	  := 0
   LOCAL bRest   := { || BD6->(DbSetOrder(nOrdBD6)), BD6->(DbGoTo(nRecBD6)), BE4->(DbSetOrder(nOrdBE4)), BE4->(DbGoTo(nRecBE4)) }

   LOCAL cCpoBD6 := "BD6_FASE,BD6_SITUAC,BD6_SEQUEN,BD6_CODPRO,BD6_QTDPRO,BD6_CODPAD,BD6_DESPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_NOMRDA,BD6_DATPRO,BD6_CODRDA,BD6_NOMUSR,BD6_CID,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_VLRPAG,BD6_VLRTPF"
   LOCAL cCpoBE4 := "BE4_FASE,BE4_SITUAC,BE4_CODLDP,BE4_CODPEG,BE4_NUMERO,BE4_NOMRDA,BE4_CODRDA,BE4_NOMUSR,BE4_CID,BE4_CODEMP,BE4_MATRIC,BE4_TIPREG,BE4_VLRPAG,BE4_VLRPF,BE4_CODLDP,BE4_CODPEG,BE4_NUMERO"
   LOCAL cStatGuia := GetNewPar("MV_PLSGHIS","2,3,4")

   LOCAL cCposSer := GetNewPar("MV_PLSCPMS","")+","
   LOCAL cCposInt := GetNewPar("MV_PLSCPMI","BE4_FASE,BE4_SITUAC,BE4_CODLDP,BE4_CODPEG,BE4_NUMERO,BE4_NOMRDA,BE4_CODRDA,BE4_NOMUSR,BE4_CID,BE4_CODEMP,BE4_MATRIC,BE4_TIPREG,BE4_VLRPAG,BE4_VLRPF,BE4_CODLDP,BE4_CODPEG,BE4_NUMERO")

   Local cCpoBE2 := ""
   Local cAux    := ""
   //LOCAL cCposInt := GetNewPar("MV_PLSCPMI","BD6_NOMUSR,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO,BD6_DESPRO,BD6_QTDPRO,BD6_DATPRO,BD6_FASE,BD6_SITUAC,BD6_NOMRDA,BD6_CODRDA,BD6_CID,BD6_VLRPAG,BD6_VLRTPF")
   //LOCAL cCposSer := GetNewPar("MV_PLSCPMS","BE4_NOMUSR,BE4_CODEMP,BE4_MATRIC,BE4_TIPREG,BE4_CODLDP,BE4_CODPEG,BE4_NUMERO,BE4_FASE,BE4_SITUAC,BE4_NOMRDA,BE4_CODRDA,BE4_CID,BE4_VLRPAG,BE4_VLRPF,BE4_CODLDP,BE4_CODPEG,BE4_NUMERO")
   LOCAL aSize 	 := {}
   LOCAL aInfo 	 := {}
   LOCAL aObjects 	 := {}
   LOCAL aPosObj 	 := {}

   LOCAL aHeaderAux 	:= {}
   LOCAL cStrAt 	:= ""
   LOCAL cStrCpo 	:= ""
   LOCAL nPos 		:= 0
   //Integracao HAT
   LOCAL nX         := 0
   Local nT         := 0
   LOCAL nLenCabMob := 0
   LOCAL cSql       := ""
   Local cTypDB	  := UPPER(TcGetDB())
   LOCAL lConvBE2   := .F.
   LOCAL nPosSDT    := 0
   LOCAL nPosINT    := 0

   LOCAL nPosCodLdp := ""
   LOCAL nPosPEG := ""
   LOCAL nPosNumero := ""
   LOCAL nPosSequen := ""
   LOCAL cCodLdp := ""
   LOCAL cPEG := ""
   LOCAL cNumero := ""
   LOCAL cSequen := ""
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis...                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PRIVATE oTreeUsr
   PRIVATE oTreeCon
   PRIVATE oDlgMov
   PRIVATE aUserInfo
   PRIVATE aCabMov  := {}
   PRIVATE aDadMov  := {}
   PRIVATE oBrwMov
   PRIVATE cTitulo  := STR0024 // //"Historico de Movimentacoes de Procedimentos"
   PRIVATE aCols    := {}
   PRIVATE aHeader  := {}
   PRIVATE aVetTrab := {}

   PRIVATE aCabInt  := {}
   PRIVATE aDadInt  := {}
   PRIVATE aVetInt  := {}
   PRIVATE oBrwInt

   DEFAULT cFilBE4  := "(BE4->BE4_FASE $ '"+cStatGuia+"'  .And.  !(BD6->BD6_TIPGUI $ ('03','05'))  .And. BE4->BE4_SITUAC = '1')"
   DEFAULT cFilBD6  := "(BD6->BD6_FASE $ '"+cStatGuia+"'  .And.  !(BD6->BD6_TIPGUI $ ('03','05'))  .And. ( ( BD6->BD6_SITUAC = '1' ) .Or. ( BD6->BD6_SITUAC = '3' .And. BD6->BD6_LIBERA = '1' )  )  )"
   DEFAULT lAllFami := .F.
   DEFAULT aRecnosBD6 := {}
   DEFAULT aOpcFase   := {}

   cCposSer := "BD6_FASE,BD6_NUMFAT,BD6_SITUAC,BD6_SEQUEN,BD6_CODPRO,BD6_QTDPRO,BD6_CODPAD,BD6_DESPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_NOMRDA,BD6_DATPRO,BD6_CODRDA,BD6_NOMUSR,BD6_CID,BD6_CODEMP,BD6_MATRIC,BD6_TIPREG,BD6_VLRPAG,BD6_VLRTPF"+cCposSer

   // Ponto de entrada para manipular o filtro das váriaveis cFilBE4 e cFilBD6
   if ExistBlock("PL20HFIL")
      aRetPE := ExecBlock("PL20HFIL",.F.,.F.,{cFilBD6,cFilBE4})
      if len(aRetPE) > 0
         cFilBD6 := aRetPE[1]
         cFilBE4 := aRetPE[2]
      endIf
   endIf


   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa funcao para validacao de usuario generica...                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ! PLVLDUSU(cMatric)
      Eval(bRest)
      Return(.F.)
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Retina o digito verificador da matricula.                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If lAllFami
      cMatric := Subs(cMatric,1,14)
   Else
      cMatric := Subs(cMatric,1,16)
   Endif


   If Type('aTela') == "A"
      _aTela := aClone(aTela)
      aTela  := {}
   Endif

   If Type('aGets') == "A"
      _aGets := aClone(aGets)
      aGets  := {}
   Endif

   xPto := GetNewPar("MV_PLSCPBE","")
   If !Empty(xPto)
      cCpoBD6 += If(substr(xPto,1,1) <> ',',','+xPto+",",xPto+",")
      cCposSer+= If(substr(xPto,1,1) <> ',',','+xPto+",",xPto+",")
   Endif

   xPto := GetNewPar("MV_PLSCPBI","")
   If !Empty(xPto)
      cCpoBE4 += If(substr(xPto,1,1) <> ',',','+xPto+",",xPto+",")
      cCposInt+= If(substr(xPto,1,1) <> ',',','+xPto+",",xPto+",")
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta aCols e aHeader dos Dados das movimentacoes...               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SX3->(DbSetOrder(1))
   If SX3->(DbSeek("BD6"))
      While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "BD6"
         If AllTrim(SX3->X3_CAMPO) $ cCposSer
            aadd(aCabMov,{trim(X3TITULO()),SX3->X3_CAMPO,;
               SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
               SX3->X3_TIPO,nil,SX3->X3_CONTEXT})
         Endif
         SX3->(DbSkip())
      Enddo
   Endif

   aHeaderAux := {}
   cStrAt := ""
   cStrCpo := ""
   nPos := 0
   For nCnt := 1 To Len(cCposSer)
      cStrAt := Substr(cCposSer,nCnt,1)

      If cStrAt == "," .Or. cStrAt == '"' .Or. cStrAt == "'"
         nPos := Ascan(aCabMov, {|x| Alltrim(x[2]) == Alltrim(cStrCpo)} )

         If nPos > 0
            Aadd(aHeaderAux, aCabMov[nPos])
         Endif

         cStrCpo := ""
      Else
         cStrCpo += cStrAt
      Endif
   Next

   aCabMov := {}
   aCabMov := aClone(aHeaderAux)

   If Len(aRecnosBD6) == 0
      BD6->(DbSetOrder(5))
      If BD6->(MsSeek(xFilial("BD6")+cMatric))
         Inclui := .F.
         If ! lAllFami
            Store COLS "BD6" TO aDadMov FROM aCabMov VETTRAB aVetTrab While BD6->BD6_FILIAL  == xFilial("BD6") .And. ;
               BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG) = cMatric For &cFilBD6
         Else
            Store COLS "BD6" TO aDadMov FROM aCabMov VETTRAB aVetTrab While BD6->BD6_FILIAL  == xFilial("BD6") .And. ;
               BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC) = cMatric For &cFilBD6
         Endif
      Endif
   Else
      BD6->(DbSetOrder(5))
      If BD6->(MsSeek(xFilial("BD6")+cMatric))
         Inclui := .F.
         If ! lAllFami
            Store COLS "BD6" TO aDadMov FROM aCabMov VETTRAB aVetTrab While BD6->BD6_FILIAL  == xFilial("BD6") .And. ;
               BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG) = cMatric For ascan(aRecnosBD6,BD6->(Recno())) > 0
         Else
            Store COLS "BD6" TO aDadMov FROM aCabMov VETTRAB aVetTrab While BD6->BD6_FILIAL  == xFilial("BD6") .And. ;
               BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC) = cMatric For ascan(aRecnosBD6,BD6->(Recno())) > 0
         Endif
      Endif
   Endif

   //Verifica se o campo existe na BE2, caso exista, adiciona ao campo cCpoBE2, para ser usado na consulta abaixo.
   for nT := 1 to len(aCabMov)

      If BE2->(FieldPos(StrTran(aCabMov[nT,2],"BD6","BE2"))) >0
         cAux := (StrTran(aCabMov[nT,2],"BD6","BE2"))
         if AT(cAux,cCpoBE2) = 0
            cCpoBE2 += cAux + ","
         endif
      Endif

   next

   // Guias do HAT
   if GetNewPar("MV_PLSHAT","0") == "1" .And. len(aOpcFase) > 2 .And. aOpcFase[3]

      cSql += " SELECT  DISTINCT "
      cSql += " '3' AS BE2_FASE, "
      cSql += " ' ' AS BE2_NUMFAT, "
      cSql += " '1' AS BE2_SITUAC, "
      cSql += " 0 AS BE2_VLRPAG, "
      cSql += " 0 AS BE2_VLRTPF, "
      cSql += " BEA_NOMRDA AS BE2_NOMRDA, " + substr(cCpoBE2, 1, len(cCpoBE2)-1)
      cSql += " FROM "+RetSqlName("BE2")+" BE2 "

      cSql += " INNER JOIN "+RetSQLName("BEA") +" BEA "
      cSql += "   ON BEA_FILIAL = '"+xFilial("BEA")+"' "
      cSql += "   AND BE2_OPEMOV = BEA_OPEMOV "
      cSql += "   AND BE2_ANOAUT = BEA_ANOAUT "
      cSql += "   AND BE2_MESAUT = BEA_MESAUT "
      cSql += "   AND BE2_NUMAUT = BEA_NUMAUT "
      cSql += "   AND BE2_STATUS = '1' "
      cSql += "   AND BEA.D_E_L_E_T_ = ' ' "

      cSql += " LEFT JOIN "+RetSQLName("BD5") +" BD5 "
      cSql += "   ON BD5_FILIAL = '"+xFilial("BD5")+"' "
      cSql += "   AND BD5_SENHA = BEA_SENHA "
      cSql += "   AND BD5_SITUAC = '1' "
      cSql += "   AND BD5.D_E_L_E_T_ = ' ' "

      cSql += " WHERE BE2_FILIAL = '"+xFilial("BE2")+"' "
      cSql += "   AND BE2_OPEUSR = '"+Substr(cMatric,1,4)+"' "
      cSql += "   AND BE2_CODEMP = '"+Substr(cMatric,5,4)+"' "
      cSql += "   AND BE2_MATRIC = '"+Substr(cMatric,9,6)+"' "
      cSql += "   AND BE2_TIPREG = '"+Substr(cMatric,15,2)+"' "
      cSql += "   AND "+iif(cTypDB=='MSSQL','SUBSTRING','SUBSTR')+"(BE2_NUMAUT,1,1) = '9' "
      cSql += "   AND BE2.D_E_L_E_T_            = ' ' "
      cSql += "   ORDER BY BE2_DATPRO DESC "

      // Ponto de entrada para manipular a query que busca as guias do Portal Autorizador
      if ExistBlock("PL20HQRY")
         cSql := ExecBlock("PL20HQRY",.F.,.F.,{cSql})
      endIf

      nPosCodLdp := aScan(aCabMov,{|x| x[2] == 'BD6_CODLDP'})
      nPosPEG := aScan(aCabMov,{|x| x[2] == 'BD6_CODPEG'})
      nPosNumero := aScan(aCabMov,{|x| x[2] == 'BD6_NUMERO'})
      nPosSequen:= aScan(aCabMov,{|x| x[2] == 'BD6_SEQUEN'})

      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRB",.T.,.F.)
      While !TRB->(EOF())

         nLenCabMob := len(aCabMov)
         aAux := Array(nLenCabMob+1)
         aAux[nLenCabMob+1] := .F.

         for nX := 1 to nLenCabMob

            if aCabMov[nX,8] == "D"
               If FieldPos(StrTran(aCabMov[nX,2],"BD6","BE2")) >0
                  aAux[nX] := &("Stod(TRB->"+StrTran(aCabMov[nX,2],"BD6","BE2")+")")
               Endif
            else
               If FieldPos(StrTran(aCabMov[nX,2],"BD6","BE2")) >0
                  aAux[nX] := &("TRB->"+StrTran(aCabMov[nX,2],"BD6","BE2"))
               Endif
            endIf

         next

         cCodLdp := IIf(nPosCodLdp > 0, aAux[nPosCodLdp], "")
         cPEG := IIf(nPosPeg > 0, aAux[nPosPeg], "")
         cNumero := IIf(nPosNumero > 0, aAux[nPosNumero], "")
         cSequen := IIf(nPosSequen > 0, aAux[nPosSequen], "")

         If aScan(aDadMov, {|x| x[nPosCodLdp] == cCodLdp .And. x[nPosPEG] == cPEG .And. ;
               x[nPosNumero] == cNumero .And. x[nPosSequen] == cSequen}) == 0
            Aadd(aDadMov,aAux)
         Endif

         TRB->(DbSkip())

      EndDo
      TRB->(dbCloseArea())

   endIf

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta aCols e aHeader dos Dados das internacoes...                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   SX3->(DbSetOrder(1))
   If SX3->(DbSeek("BE4"))
      While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == "BE4"
         If AllTrim(SX3->X3_CAMPO) $ cCpoBE4
            aadd(aCabInt,{trim(X3TITULO()),SX3->X3_CAMPO,;
               SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,;
               SX3->X3_TIPO,nil,SX3->X3_CONTEXT})
         Endif
         SX3->(DbSkip())
      Enddo
   Endif

   aHeaderAux := {}
   cStrAt := ""
   cStrCpo := ""
   nPos := 0
   For nCnt := 1 To Len(cCposInt)
      cStrAt := Substr(cCposInt,nCnt,1)

      If cStrAt == ","
         nPos := Ascan(aCabInt, {|x| Alltrim(x[2]) == Alltrim(cStrCpo)} )

         If nPos > 0
            Aadd(aHeaderAux, aCabInt[nPos])
         Endif

         cStrCpo := ""
      Else
         cStrCpo += cStrAt
      Endif
   Next

   aCabInt := {}
   aCabInt := aClone(aHeaderAux)

   If Len(aRecnosBD6) == 0
      BE4->(DbSetOrder(4))
      If BE4->(MsSeek(xFilial("BE4")+cMatric))
         Inclui := .F.
         If ! lAllFami
            Store COLS "BE4" TO aDadInt FROM aCabInt VETTRAB aVetInt While BE4->BE4_FILIAL  == xFilial("BE4") .And. ;
               BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG) = cMatric For &cFilBE4
         Else
            Store COLS "BE4" TO aDadInt FROM aCabInt VETTRAB aVetInt While BE4->BE4_FILIAL  == xFilial("BE4") .And. ;
               BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC) = cMatric For &cFilBE4
         Endif
      Endif
   Endif

   If (nPosSDT := aScan(aCabMov,{|x| x[2] == 'BD6_DATPRO'})) > 0
      aDadMov := aSort(aDadMov,,,{|x,y| x[nPosSDT] > y[nPosSDT]})
   Endif

   If (nPosINT := aScan(aCabInt,{|x| x[2] == 'BE4_NUMERO'})) > 0
      aDadInt := aSort(aDadInt,,,{|x,y| x[nPosINT] > y[nPosINT]})
   Endif


   If ExistBlock("PLSHSMOV")
      aRetPtoEn := ExecBlock("PLSHSMOV",.F.,.F.,{aCabMov,cFilBD6,aDadMov,aVetTrab, aCabInt, aDadInt, aVetInt, cFilBE4})
      aDadMov   := aRetPtoEn[1]
      aVetTrab  := aRetPtoEn[2]
      If Len(aRetPtoEn) > 2
         aDadInt   := aRetPtoEn[3]
         aVetInt   := aRetPtoEn[4]
      EndIf
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define Dialogo...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo += " - "+AllTrim(BA1->BA1_NOMUSR)

   aSize := MsAdvSize()
   aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
   aObjects := {}
   AAdd( aObjects, { 100, 90, .t., .f. } )
   AAdd( aObjects, { 100, 100, .t., .t.,.f. } )
   aPosObj := MsObjSize( aInfo, aObjects )


   aInfo2 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
   aObjects2 := {}
   AAdd( aObjects2, { 100, 90, .t., .f. } )
   AAdd( aObjects2, { 100, 100, .t., .t.,.t. } )
   aPosObj2 := MsObjSize( aInfo2, aObjects2 )

   DEFINE MSDIALOG oDlgMov TITLE cTitulo FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd Pixel

   @ aPosObj2[2][1],aPosObj2[2][2] FOLDER oFolder SIZE aPosObj2[2][3],aPosObj2[2][4] OF oDlgMov PIXEL	PROMPTS	STR0048,STR0025 //"SADT/Consultas"### //"Internacoes"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Dados do Titular e Depedentes...          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   PLDADUSR(BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC),oDlgMov,oTreeUsr,oTreeCon,nil,aPosObj)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Browse Movimentacao...                    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Len(aDadMov) > 0
      oBrwMov := MsNewGetDados():New(005,005,aPosObj[2][3]*0.4,aPosObj[2][4]*0.99,0,,,,,,9999,,,,oFolder:aDialogs[1],aCabMov,aDadMov)
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Browse Internacoes...                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Len(aDadInt) > 0
      oBrwInt := MsNewGetDados():New(005,005,aPosObj[2][3]*0.4,aPosObj[2][4]*0.99,0,,,,,,9999,,,,oFolder:aDialogs[2],aCabInt,aDadInt)
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Botao de OK padrao...                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   SButton():New(aPosObj[2][3]*0.95, 015, 1, {|| oDlgMov:End() },,.T.)

   @ aPosObj[2][3]*0.95, 050 BUTTON oBotAde PROMPT "Busca" ACTION { || If(oFolder:nOption == 1,If(Len(aDadMov)>0,GdSeek(oBrwMov,OemtoAnsi("Busca "+STR0048),,,.T.),nil),If(Len(aDadInt)>0,GdSeek(oBrwInt,OemtoAnsi("Busca "+STR0025),aCabInt,aDadInt,.T.),nil)) } SIZE 45, 11 OF oDlgMov PIXEL

   @ aPosObj[2][3]*0.95, 100 BUTTON oBotAde PROMPT "Imprimir" ACTION { || xImpMov(aCabMov,aDadMov,aCabInt,aDadInt,cMatric) } SIZE 45, 11 OF oDlgMov PIXEL

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ponto de Entrada ...                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ExistBlock("PLS20DLG")
      ExecBlock("PLS20DLG",.F.,.F., {oFolder} )
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Ativa o Dialogo...                              ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   //-------------------------------------------------------------------
   //  LGPD
   //-------------------------------------------------------------------
   objCENFUNLGP:useLogUser()
   DbSelectArea("BA1")  // colocado por Eduardo Motta porque no Protheus 8 dava ALIAS DOES NOT EXIST depois de fechar a dialog
   ACTIVATE MSDIALOG oDlgMov

   If Len(_aTela) > 0
      aTela := aClone(_aTela)
   Endif

   If Len(_aGets) > 0
      aGets := aClone(_aGets)
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   Eval(bRest)
   RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ CriaSX1   ³ Autor ³ Alexander			 ³ Data ³ 23.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Atualiza SX1                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function CriaSX1(cPerg)
   LOCAL aRegs	:=	{}

   aadd(aRegs,{cPerg,"01","Operadora        ?","","","mv_ch1","C",4	,0,0,"G","","mv_par01",""			,"","","","",""				,"","","","",""		,"","","","","","","","","","","","","","B89PLS"	,""})

   PlsVldPerg( aRegs )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ xImpMov 	³ Autor ³ Daher          		³ Data ³ 30.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ 															  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Right CLick do Dbtree                                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xImpMov(aCabMov,aDadMov,aCabInt,aDadInt,cMatric)
   PRIVATE cTitulo 	:= "Relatorio de Movimentações"
   PRIVATE cPerg       := Padr("PLRCONUS",Len(SX1->X1_GRUPO))
   PRIVATE oReport     := nil
   PRIVATE cFileName	:= lower("movtusr"+CriaTrab(NIL,.F.))
   PRIVATE nTweb		:= 1
   PRIVATE nLweb		:= 0
   PRIVATE aRetWeb		:= {}
   PRIVATE aRet		:= {}
   PRIVATE nLeft		:= 40
   PRIVATE nRight		:= 4000
   PRIVATE nCol0  		:= nLeft
   PRIVATE nTop		:= 100
   PRIVATE nTopInt		:= nTop
   PRIVATE nPag		:= 1

   CriaSX1(cPerg)
   oReport	:= TReport():New("PLSM020", cTitulo, cPerg, {|oReport| x2ImpMo(oReport,aCabMov,aDadMov,aCabInt,aDadInt,cMatric) }, cTitulo)
   oReport:SetLandscape()	//--Modo paisagem
   oReport:PrintDialog()

Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ x2ImpMo 	³ Autor ³ Daher          		³ Data ³ 30.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ 															  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Right CLick do Dbtree                                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function x2ImpMo(oReport,aCabMov,aDadMov,aCabInt,aDadInt,cMatric)

   LOCAL nPos4  := PLRETPOS("BD6_VLRPAG",aCabMov)
   LOCAL nPosA4 := PLRETPOS("BE4_VLRPAG",aCabInt)

   LOCAL nPos5  := PLRETPOS("BD6_CID",aCabMov)
   LOCAL nPosA5 := PLRETPOS("BE4_CID",aCabInt)

   LOCAL nPos7  := PLRETPOS("BD6_CODRDA",aCabMov)
   LOCAL nPosA7 := PLRETPOS("BE4_CODRDA",aCabInt)

   LOCAL nPos8  := PLRETPOS("BD6_DATPRO",aCabMov)
   //LOCAL nPosA8  := PLRETPOS("BE4_DATPRO",aCabInt)

   LOCAL nPos9  := PLRETPOS("BD6_NOMRDA",aCabMov)
   LOCAL nPosA9  := PLRETPOS("BE4_NOMRDA",aCabInt)

   LOCAL nPos10 := PLRETPOS("BD6_CODPEG",aCabMov)
   LOCAL nPosA10 := PLRETPOS("BE4_CODPEG",aCabInt)

   LOCAL nPos11 := PLRETPOS("BD6_NUMERO",aCabMov)
   LOCAL nPosA11 := PLRETPOS("BE4_NUMERO",aCabInt)

   LOCAL nPos12 := PLRETPOS("BD6_DESPRO",aCabMov)
   //LOCAL nPosA12 := PLRETPOS("BE4_DESPRO",aCabInt)

   LOCAL nPos13 := PLRETPOS("BD6_CODPAD",aCabMov)
   //LOCAL nPosA13 := PLRETPOS("BE4_CODPAD",aCabInt)

   LOCAL nPos14 := PLRETPOS("BD6_CODPRO",aCabMov)
   //LOCAL nPosA14 := PLRETPOS("BE4_CODPRO",aCabInt)

   LOCAL nPos15 := PLRETPOS("BD6_QTDPRO",aCabMov)
   //LOCAL nPosA15 := PLRETPOS("BE4_QTDPRO",aCabInt)

   LOCAL nI		:= 1
   LOCAL oSTITULO := NIL
   PRIVATE oFnt9		:= TFont():New("Courier New"		,,9,,.F.,,,,,.F.,.F.)
   PRIVATE oFnt10		:= TFont():New("Arial"		,,10,,.F.,,,,,.F.,.F.)
   PRIVATE oFnt10c		:= TFont():New("Lucida Console",,10,,.F.,,,,,.F.,.F.)
   PRIVATE oFnt10N		:= TFont():New("Arial"		,,10,,.T.,,,,,.F.,.F.)
   PRIVATE oFnt10cN	:= TFont():New("Courier New",,10,,.T.,,,,,.F.,.F.)
   PRIVATE oFnt14N		:= TFont():New("Arial"		,,14,,.T.,,,,,.F.,.F.)
   PRIVATE oFnt32N		:= TFont():New("Courier New",,32,,.T.,,,,,.F.,.F.)

   oReport:HideHeader()
   oReport:HideFooter()

   oSTITULO := TRSection():new(oReport, "TITULO", {"TRBLIV"},,.f.,.t.)
   oSTITULO:setPageBreak(.F.)
   oSTITULO:setLineBreak(.T.)
   oSTITULO:setHeaderPage(.T.)
   oSTITULO:SetAutoSize(.T.)
   oSTITULO:SetHeaderSection(.T.)

   TRCell():new(oSTITULO,"DATPRO", "TRBLIV", "Data Pro.", "@D", 25) // Data do procedimentp
   TRCell():new(oSTITULO,"CODRDA", "TRBLIV", "Código RDA", "@R 99999999", 08)//Código da RDA
   TRCell():new(oSTITULO,"NOMRDA", "TRBLIV", "Nome da RDA", "@!", 25)//Nome da RDA
   TRCell():new(oSTITULO,"NUMERO", "TRBLIV", "Protocolo", "@R 99999999", 25)//Número do protocolo
   TRCell():new(oSTITULO,"CODPRO", "TRBLIV", "Cód. Procedimento", "@R 9999999999", 25)//Código do procedimento
   TRCell():new(oSTITULO,"DESPRO", "TRBLIV", "Desc. Procedimento", "@!", 30)//Descrição do procedimento
   TRCell():new(oSTITULO,"QTDPRO", "TRBLIV", "Qtd", "@R 99999999", 25)//Quantidade do procedimento
   TRCell():new(oSTITULO,"CID", "TRBLIV", "CID", "@!", 25)//CID
   TRCell():new(oSTITULO,"VLRPAG", "TRBLIV", "Valor", "@!", 25)//Valor

   If Len(aDadMov) <> 0 .or. Len(aDadInt) <> 0

      If Len(aDadMov) > 0

         For nI:=1 to Len(aDadMov)

            oSTITULO:init()

            oSTITULO:cell("DATPRO"):setValue(PADR(dtoc(aDadMov[nI][nPos8]),__NTAM1))
            oSTITULO:cell("CODRDA"):setValue(PADR(aDadMov[nI][nPos7]+aDadMov[nI][nPos9],__NTAM2))
            oSTITULO:cell("NOMRDA"):setValue(PADR(aDadMov[nI][nPos9],__NTAM2))
            oSTITULO:cell("NUMERO"):setValue(PADR(aDadMov[nI][nPos10]+aDadMov[nI][nPos11],__NTAM3))
            oSTITULO:cell("CODPRO"):setValue(PADR(aDadMov[nI][nPos13]+aDadMov[nI][nPos14],__NTAM4))
            oSTITULO:cell("DESPRO"):setValue(PADR(aDadMov[nI][nPos12],__NTAM5)+SPACE(10))
            oSTITULO:cell("QTDPRO"):setValue(PADR(aDadMov[nI][nPos15],__NTAM6))
            oSTITULO:cell("CID"):setValue(PADR(aDadMov[nI][nPos5],__NTAM7)+SPACE(10))
            oSTITULO:cell("VLRPAG"):setValue(PADR('R$ '+alltrim(TransForm(aDadMov[nI][nPos4],PLSMONEY)),__NTAM8))

            oSTITULO:printLine()
            oSTITULO:finish()
         Next
      Endif

      If Len(aDadMov) > 0

         For nI:=1 to Len(aDadInt)

            oSTITULO:init()

            oSTITULO:cell("DATPRO"):setValue(PADR(dtoc(aDadMov[nI][nPos8]),__NTAM1))
            oSTITULO:cell("CODRDA"):setValue(PADR(aDadInt[nI][nPosA7]+aDadInt[nI][nPosA9],__NTAM2)	)
            oSTITULO:cell("NOMRDA"):setValue(PADR(aDadInt[nI][nPosA9],__NTAM2))
            oSTITULO:cell("NUMERO"):setValue(PADR(aDadInt[nI][nPosA10]+aDadInt[nI][nPosA11],__NTAM3))
            oSTITULO:cell("CODPRO"):setValue(PADR(aDadMov[nI][nPos13]+aDadMov[nI][nPos14],__NTAM4))
            oSTITULO:cell("DESPRO"):setValue(PADR(aDadMov[nI][nPos12],__NTAM5)+SPACE(10))
            oSTITULO:cell("QTDPRO"):setValue(PADR(aDadMov[nI][nPos15],__NTAM6))
            oSTITULO:cell("CID"):setValue(PADR(aDadInt[nI][nPosA5],__NTAM7)+SPACE(10))
            oSTITULO:cell("VLRPAG"):setValue(PADR('R$ '+alltrim(TransForm(aDadInt[nI][nPosA4],PLSMONEY)),__NTAM8))

            oSTITULO:printLine()
            oSTITULO:finish()

         Next
      Endif
   Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ x2ImpMo 	³ Autor ³ Daher          		³ Data ³ 30.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ 															  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Right CLick do Dbtree                                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xCabPGR(oReport,cTitulo,lInter)
   DEFAULT lInter := .F.

   nTop		:= 100
   nTopInt		:= nTop
   nLeft		:= 40

   nTop	+= _BL
   nTopAux := nTop


   nRight	:= 4000

   aBMP:={"lgrl.bmp"}
   If File("lgrl" + FWGrpCompany() + FWCodFil() + ".bmp")
      aBMP := { "lgrl" + FWGrpCompany() + FWCodFil() + ".bmp" }
   ElseIf File("lgrl" + FWGrpCompany() + ".bmp")
      aBMP := { "lgrl" + FWGrpCompany() + ".bmp" }
   EndIf

   oReport:SayBitmap(nTop/nTweb, nLeft/nTweb, aBMP[1], 400/nTweb, 123/nTweb)

   cMsg := "Relatorio de Movimentacoes - "+cTitulo
   nTop += 125
   oReport:Say(((nTop)/nTweb)+nLweb, (nLeft + 1000)/nTweb, cMsg, oFnt14N)
   cMsg := "Data: "+dToc(dDataBase)
   nTop += 35
   oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
   cMsg := "Hora: "+time()
   nTop += 35
   oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
   cMsg := "Beneficiario: "+BA1->BA1_NOMUSR
   nTop += 35
   oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
   cMsg := "Pagina: "+alltrim(str(nPag))+""
   nTop += 35
   oReport:Say(((nTop)/nTweb)+nLweb, nLeft/nTweb, cMsg, oFnt10c)
   nTop += _BL
   oReport:Line(((nTop)/nTweb)+nLweb, nLeft/nTweb, (nTop/nTweb)+nLweb, nRight/nTweb)
   nTop += _BL
   nPag++


   nTop += 60
   If !lInter
      cMsg := PADR("Data ",__NTAM1)
      cMsg += PADR("Prestador",__NTAM2)
      cMsg += PADR("Protocolo",__NTAM3)
      cMsg += PADR("Procedimento",__NTAM4+__NTAM5+10)
      cMsg += PADR("QTD",__NTAM6)
      cMsg += PADR("CID",__NTAM7+10)
      cMsg += PADR("Valor Pago",__NTAM8)
   Else
      cMsg := PADR("Prestador",__NTAM2)
      cMsg += PADR("Protocolo",__NTAM3)
      cMsg += PADR("CID",__NTAM7+10)
      cMsg += PADR("Valor Pago",__NTAM8)
   Endif
   oReport:Say(nTop/nTweb, nCol0/nTweb, cMsg, oFnt10c)

   nTop += _BL
   oReport:Line((nTop/nTweb)-nLweb, nLeft/nTweb, (nTop/nTweb)-nLweb, nRight/nTweb)



Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ M100EDIT ³ Autor ³ Tulio Cesar           ³ Data ³ 30.06.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Edita registro clicado no Dbtree.                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Right CLick do Dbtree                                      ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100Edit(cCargo)
   LOCAL cAlias
   LOCAL nRecno
   LOCAL cOldCad := ""
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Testa conteudo do parametro...                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If Empty(cCargo)
      Return
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Estrutura do cCargo...                          ³
   //³ 1,3  -> Alias do Arquivo...                     ³
   //³ 4,6  -> Numero do registro...                   ³
   //³ 8,30 -> Titulo...                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cAlias  :=Subs(cCargo,1,3)
   nRecno  := Val(Subs(cCargo,5,6))
   If Type('cCadastro') == "C"
      cOldCad := cCadastro
   Endif

   DbSelectArea(cAlias)
   DbGoTo(nRecno)

   cCadastro := Subs(cCargo,12,30)

   AxVisual(cAlias,nRecno,K_Visualizar)

   If ! Empty(cOldCad)
      cCadastro := cOldCad
   Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVALBAI ³ Autor ³ Tulio Cesar       ³ Data ³ 28.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna o valor da movimentacao bancaria de um titulo  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLVALBAI(dDataIni,dDataFin,lPorData)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Parametros default...                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   DEFAULT lPorData := .F.
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ aRetorno[1] - Valor dos Descontos                              ³
   //³ aRetorno[2] - Valor dos Juros                                  ³
   //³ aRetorno[3] - Valor da Multa                                   ³
   //³ aRetorno[4] - Valor da Correcao                                ³
   //³ aRetorno[5] - Valor total das baixas                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aRetorno := {0,0,0,0,0}
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Por enquando vou voltar o do titulo mesmo...                   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aRetorno[1] := SE1->E1_DESCONT
   aRetorno[2] := SE1->E1_JUROS
   aRetorno[3] := SE1->E1_MULTA
   aRetorno[4] := SE1->E1_CORREC
   aRetorno[5] := SE1->E1_VALLIQ
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Retorno da funcao...                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRetorno)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLMOVMAN ³ Autor ³ Tulio Cesar       ³ Data ³ 08.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Trata codigo do procedimento da digitacao da guia...   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLMOVMAN(cMatric,dDataPro)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Salva dados...                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL nRecBA1 := BA1->(Recno())
   LOCAL nOrdBA1 := BA1->(IndexOrd())

   LOCAL nRecBA3 := BA3->(Recno())
   LOCAL nOrdBA3 := BA3->(IndexOrd())

   LOCAL lRet    := .T.
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Posiciona no contrato...                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BA3->(DbSetOrder(1))

   If BA3->(MsSeek(xFilial("BA3")+Subs(cMatric,1,13)))
      If ! Empty(BA3->BA3_MOTBLO) .And. dtos(dDataPro) >= dtos(BA3->BA3_DATBLO)
         lRet := .F.
      Endif

      If lRet
         BA1->(DbSetOrder(2))

         If BA1->(MsSeek(xFilial("BA1")+cMatric))
            If ! Empty(BA1->BA1_MOTBLO) .And. dtos(dDataPro) >= dtos(BA1->BA1_DATBLO)
               lRet := .F.
            Endif
         Endif
      Endif
   Endif

   SX3->(DbSetOrder(2))
   If SX3->(MsSeek("BG3_MOVTO")) .And. ! lRet
      BG3->(DbSetOrder(1))
      If BG3->(MsSeek(xFilial("BG3")+BA3->BA3_MOTBLO))
         If BG3->BG3_MOVTO == "S"
            lRet := .T.
         Endif
      Endif
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Caso esteja bloqueado no dia gloso automatico...               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ! lRet
      nPos := PLRETPOS("BE2_CODGLO",aHeader)
      aCols[n,nPos] := GETMV("MV_PLUSUDE")
      nPos := PLRETPOS("BE2_MOTGLO",aHeader)
      aCols[n,nPos] := Posicione("SX5",1,xFilial("SX5")+"B2"+GETMV("MV_PLUSUDE"),"X5_DESCRI")

      MsgInfo(STR0028+Chr(13)+Chr(13)+STR0029) //### //"Usuario Bloqueado."###"O Sistema vai glosar automaticamente"
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Restaura dados salvados...                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BA1->(DbGoto(nRecBA1))
   BA1->(DbSetOrder(nOrdBA1))

   BA3->(DbGoto(nRecBA3))
   BA3->(DbSetOrder(nOrdBA3))

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Retorno da funcao...                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLVINCPAR³ Autor ³ Tulio Cesar       ³ Data ³ 08.08.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Vincula primeira parcela do contrato...                ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLVincPar(cMatric)
   LOCAL nI
   LOCAL lOK := .F.
   LOCAL cSqlFilial:= ""

   If ExistBlock( "PLSXFILI" )
      cSqlFilial := ExecBlock( "PLSXFILI", .F., .F., {"SE1"} )
   Else
      cSqlFilial := xFilial("SE1")
   EndIf

   BA3->(DbSetOrder(1))

   If BA3->(MsSeek(xFilial("BA3")+cMatric))
      SA1->(DbSetOrder(1))
      If SA1->(MsSeek(xFilial("SA1")+BA3->(BA3_CODCLI+BA3_LOJA)))
         SE1->(DbSetOrder(1))

         SX5->(DbSetOrder(1))

         If SX5->(MsSeek(xFilial("SX5")+"BG"))
            aSX5    := FWGetSX5("BG")
            nLenSX5 := LEN(aSX5)
            FOR nI := 1 TO nLenSX5
               If AllTrim( aSX5[nI][1] + aSX5[nI][2] ) == xFilial("SX5")+"BG"
                  If SE1->(MsSeek(cSqlFilial+Subs(aSX5[nI][3],1,3)+BA3->BA3_NUMCON))
                     If VAL(SE1->E1_CPFCLI) == VAL(SA1->A1_CGC) .And. Empty(SE1->E1_MATRIC)
                        SE1->(RecLock("SE1",.F.))

                        If SE1->E1_PREFIXO == "REC"
                           SE1->E1_MESBASE := StrZero(Month(BA3->BA3_DATBAS),2)
                           SE1->E1_ANOBASE := Subs(dtos(BA3->BA3_DATBAS),1,4)
                        Endif
                        SE1->E1_CODINT  := BA3->BA3_CODINT
                        SE1->E1_CODEMP  := BA3->BA3_CODEMP
                        SE1->E1_MATRIC  := BA3->BA3_MATRIC
                        SE1->(MsUnLock())
                        lOK := .T.
                     Endif
                  Endif
               EndIf
            NEXT
         Endif
      Endif
   Endif

Return(lOK)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLCUSUSR ³ Autor ³ Tulio Cesar       ³ Data ³ 26.12.00 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Avalida o lucro ou prejuizo de um usuario              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLCUSUSR(cMatric,cAno,cMes)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Avalia o custo de toda a sua movimentacao...                   ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nCusto := 0

   BE2->(DbSetOrder(3))
   If BE2->(MsSeek(xFilial("BE2")+cMatric+cAno+cMes))
      While ! BE2->(Eof()) .And. BE2->(BE2_FILIAL+BE2_CODINT+BE2_CODEMP+BE2_MATRIC+BE2_TIPREG+BE2_ANO+BE2_MES) == xFilial("BE2")+cMatric+cAno+cMes
         nCusto += (BE2_VALTOT-BE2_VLRGLO)
         BE2->(DbSkip())
      Enddo
   Endif

Return(nCusto)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLSMSGCA³ Autor ³ Roberto Vanderlei      ³ Data ³ 02.04.15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe dialogo com pacotes ...     					       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSMSGPCT(cCodPro, aDadProc)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Parametros: cCodPro - Código do Procedimento                          ³
   //	  			  aDadProc - Dados do Procedimento                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis da rotina...                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   local cTitulo := ""
   local oDlg
   LOCAL oSay		 := nil
   local aSize := {}
   local nLinSel

   local cLin1 := 008.0
   local cLin2 := 030.8
   local cCol1 := 010.3
   local cCol2 := 90.3

   Local aCampos := {}
   Local aBls    := {}

   cTitulo := STR0049 + cCodPro //Pacotes do procedimento


   DEFINE FONT oFont NAME "Arial" Size 0,-16 BOLD
   DEFINE MSDIALOG oDlg TITLE cTitulo FROM cLin1,cCol1 TO cLin2,cCol2


   oList := TCBrowse():New( 01, 01, 320, 156,, {/*'Código'*/STR0040, /*'Descrição'*/ STR0031},{20,50,50,50}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oList:SetArray(aDadProc)

   oList:bLine := { || { aDadProc[oList:nAt, 01], aDadProc[oList:nAt, 02] }}

   //-- LGPD --------
   if objCENFUNLGP:isLGPDAt()
      aCampos := {"BLD_CODPRO","BLD_DESPRO"}
      aBls := objCENFUNLGP:getTcBrw(aCampos)
      oList:aObfuscatedCols := aBls
   endif
   //----------------

   oList:blDblClick := {|| nLinSel := aDadProc[oList:nAt, 01], oDlg:End()}

   TButton():New(160, 002,"Não Vincular ao Pacote",,{|| nLinSel := 1,oDlg:End()},075,010,,,,.T.)

   ACTIVATE MSDIALOG oDlg CENTERED

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return nLinSel




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLSMSGCA³ Autor ³ Tulio Cesar            ³ Data ³ 05.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe dialogo com msg de cartao magnetico ...              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSMSGCA(cMatric)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Parametros: cMatric - Matricula do Usuario                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis da rotina...                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL aDados
   LOCAL aCabec  := { {STR0030,"@!",70},{STR0031,"@!",150},{STR0032,"@D",040},{STR0033,"@C",080}} //######### //"Codigo Grupo de Carencia"###"Descricao"###"Data Carencia"###"Situacao"
   LOCAL cTitulo := ""
   LOCAL cTipo	  := "1"

   BA1->(DbSetOrder(2))
   BA1->(MsSeek(xFilial("BA1")+cMatric))

   If  !BA1->(Found())
      BA1->(DbSetOrder(5))
      BA1->(MsSeek(xFilial("BA1")+cMatric))
      cTipo	  := "2"
   Endif

   If BA1->(Found())

      cTitulo := STR0034+ dtoc(BA1->BA1_DATCAR)+Space(02)+ AllTrim(BA1->BA1_NOMUSR)  // //"GRUPO DE CARENCIA  Data Base Carencia "
      BA3->(DbSetOrder(1))
      BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
      aDados := PLSLISMSGC(cMatric,BA3->(BA3_CODINT+BA3_CODPLA),BA3->BA3_VERSAO,BA1->BA1_DATCAR,BA1->BA1_SEXO,cTipo)

      aCdCores  	:= { 	{ 'BR_VERDE'    ,OemtoAnsi('Carencia Cumprida')},;
         { 'BR_VERMELHO' ,OemtoAnsi('Em Carencia')} }

      aCores   := {	{ 'aDados[oCritica:nAt, 4] == "Carencia Cumprida"'	,aCdCores[1,1] },;
         { 'aDados[oCritica:nAt, 4] == "Em Carencia"'		,aCdCores[2,1] }}

      PLSCRIGEN(aDados,aCabec,cTitulo,,,,,,,,,,,,,,,,,aCores,aCdCores)
      //   PLSCRIGEN(aDados,aCabec,cTitulo)
   Else
      Help("",1,"PLSMSGCA")
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³PLSLISMSGC³ Autor ³ Tulio Cesar           ³ Data ³ 06.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna uma matriz com os grupos de carencia p/ um usuario ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSLISMSGC(cMatric,cCodPla,cVersao,dDataCar,cSexo,cTipo)
   LOCAL aDados    := {}
   LOCAL nMaior    := 0
   LOCAL nQtd      := 0
   LOCAL lOk       := .T.
   LOCAL aCarencia := array(6)
   LOCAL aRet      := {}
   LOCAL aDadUsr   := {}
   LOCAL sMsg1		:= STR0035 // //"Carencia Cumprida"
   LOCAL sMsg2		:= STR0036 // //"Em Carencia"
   LOCAL aReturn   := {}
   LOCAL lPLSPEMGC := ExistBlock("PLSPEMGC")
   DEFAULT cTipo   := "1"

   aDadUsr   := PLSDADUSR(cMatric,cTipo,.F.,dDatabase)

   If aDadUsr[1]
      BAY->(DbSetOrder(1))
      BAT->(dbSetOrder(1))
      BAE->(DbSetOrder(1))
      If BAY->(MsSeek(xFilial("BAY")+cCodPla+cVersao))
         //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         //³ Processa cada Grupo de Carencia do produto                          ³
         //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
         While ! BAY->(Eof()) .And. BAY->(BAY_FILIAL+BAY_CODIGO+BAY_VERSAO) == xFilial("BAY")+cCodPla+cVersao

            //Ponto de entrada para mudanca das mensagens exibibas para informar se esta em carencia por grupo
            If  lPLSPEMGC
               aReturn := ExecBlock("PLSPEMGC",.F.,.F.,{BAY->BAY_CODGRU,sMsg1,sMsg2})
               sMsg1	:= aReturn[1]
               sMsg2	:= aReturn[2]
            Endif

            If BAE->(MsSeek(xFilial("BAE")+cCodPla+cVersao+BAY->BAY_CODGRU))
               nMaior := 0
               //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
               //³ Processa cada Casse de Carencia deste Grupo de Carencia             ³
               //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
               While ! BAE->(Eof()) .And. BAE->(BAE_FILIAL+BAE_CODIGO+BAE_VERSAO+BAE_CODGRU) == xFilial("BAE")+cCodPla+cVersao+BAY->BAY_CODGRU

                  aCarencia[1] := BAE->BAE_UNCAR        // unidade de carencia
                  aCarencia[2] := BAE->BAE_CARENC       // qtd de carencia
                  aCarencia[3] := ""                    // nivel da classe de carencia
                  aCarencia[4] := BAE->BAE_CLACAR       // classe de carencia
                  aCarencia[5] := substr(cMatric,1,4)   // operadora
                  aCarencia[6] := dDataCar

                  aRet := PlsClasCar(aCarencia,aDadUsr,"","",substr(cMatric,1,4),Substr(cCodPla,5),cVersao,.F.)

                  nQtd := PLSCarDias(aRet[2],aRet[1])

                  If nQtd > nMaior
                     nMaior := nQtd
                  Endif

                  BAE->(DbSkip())

               Enddo

               BAT->(MsSeek(xFilial("BAT")+Subs(BAY->BAY_CODIGO,1,4)+BAY->BAY_CODGRU))
               If  BAT->(FieldPos("BAT_SEXO")) > 0
                  If  BAT->BAT_SEXO $ " 3" .or. BAT->BAT_SEXO == cSexo
                     lOk := .T.
                  Else
                     lOk := .F.
                  Endif
               Else
                  lOk := .T.
               Endif

               If  lOk
                  aadd(aDados,{BAY->BAY_CODGRU,;
                     BAT->BAT_DESCRI,;
                     dDataCar+nMaior,;
                     If(dDataCar+nMaior<=dDataBase,sMsg1,sMsg2),;
                     nMaior})
               Endif
            Endif

            BAY->(DbSkip())

         Enddo
      Endif
   Endif

Return(aDados)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³PLSCLACAR³ Autor ³ Tulio Cesar            ³ Data ³ 06.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe dialogo com as classes de carencia p/ um usuario     ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSVSCLACAR(cMatric)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Parametros: cMatric - Matricula do Usuario                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis da rotina...                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL cMatOri:= ""
   LOCAL aDados
   LOCAL aNew    := {}
   LOCAL nY      := 0
   LOCAL aAjus   := {}
   LOCAL aMatric := {}
   LOCAL nH      := 0
   LOCAL aCabec  := { {STR0037,"@!","10"},{STR0031,"@!","45"},{STR0038,"@D","20"},{STR0033,"@C","50"}} // ######### //"Codigo Classe de Carencia"###"Descricao"###"Final Carencia"###"Situacao"
   LOCAL cTitulo := Eval({ || BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+cMatric)), ;
      STR0039 + dtoc(BA1->BA1_DATCAR)+Space(02)+" - "+; // //"CLASSE DE CARENCIA  - Data Base Carencia : "
      AllTrim(BA1->BA1_NOMUSR) })

   If BA1->(Found())
      BA3->(DbSetOrder(1))
      BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

      If Empty(BA1->BA1_DATTRA)
         aDados := PLSCLACAR(BA1->BA1_CODINT,cMatric,BA1->BA1_DATCAR)
      else
         aDados := PLSCLACAR(BA1->BA1_CODINT,cMatric,BA1->BA1_DATCAR)                                      //este novo tratamento é só para benef. transferido
         aDados:= aDados[2]                                                                                //pego somente as informações de carência baseada na data de carência do benf. atual

         aAreaBA1 := BA1->(getArea())
         cMatOri := allTrim(BA1->BA1_TRAORI)

         BA1->(DBGoTop())
         BA1->(dbSetOrder(2))

         while ! empty(cMatOri) .and. BA1->(msSeek(xFilial("BA1")+cMatOri))

            aadd(aMatric,{BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO),BA1->(recno())})

            if allTrim(cMatOri) <> allTrim(BA1->BA1_TRAORI) .And. !EmpTy(BA1->BA1_TRAORI)
               cMatOri := allTrim(BA1->BA1_TRAORI)
            else
               cMatOri := ""
            endIf

         endDo

         BA1->(restArea(aAreaBA1))

         If Len(aMatric) > 0
            ASORT(aMatric, , , {|x, y| x[2] < y[2]} )
         EndIf

         for nY := 1 to len(aMatric)
            cDadAnt := ""
            aCodCri := {}
            aSlvUsr := PLSDADUSR(aMatric[nY][1],"1",.f.,dDataBase,nil,nil,nil,nil,.f.)

            if aSlvUsr[1]

               aAjus:=PLSCLACAR(BA1->BA1_CODINT,aMatric[nY,1],aSlvUsr[28])

               If aAjus[1]
                  aAjus:=aAjus[2]

                  for nH:=1 to Len(aAjus)                                                   //aqui pego as classes antigas e vou juntando no aAux
                     If Len(aNew)==0 .Or. (Ascan(aNew,{ |x| x[1] == aAjus[nH,1]}))==0       //vou manter a primeira classe, as posteriores iguais desconsidero
                        AADD(aNew,aAjus[nH])

                        If (nPos:=Ascan(aDados,{ |x| x[1] == aNew[Len(aNew),1]}))>0
                           aNew[Len(aNew),5]:= aDados[nPos,3]
                           aNew[Len(aNew),6]:= aDados[nPos,4]
                        Endif

                     Endif
                  Next nH
               EndIf
            endIf

         next

         for nH:=1 to Len(aDados)                                                        //as que eu não tinha antes, agora tenho baseado na data de transferência
            If (Ascan(aNew,{ |x| x[1] == aDados[nH,1]}))==0
               AADD(aNew,aDados[nH])
               aNew[Len(aNew),5] :=  aNew[Len(aNew),3]
               aNew[Len(aNew),6] :=  aNew[Len(aNew),4]
               aNew[Len(aNew),3] :=  "         -"
               aNew[Len(aNew),4] :=  "         -"

            EndIf
         next nH

         for nH:=1 to Len(aNew)
            If ValType(aNew[nH,6]) == "L"
               aNew[nH,5] :=  "         -"
               aNew[nH,6] :=  "         -"
            EndIf
         next nH

         If Len(aNew)>0
            aDados:={}
            AADD(aDados,.T.)
            AADD(aDados,ASORT(aNew, , , {|x, y| x[1] < y[1]} ))

            aCabec:= { {STR0037,"@!","10"},{STR0031,"@!","45"},{"Final Carência(Rede Migrada)","@D","20"},{"Status(Rede Migrada)","@C","50"},{"Final Carência(Nova Rede)","@D","20"},{"Status(Nova Rede)","@C","50"} }

         ElseIf Len(aDados)==0
            AADD(aDados,.F.)
         Endif

      Endif

      If aDados[1]
         PLSCRIGEN(aDados[2],aCabec,cTitulo,,,,,,,,116)
      Else
         Help("",1,"PLSCLACAR")
      Endif

   Else
      Help("",1,"PLSCLACAR")
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLSRTGCUSR ³ Autor ³ Tulio Cesar         ³ Data ³ 05.11.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Retorna os grupos de coberturas de um usuario.             ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSRTGCUSR(cMatric)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Parametros: cMatric - Matricula do Usuario                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis da rotina...                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL aDados
   LOCAL aCabec  := { {STR0040,"@!",20},{STR0041,"@!",100},{STR0042,"@C",050}} //###### //"Codigo"###"Grupo de Cobertura"###"Nivel"
   LOCAL cTitulo := Eval({ || BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+cMatric)), ;
      STR0043+AllTrim(BA1->BA1_NOMUSR)+STR0044 }) //### //"Grupos de Cobertura do Usuario ["###"]"

   If BA1->(Found())
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Define variaveis da rotina...                                       ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      aDados := PLSGCOBUSR(cMatric)

      If aDados[1]
         PLSCRIGEN(aDados[2],aCabec,cTitulo)
      Else
         Help("",1,"PLSRTGCUSR")
      Endif
   Else
      Help("",1,"PLSRTGCUSR")
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Fim da Rotina...                                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSGCOBUSR ³ Autor ³ Tulio Cesar          ³ Data ³ 05.11.2003 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna uma matriz com os grupos de cobertura do usuario      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSGCOBUSR(cMatricUsr)
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define variaveis da rotina...                                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   LOCAL aRet      := {.F.,{}}
   LOCAL aGrupos   := {}
   LOCAL bVldExist := { || nPos := Ascan(aGrupos, {|x| x[1] == BG7->BG7_CODGRU } ), (nPos == 0) }
   LOCAL cCodPla	:= ''
   LOCAL cVerPla	:= ''
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Posiciona no usuario...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BA1->(DbSetOrder(2))
   If ! BA1->(MsSeek(xFilial("BA1")+cMatricUsr))
      Return(aRet)
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Posiciona no familia...                                                  ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BA3->(DbSetOrder(1))
   If ! BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
      Return(aRet)
   Endif

   If !Empty(BA1->BA1_CODPLA)
      cCodPla := BA1->BA1_CODPLA
      cVerPla := BA1->BA1_VERSAO
   Else
      cCodPla := BA3->BA3_CODPLA
      cVerPla := BA3->BA3_VERSAO
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Define ordem padrao para pesquisa no arquivo de grupo de cobertura...    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BG7->(DbSetOrder(1))
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Pesquisa Grupos de Cobertura do Usuario...                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BFE->(DbSetOrder(1))
   If BFE->(MsSeek(xFilial("BFE")+cMatricUsr))
      While ! BFE->(Eof()) .And. BFE->(BFE_FILIAL+BFE_CODINT+BFE_CODEMP+BFE_MATRIC+BFE_TIPREG) == ;
            xFilial("BFE")+cMatricUsr

         If BG7->(MsSeek(xFilial("BG7")+BFE->BFE_CODINT+BFE_CODGRU)) .And. Eval(bVldExist)
            aadd(aGrupos,{BG7->BG7_CODGRU,BG7->BG7_DESCRI,STR0045}) // //"Usuario"
         Endif

         BFE->(DbSkip())
      Enddo
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Pesquisa Grupos de Cobertura da familia...                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BFC->(DbSetOrder(1))
   If BFC->(MsSeek(xFilial("BFC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
      While ! BFC->(Eof()) .And. BFC->(BFC_FILIAL+BFC_CODINT+BFC_CODEMP+BFC_MATRIC) == ;
            xFilial("BFC")+cMatricUsr

         If BG7->(MsSeek(xFilial("BG7")+BFC->BFC_CODINT+BFC_CODGRU)) .And. Eval(bVldExist)
            aadd(aGrupos,{BG7->BG7_CODGRU,BG7->BG7_DESCRI,STR0023}) // //"Familia"
         Endif

         BFC->(DbSkip())
      Enddo
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Pesquisa Grupos de Cobertura do Grupo Empresa...                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If BA3->BA3_TIPOUS == "2"
      BT7->(DbSetOrder(1))
      If BT7->(MsSeek(xFilial("BFC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+cCodPla)))
         While ! BT7->(Eof()) .And. BT7->(BT7_FILIAL+BT7_CODINT+BT7_NUMCON+BT7_VERCON+BT7_SUBCON+BT7_VERSUB+BT7_CODPLA) == ;
               xFilial("BFC")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+cCodPla)

            If BG7->(MsSeek(xFilial("BG7")+BT7->BT7_CODINT+BT7_CODGRU)) .And. Eval(bVldExist)
               aadd(aGrupos,{BG7->BG7_CODGRU,BG7->BG7_DESCRI,STR0020}) // //"Empresa"
            Endif

            BT7->(DbSkip())
         Enddo
      Endif
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Pesquisa Grupos de Cobertura do Produto...                               ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   BRV->(DbSetOrder(1))
   If BRV->(MsSeek(xFilial("BRV")+BA3->BA3_CODINT+cCodPla+cVerPla))
      While ! BRV->(Eof()) .And. BRV->(BRV_FILIAL+BRV_CODPLA+BRV_VERSAO) == ;
            xFilial("BRV")+BA3->BA3_CODINT+cCodPla+cVerPla

         If BG7->(MsSeek(xFilial("BG7")+SUBS(BRV->BRV_CODPLA,1,4)+BRV->BRV_CODGRU)) .And. Eval(bVldExist)
            aadd(aGrupos,{BG7->BG7_CODGRU,BG7->BG7_DESCRI,STR0046}) // //"Produto"
         Endif

         BRV->(DbSkip())
      Enddo
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ monta retorno...                                                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aRet := {.T.,aGrupos}
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Retorno da funcao...                                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSM020   ºAutor  ³Microsiga           º Data ³  05/17/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M020DET(nFolder, cMatric, oBrwFin, oBrwFinB, oBrwFinT, _cNivel)

   LOCAL oObj
   LOCAL cNumero	:= ''
   LOCAL cPrefix	:= ''
   LOCAL cNumTit	:= ''
   LOCAL cParcel	:= ''
   LOCAL cSqlFilial:= ""

   BA1->(DbSetOrder(2))
   BA1->(MsSeek(xFilial("BA1")+cMatric))

   If nFolder == 1
      oObj := oBrwFin

   Elseif nFolder == 2
      oObj := oBrwFinB

   Else
      oObj := oBrwFinT

   Endif

   If Valtype(oObj) <> 'O'
      Return()
   Endif

   cNumero	:= oObj:FieldGet("E1_PLNUCOB")
   cPrefix	:= oObj:FieldGet("E1_PREFIXO")
   cNumTit	:= oObj:FieldGet("E1_NUM")
   cParcel	:= oObj:FieldGet("E1_PARCELA")

   If ExistBlock( "PLSXFILI" )
      cSqlFilial := ExecBlock( "PLSXFILI", .F., .F., {"SE1"} )
   Else
      cSqlFilial := xFilial("SE1")
   EndIf

   SE1->( dbSetorder(01) )
   SE1->( dbSeek(cSqlFilial+cPrefix+cNumTit+cParcel) )

   PLSCobGrp(SE1->E1_ANOBASE,SE1->E1_MESBASE,Val(_cNivel),SE1->E1_CODINT,cNumero,cPrefix,cNumTit,cParcel,SE1->E1_TIPO)

Return()


//--------------------------------------------------------------------
/*/ {Protheus.doc} GetStatusTit
Retorna o Status do Título posicionado

@author Vinicius Queiros Teixeira
@since 30/12/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Static Function GetStatusTit()

   Local cStatus := ""

   Do Case
      Case SE1->E1_SALDO == SE1->E1_VALOR
         cStatus := LEG_ABERTO

      Case SE1->E1_SALDO > 0 .And. SE1->E1_SALDO < SE1->E1_VALOR
         cStatus := LEG_PARCIAL

      Case SE1->E1_SALDO == 0
         cStatus := LEG_BAIXADO

   EndCase

Return cStatus


//--------------------------------------------------------------------
/*/ {Protheus.doc} PrintLegStatus
Printa a legenda dos status na tela dos Folder

@author Vinicius Queiros Teixeira
@since 30/12/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Static Function PrintLegStatus(aPosObj, oFolder, nFolder)

   Local oBitMap := Nil
   Local oSay := Nil
   // Dimensões do Group
   Local nPosYGroup := (aPosObj[2][3] * 0.4) + 5
   Local nPosXGroup := aPosObj[1][4] * 0.60
   Local nAltGroup := (aPosObj[2][3] * 0.4) + 27
   Local nTamGroup := (aPosObj[1][4] * 0.61) + 170
   // Dimensões do BitMap e Say
   Local nPosYLeg := (aPosObj[2][3] * 0.4) + 15
   Local nPosXLeg := aPosObj[1][4] * 0.61

   TGroup():New(nPosYGroup, nPosXGroup, nAltGroup, nTamGroup, STR0050, oFolder:aDialogs[nFolder], Nil, Nil, .T.) // "Legenda do Status"

   @ nPosYLeg, nPosXLeg BITMAP oBitMap RESNAME LEG_ABERTO OF oFolder:aDialogs[nFolder] SIZE 20,20 NOBORDER WHEN .F. PIXEL
   @ nPosYLeg, (nPosXLeg + 10) Say oSay PROMPT STR0051 OF oFolder:aDialogs[nFolder] SIZE 120,10 PIXEL // "Titulo em aberto"

   @ nPosYLeg, (nPosXLeg + 50) BITMAP oBitMap RESNAME LEG_PARCIAL OF oFolder:aDialogs[nFolder] SIZE 20,20 NOBORDER WHEN .F. PIXEL
   @ nPosYLeg, (nPosXLeg + 60) Say oSay PROMPT STR0052 OF oFolder:aDialogs[nFolder] SIZE 120,10 PIXEL // "Baixado Parcialmente"

   @ nPosYLeg, (nPosXLeg + 115) BITMAP oBitMap RESNAME LEG_BAIXADO OF oFolder:aDialogs[nFolder] SIZE 20,20 NOBORDER WHEN .F. PIXEL
   @ nPosYLeg, (nPosXLeg + 125) Say oSay PROMPT STR0053 OF oFolder:aDialogs[nFolder] SIZE 120,10 PIXEL // "Titulo Baixado"

Return
