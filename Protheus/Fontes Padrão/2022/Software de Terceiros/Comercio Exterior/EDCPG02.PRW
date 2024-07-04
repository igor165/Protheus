#include "protheus.ch"
#include "msgraphi.ch"
#Include "Average.ch"
#Include "TOPCONN.CH"
#include "edcpg02.ch"

********************************************************************************************************
Function EDCPG02()
********************************************************************************************************

 Local aRetPanel := {}        ,;
       TypeGraph := GRP_BAR   ,;
       cTitleG   := STR0001   ,; //"Ganhos"
       bClickG   := {||  }    ,;
       cTitleT   := STR0002   ,; //"Impostos"
       bClickT   := {||  }
       
 Private aEixoX    := {}  ,;
         aEixoY    := {0,0,0,0,0,0,0}  ,;
         aTabela   := {}  ,;
         aDespesas := {}

   // TypeGraph : Tipo do Gráfico ( GRP_LINE, GRP_PIE, GRP_BAR )
   // cTitleG   : Título do Gráfico 
   // bClickG   : Bloco de código a ser executado no clique do gráfico 
   // aEixoX    : Array contendo os atributos a serem exibidos
   // aEixoY    : Array contendo os valores dos atributos
   // cTitleT   : Título da Tabela
   // bClickT   : Bloco de Código a ser executado no clique da Tabela 
   // aTabela   : Array multidimensional contendo os arrays por filtro, no formato { "filtro", aCabec, aValores } , onde :  
   //             aCabec    : Array contendo o cabeçalho.
   //             aValores  : Array contendo os valores da lista. 

   EDCPG02ExX()  // Monta aEixoX
   EDCPG02ExY()  // Monta aEixoY
   EDCPG02Tab()  // Monta aTabela

   aRetPanel := { TypeGraph ,{cTitleG, bClickG, aEixoX, aEixoY } , { cTitleT , bClickT, aTabela } }

Return aRetPanel


********************************************************************************************************
Static Function EDCPG02ExX()
********************************************************************************************************

   AAdd( aEixoX, "II"     )
   AAdd( aEixoX, "IPI"    )
   AAdd( aEixoX, "ICMS"   )
   AAdd( aEixoX, "AFFRM"  )
   AAdd( aEixoX, "PIS"    )
   AAdd( aEixoX, "COFINS" )
   AAdd( aEixoX, "ARMAZ"  )

Return


********************************************************************************************************
Static Function EDCPG02ExY()
********************************************************************************************************

 Private cNomArq,cNomArq1, dDtIni, dDtFinal, cDespAFRMM, cDespArm
 Private aNroDi    := {}
 Private lGenerico,lSuspensao,lIntermediario, lVez:= .T., cFileDbf
 Private lDiExt    := EasyGParam("MV_EDCDIE",,.F.)

 // Apagar
 Private cMoeDolar := EasyGParam("MV_SIMB2",,"US$")

   ED0->(DBSETORDER(1))
   ED4->(DBSETORDER(1))
   SW8->(DBSETORDER(5))
   SW7->(DBSETORDER(4))

   If !Empty(mv_par01)
      dDtIni := CToD("01/"+mv_par01)
   Else
      dDtIni := CToD("  /  /  ")
   EndIf
   If !Empty(mv_par02)
      dDtFinal := CToD("31/"+mv_par02)
   Else
      dDtFinal := CToD("  /  /  ")
   EndIf
   
   #IFDEF TOP
      EDCPG02Qry()
   #ENDIF

   EDCPG02Pro()

RETURN .T.

