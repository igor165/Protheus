#INCLUDE "EDCDE150.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCDE150  ³ Autor ³ Thomaz               ³ Data ³ 22/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relat. de Divergências de Estruturas(Cad. Estr. e Cad. A.C.)±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Drawback                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*------------------*
Function EDCDE150() 
*------------------*
Local cAlias := "SG1", nOpca := 1
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}
Local nOrdSX3 := SX3->(IndexOrd())

SX3->(DBSETORDER(2))
if .not. SX3->(DBSeek("ED2_RE")) // ACSJ - 19/11/2004 
   MsgInfo( STR0045 + Chr(13) +;
            STR0046 )  
   Return .t.
Endif               
SX3->(DBSETORDER(nOrdSX3))

Private lNegEstr:= EasyGParam("MV_NEGESTR"), cMarca := GetMark(), cFileDbf, lInverte := .F.
Private cFilSG1 := xFilial("SG1"), cFilSB1 := xFilial("SB1"), cFilED2:= xFilial("ED2")
Private cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1", cFilSYT:=xFilial("SYT")  //Para utilizar produtos de outra Empresa/Filial
Private cProdEstr:= Space(AVSX3("B1_COD",3)), cPedEstr:= Space(AVSX3("ED0_PD",3))
Private cFilED1:= xFilial("ED1"), cFilED0:= xFilial("ED0"), cPergunte:= "EDCDE1"
Private cPictQuant := AVSX3("G1_QUANT",6), cPictPerda := AVSX3("G1_PERDA",6)
Private cPictRE:= AVSX3("EE9_RE",6)
Private nInd

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif
If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   SETKEY(VK_F4,{||If(ReadVar() == "MV_PAR02", EDCAC400HLP(@mv_par02), )})

Endif

While .T.

   dbSelectArea("SG1")
   If ! Pergunte(cPergunte,.T.)
      Return .F.
   EndIf
   
   cPedEstr  := mv_par01
   cProdEstr := mv_par02
   
   If nOpca == 1
      Processa({|| EDCDE150IMP() })
   ElseIf nOpca == 0
      Exit
   EndIf
   
EndDo 

// Desabilita o F4 caso esteja ativo
SETKEY(VK_F4,NIL)

dbSelectArea(cAlias)

Return

*-----------------------------*
STATIC FUNCTION EDCDE150IMP()
*-----------------------------*
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatório "
Local cDesc2         := STR0002 //"de Divergências de Estruturas entre o A.C. e o "
Local cDesc3         := STR0003 //"Cadastro de Estruturas."
Local cPict          := ""
Local imprime        := .T.
Private titulo       := STR0004 //"Relatório de Divergências de Estruturas."
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "SG1"
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "EDCDE150"
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 2, 2, 1, "" , 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "EDCDE150" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nPagina      := 0
Private lImprime     := .F.
cbtxt := Space(10)
wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

DE150CRIAWORK()

RptStatus({|lEnd| lImprime:=Imprime(wnRel,cString)})
If(lImprime, EDCDEGERADBF(), )

WORK->(E_EraseArq(cFileDbf))

Return .T.

*--------------------------------------*
Static Function Imprime(wnrel,cString)
*--------------------------------------*
Local nTipo:= 0, nNivel, nX, nPosCnt:= nPosOld:= 0
Local bWhile:= {||ED1->ED1_FILIAL == cFilED1}, z, i
Local lSkip, nContaED2:=nContaSG1:= 0, lRet:= .T.

Private cModal:= "", cTipoAc:= "", dDtReg:= cTod("")
Private nCol1:=00, nCol2:=nCol1+26, nCol3:=nCol2+27, nCol4:=nCol3+20, nCol5:=nCol4+20
Private nCol6:=nCol5+10, nCol7:=nCol6+45, nCol8:= nCol7+23, nCol9:=nCol8+39
Private nCol10:=06, nCol11:=nCol10+07, nCol12:=nCol11+35, nCol13:=nCol12+08
Private nColun1:= 13, nColun2 := nColun1+20, nColun3 := nColun2+21, nColun4 := nColun3+20
Private nCol14:=nCol13+41, nCol15:=nCol14+07,nColun16:=12, nColun17:=nColun16+12
Private nColun18:= nColun17+31, nColun19:= nColun18+21, nColun20:= nColun19+09
Private nColun21:= nColun20+30, nColun22:= nColun21+21, nColun23:= nColun22+16
Private nLin := 99, aEstED2:={}, aEstSG1:={}, cMensa:= ""
Private cProdFi, cProduto, nCont:= 0, lImprime:= .F., aDelED2:={}, aDelSG1:={}
Private cPictQtd:=AVSX3("G1_QUANT",6), cPictPer:=AVSX3("G1_PERDA",6)
Private cPictPEd2:=AVSX3("ED2_PERCPE",6), cPictCoe:=AVSX3("ED2_COEF",6)

