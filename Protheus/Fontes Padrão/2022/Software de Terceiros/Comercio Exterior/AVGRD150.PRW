#INCLUDE "AVERAGE.CH"
#INCLUDE "AVGRD150.CH"  

// ****************************************************************//
// Programa....: AVGRD150.PRW
// Programador.: Alessandro Alves Ferreira - AAF
// Data........: 01 de Setembro de 2006
// Objetivo....: Rel. de Demurrage.
// Observação..: Este relatório pertencia ao AVGDM400,
//               foi retirado para se adequar ao padrão.
//*****************************************************************//

#DEFINE TP_EXP "E"
#DEFINE TP_IMP "I"

//***********************************************//
//Função......: AVGRD150.PRW                     
//Programador.: Alessandro Alves Ferreira - AAF  
//Objetivo....: Rel. de Demurrage
//Data........: 01/07/06 - 10:00
//***********************************************//
Function AVGRD150()
//***********************************************//
Local oDlg, nOp:=0
//LRL-21/01/05-Não é mais chaado apartir do arotina------------------------------------------------------------------------------
PRIVATE cFilSx5 := xFilial("SX5"), cFilSw6 := xFilial("SW6"), cFilEE6 := xFilial("EE6")
PRIVATE cFilSY9 := xFilial("SY9"), cFilSA2 := xFilial("SA2"), cFilSYF := xFilial('SYF') , cFilSA1 := xFilial("SA1")
PRIVATE cFilSW8 := xFilial("SW8"), cFilEG0 := xFilial("EG0"), cFilEG1 := xFilial("EG1")
PRIVATE cFilEG2 := xFilial("EG2"), cFilSAH := xFilial("SAH"), cFilSW7 := xFilial("SW7")
PRIVATE cFilSY7 := xFilial('SY7'), cFilEEC := xFilial("EEC"), cFilEE9 := xFilial("EE9") ,cFilEE4 := xFilial("EE4")
PRIVATE lCpoViagem     := .f.
PRIVATE lExistDM := if (EG0->( FieldPos( "EG0_DEMURR" ) ) > 0 .AND. EG1->( FieldPos( "EG1_DEMURR" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_NRINVO" ) ) > 0 .AND. EG1->( FieldPos( "EG1_PEDIDO" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_SEQUEN" ) ) > 0 .AND. EG1->( FieldPos( "EG1_COD_I" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_QTDUC" ) ) > 0  .AND. EG1->( FieldPos( "EG1_QTDMT" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_UNMED" ) ) > 0  .AND. EG1->( FieldPos( "EG1_COEF" ) ) > 0 ;
        .AND. EG2->( FieldPos( "EG2_DEMURR" ) ) > 0  ,.T.,.F.) 