********************************************************************************************************
Static Function EDCPG02Qry()
********************************************************************************************************

 Local cFilED0 := xFilial("ED0")  ,;
       cQuery  := ""              ,;
       cFrom   := ""              ,;
       cWhere  := ""

   cQuery := " SELECT ED0.ED0_PD, ED0.ED0_AC, ED0.ED0_TIPOAC, ED0.ED0_MODAL "

   cFrom := "FROM "+RetSqlName("ED0")+" ED0 "

   cWhere := "WHERE ED0.ED0_FILIAL='"+cFilED0+"' "+IIF(TcSrvType()<>"AS/400","AND ED0.D_E_L_E_T_ <> '*' ","")
   cWhere += "AND ED0.ED0_AC <> '' AND ED0.ED0_AC <> '             ' "
   cWhere += "AND ED0.ED0_DT_ENC = '        ' "

   cQuery += cFrom+cWhere+" ORDER BY ED0_PD "
   cQuery := ChangeQuery(cQuery)

   TcQuery cQuery ALIAS "TRB" NEW
   DBSelectArea("TRB")

Return

********************************************************************************************************
Static Function EDCPG02Pro()
********************************************************************************************************
Local cFilED0:=xFilial("ED0"),cFilED4:=xFilial("ED4"), nInd, i
Local cFilSW6:=xFilial("SW6"),cFilSW9:=xFilial("SW9"),cFilSYD:=xFilial("SYD")
Local cFilSWN:=xFilial("SWN"), cFilED2:= xFilial("ED2")
Local cFilSF1:=xFilial("SF1")
Local nCont:=0, nVlArm:=0
Local aFrete:={}, nPesoAto, nFobAto, lPrim:= .T.
Local cViaTra:="", nRecSW8, nIndSW8
Local Ni
Local bWhile := { ||  }
Local bCond  := { ||  }

Private cAliasED0 := ""
Private nParidade
Private cHawb
Private cFilSW7:=xFilial("SW7"), cFilSWD:=xFilial("SWD"), cFilSW8:=xFilial("SW8")
Private cFilED8:=xFilial("ED8")
Private nSomaAffrm:=nSomaArmaz:=nSomaII:=nSomaIPI:=nSomaICMS:= 0
PRIVATE lMV_PIS_EIC:=EasyGParam("MV_PIS_EIC",,.F.) .AND. SW8->(FIELDPOS("W8_BASPIS")) # 0 .AND. SYD->(FIELDPOS("YD_PER_PIS")) # 0
Private nIndFor

#IFDEF TOP
   cAliasED0 := "TRB"
   bWhile    := { || .T. }
   bCond     := { || .T. }
   TRB->( DBGoTop() )
#ELSE
   cAliasED0 := "ED0"
   bWhile    := { || ED0->( ED0_FILIAL == cFilED0 ) }
   bCond     := { || ED0->( Empty(ED0_DT_ENC)  .And.  !Empty(ED0_AC) ) }
   ED0->( DBSeek(cFilED0) )
#ENDIF

aNroDi:= {}

SWN->(dbSetOrder(3))
ED2->(dbSetOrder(3))
SYQ->(dbSetOrder(1))
SW6->(dbSetOrder(1))
SF1->(dbSetOrder(5))

If lDiExt
   ED8->( dbSetOrder(3) )
EndIf