ED1->(dbSetOrder(3))
(cAliasSB1)->(dbSetOrder(1))
SG1->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o Cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cabec1 := " "
                    
//Verificar Itens a Exportar(Pai) e sua Explosão de estrutura(Filhos)
ED1->(dbSeek(cFilED1+cPedEstr,.T.)) //Softseek

If !Empty(cPedEstr)
   bWhile:= {||ED1->ED1_FILIAL == cFilED1 .And. ED1->ED1_PD == cPedEstr}
Endif

While !ED1->(EOF()) .And. Eval(bWhile)
   
   lSkip:= .F.
   aEstSG1:= {}
   aEstED2:= {}
   aDelED2:= {}
   aDelSG1:= {}
   nContaED2:=nContaSG1:= 0

   cProduto:= cProdEstr
   
   If Empty(cProdEstr)
      cProduto:= ED1->ED1_PROD
   ElseIf !Empty(cProdEstr)          //Empty(cPedEstr) .And. 
      If ED1->ED1_PROD <> cProdEstr
         ED1->(dbSkip())
         Loop
      Endif
/*   ElseIf !Empty(cPedEstr) .And. !Empty(cProdEstr)
      If ED1->ED1_PROD <> cProdEstr
         ED1->(dbSkip())
         Loop
      Endif         */
   Endif         

   (cAliasSB1)->(dbSeek(cFilSB1Aux+cProduto))
   nQtBase:= (cAliasSB1)->B1_QB

   SG1->(dbSeek(cFilSG1+cProduto))

   While !SG1->(EOF()) .And. SG1->G1_FILIAL == cFilSG1 .And. SG1->G1_COD == cProduto

      SG1->(dbSeek(cFilSG1+cProduto))

      cProdFi:= SG1->G1_COD
      (cAliasSB1)->(dbSetOrder(1))
                                    
      If (cAliasSB1)->(dbSeek(cFilSB1Aux+cProdFi))      
      
         nNivel    := 2
         nPosOld:= nPosCnt

         nPosCnt+= EDCDE150EXP(cProdFi,IF((cAliasSB1)->B1_QB == 0,1,(cAliasSB1)->B1_QB),nNivel,cPictQuant,cPictPerda,(cAliasSB1)->B1_OPC,IF((cAliasSB1)->B1_QB==0,1,(cAliasSB1)->B1_QB),titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
              
	     For i:=nPosOld to nPosCnt
            IncProc()
         Next i
                                                           
      Endif

      SG1->(dbSkip())
      Loop
   EndDo
   
   ED0->(dbSetOrder(1))
   SYT->(dbSetOrder(1))

   ED0->(dbSeek(cFilED0+ED1->ED1_PD))
   SYT->(dbSeek(cFilSYT+ED0->ED0_IMPORT))

   If ED0->ED0_MODAL == "1" //Suspensao
      ED2->(dbSetOrder(2))
      ED2->(dbSeek(cFilED2+ED1->ED1_PD+ED1->ED1_PROD+ED1->ED1_SEQ))
   Else                     //Isencao
      ED2->(dbSetOrder(8))
      ED2->(dbSeek(cFilED2+ED1->ED1_PD+ED1->ED1_RE+ED1->ED1_PROD))
   Endif

   While !ED2->(EOF()) .And. ED2->ED2_FILIAL == cFilED2 .And. ED2->ED2_PD == ED1->ED1_PD;
      .And. If(ED0->ED0_MODAL == "1", ED1->ED1_PROD == ED2->ED2_PROD .And. ED1->ED1_SEQ == ED2->ED2_SEQ,;
      ED1->ED1_RE == ED2->ED2_RE .AND. ED1->ED1_PROD == ED2->ED2_PROD)

      nQuant:= ED2->ED2_QTD/nQtBase

      AADD(aEstED2,{ ED2->ED2_PROD, ED2->ED2_ITEM, nQuant, ED2->ED2_PERCPE, ED2->ED2_COEF, ED2->ED2_MARCA})

      ED2->(dbSkip())
   EndDo

   ASORT(aEstSG1,,,{|X,Y|X[2]<Y[2]})
      
   If (Len(aEstSG1) > 0 .And. Len(aEstED2) > 0) .And. Len(aEstSG1) == Len(aEstED2)
      For z:= 1 to Len(aEstSG1)
         If aEstSG1[z,1] == aEstED2[z,1] .And. aEstSG1[z,2] == aEstED2[z,2] .And.; 
         Str(aEstSG1[z,3],15,5) == Str(aEstED2[z,3],15,5) .And. !Empty(aEstED2[z,6])
            lSkip:= .T.            
         Else
            lSkip:= .F. 
            Exit
         Endif
      Next
   ElseIf Len(aEstSG1) == 0 .And. Len(aEstED2) == 0
      lSkip:= .T.
   Endif
   
   If lSkip
      ED1->(dbSkip())
      Loop   
   Endif

/*   
   ED0->(dbSetOrder(1))
   SYT->(dbSetOrder(1))

   ED0->(dbSeek(cFilED0+ED1->ED1_PD))
   SYT->(dbSeek(cFilSYT+ED0->ED0_IMPORT))
*/
   If Empty(ED0->ED0_DT_ENC)

      cModal:= If(ED0->ED0_MODAL == "1", STR0008, STR0009)  //"Suspensão"###"Isenção"
      
      If ED0->ED0_PROAP3 == "1"
         dDtReg := ED0->ED0_DT_PR3
      Elseif ED0->ED0_PROAP2 == "1"
         dDtReg := ED0->ED0_DT_PR2
      Elseif ED0->ED0_PROAP1 == "1"
         dDtReg := ED0->ED0_DT_PR1
      Elseif !EMPTY(ED0->ED0_DT_VA2)
        dDtReg := ED0->ED0_DT_VA2
      Else
        dDtReg := ED0->ED0_DT_VA1
      Endif

      Do Case
         Case ED0->ED0_TIPOAC == "01"
            cTipoAc := STR0010 //"Comum"
         Case ED0->ED0_TIPOAC == "02"
            cTipoAc := STR0011 //"Intermediário"
         Case ED0->ED0_TIPOAC == "03"
            cTipoAc := STR0012 //"Solidário"
         Case ED0->ED0_TIPOAC == "04"
            cTipoAc := STR0013 //"Embarcação"
         Case ED0->ED0_TIPOAC == "05"
            cTipoAc := STR0014 //"Forn. no Merc. Interno"
         Case ED0->ED0_TIPOAC == "06"
            cTipoAc := STR0015 //"Genérico"
         Case ED0->ED0_TIPOAC == "08"
            cTipoAc := STR0016 //"Genérico/Embarcação"
         OtherWise
            cTipoAc := STR0017 //"Genér./Forn. Merc. Interno"
      EndCase

      SysRefresh()
      If nLin >= 58
        Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
        nLin := Prow()+01
      Endif

      If nLin+06 >= 58
         Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
         EDCDE150CAB()
      Else
         EDCDE150CAB()
      Endif

      If Len(aEstSG1) <> 0 .Or. Len(aEstED2) <> 0
         For i:= 1 to Len(aEstSG1)
            nInd := i
            SysRefresh()
            If nLin >= 58
               Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
               EDCDE150CAB()
            Endif
            nLin++
            nPos:= ASCAN(aEstED2,{|x| x[2]==aEstSG1[i,2]}) //.And. Str(x[3],15,5)== Str(aEstSG1[i,3],15,5)})
            If nPos == 0
               cMensa:=STR0026+Alltrim(cProduto)+STR0027+Alltrim(aEstSG1[i,2])+STR0031  //"O Prod. "###" está sem Estrutura no Ato Concessório."###") no A.C."
               @ nlin,nColun16 PSAY STR0023 //"-->dif."
               @ nlin,nColun17 PSAY aEstSG1[i,2]
               @ nlin,nColun18 PSAY Transf(aEstSG1[i,5], cPictQtd)
               @ nlin,nColun19 PSAY Transf(aEstSG1[i,4], cPictPer)
               @ nlin,nColun20 PSAY STR0028 //"__"
               @ nlin,nColun21 PSAY STR0028 //"__"
               @ nlin,nColun22+1 PSAY STR0028 //"__"
               @ nlin,nColun23 PSAY cMensa
               lImprime:= .T.
               EDCDEGRVDBF("1")
            Else
               If Str(aEstSG1[i,3],15,5) <> Str(aEstED2[nPos,3],15,5)
                  cMensa:=STR0024+Alltrim(Str(aEstSG1[i,3],15,5))+STR0025+Alltrim(Str(aEstED2[nPos,3],15,5)) //"Qtd. Cad. "###" difere da Qtd. no A.C. "
                  @ nlin,nColun16 PSAY STR0023 //"-->dif."
                  @ nlin,nColun17 PSAY aEstSG1[i,2]
                  @ nlin,nColun18 PSAY Transf(aEstSG1[i,5], cPictQtd)
                  @ nlin,nColun19 PSAY Transf(aEstSG1[i,4], cPictPer)
                  @ nlin,nColun20 PSAY aEstED2[npos,2]
                  @ nlin,nColun21 PSAY Transf(aEstED2[nPos,5], cPictCoe)
                  @ nlin,nColun22 PSAY Transf(aEstED2[nPos,4], cPictPEd2)
                  @ nlin,nColun23 PSAY cMensa
                  lImprime:= .T.
                  EDCDEGRVDBF("2")
                  Aadd(aDelED2,nPos)
                  Aadd(aDelSG1,i)                                    
               Else
                  If Empty(aEstED2[nPos,6])
                     cMensa:=STR0032+Alltrim(aEstED2[nPos,2])+STR0033 //"Item "###" não está sendo utilizado no Ato Concessório. "
                     @ nlin,nColun16 PSAY STR0023 //"-->dif."
                     @ nlin,nColun17 PSAY aEstSG1[i,2]
                     @ nlin,nColun18 PSAY Transf(aEstSG1[i,5], cPictQtd)
                     @ nlin,nColun19 PSAY Transf(aEstSG1[i,4], cPictPer)
                     @ nlin,nColun20 PSAY aEstED2[npos,2]
                     @ nlin,nColun21 PSAY Transf(aEstED2[nPos,5], cPictCoe)
                     @ nlin,nColun22 PSAY Transf(aEstED2[nPos,4], cPictPEd2)
                     @ nlin,nColun23 PSAY cMensa
                     lImprime:= .T.
                     EDCDEGRVDBF("3")
                     Aadd(aDelED2,nPos)
                     Aadd(aDelSG1,i)   
                  Else
                     nLin:=nLin-1
                  Endif
               Endif
            Endif
         Next

         j:=Len(aDelED2)
         Do While j>=1
            aDel(aEstED2, aDelED2[j])
            nContaED2+=1
            j -= 1
         EndDo
/*         For j:=1 to Len(aDelED2)
            aDel(aEstED2, aDelED2[j])
            nContaED2+=1
         Next   */

         K:=Len(aDelSG1)
         Do While k>=1
            aDel(aEstSG1, aDelSG1[k])
            nContaSG1+=1
            k -= 1
         EndDo
/*         For k:= 1 to Len(aDelSG1)
            aDel(aEstSG1, aDelSG1[k])
            nContaSG1+=1            
         Next */
         
         aSize(aEstED2,(Len(aEstED2)-nContaED2)) //Para recalcular o tamanho dos Array's
         aSize(aEstSG1,(Len(aEstSG1)-nContaSG1))

         For i:= 1 to Len(aEstED2)
            nInd := i
            SysRefresh()
            If nLin >= 58
               Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
               EDCDE150CAB()
            Endif
            nLin++
            nPos:= ASCAN(aEstSG1,{|x| x[2]==aEstED2[i,2]})  //.And. Str(x[3],15,5)== Str(aEstSG1[i,3],15,5)})
            If nPos == 0
               cMensa:=STR0026+Alltrim(cProduto)+STR0027+Alltrim(aEstED2[i,2])+STR0029 //"O Prod. "###" está sem a Estrutura###no Cadastro."
               @ nlin,nColun16 PSAY STR0023 //"-->dif."
               @ nlin,nColun17 PSAY STR0028 //"__"
               @ nlin,nColun18 PSAY STR0028 //"__"
               @ nlin,nColun19 PSAY STR0028 //"__"
               @ nlin,nColun20 PSAY aEstED2[i,2]
               @ nlin,nColun21 PSAY Transf(aEstED2[i,5], cPictCoe)
               @ nlin,nColun22 PSAY Transf(aEstED2[i,4], cPictPEd2)
               @ nlin,nColun23 PSAY cMensa
               lImprime:= .T.
               EDCDEGRVDBF("4")
            Else
               If Str(aEstSG1[npos,3],15,5) <> Str(aEstED2[i,3],15,5)
                  cMensa:=STR0024+Alltrim(Str(aEstSG1[nPos,3],15,5))+STR0025+Alltrim(Str(aEstED2[i,3],15,5)) //"Qtd. Cad. "###" difere da Qtd. no Ato Concessório. "
                  @ nlin,nColun16 PSAY STR0023 //"-->dif."
                  @ nlin,nColun17 PSAY aEstSG1[nPos,2]
                  @ nlin,nColun18 PSAY Transf(aEstSG1[nPos,5], cPictQtd)
                  @ nlin,nColun19 PSAY Transf(aEstSG1[nPos,4], cPictPer)
                  @ nlin,nColun20 PSAY aEstED2[npos,2]
                  @ nlin,nColun21 PSAY Transf(aEstED2[i,5], cPictCoe)
                  @ nlin,nColun22 PSAY Transf(aEstED2[i,4], cPictPEd2)
                  @ nlin,nColun23 PSAY cMensa
                  lImprime:= .T.
                  EDCDEGRVDBF("5")
               Else 
                  If Empty(aEstED2[i,6])
                     cMensa:=STR0032+Alltrim(aEstED2[i,2])+STR0033 //"Item "###" não está sendo utilizado no Ato Concessório. "
                     @ nlin,nColun16 PSAY STR0023 //"-->dif."
                     @ nlin,nColun17 PSAY aEstSG1[nPos,2]
                     @ nlin,nColun18 PSAY Transf(aEstSG1[nPos,5], cPictQtd)
                     @ nlin,nColun19 PSAY Transf(aEstSG1[nPos,4], cPictPer)
                     @ nlin,nColun20 PSAY aEstED2[i,2]
                     @ nlin,nColun21 PSAY Transf(aEstED2[i,5], cPictCoe)
                     @ nlin,nColun22 PSAY Transf(aEstED2[i,4], cPictPEd2)
                     @ nlin,nColun23 PSAY cMensa
                     lImprime:= .T.
                     EDCDEGRVDBF("6")
                  Else
                     nLin:=nLin-1
                  Endif
               Endif
            Endif
         Next
      Endif
   Endif
   
   //If Len(aEstED2) <> 0 .Or. Len(aEstSG1) <> 0
      nLin++
      @ nlin,000 PSAY __PrtThinline()
      nlin +=2
   //Endif
                             
   ED1->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Devolve a condicao original do arquivo principal             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SG1->(dbSetOrder(1))

If lImprime
   If aReturn[5] = 1
      Set Printer To
	  Commit
	  Ourspool(wnrel)
   EndIf
Else
   lRet:= .F.
   Help(" ",1,"AVG0005190") //"Nao Ha Dados para Impressao !!!"   
Endif

MS_FLUSH()

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Função   ³EDCDE150EXP ³                             ³ Data ³ 03/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição³ Faz a explosao de uma estrutura                             ±±
±±  Adaptação da Função MR225Expl() usado no Prgrama Matr225.PRX           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe  ³ EDCDE150EXP(ExpC1,ExpN1,ExpN2,ExpC2,ExpC3,ExpC4,ExpN3)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do produto a ser explodido                  ³±±
±±³          ³ ExpN1 = Quantidade do pai a ser explodida                  ³±±
±±³          ³ ExpN2 = Nivel a ser impresso                               ³±±
±±³          ³ ExpC2 = Picture da quantidade                              ³±±
±±³          ³ ExpC3 = Picture da perda                                   ³±±
±±³          ³ ExpC4 = Opcionais do produto                               ³±±
±±³          ³ ExpN3 = Quantidade do Produto Nivel Anterior               ³±±
±±³          ³ As outras 6 variaveis sao utilizadas pela funcao Cabec     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Drawback                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

*--------------------------------------------------------------------------------------------------------------------------------------------*
Static Function EDCDE150EXP(cProdFi,nQuantPai,nNivel,cPictQuant,cPictPerda,cOpcionais,nQtdBase,Titulo,cabec1,cabec2,wnrel,Tamanho,nTipo,nCont)
*--------------------------------------------------------------------------------------------------------------------------------------------*
Local nReg,nQuantItem,nCntItens:= nCalc:= 0
If(nCont=NIL,nCont:=0,)
If(nQtBase <= 0,1,nQtBase)

SG1->(dbSetOrder(1))
SB1->(dbSetOrder(1))

While !SG1->(Eof()) .And. SG1->G1_FILIAL == cFILSG1 .And. SG1->G1_COD == cProdFi
   nReg       := SG1->(Recno())
   nQuantItem := AvExplEstr(nQuantPai,,cOpcionais,,) // Função para a Explosão de Estrutura

   If nCont = 0
      //(ED1->ED1_QTD * SG1->G1_QUANT)+((SG1->G1_PERDA * (ED1->ED1_QTD * SG1->G1_QUANT))/100) //(ED1->ED1_QTD * SG1->G1_QUANT)+(ED1->ED1_QTD * SG1->G1_QUANT)* (SG1->G1_PERDA/100)      
      nCalc := (ED1->ED1_QTD * SG1->G1_QUANT) / (1-(SG1->G1_PERDA / 100)) //AAF 05/08/05 - Ajuste dos calculos.
   Else
      //nCalc := (nCont * SG1->G1_QUANT)+((SG1->G1_PERDA * (nCont * SG1->G1_QUANT))/100)
      nCalc := (nCont * SG1->G1_QUANT) / (1-(SG1->G1_PERDA / 100)) //AAF 05/08/05 - Ajuste dos calculos.
   EndIf

   nCalc:= nCalc/If(nQtBase <= 0,1,nQtBase)  //nQtBase

   If lNegEstr .Or. (! lNegEstr .And. nQuantItem > 0 )
      AADD(aEstSG1,{ cProduto, SG1->G1_COMP, nCalc, SG1->G1_PERDA, SG1->G1_QUANT})
   Endif
                     	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica se existe sub-estrutura                ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   SG1->(dbSetOrder(1))

   If SG1->(dbSeek(cFilSG1+SG1->G1_COMP))
      EDCDE150EXP(SG1->G1_COD,nQuantItem,nNivel,cPictQuant,cPictPerda,cOpcionais,IF(SB1->B1_QB == 0,1,SB1->B1_QB),titulo,cabec1,cabec2,wnrel,Tamanho,nTipo,nCalc)
   EndIf

   dbGoto(nReg)

   SG1->(dbSkip())
   nCntItens++
EndDo

nCntItens--

Return nCntItens

*---------------------------*
Function EDCDE150VAL(cParam) 
*---------------------------*
Local lRet:= .T.

If cParam == "MV_PAR01" .And. !Empty(MV_PAR01)
   If(!ExistCpo("ED0", MV_PAR01), lRet:= .F., )
Endif

If cParam == "MV_PAR02" .And. !Empty(MV_PAR02)
   If lAbriuExp
      If(!ExistCpo("SB1EXP", MV_PAR02), lRet:= .F., )
   Else
      If(!ExistCpo("SB1", MV_PAR02), lRet:= .F., )
   Endif
Endif              

Return lRet

*-------------------------------*
Static Function EDCDE150CAB()
*-------------------------------*
nLin := Prow()+01

@ nlin,nCol1 PSAY STR0034 //"Ato Conc.:"
@ nlin,nCol1+Len(STR0034)+1 PSAY Alltrim(ED1->ED1_AC) //"Ato Conc.:"
@ nlin,nCol2-1 PSAY STR0035//"Ped. Draw.:"
@ nlin,nCol2-1+Len(STR0035)+1 PSAY Alltrim(ED1->ED1_PD) //"Ped. Draw.:"
@ nlin,nCol3-2 PSAY STR0036 //"Dt. Reg.:"
@ nlin,nCol3-2+Len(STR0036)+1 PSAY ED0->ED0_DT_REG //"Dt. Reg.:"
@ nlin,nCol4-3 PSAY STR0037 //"Dt. Val.:"
@ nlin,nCol4-3+Len(STR0037)+1 PSAY dDtReg //"Dt. Val.:"
@ nlin,nCol5-4 PSAY STR0038 //"Imp.:"
@ nlin,nCol5-4+Len(STR0038)+1 PSAY Alltrim(ED0->ED0_IMPORT)+" - "+Alltrim(Substr(SYT->YT_NOME_RE, 1, 27)) //"Imp.:" # "Descrição Imp.:"
@ nlin,nCol7-22 PSAY STR0040 //"Modalidade:"
@ nlin,nCol7-22+Len(STR0040)+1 PSAY Alltrim(cModal) //"Modalidade:"
@ nlin,nCol8-23 PSAY STR0041 //"Tipo A.C.:"
@ nlin,nCol8-23+Len(STR0041)+1 PSAY Alltrim(cTipoAc) //"Tipo A.C.:"
@ nlin,nCol9-24 PSAY STR0042 //"Seq.:"
@ nlin,nCol9-24+Len(STR0042)+1 PSAY Alltrim(ED1->ED1_SEQ) //"Seq.:"

//** AAF 08/08/05 - Impressão do RE.
If ED0->ED0_MODAL == "2"//Isenção
   nCol10:= nCol9-24+Len(STR0042)+1+Len(Alltrim(ED1->ED1_SEQ))+1
   @ nlin,nCol10 PSAY "R.E.:" //"R.E.:"
   @ nlin,nCol10+Len("R.E.:")+1 PSAY TransForm(ED1->ED1_RE,cPictRE)//"R.E.:"
Endif
//** 
      
/*@ nlin+1,nCol1 Psay Replicate("-", Len(STR0034))+Space(16)+Replicate("-", Len(STR0035))+; //"Ato Conc.:"###"Ped. Draw.:"
Space(16)+Replicate("-", Len(STR0036))+Space(11)+Replicate("-", Len(STR0037))+Space(11)+; //"Dt. Reg.:"###"Dt. Val.:"
Replicate("-", Len(STR0038))+Space(05)+Replicate("-", Len(STR0039))+Space(30)+; //"Imp.:"###"Descrição Imp.:"
Replicate("-", Len(STR0040))+Space(12)+Replicate("-", Len(STR0041))+Space(29)+; //"Modalidade:"###"Tipo A.C.:"
Replicate("-", Len(STR0042)) //"Seq.:"
      */
nLin+= 3

(cAliasSB1)->(dbSetOrder(1))
(cAliasSB1)->(dbSeek(cFilSB1Aux+cProduto))
                                                                     
@ nlin,nCol10 PSAY STR0018 //"Prod.: "
@ nlin,nCol11 PSAY cProduto
@ nlin,nCol12 PSAY STR0019 //"Descr.: "
@ nlin,nCol13 PSAY SubStr((cAliasSB1)->B1_DESC,1,34)
@ nlin,nCol14 PSAY STR0020 //"U.M.: "
@ nlin,nCol15 PSAY (cAliasSB1)->B1_UM

nlin+= 2
   
@ nlin,nColun16 PSAY STR0021 //"          Código Estr.          Qtde. Base na Estr.  %Perda Estr.       Código A.C.          Coeficiente no A.C.   %Perda A.C.     Mensagem"
nLin:= nLin + 1
@ nlin,nColun16 PSAY Space(11)+Replicate("-",12)+Space(18)+Replicate("-",19)+;
Space(02)+Replicate("-",12)+Space(07)+Replicate("-",11)+Space(10)+;
Replicate("-",19)+Space(03)+Replicate("-",11)+Space(04)+Replicate("-",08)

Return .T. 

*------------------------------*
Static Function EDCDEGERADBF()
*------------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0043; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0044 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancel

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   TR350ARQUIVO("Work")
Else
   lRet:= .F.
EndIf

Return lRet

*-------------------------------*
Static Function DE150CRIAWORK()
*-------------------------------*
Private aWork:={;
               {"WKAC"    ,"C",AVSX3("ED0_AC",3)  ,0},;
               {"WKPD"    ,"C",AVSX3("ED0_PD",3)  ,0},;
               {"WKDTREG" ,"D",8 ,0},;
               {"WKDTVAL" ,"D",8 ,0},;
               {"WKIMPORT","C",33,0},;
               {"WKMODAL" ,"C",9 ,0},;
               {"WKTIPO"  ,"C",10,0},;
               {"WKSEQUEN","C",AVSX3("ED1_SEQ",3),0},;
               {"WKITEM"  ,"C",AVSX3("ED2_ITEM",3),0},;
               {"WKDESC"  ,"C",AVSX3("B1_DESC",3),0},;
               {"WKUM"    ,"C",AVSX3("ED2_UM",3),0},;
               {"WKESTR"  ,"C",AVSX3("ED2_ITEM",3),0},;
               {"WKQTBASE","N",AVSX3("G1_QUANT",3),AVSX3("G1_QUANT",4)},;
               {"WKPERDA" ,"N",AVSX3("G1_PERDA",3),AVSX3("G1_PERDA",4)},;
               {"WKCODAC" ,"C",AVSX3("ED2_ITEM",3),0},;
               {"WKCOEF"  ,"N",AVSX3("ED2_COEF",3),AVSX3("ED2_COEF",4)},;
               {"WKPERDAC","N",AVSX3("G1_PERDA",3),AVSX3("G1_PERDA",4)},;
               {"WKMENSA" ,"C",100,0}}

cFileDbf:=E_CriaTrab(,aWork,"Work")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IndRegua("Work",cFileDbf+TEOrdBagExt(),"WKPD+WKAC")

Return .T.

*----------------------------------*
Static Function EDCDEGRVDBF(cParam)
*----------------------------------*
Work->(dbAppend())

Work->WKAC    :=ED1->ED1_AC
Work->WKPD    :=ED1->ED1_PD
Work->WKDTREG :=ED0->ED0_DT_REG
Work->WKDTVAL :=dDtReg
Work->WKIMPORT:=ED0->ED0_IMPORT+" - "+Substr(SYT->YT_NOME, 1, 27)
Work->WKMODAL :=cModal
Work->WKTIPO  :=cTipoAc
Work->WKSEQUEN:=ED1->ED1_SEQ
Work->WKITEM  :=cProduto
Work->WKDESC  :=(cAliasSB1)->B1_DESC
Work->WKUM    :=(cAliasSB1)->B1_UM

Do Case
   Case cParam $ "1/2/3"
      Work->WKESTR  :=aEstSG1[nInd,2]
      Work->WKQTBASE:=aEstSG1[nInd,5]
      Work->WKPERDA :=aEstSG1[nInd,4]
      Work->WKCODAC :=If(cParam$"2/3",aEstED2[npos,2],STR0028)
      Work->WKCOEF  :=If(cParam$"2/3",aEstED2[nPos,5],0)
      Work->WKPERDAC:=If(cParam$"2/3",aEstED2[nPos,4],0)
   Case cParam $ "4/5/6"
      Work->WKESTR  :=If(cParam$"5/6",aEstSG1[nPos,2],STR0028)
      Work->WKQTBASE:=If(cParam$"5/6",aEstSG1[nPos,5],0)
      Work->WKPERDA :=If(cParam$"5/6",aEstSG1[nPos,4],0)
      Work->WKCODAC :=If(cParam$"4/6",aEstED2[nInd,2],aEstED2[npos,2])
      Work->WKCOEF  :=aEstED2[nInd,5]
      Work->WKPERDAC:=aEstED2[nInd,4]
EndCase

Work->WKMENSA :=cMensa

Return .T.