Private  lExistFret := if  ( EG2->( FieldPos( "EG2_TP_LD" ) ) > 0 .AND. EG0->( FieldPos( "EG0_FRETE"  ) ) > 0 ; 
                       .AND. EG0->( FieldPos( "EG0_BANCO" ) ) > 0 .AND. EG0->( FieldPos( "EG0_NOR"    ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_TCFDT" ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_TCFTM" ) ) > 0 .AND. EG0->( FieldPos( "EG0_CODTER" ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_CODAGE") ) > 0 .AND. EG0->( FieldPos( "EG0_NEG_VL" ) ) > 0 ;
                       .AND. EG0->( FieldPos( "EG0_VCT"   ) ) > 0 .AND. EG0->( FieldPos( "EG0_CLIENT" ) ) > 0;
                       .AND. EG0->( FieldPos( "EG0_CLILOJ" ) ) > 0,.T.,.F.) //LRL 12/01/05
Private lLojaFor := EG0->( FieldPos( "EG0_FORLOJ" ) ) > 0                       
//------------------------------------------------------------------------------LRL-21/01/05-Não é mais chaado apartir do arotina
Private lMulTiFil    :=  VerSenha(115) .and. Posicione("SX2",1,"EG0","X2_MODO") == "C" .AND. (nModulo == 17 .and. Posicione("SX2",1,"SW8","X2_MODO") == "E" .Or. nModulo == 29 .and. Posicione("SX2",1,"EE9","X2_MODO") == "E" ) .AND. EG1->( FieldPos( "EG1_FILORI" ) ) > 0 .And. lExistDm .and. lExistFret
Private lFiltraFil   :=  VerSenha(115) .and. Posicione("SX2",1,"EG0","X2_MODO") == "E" .And. lExistDm .and. lExistFret
Private lExistFilOri :=  EG1->( FieldPos( "EG1_FILORI" ) ) > 0                                 
Private aFil   

PRIVATE aMensagem      := {}

If lFiltraFil
   aFil :=  AvgSelecTFil()
Else 
   aFil :=  AvgSelecTFil(.F.,"EG0","EG0")
EndIf

If Pergunte("DM400",.T.)
   If mv_par11 == 1  //caso destino seja impressora
      
      DEFINE MSDIALOG oDlg TITLE STR0024 FROM 12,05 To /*20*/24,55 OF GetwndDefault() //"Mensagens/Impressão"     // GFP - 30/03/2012 - Ajuste tamanho tela para versão M11.5
      
      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 22/07/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      @30,(oDlg:nClientWidth-4)/2-135 BUTTON STR0025 SIZE 34,11 OF oPanel PIXEL ACTION(RD150MSG(),oDlg:End()) //"Mensagens"
      @30,(oDlg:nClientWidth-4)/2-95 BUTTON STR0026 SIZE 34,11 OF oPanel PIXEL ACTION(RD150REL(),oDlg:End()) //"Impressão"
      
      ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, {||nOp:=1,oDlg:End()}, {||oDlg:End()} ) CENTERED
      
   Else
      RD150ImpRel()
   EndIf
EndIf

Return .T.

// ----------------------------
// Define as mensagens que serão impressas no relatório.
// ACSJ - 27 de Janeiro de 2004
Function RD150MSG()
// ----------------------------
Local i

lImp:= .T.
If AV_ESC_OBS("B",,,,,)

   WORK_MEN->( dbGoTop() )
   Do While !WORK_MEN->( EoF() ) .AND. WORK_MEN->WKORDEM <> "zzzzz"
      For i := 1 to MlCount( WORK_MEN->WKOBS, 220 )
         Aadd( aMensagem, MemoLine( WORK_MEN->WKOBS, 220, i ) )
      Next
      WORK_MEN->( dbSkip() )
   EndDo
   
   RD150REL()
Endif

Return .T.

// -------------------------------------------------------
// Relatório de Demurrage / Despatch sem data de pagamento
// ACSJ - 27 de Janeiro de 2004
FUNCTION RD150REL()
// -------------------------------------------------------
Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatório "
Local cDesc2         := STR0002 //"de Demurrage / Despatch."
Local cDesc3         := ""
Private titulo       := STR0003//"Relatório de Demurrage / Despatch."
Private nLin         := 99
Private cString      := "EG0"
Private tamanho      := "G"
Private nomeprog     := "AVGRD150"
Private aReturn      := {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administração"
Private wnrel        := "AVGRD150" // Coloque aqui o nome do arquivo usado para impressao em disco

If EG0->(Eof()) .AND. EG0->(Bof())     // GFP - 30/03/2012 - Verifica se existe registros na tabela antes de iniciar impressão
   Help(" ",1,"AVG0005112") //"Não há Dados para Impressão!"
   Return .F.
EndIf

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

If nLastKey = 27
   Return
Endif

SetDefault(aReturn,cString)
RptStatus({|lEnd| RD150ImpRel(wnRel,cString)})
OurSpool(wnRel)

Return .T.

// -----------------------
// Impressao do Relatorio
// ACSJ - 27 de Janeiro de 2004
Function RD150IMPREL()
// -----------------------
Local nFil 
Local cxFil := cFilAnt
Local cOldFil
Local cEmbOld        := " "
Local cCod_I         := " "
Local nOwDemTot      := 0, nParDemTot := 0, nOwDesTot := 0, nParDesTot := 0, nPos := 0, nPos2 := 0,Tot_embarque:=0
Local aMoedas        := {}                          
Local aPortos        := {}
Local lOk            := .T.
Local cUltimoForn       // AAF 28/05/04 - Guarda o fornecedor do ultimo registro impresso
Local aMoedasForn := {} // AAF 28/05/04
Local aMoeFornFil := {}
Local aPortFil := {}
Local aPortosForn := {} // AAF 28/05/04
Local nDemuDespC,EG1_ATUAL,nOwDem, nParcDem, nOwDes, nParcDes, cCondP1, cCondP2, cCondP3
Local nTotOwne, nTotParc, nTotDiff, cTitTot, cTitMed, nDemMedPrt, nDesMedPrt
Local porto_n := ""
Local cCodI
Local nForneCont := 0 //LRL 03/06/04 Conta Fornecedores para garantir q relatorios com um só 
                      //             fornecedor não imprimam Media Geral

/* Alterado a pedido da trevo - ACSJ - 15/03/2004 
Local nCol01:= 000, nCol02:= 016, nCol03:= 027, nCol04:= 032, nCol05:= 063, nCol06:= 082, nCol07:= 093, nCol08:= 112
Local nCol09:= 117, nCol10:= 135, nCol11:= 143, nCol12:= 160, nCol13:= 168, nCol14:= 186, nCol15:= 194, nCol16:= 213
*/

Private nCol01 := 000, nCol02:= 026, nCol03:= 047, nCol04:= 001, nCol05:= 032, nCol06:= 083, nCol07:= 094, nCol08:= 113
Private nCol09 := 117, nCol10:= 135, nCol11:= 143, nCol12:= 161, nCol13:= 169, nCol14:= 187, nCol15:= 195, nCol16:= 213
Private lPrtVz := .T.
Private nDias  := 0 //AAF 02/12/04 - Guarda o Numero de Dias em Demurrage ou Despatch para o relatório em Excel.
Private WorkFile    //AAF 02/12/04 - Guarda o Nome do Arquivo gerado para Excel.
Private M_pag  := 0
Private lLoop  := .F.
Private cHeader

If lMulTiFil
   cHeader := STR0030//"          BRANCH - O/REF.                     PRODUCT                            OPERAT. DATE        QTTY      MONEY    OWNERS DEMUR.  VAL./TON.  VAL. DEMUR.    VAL./TON.  OWNERS DESP.   VAL./TON.   VAL. DESP.  VAL./TON."         
Else
   cHeader := STR0023//"             O/REF.                           PRODUCT                            OPERAT. DATE        QTTY      MONEY    OWNERS DEMUR.  VAL./TON.  VAL. DEMUR.    VAL./TON.  OWNERS DESP.   VAL./TON.   VAL. DESP.  VAL./TON."         
EndIf

//Private aDriver    := ReadDriver() //Alcir - 06-12-04
If mv_par11==2  //caso destino seja excel
   nLin:= 0
   
   aData := {}
   aAdd(aData,{"WK_NAVIO"  ,AVSX3("EG0_NAVIO",2) ,AVSX3("EG0_NAVIO",3) ,AVSX3("EG0_NAVIO",4) })
   aAdd(aData,{"WK_VIAGEM" ,AVSX3("EG0_VIAGEM",2),AVSX3("EG0_VIAGEM",3),AVSX3("EG0_VIAGEM",4)})
   aAdd(aData,{"WK_PORTO"  ,"C"                  ,80                   ,0                    })
   aAdd(aData,{"WK_FORNEC" ,"C"                  ,80                   ,0                    })
   aAdd(aData,{"WK_DIA"    ,"N"                  ,15                   ,5                    })
   aAdd(aData,{"WK_TIPO"   ,"C"                  ,15                   ,0                    })
   aAdd(aData,{"WK_EMBARQ" ,"C"                  ,80                   ,0                    })
   aAdd(aData,{"WK_OPER_DT","D"                  ,08                   ,0                    })
   aAdd(aData,{"WK_MOEDA"  ,"C"                  ,80                   ,0                    })
   aAdd(aData,{"WK_QTTY"   ,"N"                  ,15                   ,5                    })
   aAdd(aData,{"WK_PROD"   ,"C"                  ,80                   ,0                    })
   aAdd(aData,{"WK_QTTYIT" ,"N"                  ,15                   ,5                    })//AAF 02/12/04 - Quantidade por item.
   aAdd(aData,{"WK_PROD_D" ,"N"                  ,15                   ,2                    })
   
   If lMultiFil
      aAdd(aData,{"WK_FILORI",AVSX3("EG0_FILORI",2),AVSX3("EG0_FILORI",3),AVSX3("EG0_FILORI",4)})          
   EndIf
   
   WorkFile := E_CriaTrab(,aData, "WORK2")  //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados

Endif

EG0->( DBSetOrder(2) ) // AAF 28/05/04 Alteração de Indice - EG0_FILIAL+EG0_MODULO+EG0_FORNEC+EG0_MOEDA+EG0_NAVIO+EG0_VIAGEM+EG0_DEST
EG1->( DBSetOrder(1) )
EG2->( DBSetOrder(1) )
EE6->( DBSetOrder(1) )
SW8->( DBSetOrder(1) )
SW6->( DBSetOrder(1) )  

If mv_par01 == 1
   cCondP1 := "!Empty(EG0->EG0_PGT)"
Elseif mv_par01 == 2
   cCondP1 := " Empty(EG0->EG0_PGT)"
Else
   cCondP1 := ".T." 
Endif

If mv_par06 == 1
   cCondP2 := "EG0->EG0_TIPO == '1'"
Elseif mv_par06 == 2
   cCondP2 := "EG0->EG0_TIPO == '2'"
Else                                
   cCondP2 := ".T."
Endif

If mv_par07 == 1
   cCondP3 := "EG0->EG0_REVER == '1'"
Elseif mv_par07 == 2
   cCondP3 := "EG0->EG0_REVER == '2'"
Else
   cCondP3 := ".T."
Endif

If EasyEntryPoint("AVGDM400")                       
   ExecBlock("AVGDM400",.F.,.F.,"IMPREL")
EndIf

For nFil := 1 to Len(aFil)
   cFilAnt:= aFil[nFil]
   cOldFil := If(lFiltraFil,"XXX",aFil[nFil])
   SetFil()
   
   EG0->( dbSeek(cFilEG0) )
   cUltimoForn := EG0->EG0_FORNEC //AAF 28/05/04                    
   Do While !EG0->( EoF() ) .AND. EG0->EG0_FILIAL == cFilEG0
      lPriVez := .T.
      lImpr   := .F.
      
      If &cCondP1
         If mv_par01 == 1   // Pago
            lOk := .F.
            If ( EG0->EG0_PGT >= mv_par08 .or. Empty(mv_par08) ) .and. ( EG0->EG0_PGT <= mv_par09 .or. Empty(mv_par09) )
               lOk := .T.
            EndIf
         EndIf
         If lOk
            
            If lExistDm
               EG1->(DBSeek( cFilEG0 + iif(nModulo == 17, "I", iif(nModulo == 29, "E", " ") )+EG0->EG0_DEMURR))
            Else
               EG1->(DBSeek( cFilEG0 + iif(nModulo == 17, "I", iif(nModulo == 29, "E", " ") ) +EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST ))         
            EndIf
            
            If !EG1->( EoF() )
               
               /*                  
               cCondEG1 := '( cFilEG1 + iif(nModulo == 17, "I", iif(nModulo == 29, "E", " ") ) + EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) == ' 
               cCondEG1 += '( cFilEG0 + iif(nModulo == 17, "I", iif(nModulo == 29, "E", " ") ) + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST )'
               */
               
               cCondEG1 := '( cFilEG1 + iif(nModulo == 17, "I", iif(nModulo == 29, "E", " ") ) + If(lExistDm,EG1->EG1_DEMURR,"") + EG1->EG1_NAVIO + EG1->EG1_VIAGEM + EG1->EG1_DEST ) == ' //LRL
               cCondEG1 += '( cFilEG0 + iif(nModulo == 17, "I", iif(nModulo == 29, "E", " ") ) + If(lExistDm,EG0->EG0_DEMURR,"") + EG0->EG0_NAVIO + EG0->EG0_VIAGEM + EG0->EG0_DEST )'     //12/11/04 vide lExistDM
               
            Else
               lLoop    := .t.    //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	
                                  // ACSJ - 27/05/2004
               
               cCondEG1 := "lLoop"
            Endif
            
            iif( Empty(EG0->EG0_DEST), lPorto := .t., lPorto := .f. )
            
            Do While &cCondEG1
               If !lLoop //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	
                         // ACSJ - 27/05/2004
                  
                  //Alcir - 22-11-04
                  If lExistDm
                     If nModulo == 17
                        SW6->( DBSeek( cFilSW6 + AVKey(EG1->EG1_EMBARQ, "W6_HAWB") ) )
                     Else   
                        EEC->( DBSeek( cFilEEC + AVKey(EG1->EG1_EMBARQ, "EEC_PREEMB") ) )
                     EndIf   
                     cCond := " EG1->EG1_DEMURR == '" +EG1->EG1_DEMURR +"' .AND. " +" EG1->EG1_EMBARQ == '" + EG1->EG1_EMBARQ + "'  .AND. "+IIf(nModulo == 17,"EG1->EG1_MODULO='I'","EG1->EG1_MODULO='E'")                 
                  Else
                     If nModulo == 17   // IMPORTACAO
                        SW6->( DBSeek( cFilSW6 + AVKey(EG1->EG1_EMBARQ, "W6_HAWB") ) )
                        SW8->( DBSeek( cFilSW8 + AVKey(EG1->EG1_EMBARQ, "W8_HAWB") ) ) 
                        cCond := " SW8->W8_HAWB == '" + AVKey(EG1->EG1_EMBARQ, "W8_HAWB") + "' "
                     Elseif nModulo == 29   // EXPORTACAO                                     
                        EEC->( DBSeek( cFilEEC + AVKey(EG1->EG1_EMBARQ, "EEC_PREEMB") ) )
                        EE9->( DBSetOrder(2) )
                        EE9->( DBSeek( cFilEE9 + AVKey(EG1->EG1_EMBARQ, "EE9_PREEMB") ) ) 
                        cCond := " EE9->EE9_PREEMB == '" + AVKey(EG1->EG1_EMBARQ, "EE9_PREEMB") + "'"            
                     Endif   
                  EndIf 
                  cEmbOld := ""
         	   Else
         	      cCond := ".t."
               EndIf
               
               Tot_embarque:=0
               Do While &cCond 
                  If Empty(mv_par02) .or. mv_par02 == EG0->EG0_NAVIO
                     //If Empty(mv_par03) .or. mv_par03 == EG0->EG0_VIAGEM //wfs
                     If Empty(mv_par03) .or. AvKey(mv_par03, "EG0_VIAGEM") == EG0->EG0_VIAGEM //wfs
                        If Empty(mv_par04) .or. mv_par04 == If( Empty(EG0->EG0_DEST),If(nModulo == 17, SW6->W6_DEST,;
                                                                                     If(nModulo == 29, EEC->EEC_DEST,"") ),;
                                                                                     EG0->EG0_DEST)
                           If Empty(mv_par05) .or. mv_par05 == EG0->EG0_FORNEC   // GFC 
                              If &cCondP2                                     
                                 If &cCondP3         
                                 
                                    lImpr := .t.
                                 
                                    If nLin > 66 .OR. cOldFil != aFil[nFil] .OR. EG0->EG0_FORNEC <> cUltimoForn .AND. lPriVez // AAF 28/05/04 - Compara se o fornecedor ainda é o mesmo
                                       If EG0->EG0_FORNEC <> cUltimoForn .AND. lPriVez .AND. nLin < 99 
                                          nForneCont ++
                                          If !lFiltraFil
                                             nLin++
                                             If mv_par11==1  //caso destino seja impressora - Alcir 25-11-04
                                                @ nLin,96 PSay STR0006 //"SUPPLIER'S AVERAGE BY MONEY"
                                             Endif
                                             RD150RELMOE(aMoedasForn,aPortosForn)
                                             aMoedasForn := {}
                                             aPortosForn := {}     
                                          EndIf   
                                          cUltimoForn := EG0->EG0_FORNEC
                                       EndIf
                                       RD150RELCAB()
                                       nLin := 10
                                       If lFiltraFil .AND. mv_par11==1  //caso destino seja impressora ////Alcir - 22-11-04 
                                         @ nLin, nCol01 PSay STR0031 + aFil[nFil] + " - " + AvgFilName({aFil[nFil]})[1] //"DEMURRAGE : "   //"BRANCH : "
                                         nLin+=2
                                         cOldFil := aFil[nFil]
                                       EndIf
                                    EndIf
                                    
                                    If lPriVez
                                       If lExistDm .and. mv_par11==1  //caso destino seja impressora ////Alcir - 22-11-04 
                                          @ nLin, nCol01 PSay STR0028 + EG0->EG0_DEMURR //"DEMURRAGE : "
                                       EndIf
                                       
                                       If mv_par11==1  //caso destino seja impressora
                                          @ nLin,IIf(lExistDm,nCol02,nCol01) PSay STR0007 + EG0->EG0_NAVIO //"VESSEL : "
                                          @ nLin,IIf(lExistDm,(nCol03+16),nCol02) PSay STR0008  + EG0->EG0_VIAGEM //"TRIP   : "
                                       EndIf
                                       If !lLoop //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	                           			      // ACSJ - 27/05/2004
                                          porto_n:=""
                                          porto_n:=iif(lPorto, iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST), EG1->EG1_DEST )
                                          
                                          If mv_par11==1 //caso destino seja impressora //AAF 02/12/04 - O porto não estava sendo exibido em relatório Excel.
                                             @ nLin,IIf(lExistDm,(nCol03+46),nCol03) PSay STR0009 + porto_n //"PORT : "
                                          EndIf
                                       EndIf
                                       
                                       SA2->( dbSetOrder(1) )
                                       SA2->( dbSeek(cFilSa2 + EG0->EG0_FORNEC) )
                                       cFornec := SA2->A2_NREDUZ
                                       
                                       If mv_par11==1  //caso destino seja impressora
                                          @ nLin,IIf(lExistDm,(nCol03+082),(nCol03 + 16)) PSay STR0010 + cFornec //"FORNECEDOR : "
                                          @ nLin,IIf(lExistDm,(nCol03+135),(nCol03 + 52)) PSay Transform(EG0->EG0_TEMPO, AVSX3("EG0_TEMPO",6,"EG0") ) + STR0027 +; //" DAYS ON "
                                                             iif(EG0_CLASSI == "1", "DEMURRAGE","DESPATCH")

                                          nLin ++
                                       EndIf
                                       // @ nLin, nCol04 PSay EG1->EG1_EMBARQ
                                    EndIf
                                    
                                    If lPorto .and. .not. lPriVez .and. cEmbOld <> EG1->EG1_EMBARQ .and. mv_par10==2 .and. mv_par11==1  //caso destino seja impressora
                                       @ nLin-1, IIf(lExistDm,(nCol03+48),nCol03) PSay STR0009 + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST) //"PORT :  "
                                       // nLin ++
                                    EndIf
                                    // ----------------------------------------------
                                    If lPriVez
                                       //nDemuDespC:=((EG0->EG0_PARC_C/EG0->EG0_CARGO)*(EG0->EG0_TEMPO*EG0->EG0_DEM_V))/EG0->EG0_PARC_C //CONSTANTE DEMURRAGE/DESPATCH/NO DEMURRAGE OU NO DESPATCH
                                       
                                       nDemuDespC:=((EG0->EG0_PARC_C/EG0->EG0_CARGO)*EG0->EG0_VALPRO)/EG0->EG0_PARC_C //CONSTANTE DEMURRAGE/DESPATCH/NO DEMURRAGE OU NO DESPATCH
                                       nOwDem     := Iif( EG0->EG0_OW_TP == "1",  EG0->EG0_OW_VL, 0 )
                                       nParcDem   := Iif( EG0->EG0_CLASSI == "1", ( (EG0->EG0_PARC_C / EG0->EG0_CARGO) * EG0->EG0_VALPRO ), 0)
                                       nDemMedPrt := ( nParcDem / EG0->EG0_PARC_C )
                                       nOwDes     := Iif( EG0->EG0_OW_TP == "2",  EG0->EG0_OW_VL, 0 )
                                       nParcDes   := Iif( EG0->EG0_CLASSI == "2", ( (EG0->EG0_PARC_C / EG0->EG0_CARGO) * EG0->EG0_VALPRO ), 0)
                                       nDesMedPrt := ( nParcDes / EG0->EG0_PARC_C)
                                       
                                       If mv_par11==1  //caso destino seja impressora - Alcir 25-11-04