Do While (cAliasED0)->( !EoF() )  .And.  Eval(bWhile)

   nCont++
   
   If !Eval(bCond)
      (cAliasED0)->( DBSkip() )
      Loop
   EndIf

   lGenerico      := (cAliasED0)->ED0_TIPOAC == "06"
   lIntermediario := (cAliasED0)->ED0_TIPOAC == "02"
   lSuspensao     := (cAliasED0)->ED0_MODAL  == "1"

   aHawb:={}

   If ( SW8->(DbSeek(cFilSW8+(cAliasED0)->ED0_AC)) .OR. If(lDiExt,ED8->( dbSeek(xFilial("ED8")+(cAliasED0)->ED0_AC) ),.F.) )

      nFobAto:=nPesoAto:=nDespTot:=nFrete:=nSeguro:=nDespArm:=nDespArTot:=0
      nTotAFRMM:=nTotFrete:=nTotSeguro:=nFreteTot:=nSeguroTot:=0
      nTotII:=nTotIPI:=nTotICMS:=nTotPIS:=nTotCOF:=nCalAFRMM:=nTotArm:=nVlProc:=0
      nCalcFob:=nCalcPeso:=nCalcFAto:=nCalcPAto:=nCalcAFRMM:= 0
      aHawb:={}

      Do While SW8->(!Eof()) .And. SW8->W8_FILIAL+SW8->W8_AC==cFilSW8+(cAliasED0)->ED0_AC      

         nCont++

         If !SW6->( dbSeek(cFilSW6+SW8->W8_HAWB) ) .OR. Empty(SW6->W6_DTREG_D)
            SW8->(Dbskip())
            Loop
         EndIf
         
         If !SF1->( dbSeek(cFilSF1+SW8->W8_HAWB+"1") )
            SW8->(Dbskip())
            Loop
         EndIf
         If !Empty(dDtIni)  .And.  SF1->F1_EMISSAO < dDtIni
            SW8->(Dbskip())
            Loop
         Endif
         If !Empty(dDtFinal)  .And.  SF1->F1_EMISSAO > dDtFinal
            SW8->(Dbskip())
            Loop
         EndIf

         nTxUSD:= SW6->W6_TX_US_D
         nParidade:=1         

         //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
         If SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
            Do While SW9->(!EOF()) .And. SW9->(W9_FILIAL+W9_INVOICE+W9_FORN)==cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN
               If SW9->W9_HAWB==SW8->W8_HAWB
                  If SW9->W9_MOE_FOB<>cMoeDolar
                     nParidade:=SW9->W9_TX_FOB/nTxUSD
                  EndIf
                  Exit
               Endif
            EndDo
         Endif

         nRecSW8 := SW8->(RecNo())
         nIndSW8 := SW8->(IndexOrd())
         cHawb   := SW8->W8_HAWB
         SW8->(dbSetOrder(1))
         SW8->(dbSeek(cFilSW8+cHawb))
         Do While !SW8->(EOF()) .and. SW8->W8_FILIAL==cFilSW8 .and. SW8->W8_HAWB==cHawb
            If Empty(SW8->W8_AC)
               Exit
            EndIf
            SW8->(dbSkip())
         EndDo
         SW8->(dbSetOrder(nIndSW8))
         SW8->(dbGoTo(nRecSW8))
         
         
         nRatIPD   := DITRANS(SW8->W8_INLAND+SW8->W8_PACKING+SW8->W8_OUTDESP-SW8->W8_DESCONT+SW8->W8_FRETEIN,2)
         nRatIPD_RS:= DITRANS(nRatIPD*nParidade,2)

         //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
         SW9->(DbSeek(cFilSW9+SW8->W8_INVOICE+SW8->W8_FORN+EICRetLoja("SW8", "W8_FORLOJ")+SW8->W8_HAWB))
         If SW9->W9_FREINC=="1"
            nFreInv := EDCPG02Des("FI")
         Else
            nFreInv := 0
         EndIf
         
         SW7->(DbSeek(cFilSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))

         nFobAto+=SW8->(W8_QTDE*W8_PRECO)*nParidade+nRatIPD_RS - nFreInv
         nPesoAto+=SW8->W8_QTDE*SW7->W7_PESO

         nCalcFob:=(SW8->(W8_QTDE*W8_PRECO)*nParidade)+nRatIPD_RS - nFreInv
         nCalcPeso:=SW8->W8_QTDE*SW7->W7_PESO

         If SYQ->(DBSEEK(xFilial("SYQ")+SW6->W6_VIA_TRA))
            cViaTra:= LEFT(SYQ->YQ_COD_DI,1)
         EndIf

         If (nPos:=aScan(aFrete,{|x| x[1]==SW8->W8_HAWB })) = 0

            nPesoTot := EDCPG02Des("P")
            nDespesa := EDCPG02Des("D")
            nDespArm := EDCPG02Des("A")
            
            If SW6->W6_SEGMOED = "US$"
               nSeguro:=SW6->W6_VL_USSE
               nSeguroTot:=(nCalcFob*SW9->W9_TX_FOB/SW6->W6_FOB_TOT)*nSeguro
            Else
               nSeguro:=ConvVal(SW6->W6_SEGMOED,SW6->W6_VL_USSE,SW6->W6_DTREG_D)
               nSeguroTot:=(nCalcFob*SW9->W9_TX_FOB/SW6->W6_FOB_TOT)*nSeguro
            EndIf

            nFrete:= ValorFrete(SW6->W6_HAWB,"US$",SW6->W6_DTREG_D,3,)
            aAdd(aFrete,{SW8->W8_HAWB,nPesoTot,nFrete,nDespesa,nDespArm})
            nFreteTot  +=(SW8->W8_QTDE*SW7->W7_PESO/nPesoTot)*nFrete
         Else
            nFreteTot +=(SW8->W8_QTDE*SW7->W7_PESO/aFrete[nPos,2])*aFrete[nPos,3]
            nDespesa := aFrete[nPos,4]
            nDespArm := aFrete[nPos,5]
         EndIF
         
         SYD->(DbSeek(cFilSYD+SW8->W8_TEC+SW8->W8_EX_NCM+SW8->W8_EX_NBM))
         AAdd(aNroDi,{SW8->W8_HAWB    ,;
                      SW6->W6_DI_NUM  ,;
                      SW8->W8_COD_I   ,;
                      SW8->W8_TEC     ,;
                      nCalcFob        ,;
                      nCalcPeso       ,;
                      0               ,;
                      SW8->W8_POSICAO ,;
                      nFrete          ,;
                      nSeguro         ,;
                      0               ,;
                      0               ,;
                      cViaTra         ,;
                      lSuspensao      ,;
                      lIntermediario  ,;
                      SW8->W8_AC      ,;
                      SW8->W8_PO_NUM  ,;
                      nDespesa        ,;
                      nDespArm        ,;
                      0               ,;
                      0               ,;
                      0               ,;
                      nSeguroTot      ,;
                      SW8->W8_VLRPIS*nParidade ,;
                      SW8->W8_VLRCOF*nParidade ,;
                      SYD->YD_RED_PIS ,;
                      SYD->YD_RED_COF ,;
                      SW8->W8_QTDE    ,;
                      0               ,;
                      0               ,;
                      SW8->W8_INVOICE ,;
                      Right(DToC(SF1->F1_EMISSAO),5)  })

         nCalcFob:=nCalcPeso:=nCalcFAto:=nCalcPAto:=nVlProc:=nSeguroTot:=0

         SW8->(DbSkip())

      EndDo

      If lDiExt

         ED8->(DBSEEK(cFilED8+(cAliasED0)->ED0_AC))
         Do While ED8->( !EoF() ) .And. ED8->ED8_FILIAL+ED8->ED8_AC==cFilED8+(cAliasED0)->ED0_AC      
            nCont++
            
            If Empty(ED8->ED8_EMISSA)
               ED8->( DBSkip() )
               Loop
            EndIf
            If !Empty(dDtIni)  .And.  ED8->ED8_EMISSA < dDtIni
               ED8->(Dbskip())
               Loop
            Endif
            If !Empty(dDtFinal)  .And.  ED8->ED8_EMISSA > dDtFinal
               ED8->(Dbskip())
               Loop
            EndIf

            nTxUSD:= ED8->ED8_TX_USS
            nParidade:= 1
            nRecED8 := ED8->(RecNo())
            nIndED8 := ED8->(IndexOrd())
            cHawb   := ED8->ED8_DI_NUM
            nRatIPD   := DITRANS(ED8->ED8_INLAND+ED8->ED8_PACKIN+ED8->ED8_OUTDES-ED8->ED8_DESCNT,2)
            nRatIPD_RS:= DITRANS(nRatIPD*nParidade,2)
            
            nFobAto+=(ED8->ED8_VALEMB*nParidade)+nRatIPD_RS
            nPesoAto+=ED8->ED8_QTD*ED8->ED8_PESO
            
            nCalcFob:=((ED8->ED8_VALEMB*nParidade)+nRatIPD_RS)
            nCalcPeso:=ED8->ED8_QTD*ED8->ED8_PESO
         
            If (nPos:=aScan(aFrete,{|x| x[1]==ED8->ED8_DI_NUM })) = 0
               nPesoTot :=ED8->ED8_QTD*ED8->ED8_PESO
               nDespesa :=ED8->ED8_MRCDES/ED8->ED8_TX_USS
               nDespArm :=ED8->ED8_ARMDES/ED8->ED8_TX_USS
               
               If nDespesa > 0
                  cViaTra := "1"
               Else
                  cViaTra := "4"
               EndIf
               
               nSeguro:=ED8->ED8_SEGURO
               nSeguroTot:=(nCalcFob/ED8->ED8_VALEMB)*nSeguro
               
               nFrete:=ED8->ED8_FRETE*nParidade
               aAdd(aFrete,{ED8->ED8_DI_NUM,nPesoTot,nFrete,nDespesa,nDespArm})
               nFreteTot  +=(ED8->ED8_QTD*ED8->ED8_PESO/nPesoTot)*nFrete
            Else
               nFreteTot +=(ED8->ED8_QTD*ED8->ED8_PESO/aFrete[nPos,2])*aFrete[nPos,3]
               nDespesa := aFrete[nPos,4]
               nDespArm := aFrete[nPos,5]
               If nDespesa > 0
                  cViaTra := "1"
               Else
                  cViaTra := "4"
               EndIf
            EndIF
            
            SYD->(DbSeek(cFilSYD+ED8->ED8_NCM)) 
            IF lMV_PIS_EIC
                nPisVal:=0
                nCofVal:=0
            else
                nPisVal:=0
                nCofVal:=0
            endif
            AAdd(aNroDi,{ED8->ED8_DI_NUM ,;
                         ED8->ED8_DI_NUM ,;
                         ED8->ED8_COD_I  ,;
                         ED8->ED8_NCM    ,;
                         nCalcFob        ,;
                         nCalcPeso       ,;
                         0               ,;
                         ED8->ED8_POSDI  ,;
                         nFrete          ,;
                         nSeguro         ,;
                         0               ,;
                         0               ,;
                         cViaTra         ,;
                         lSuspensao      ,;
                         lIntermediario  ,;
                         ED8->ED8_AC     ,;
                         ""              ,;
                         nDespesa        ,;
                         nDespArm        ,;
                         0               ,;
                         0               ,;
                         0               ,;
                         nSeguroTot      ,;
                         nPisVal         ,;
                         nCofVal         ,;
                         SYD->YD_RED_PIS ,;
                         SYD->YD_RED_COF ,;
                         ED8->ED8_QTD    ,;
                         0               ,;
                         0               ,;
                         ED8->ED8_INVOIC ,;
                         Right(DToC(ED8->ED8_EMISSA),5)    })
            nCalcFob:=nCalcPeso:=nCalcFAto:=nCalcPAto:=nVlProc:=nSeguroTot:=0
            
            ED8->(DbSkip())         
         EndDo
      EndIf

      If lPrim
         nCont:= 1
      Else
         nCont:= nContAux+1
      Endif

      For Ni:= nCont to Len(aNroDi)
         nIndFor:=Ni
         SYD->(DbSeek(cFilSYD+aNroDi[nIndFor,4]))

         nTxII  :=SYD->YD_PER_II
         nTxIPI :=SYD->YD_PER_IPI
         nTxICMS:=SYD->YD_ICMS_RE
         nTxPIS :=SYD->YD_PER_PIS
         nTxCOF :=SYD->YD_PER_COF
         
         nPos:=aScan(aFrete,{|x| x[1]==aNroDi[nIndFor,1] })
         aNroDi[nIndFor,7]:=aNroDi[nIndFor,5]+(aNroDi[nIndFor,6]/aFrete[nPos,2])*aFrete[nPos,3]+aNroDi[nIndFor,23]
         If(aNroDi[nIndFor,13]=="1", aNroDi[nIndFor,11]:= ((((aNroDi[nIndFor,6] / aFrete[nPos,2]) * aFrete[nPos,3]) + ((aNroDi[nIndFor,6] / aFrete[nPos,2]) * aNroDi[nIndFor,18])) * 25) / 100 , aNroDi[nIndFor,11]:=0) /*nFreteTot*/
         If(aNroDi[nIndFor,13]=="4", aNroDi[nIndFor,12]:= (aNroDi[nIndFor,5]/nFobAto)*aNroDi[nIndFor,19], aNroDi[nIndFor,12]:=0 )
         lPrim:=.F.
         
         aNroDi[nIndFor,20] := (aNroDi[nIndFor,7]*nTxII)/100
         aNroDi[nIndFor,21] := ((aNroDi[nIndFor,7]+aNroDi[nIndFor,20])*nTxIPI)/100
         
         If aNroDi[nIndFor,24] > 0
            aNroDi[nIndFor,29] := aNroDi[nIndFor,24]
            aNroDi[nIndFor,30] := aNroDi[nIndFor,25]
         ElseIf lMV_PIS_EIC
            IF SB1->(DbSeek(xFilial("SB1")+aNroDi[nIndFor,3])) .AND. !EMPTY(SB1->B1_TAB_IPI)
               EI6->(DBSEEK(xFilial("EI6")+SB1->B1_TAB_IPI))
               nVlrIPIEsp:=aNroDi[nIndFor,28]*EI6->EI6_IPIUNI
            EndIf
            aNroDi[nIndFor,29] := DI500PISCalc(aNroDi[nIndFor,7],aNroDi[nIndFor,18],(nTxII/100),(nTxIPI/100),(nTxICMS/100),(nTxPIS/100),(nTxCOF/100),(aNroDi[nIndFor,26]/100),0) * (nTxPIS/100) //DI500PISCalc(aNroDi[nIndFor,7],aNroDi[nIndFor,20]+aNroDi[nIndFor,21],(nTxII/100),(nTxIPI/100),(nTxICMS/100),(aNroDi[nIndFor,26]/100),(aNroDi[nIndFor,27]/100),(aNroDi[nIndFor,26]/100),0,nVlrIPIEsp)
            aNroDi[nIndFor,30] := DI500PISCalc(aNroDi[nIndFor,7],aNroDi[nIndFor,18],(nTxII/100),(nTxIPI/100),(nTxICMS/100),(nTxPIS/100),(nTxCOF/100),(aNroDi[nIndFor,27]/100),0) * (nTXCOF/100) //DI500PISCalc(aNroDi[nIndFor,7],aNroDi[nIndFor,20]+aNroDi[nIndFor,21],(nTxII/100),(nTxIPI/100),(nTxICMS/100),(aNroDi[nIndFor,26]/100),(aNroDi[nIndFor,27]/100),(aNroDi[nIndFor,27]/100),0,nVlrIPIEsp)
         EndIf
         
         aNroDi[nIndFor,22] := ( ( aNroDi[nIndFor,7]+aNroDi[nIndFor,20]+aNroDi[nIndFor,21] ;
                                  +aNroDi[nIndFor,29]+aNroDi[nIndFor,30])                  ;
                                 / (100 - nTxICMS ) ) * nTxICMS
         If !aNroDi[nIndFor,14] .Or. aNroDi[nIndFor,15]
            aNroDi[nIndFor,22] := aNroDi[nIndFor,22] - ( ( aNroDi[nIndFor,7] / ( 100 - nTxICMS ) ) * nTxICMS )
         Endif
            
         cMes := Left( aNroDi[nIndFor][32],2)
         cAno := Right(aNroDi[nIndFor][32],2)
         nPos := AScan( aDespesas, { |x| x[8]+x[9] == cMes+cAno } )
         If nPos > 0
            aDespesas[nPos][1] += aNroDi[nIndFor][20]
            aDespesas[nPos][2] += aNroDi[nIndFor][21]
            aDespesas[nPos][3] += aNroDi[nIndFor][22]
            aDespesas[nPos][4] += aNroDi[nIndFor][11]
            aDespesas[nPos][5] += aNroDi[nIndFor][29]
            aDespesas[nPos][6] += aNroDi[nIndFor][30]
            aDespesas[nPos][7] += aNroDi[nIndFor][12]
         Else
            AAdd(aDespesas,{ aNroDi[nIndFor][20] ,;
                             aNroDi[nIndFor][21] ,;
                             aNroDi[nIndFor][22] ,;
                             aNroDi[nIndFor][11] ,;
                             aNroDi[nIndFor][29] ,;
                             aNroDi[nIndFor][30] ,;
                             aNroDi[nIndFor][12] ,;
                             cMes                ,;
                             cAno                   } )
         EndIf

         nTotII     += aNroDi[nIndFor,20]
         nTotIPI    += aNroDi[nIndFor,21]
         nTotICMS   += aNroDi[nIndFor,22]
         nSomaAffrm += aNroDi[nIndFor,11]
         nTotPIS    += aNroDi[nIndFor,29]
         nTotCOF    += aNroDi[nIndFor,30]
         nSomaArmaz += aNroDi[nIndFor,12]
         
      Next nIndFor

      nContAux:= Len(aNroDi)
      
      aEixoY[1] += Round(nTotII,2)
      aEixoY[2] += Round(nTotIPI,2)
      aEixoY[3] += Round(nTotICMS,2)
      aEixoY[4] += Round(nSomaAffrm,2)
      aEixoY[5] += Round(nTotPIS,2)
      aEixoY[6] += Round(nTotCOF,2)
      aEixoY[7] += Round(nSomaArmaz,2)

   EndIf

   (cAliasED0)->(DBSKIP())