//                                        @ nLin,0 PSAY + &(aDriver[3]) //caracter comprimido
                                          @ nLin, nCol06 PSay EG0->EG0_BERT
                                          @ nLin, nCol07 PSay Transform( EG0->EG0_PARC_C, "@E 999,999,999.99999")
                                          @ nLin, ncol08 PSay EG0->EG0_MOEDA
                                          @ nLin, nCol09 PSay Transform( nOwDem, "@E 99,999,999,999.99")
                                          @ nLin, nCol10 PSay Transform( ( nOwDem / EG0->EG0_PARC_C ), "@E 9999.99" )
                                          @ nLin, nCol11 PSay Transform( nParcDem, "@E 99,999,999,999.99")
                                          @ nLin, nCol12 PSay Transform( (nParcDem / EG0_PARC_C ), "@E 9999.99")
                                          @ nLin, nCol13 PSay Transform( nOwDes, "@E 99,999,999,999.99")
                                          @ nLin, nCol14 PSay Transform( ( nOwDes / EG0_PARC_C ), "@E 9999.99")
                                          @ nLin, nCol15 PSay Transform( nParcDes, "@E 99,999,999,999.99")
                                          @ nLin, nCol16 PSay Transform( ( nParcDes / EG0_PARC_C), "@E 9999.99")
                                       Else
                                          nDias := EG0->EG0_TEMPO
                                       EndIf
                                       
                                       nPos  := AScan(aMoedas, {|x| x[2] == EG0->EG0_MOEDA} )
                                       
                                       If !lLoop   // Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	
                                                   // ACSJ - 27/05/2004
                                          nPos2 := AScan(aPortos, {|x| x[2] == EG0->EG0_MOEDA + " - " + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST)} )
                                       EndIf
                                       
                                       If nPos == 0 // Não existe esta moeda no array aMoedas
                                          //               1         2              3        4        5      6
                                          aAdd( aMoedas, { "", EG0->EG0_MOEDA,    nOwDem, nParcDem, nOwDes, nParcDes} )
                                       Else
                                          aMoedas[nPos,3] += nOwDem
                                          aMoedas[nPos,4] += nParcDem
                                          aMoedas[nPos,5] += nOwDes
                                          aMoedas[nPos,6] += nParcDes
                                       EndIf
                                       
                                       If !lLoop //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	
                             			             // ACSJ - 27/05/2004
                                          If nPos2 == 0 // Não existe esta moeda no array aPortos 
                                             aAdd( aPortos, {"",EG0->EG0_MOEDA + " - " + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST), nDemMedPrt, nDesMedPrt} )
                                          Else
                                             aPortos[nPos2,3] += nDemMedPrt
                                             aPortos[nPos2,4] += nDesMedPrt
                                          EndIf
                                       EndIf
                                       
                                       // AAF 28/05/04 - Posição da moeda e do porto nos arrays
                                       nPosForn  := AScan(aMoedasForn, {|x| x[1] == EG0->EG0_FORNEC .AND. x[2] == EG0->EG0_MOEDA } )
                                       If lFiltraFil
                                          nPosFornFil  := AScan(aMoeFornFil, {|x| x[1] == EG0->EG0_FORNEC .AND. x[2] == EG0->EG0_MOEDA } )
                                          nPosPortFil  := AScan(aPortFil   , {|x| x[1] == EG0->EG0_FORNEC .AND. x[2] == EG0->EG0_MOEDA + " - " + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST)} )
                                       EndIf
                                       nPosForn2 := AScan(aPortosForn, {|x| x[1] == EG0->EG0_FORNEC .AND. x[2] == EG0->EG0_MOEDA + " - " + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST)} )
                                       
                                       // AAF 28/05/04 - Total por fornecedor e moeda                                    
                                       If nPosForn == 0 // Não existe esta moeda no array aMoedasForn
                                          //                       1                                                       2        3        4        5    
                                          aAdd( aMoedasForn, {EG0->EG0_FORNEC, EG0->EG0_MOEDA, nOwDem, nParcDem, nOwDes, nParcDes} )
                                       Else
                                          aMoedasForn[nPosForn,3] += nOwDem
                                          aMoedasForn[nPosForn,4] += nParcDem
                                          aMoedasForn[nPosForn,5] += nOwDes
                                          aMoedasForn[nPosForn,6] += nParcDes
                                       EndIf
                                       
                                       If lFiltraFil
                                          If nPosFornFil == 0 // Não existe esta moeda no array aMoedasForn
                                             //                        1                    2        3        4        5       6
                                             aAdd( aMoeFornFil , {EG0->EG0_FORNEC, EG0->EG0_MOEDA, nOwDem, nParcDem, nOwDes, nParcDes} )
                                          Else
                                             aMoeFornFil[nPosFornFil,3] += nOwDem
                                             aMoeFornFil[nPosFornFil,4] += nParcDem
                                             aMoeFornFil[nPosFornFil,5] += nOwDes
                                             aMoeFornFil[nPosFornFil,6] += nParcDes
                                          EndIf
                                          
                                          If nPosPortFil == 0 // Não existe esta moeda no array aPortosForn
                                             aAdd( aPortFil , {EG0->EG0_FORNEC , EG0->EG0_MOEDA + " - " + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST), nDemMedPrt, nDesMedPrt} )
                                          Else
                                             aPortFil[nPosPortFil,3] += nDemMedPrt
                                             aPortFil[nPosPortFil,4] += nDesMedPrt
                                          EndIf
                                          
                                       EndIf  
                                       
                                       // AAF 28/05/04 - Total por fornecedor, porto e moeda                                                                        
                                       If nPosForn2 == 0 // Não existe esta moeda no array aPortosForn
                                          aAdd( aPortosForn, {EG0->EG0_FORNEC , EG0->EG0_MOEDA + " - " + iif(nModulo == 17, SW6->W6_DEST, EEC->EEC_DEST), nDemMedPrt, nDesMedPrt} )
                                       Else
                                          aPortosForn[nPosForn2,3] += nDemMedPrt
                                          aPortosForn[nPosForn2,4] += nDesMedPrt
                                       EndIf
                                       
                                       lPriVez := .F.
                                    EndIf
                                    
                                    If cEmbOld <> EG1->EG1_EMBARQ
                                       cEmbOld := EG1->EG1_EMBARQ
                                       If !lPriVez
                                          nLin += 2
                                          If mv_par10==2 .and. mv_par11==1  //caso destino seja impressora - Alcir 25-11-04
                                             @ nLin, 000    PSay " "
                                             @ nLin, nCol04 PSay If(lMultiFIl .and. !Empty(EG1->EG1_FILORI) , + AvgFilName({EG1->EG1_FILORI})[1] + " - ","") + EG1->EG1_EMBARQ
                                             nLin ++
                                          EndIf
                                       EndIf
                                    EndIf
                                    
                                    If !lLoop .AND. mv_par10==2  //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1
                                     			                    // ACSJ - 27/05/2004
                                        
                                       // Alterado a pedido da trevo - ACSJ - 15/03/2004                         
                                       If lExistDm 
                                          cCodI := EG1->EG1_COD_I
                                       Else
                                          If nModulo == 17       //IMPORTACAO
                                             cCodI := SW8->W8_COD_I 
                                          ElseIf nModulo == 29   // EXPORTACAO
                                             cCodI :=  EE9->EE9_COD_I
                                          EndIf
                                       EndIf
                                       
                                       SB1->( dbSetOrder(1) )
                                       SB1->( dbSeek(xFilial("SB1")+AVKEY(cCodI,"B1_COD")) )
                                       cCodI += " - " + SubStr(SB1->B1_DESC,1,31)
                                       nQTDE := 0
                                       Sufixo_N := ""
                                       
                                       If lExistDm //Alcir - 22-11-04
                                          nQTDE := EG1->EG1_QTDMT
                                       Else
                                          If nModulo == 17       // IMPORTACAO
                                             SAH->( dbSeek(cFilSAH+AVKey(SW8->W8_UNID,"AH_UNIMED")) )
                                             
                                             If SAH->AH_COD_SIS = '21'     // Toneladas
                                                nQTDE := SW8->W8_QTDE
                                             ElseIf SAH->AH_COD_SIS = '10' // Kg
                                                nQTDE := SW8->W8_QTDE/ 1000    
                                             ElseIf SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM)) .And. SW7->W7_PESO # 0
                                                nQTDE := (SW7->W7_PESO * SW8->W8_QTDE) / 1000
                                             Else
                                                nPesoL := B1Peso(SW8->W8_CC, SW8->W8_SI_NUM, SW8->W8_COD_I, SW8->W8_REG, SW8->W8_FABR, SW8->W8_FORN)
                                                If nPesoL # 0
                                                   nQTDE := (nPesoL * SW8->W8_QTDE) / 1000
                                                Else
                                                   nQTDE := AVTransUnid(SW8->W8_UNID, "MT", SW8->W8_COD_I,SW8->W8_QTDE)   
                                                EndIf
                                             EndIf
                                          ElseIf nModulo == 29   // EXPORTACAO
                                             SB1->( dbSetOrder(1) )
                                             SB1->( dbSeek(xFilial("SB1")+EE9->EE9_COD_I) )
                                             cUnidade := EE9->EE9_UNIDAD
                                             
                                             If(Empty(cUnidade),cUnidade:=EEC->EEC_UNIDAD,)
                                             If(Empty(cUnidade),cUnidade:=EE9->EE9_UNPRC ,)
                                             If(Empty(cUnidade),cUnidade:=EE9->EE9_UNPES ,)
                                             If(Empty(cUnidade),cUnidade:=SB1->B1_UM     ,)
                                             
                                             SAH->( dbSeek(cFilSAH+AVKey(cUnidade,"AH_UNIMED")) )
                                             
                                             If SAH->AH_COD_SIS = '21'     // Toneladas
                                                nQTDE := EE9->EE9_SLDINI
                                             ElseIf SAH->AH_COD_SIS = '10' // Kg
                                                nQTDE :=EE9->EE9_SLDINI / 1000
                                             Elseif .not. Empty(EE9->EE9_PSBRTO)
                                                nQTDE := EE9->EE9_PSBRTO / 1000
                                             Else
                                                If SB1->B1_PESO # 0
                                                   nQTDE := SB1->B1_PESO * EE9->EE9_SLDINI / 1000
                                                Else
                                                   nQTDE := AVTransUnid(cUnidade, "MT", EE9->EE9_COD_I, EE9->EE9_SLDINI, .t.)   
                                                EndIf
                                             EndIf
                                          EndIf
                                       EndIf
                                       Tot_embarque:=Tot_embarque+(nDemuDespC*nQTDE)
                                       
                                       //ALCIR - 25-11-04 / TRATAMENTO DE DEMURRAGE/DESPATCH POR ITEM
                                       If mv_par11==2
                                          
                                          dbSelectArea("WORK2")
                                          
                                          RecLock("WORK2",.T.)
                                          
                                          WORK2->WK_NAVIO  := EG0->EG0_NAVIO
                                          WORK2->WK_VIAGEM := EG0->EG0_VIAGEM
                                          WORK2->WK_PORTO  := porto_n
                                          WORK2->WK_FORNEC := cFornec
                                          WORK2->WK_DIA    := nDias  //EG0->EG0_TEMPO //AAF 02/12/04
                                          WORK2->WK_EMBARQ := EG1->EG1_EMBARQ
                                          WORK2->WK_OPER_DT:= EG0->EG0_BERT
                                          WORK2->WK_MOEDA  := EG0->EG0_MOEDA 
                                          WORK2->WK_QTTY   := EG0->EG0_PARC_C
                                          WORK2->WK_QTTYIT := nQTDE //AAF 02/12/04 - Quantidade por item
                                          WORK2->WK_PROD   := cCodI
                                          WORK2->WK_PROD_D := nDemuDespC * nQTDE
                                          WORK2->WK_TIPO   := If(EG0->EG0_CLASSI == "1","DEMURRAGE","DESPATCH")
                                          
                                          WORK2->( MsUnLock() )
                                          
                                       EndIf                                      
                                       
                                       //ALCIR - 19-11-04 / TRATAMENTO DE DEMURRAGE/DESPATCH POR ITEM
                                       If mv_par10==2 .and. mv_par11==1  //caso destino seja impressora - Alcir 25-11-04
                                          @ nLin,nCol02 PSay cCodI
                                          @ nLin,nCol07 PSay TransForm(nQTDE,"@E 999,999,999.99999")
                                          @ nLin,If(EG0->EG0_CLASSI == "1",ncol11,ncol15) PSay TransForm(nDemuDespC*nQTDE,"@E 99,999,999,999.99")
                                          //"DEMURRAGE" "DESPATCH"
                                          nLin ++
                                       EndIf
                                    EndIf
                                 EndIf
                              EndIf
                           EndIf
                        EndIf          
                     EndIf
                  EndIf                
               
                  If !lLoop   //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	
                              // ACSJ - 27/05/2004
                     
                     //Alcir - 22-11-04
                     If lExistDm
                        EG1->( dbSkip() )
                     Else
                        If nModulo == 17
                           SW8->( dbSkip() )
                        ElseIf nModulo == 29
                           EE9->( dbSkip() )
   			            EndIf
   			         EndIf
                  Else
                     cCond := ".F."
                  Endif
               
               EndDo
               
               //Alcir - 22-11-04 
               //Total por embarque
               //@ nLin,(nCol03 + 52) psay transform(Tot_embarque,"@E 999,999,999.99999") //+" "+EG0->EG0_MOEDA+"*"+STR0150 
               //nLin ++                
               //If mv_par10==2
                  //nLin ++                                                                                                                              
               //EndIf
               
               If !lLoop  //Alteração para sair no relatório(RD150RELIMP) sem dados no EG1	
                          // ACSJ - 27/05/2004
                  If !lExistDm
                     EG1->( dbSkip() )
                  EndIf
               Else
                  lLoop := .f.
               EndIf
               
            EndDo
         EndIf
      EndIf
      
      If lImpr .AND. mv_par11 == 1  //caso destino seja impressora - Alcir 25-11-04
         nLin ++
         @ nLin, 00 PSay __PrtFatline()
         nLin ++
      EndIf
      cUltimoForn := EG0->EG0_FORNEC // AAF 28/05/04 - Guarda o ultimo fornecedor
      EG0->( dbSkip() )
   EndDo
   
   If lFiltraFIl .AND. mv_par11 == 1  //caso destino seja impressora
      @ nLin,95 PSay  STR0032 //"BRANCH'S AVERAGE BY MONEY"
      RD150RELMoe(aMoeFornFil,aPortFil)
      aMoeFornFil := {}
      aPortFil    := {}
      nLin ++
   EndIf
Next nFil

//Alcir - 25-11-04
If mv_par11 == 2 //caso seja excel
   OpenExcel(aData,"WORK2",.T.)
   WORK2->( dbCloseArea() )
   E_EraseArq(WorkFile)//AAF 02/12/04 - Exclusão da Work
Else
   //AAF 28/05/04 - Imprime a média por Fornecedor
   If nLin < 99 //LRL 03/06/04 - Se algo foi Impresso
      nLin++
      nForneCont++
      
      //@ nLin, 00 PSay __PrtFatline()                                                                          
      If mv_par11==1  //caso destino seja impressora - Alcir 25-11-04
         @ nLin,96 PSay STR0006 //"SUPPLIER'S AVERAGE BY MONEY"
      EndIf
      
      RD150RELMOE(aMoedasForn,aPortosForn)
      aMoedasForn := {}
      aPortosForn := {}     
      If nForneCont > 1
         RD150RELCAB()
         nLin := 10
         
         If mv_par11==1  //caso destino seja impressora - Alcir 25-11-04
            @ nLin,99 PSay STR0011//"GENERAL AVERAGE BY MONEY"
         EndIf
         
         RD150RELMOE(aMoedas)
         RD150RELPOR(aPortos)
      EndIf
   EndIf
EndIf

MS_FLUSH() // Alcir -07-12-04
lPrtVz  := .T.
cFilAnt := cxFil
EG0->( dbSetOrder(1) ) //AAF 28/05/04