EndDo

If Len(aDespesas) > 0
   ASort(aDespesas,,,{|x,y| x[9]+x[8] < y[9]+y[8] })
EndIf

(cAliasED0)->( DBCloseArea() )
SWN->(dbSetOrder(1))

RETURN .T.


********************************************************************************************************
Static Function EDCPG02Des(cParam)
********************************************************************************************************
Local nValAux:=0, nVlArm:=0, nRecW7:=SW7->(RecNo()), nOrdW7:=SW7->(IndexOrd())
Local nRecaux, nOrdAux, nAux:=0

If cParam == "P"
   SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB))
   DO WHILE SW7->(!EOF()) .AND. SW7->W7_HAWB == SW8->W8_HAWB   .AND.;
   SW7->W7_FILIAL  == cFilSW7
      nValAux += (SW7->W7_QTDE*SW7->W7_PESO)
      SW7->(dbSkip())
   EndDo

   SW7->(dbSetOrder(nOrdW7))
   SW7->(dbGoTo(nRecW7))
ElseIf cParam == "FI"
   nRecAux:=SW8->(RecNo())
   nOrdAux:=SW8->(IndexOrd())
   SW8->(dbSetOrder(1))
   SW8->(dbSeek(cFilSW8+SW9->W9_HAWB+SW9->W9_INVOICE+SW9->W9_FORN))
   Do While !SW8->(EOF()) .and. SW8->W8_FILIAL==cFilSW8 .and. SW8->W8_HAWB==SW9->W9_HAWB .and.;
   SW8->W8_INVOICE==SW9->W9_INVOICE .and. SW8->W8_FORN==SW9->W9_FORN
      SW7->(DbSeek(cFilSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
      nAux += SW8->W8_QTDE * SW7->W7_PESO
      SW8->(dbSkip())
   EndDo
   SW8->(dbSetOrder(nOrdAux))
   SW8->(dbGoTo(nRecAux))
   SW7->(DbSeek(cFilSW7+SW8->(W8_HAWB+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM)))
   nValAux := ((SW8->W8_QTDE*SW7->W7_PESO) / nAux) * SW9->W9_FRETEIN
Else
   SWD->(Dbseek(cFilSWD+SW8->W8_HAWB))
   Do While SWD->(!EOF()) .And. SWD->(WD_FILIAL+WD_HAWB)==cFilSWD+SW8->W8_HAWB
      If (!Empty(dDtIni) .and. SWD->WD_DES_ADI >= dDtIni) .or.;
      (!Empty(dDtFinal) .and. SWD->WD_DES_ADI <= dDtFinal)
         If cParam=="A" .And. SWD->WD_DESPESA == "403"
            nVlArm+=SWD->WD_VALOR_R/nTxUSD
         ElseIf SWD->WD_DESPESA <> cDespArm
            nValAux+=SWD->WD_VALOR_R/BuscaTaxa(cMoeDolar,SWD->WD_DES_ADI,.T.,.F.,.T.) //nTxUSD  //Para AFRRM
         Endif
      EndIf
      SWD->(DbSkip())
   EndDo
Endif

Return IIF(cParam == "A", nVlArm, nValAux)


********************************************************************************************************
Static Function EDCPG02Tab()
********************************************************************************************************

 Local ni       := 1                       ,;
       nj       := 1                       ,;
       cFiltro  := ""                      ,;
       ;//aCabec   := { STR0003, STR0004 }  ,;//"Despesas","Valores"
       ;//aValores := {}                      ,;
       aData    := {}                      ,;
       cPicture := "@E 999,999,999.99"

   For ni := 1  To  Len(aEixoX)
      aAdd(aTabela, {aEixoX[ni],;
                     {},;
                     {{}}})
   Next
   nLen := Len(aDespesas)
   For ni := 1 To nLen
      aAdd(aDespesas, aClone(aDespesas[ni]))
      aDespesas[Len(aDespesas)][8] := "8"
   Next
   For ni := 1 To Len(aDespesas)
      aData    := DataExtenso(CToD("01/"+aDespesas[ni][8]+"/"+aDespesas[ni][9]),IncSpace(EasyGParam("MV_AVG0035",,"PORT. "), 6, .F.)+"-PORTUGUES")
      cFiltro  := aData[1]+"/"+aData[3]
      For nj := 1 To Len(aTabela)
         aAdd(aTabela[nj][2], cFiltro)
         aAdd(aTabela[nj][3][1], Transform(aDespesas[ni][nj], cPicture))
      Next
   Next
   For ni := 1 To Len(aTabela)
      aAdd(aTabela[ni][2], "Total")
      aAdd(aTabela[ni][3][1], Transform(aEixoY[ni], cPicture))
   Next

Return


********************************************************************************************************
Function EDCPG02Val(cCampo)
********************************************************************************************************

 Local lRet  := .T.  ,;
       nMes  := 0    ,;
       cMes1 := ""   ,;
       cAno1 := ""   ,;
       cMes2 := ""   ,;
       cAno2 := ""   ,;
       ni    := 1
 
   Begin Sequence

      Do Case

         Case cCampo $ "DtInicial___DtFinal"
            If cCampo == "DtInicial"
               If mv_par01 != "  /  "
                  For ni := 1  to  Len(mv_par01)
                     If SubStr(mv_par01,ni,1) $ " -"
                        lRet := .F.
                        Break
                     EndIf
                  Next ni
                  nMes := Val(Left(mv_par01,2))
                  If nMes < 1  .Or.  nMes > 12
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf
         
            If cCampo == "DtFinal"
               If mv_par02 != "  /  "
                  For ni := 1  to  Len(mv_par02)
                     If SubStr(mv_par02,ni,1) $ " -"
                        lRet := .F.
                        Break
                     EndIf
                  Next ni
                  nMes := Val(Left(mv_par02,2))
                  If nMes < 1  .Or.  nMes > 12
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

            cMes1 := Left(mv_par01,2)
            cAno1 := Right(mv_par01,2)
            cMes2 := Left(mv_par02,2)
            cAno2 := Right(mv_par02,2)
            
            If mv_par01 != "  /  "  .And.  mv_par02 != "  /  "
               If cAno1 > cAno2
                  lRet := .F.
                  Break
               ElseIf cAno1 == cAno2
                  If cMes1 > cMes2
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

      EndCase
      
   End Sequence

Return lRet