Return .T.

// ----------------------------------
// Imprime a média por Moeda
Function DM400RELFIL(aMoedas)
// ----------------------------------
Local i
For i:= 1 to Len(aMoedas)           
   
   nLin += 2

   If nLin + 10 > 60
      RD150RELCAB()
      nLin := 7
   Endif

   @ nLin, 79     PSay STR0012 + aMoedas[i,1] + " ===========>" //"TOTAL "
   @ nLin, nCol09 PSay Transform( aMoedas[i,2], "@E 99,999,999,999.99" )  // nOwDemTot 
   @ nLin, nCol11 PSay Transform( aMoedas[i,3], "@E 99,999,999,999.99" )  // nParDemTot
   @ nLin, nCol13 PSay Transform( aMoedas[i,4], "@E 99,999,999,999.99" )  // nOwDesTot
   @ nLin, ncol15 PSay Transform( aMoedas[i,5], "@E 99,999,999,999.99" )  // nParDesTot
    
   nLin += 2
   
   nTotOwne	:= ( aMoedas[i,2] - aMoedas[i,4] )
   nTotParc	:= ( aMoedas[i,3] - aMoedas[i,5] )
   nTotDiff	:= (( aMoedas[i,2] - aMoedas[i,4] ) - ( aMoedas[i,3] - aMoedas[i,5] )) 
   
   if nTotOwne == 0
      cTitTot  := STR0013 //" No Demurrage/No Despatch"
   Elseif nTotOwne > 0
      cTitTot  := STR0014 //" Demurrage"               
   Elseif nTotOwne < 0
      cTitTot  := STR0015 // " Despatch"
   Endif
     
   @ nLin, 79     PSay STR0016 + aMoedas[i,1] + " ==========>"  //"OWNERS "
   @ nLin, nCol09 PSay Transform( Abs(nTotOwne), "@E 99,999,999,999.99" ) + cTitTot // nOwDemTot - nOwDesTot 

   nLin += 2
   
   if nTotParc == 0
      cTitTot  := STR0013 //" No Demurrage/No Despatch"
   Elseif nTotParc > 0
      cTitTot  := STR0014 //" Demurrage"               
   Elseif nTotParc < 0
      cTitTot  := STR0015 // " Despatch"
   Endif
      
   @ nLin, 79     PSay STR0017 + aMoedas[i,1] + " =========>" //"PARCEL  "
   @ nLin, nCol09 PSay Transform( Abs(nTotParc), "@E 99,999,999,999.99" ) + cTitTot // nParDemTot - nParDesTot

   nLin += 2

   @ nLin, 79     PSay STR0018 + aMoedas[i,1] + " ======>" //"Difference "     
   @ nLin, nCol09 PSay Transform( Abs(nTotDiff) , "@E 99,999,999,999.99" )  // ( nOwDemTot - nOwDesTot ) - ( nParDemTot - nParDesTot )
                                                                                  
   nLin ++
   @ nLin, 00 PSay __PrtFatline()   
Next

Return .T.

// ----------------------------------
// Imprime a média por Moeda
// AAF 28/05/04
Function RD150RELMOE(aMoedas,aPortos)
// ----------------------------------
Local i
Default aPortos := {}

For i:= 1 To Len(aMoedas)
   
   nLin += 2
   
   If nLin + 11 > 60
      RD150RELCAB()
      nLin := 9
   EndIf
   
   If !Empty(aMoedas[i,1])
      @ nLin ,79     PSay STR0032 + " ===========>" //"SUPPLIER"
      @ nLin, nCol09 PSay  Posicione("SA2",1,cFilSa2 + aMoedas[i,1],"A2_NREDUZ")
     nLin+=2
   EndIf
   
   @ nLin, 79     PSay STR0012 + aMoedas[i,2] + " ===========>" //"TOTAL "
   @ nLin, nCol09 PSay Transform( aMoedas[i,3], "@E 99,999,999,999.99" )  // nOwDemTot 
   @ nLin, nCol11 PSay Transform( aMoedas[i,4], "@E 99,999,999,999.99" )  // nParDemTot
   @ nLin, nCol13 PSay Transform( aMoedas[i,5], "@E 99,999,999,999.99" )  // nOwDesTot
   @ nLin, ncol15 PSay Transform( aMoedas[i,6], "@E 99,999,999,999.99" )  // nParDesTot
   
   nLin += 2
   
   nTotOwne	:= ( aMoedas[i,3] - aMoedas[i,5] )
   nTotParc	:= ( aMoedas[i,4] - aMoedas[i,6] )
   nTotDiff	:= (( aMoedas[i,3] - aMoedas[i,5] ) - ( aMoedas[i,4] - aMoedas[i,6] ))
   
   If nTotOwne == 0
      cTitTot  := STR0013 //" No Demurrage/No Despatch"
   ElseIf nTotOwne > 0
      cTitTot  := STR0014 //" Demurrage"
   ElseIf nTotOwne < 0
      cTitTot  := STR0015 // " Despatch"
   EndIf
   
   @ nLin, 79     PSay STR0016 + aMoedas[i,2] + " ==========>"  //"OWNERS "
   @ nLin, nCol09 PSay Transform( Abs(nTotOwne), "@E 99,999,999,999.99" ) + cTitTot // nOwDemTot - nOwDesTot
   
   nLin += 2
   
   If nTotParc == 0
      cTitTot  := STR0013 //" No Demurrage/No Despatch"
   ElseIf nTotParc > 0
      cTitTot  := STR0014 //" Demurrage"               
   ElseIf nTotParc < 0
      cTitTot  := STR0015 // " Despatch"
   EndIf
   
   @ nLin, 79     PSay STR0017 + aMoedas[i,2] + " =========>" //"PARCEL  "
   @ nLin, nCol09 PSay Transform( Abs(nTotParc), "@E 99,999,999,999.99" ) + cTitTot // nParDemTot - nParDesTot
   
   nLin += 2
   
   @ nLin, 79     PSay STR0018 + aMoedas[i,2] + " ======>" //"Difference "
   @ nLin, nCol09 PSay Transform( Abs(nTotDiff) , "@E 99,999,999,999.99" )  // ( nOwDemTot - nOwDesTot ) - ( nParDemTot - nParDesTot )
                                                                                     
   nLin ++
   @ nLin, 00 PSay __PrtFatline()
   If Len(aPortos) > 0
      nLin ++
      RD150RELPOR(aPortos,aMoedas[i,1])
   EndIf
   
Next

Return .T.

// ----------------------------------
// Imprime a média por Porto e Moeda
// AAF 28/05/04
Function RD150RELPOR(aPortos,cForn)
// ----------------------------------
Local i
Default cForn := ""

For i := 1 To Len(aPortos)
   If Empty(cForn) .Or. cForn == aPortos[i,1]
      SY9->( dbSetOrder(2) )
      SY9->( dbSeek(cFilSY9+SubStr(aPortos[i,2],7,3)) )
      
      If nLin + 4 > 66
         RD150RELCAB()
         nLin := 9
      EndIf
      
      If aPortos[i,3] > aPortos[i,4]
         nLin += 2
         If i = 1 .OR. lPrtVz
            @ nLin,102 PSay STR0019 //" PORT'S AVERAGE"
            nLin   += 2
            lPrtVz := .F.
         EndIf
         @ nLin, 79           PSay Substr(aPortos[i,2],7,3) + " " + SY9->Y9_DESCR
         @ nLin, (nCol09 - 4) PSay Substr(aPortos[i,2],1,3) + " " +;
                              Transform( Abs(aPortos[i,3] - aPortos[i,4]) , "@E 99,999,999,999.99" ) + STR0014 // " Demurrage"
      EndIf
      
      If aPortos[i,3] < aPortos[i,4]
         nLin += 2
         If i = 1 .OR. lPrtVz
            @ nLin,102 PSay STR0019 //" PORT'S AVERAGE"
            nLin   += 2
            lPrtVz := .F.
         EndIf
         @ nLin, 79           PSay SubStr(aPortos[i,2],7,3) + " " + SY9->Y9_DESCR
         @ nLin, (nCol09 - 4) PSay SubStr(aPortos[i,2],1,3) + " " +;
                              Transform( Abs(aPortos[i,4] - aPortos[i,3]) , "@E 99,999,999,999.99" ) + STR0015 //" Despatch"
      EndIf
   EndIf
Next

If .not. lPrtVz
   nLin ++
   @ nLin, 00 PSay __PrtFatline()
EndIf

For i := 1 To Len(aMensagem)
   
   If nLin > 66
      RD150RELCAB()
      nLin := 10
   EndIf
   
   @nLin, 00 PSay aMensagem[i]
   nLin ++
   
Next

Return .T.

// ----------------------------------
// Cabeçalho do Relatorio           
// ACSJ - 27 de Janeiro de 2004
Function RD150RELCAB()
// ---------------------------------- 
//LOCAL nCol
//LOCAL cTitPag 
//LOCAL cTitEmi := STR0108 + DtoC(dDataBase) //"Date: "
LOCAL cTit1   := STR0020 //"DEMURRAGE/DESPATCH ACCOUNTS"
LOCAL cTit2  

Begin Sequence

   //RMD 21/07/08 - Só executa a função caso esteja na opção de IMPRESSÃO
   If MV_PAR11 == 2//Excel
      Break
   EndIf

   If mv_par01 == 1
      cTit2 := STR0021 //"Paid Processes "
   ElseIf mv_par01 == 2
      cTit2 := STR0022//"Pending Processes"
   Else                              
      cTit2 := " "
   EndIf

   // nPagina ++    
   M_pag++
   Last_lin:=Cabec(cTit1,cTit2,"","Rel_demurrage","G")
   //if mv_par11==1  //caso destino seja impressora //Alcir - 06-12-04

   //endif

   //cTitPag := STR0112 + Strzero(nPagina,4,0) //"Page "




   //@ 00, 00   PSay __PrtFatline()
   //nCol := 0
   //@ 01, nCol PSay cTitEmi
   //nCol := ( ( 220 - Len(cTit1) ) / 2) 
   //@ 01, nCol PSay cTit1
   //nCol := ( 220 - ( Len(cTitPag) + 1 ) )
   //@ 01, nCol PSay cTitPag
   
   //nCol := ( ( 220 - Len(cTit2) ) / 2) 
   //@ 02, nCol PSay cTit2                 
   
   @ Last_lin, 00 PSay __PrtFatline()
   
   
   /*   Alterado a pedido da trevo - ACSJ - 15/03/2004
   //COL DE 10 EM 10        1         2         3         4         5         6         7         8         9         100       1         2         3         4         5          6         7         8         9        200       1         2  
   //COL A COL    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234056789012345678901234567890123456789012345679012345678901234567890
   //NUMERO DAS COLUNAS   1            2      3                  4                      5              6                7          8           9             10          11            12          13          14             15
   @ 04, 00 PSay "      VESSEL0      VIAGEM   PORT              O/REF.                PRODUCT     OPERAT. DATE         QTTY       COIN    OWNERS DEMUR    VAL./MT    PARCELA DEMUR  VAL./MT    OWNERS DESP    VAL./MT    PARCELA DESP   VAL./MT"  
   //DADOS        123456789012345 1234567890 123  123456789012345678901234567890 123456789012345    10/10/10   999,999,999.99999  US$  99,999,999,999.99 9999.99 99,999,999,999.99 9999.99 99,999,999,999.99 9999.99 99,999,999,999.99 9999.99
   ------------------------------------------------- */
   //COL DE 10 EM 10        1         2         3         4         5         6         7         8         9         100       1         2         3         4         5          6         7         8         9        200       1         2  
   //COL A COL    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234056789012345678901234567890123456789012345679012345678901234567890
   //             VESSEL: 123456789012345   VIAGEM: 1234567890   PORT: 123
   //NUMERO DAS COLUNAS          4                                 5                                      6              7           8           9           10           11           12            13          14            15          16
   Last_lin ++
   @ Last_lin, 00 PSay cHeader
   //              123456789012345678901234567890 123456789012345 - 123456789012345678901234567890   10/10/10   999,999,999.99999  US$ 99,999,999,999.99 9999.99 99,999,999,999.99 9999.99 99,999,999,999.99 9999.99 99,999,999,999.99 9999.99                
   Last_lin ++
   @ Last_lin, 00 PSay __PrtFatline()

End Sequence
            
Return .T.

************************************************************************
STATIC FUNCTION OpenExcel(aEstru,WORKPA,lExcel,cDirDocs,cPath)
************************************************************************
Local cArquivo := CriaTrab(,.F.)
Local oExcelApp,i
Local cArqRD150
if cDirDocs == nil
	cDirDocs := MsDocPath()
endif
if cPath == nil
	cPath := AllTrim(GetTempPath())
endif
if lExcel == nil
	lExcel := .F.
endif

cArqRD150 := E_CriaTrab(,aEstru, cArquivo) //THTS - 28/09/2017 - TE-6431 - Temporario no Banco de Dados

(WORKPA)->( DbGoTop() )
DO WHILE !(WORKPA)->( EOF() )
	(cArquivo)->( DbAppend() )
	for i:= 1 to (cArquivo)->( FCount() )
		(cArquivo)->( FieldPut( i,(WORKPA)->(FieldGet(i)) ) )
	next
	(WORKPA)->( DbSkip() )
EndDo

if lExcel
   (cArquivo)->( dbCloseArea() )
	CpyS2T( cDirDocs+"\"+cArquivo+".DBF" , cPath, .T. )
	
	If ! ApOleClient( 'MsExcel' )
		MsgStop(STR0028)//"MsExcel não instalado."
		RETURN .F.
	else	
		oExcelApp:= MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".dbf" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	EndIf
else
	TR350ARQUIVO(cArquivo)
   (cArquivo)->( dbCloseArea() )
endif

RETURN .T.
