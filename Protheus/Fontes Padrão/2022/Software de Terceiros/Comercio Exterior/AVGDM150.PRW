#INCLUDE "AVGDM150.ch"
#INCLUDE "average.ch"       
#INCLUDE 'font.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'avprint.ch'

/*
Função   : AVGDM150
Objetivo : Gerar relatorio de demurrage por porto
Data     : 29/11/04
Autor    : Lucas Rolim Rosa Lopes
*/
*-------------------*
Function AVGDM150()
*-------------------*
Local oDlg, oCmbO
Local lOk := .f.
Local cPerg
Private cNomArq
Private dDt_Inicio := dDt_Fim := cTod("")
Private cEmb   := CRIAVAR("EG1_EMBARQ")
Private cDest  := CRIAVAR("EG0_DEST")
Private cNavio := CRIAVAR("EG0_NAVIO")
Private cTipo  := CRIAVAR("EG0_CLASSI")
Private aHeader[0],aCampos:={}, TB_Campos := {}
Private cFilEG0 := xFilial("EG0") , cFilEG1 := xFilial("EG1") , cFilEG2 := xFilial("EG2")
Private cFilSW6 := xFilial("SW6") , cFilSW8 := xFilial("SW8")
//Private cFilEEC := xFilial("EEC") , cFilEE9 := xFilial("EE9")
Private cFilSAH := xFilial("SAH") , cFilSW7 := xFilial("SW7"), cFilSB1 := xFilial("SB1"), cFilEEC := xFilial("EEC"), cFilEE9 := xFilial("EE9")
Private cPicQTD := "@E 999,999,999.99999" //Alcir - 02-12-04
PRIVATE lExistDM := if (EG0->( FieldPos( "EG0_DEMURR" ) ) > 0 .AND. EG1->( FieldPos( "EG1_DEMURR" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_NRINVO" ) ) > 0 .AND. EG1->( FieldPos( "EG1_PEDIDO" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_SEQUEN" ) ) > 0 .AND. EG1->( FieldPos( "EG1_COD_I" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_QTDUC" ) ) > 0  .AND. EG1->( FieldPos( "EG1_QTDMT" ) ) > 0 ;
        .AND. EG1->( FieldPos( "EG1_UNMED" ) ) > 0  .AND. EG1->( FieldPos( "EG1_COEF" ) ) > 0 ;
        .AND. EG2->( FieldPos( "EG2_DEMURR" ) ) > 0  ,.T.,.F.)

CriaWork()
If nModulo == 17
   cPerg:= "DM150I"
Else               
   cPerg:= "DM150E"
EndIF             

IF Pergunte(cPerg,.T.)

   cEmb       := mv_par01
   cDest      := mv_par02
   cNavio     := mv_par03
   nTipo      := mv_par04
   dDt_Inicio := mv_par05
   dDt_Fim    := mv_par06
   nSaida     := mv_par07
  MsAguarde({|| GrvWork()}, STR0001)  //"Aguarde... Lendo Dados do Arquivo..."
  If WORK->(!BOF()) .AND. WORK->(!EOF())
    If nSaida == 1
       Imprime() 
    ElseIf nSaida == 2
       Exporta(.F.)
    Else
       Exporta(.T.)
    EndIF
  Else
     MsgInfo(STR0002, STR0026) //"Não foram encontrados registros para imprimir."###"Atenção"
  EndIF  
EndIF   
If Select("WORK") <> 0
   WORK->(dbCloseArea())
EndIf   
   FErase(cNomArq)
Return .T.

*--------------------------------*
FUNCTION Imprime()
*--------------------------------*                                  
Local aRelat:= {}                                
Private aRCampos:={}, aDados
Private lPVez :=.T.
Private nQTD := nDes := nDem := nDias:= nNavio :=  0
Private nQtdTot := nDesTot := nDemTot  := 0
Private Linha
Private aNavio :={}
cNavio := cPorto := ""
aRCampos:={}
aDados :={"WORK",; 
           STR0003,;  //"Este Relatorio irá imprimir "
           STR0004,;  //"o total de demurrage/despatch por porto"
           "",;
           "G",;
           220,;
           "",;
           "",;
           STR0005,;  //"Relatório - Demurrage/Despatch por porto"
           {"ZEBRADO", 1, "IMPORTAÇÃO" , 2, 2, 1, "",1 },; 
           "AVGDM150",;
           { {|| GrvTotal()      } , { || GrvTotal()      }  }  } 
                                
WORK->(DbGotop())                                                                                 
If lExistDm
  AADD(TB_Campos,{{ ||Transf(Work->DEMURRAGE , AVSX3("EG0_DEMURR", 06)) }  , "", STR0025     } )  //"Cod. Demurrage"
EndIf
AADD(TB_Campos,{{ ||Transf(Work->EMBARQUE , AVSX3("EG1_EMBARQ", 06)) }  , "", STR0006     } )   //"Embarque"
AADD(TB_Campos,{{ ||Transf(Work->NAVIO    , AVSX3("EG1_NAVIO" , 06)) }  , "", STR0007  } )  //"Navio"
AADD(TB_Campos,{{ ||Transf(Work->DATABL   , IF(NmODULO ==17 ,AVSX3("W6_DT_EMB"  , 06),AVSX3("EEC_DTCONH", 06)))  }  , "", STR0008} )  //"DATA BL"
AADD(TB_Campos,{{ ||Transf(Work->QTDMT, cPIcQTD) }  , "", STR0009 } )  //"Quantidade MT"
AADD(TB_Campos,{{ ||Transf(Work->DEMURR   , AVSX3("EG0_DEM_V" , 06) )  }  , "", STR0010          } )  //"Demurrage"
AADD(TB_Campos,{{ ||Transf(Work->DESPATCH , AVSX3("EG0_DEM_V" , 06))  }  , "", STR0011       } )  //"Despatch"
AADD(TB_Campos,{{ ||Transf(Work->TIMELS , AVSX3("EG0_TEMPO" , 06))  }  , "", STR0012        } ) //"Dias L/S"

aRCampos:= E_CriaRCampos(TB_Campos,"C")
aDados[7]:= STR0013+DTOC(dDt_Inicio)+STR0014+DTOC(dDt_Fim)  //"Período de "###" ate "
E_Report(aDados,aRCampos)


Return .T.

*----------------------------*
Function CriaWork() 
*----------------------------*
aEstru := {}

AADD(aEstru,{ "PORT"       , AVSX3("EG1_DEST " , 02), AVSX3("EG1_DEST " , 03), AVSX3("EG1_DEST " , 04)}) 
AADD(aEstru,{ "EMBARQUE"   , AVSX3("EG1_EMBARQ", 02), AVSX3("EG1_EMBARQ", 03), AVSX3("EG1_EMBARQ", 04)})
AADD(aEstru,{ "NAVIO"      , AVSX3("EG1_NAVIO" , 02), AVSX3("EG1_NAVIO" , 03), AVSX3("EG1_NAVIO" , 04)})
If nModulo == 17 //Importação
   AADD(aEstru,{ "DATABL"  , AVSX3("W6_DT_EMB"  , 02), AVSX3("W6_DT_EMB"  , 03), AVSX3("W6_DT_EMB" , 04)})
Else
   AADD(aEstru,{ "DATABL"  , AVSX3("EEC_DTCONH", 02), AVSX3("EEC_DTCONH", 03), AVSX3("EEC_DTCONH", 04)})
EndIf 
If lExistDm
   AADD(aEstru,{ "DEMURRAGE"     , AVSX3("EG0_DEMURR", 02), AVSX3("EG0_DEMURR", 03), AVSX3("EG0_DEMURR", 04)})
   AADD(aEstru,{ "QTDMT"      , AVSX3("EG1_QTDMT " , 02), AVSX3("EG1_QTDMT ", 03), AVSX3("EG1_QTDMT" , 04)})
Else                                                                                                        
   AADD(aEstru,{ "QTDMT"      , "N", 15, 5})
EndIf   
AADD(aEstru,{ "DEMURR"     , AVSX3("EG0_DEM_V" , 02), AVSX3("EG0_DEM_V" , 03), AVSX3("EG0_DEM_V" , 04)})
AADD(aEstru,{ "DESPATCH"   , AVSX3("EG0_DEM_V" , 02), AVSX3("EG0_DEM_V" , 03), AVSX3("EG0_DEM_V" , 04)})
AADD(aEstru,{ "TIMELS"     , AVSX3("EG0_TEMPO" , 02), AVSX3("EG0_TEMPO" , 03), AVSX3("EG0_TEMPO" , 04)})
cNomArq:=E_CriaTrab(,aEstru,"Work")
If lExistDm
   IndRegua("Work",cNomArq+TEOrdBagExt(),"PORT+DEMURRAGE+EMBARQUE+NAVIO+DTOS(DATABL)") 
Else
   IndRegua("Work",cNomArq+TEOrdBagExt(),"PORT+EMBARQUE+NAVIO+DTOS(DATABL)") 
EndIF
Return .T.                     

*----------------------------*
Function GrvWork()     
*----------------------------*   
Local cEmbOld := ""
Local nDemDes := nQtdMt := 0
Local nDemuDespC := 0
Local cPortOld                   
Local dDataBl
Local cNavioOld,cEmbArq
Local cUnidade
Local lAchou
Local lCalc := .F. 
If lExistDm
   EG1->(DbSetOrder(2))
Else                   
   EG1->(DbSetOrder(1))
EndIF  
EE9->(DbSetOrder(2))
SW7->(DbSetOrder(4))
DbSelectArea("EG0")
EG0->(DbSeek(cFilEG0+if(nModulo == 17,"I","E")))

//** AAF 22/02/05 - Ponto de Entrada para modificação dos campos a serem usados.
cDtBL := "SW6->W6_DT_EMB"

If EasyEntryPoint("AVGDM150")
   ExecBlock("AVGDM150",.F.,.F.,"ANTES_GERA_DADOS")
EndIf
//**

While EG0->(!EOF()) .AND. EG0->EG0_FILIAL == cFilEG0
   /*FILTROS--------------------------------------------------------------------------*/
   If !Empty(cNavio) .And. (EG0->EG0_NAVIO != cNAVIO)
      EG0->(DbSkip())
      Loop
   EndIf 
   If !Empty(cDest) .And. (EG0->EG0_DEST != cDest)
      EG0->(DbSkip())
      Loop
   EndIf 
   If nTipo != 3 .And. Val(EG0->EG0_CLASSI) != nTipo
      EG0->(DbSkip())
      Loop
   EndIf 
   /*--------------------------------------------------------------------------FILTROS*/
   If lExistDM
      lAchou := EG1->(DbSeek(cFilEG1+if(nModulo == 17,"I","E")+EG0->EG0_DEMURR))
   Else
      lAchou := EG1->(DbSeek(cFilEG1+if(nModulo == 17,"I","E")+EG0->EG0_NAVIO+EG0->EG0_VIAGEM+EG0->EG0_DEST))
   EndIf   
   nDemuDespC:=((EG0->EG0_PARC_C / EG0->EG0_CARGO) * EG0->EG0_VALPRO )/EG0->EG0_PARC_C
   cEmbOLD := EG1->EG1_EMBARQ
   While lAchou .AND. EG1->(!EOF()) .AND. EG1->EG1_FILIAL == cFilEG1 .AND. EG1->EG1_MODULO == if(nModulo == 17,"I","E") .AND.;
         if (lExistDM,Eval({|| EG0->EG0_DEMURR == EG1->EG1_DEMURR}),EVAL({ || EG0->EG0_NAVIO == EG1->EG1_NAVIO .AND. EG0->EG0_VIAGEM == EG1->EG1_VIAGEM .AND. EG0->EG0_DEST == EG1->EG1_DEST }))
       /*FILTROS--------------------------------------------------------------------------*/
      If !Empty(cEmb) .And. (EG1->EG1_EMBARQ != cEmb)
         EG1->(DbSkip())
         cEmbOLD := EG1->EG1_EMBARQ  
         Loop
      EndIf
      /*--------------------------------------------------------------------------FILTROS*/
      If cEmbOld != EG1->EG1_EMBARQ
         RecLock("Work",.T.)
         If lExistDm
            Work->DEMURRAGE := EG0->EG0_DEMURR
         EndIF
         Work->EMBARQUE := cEmbArq
         Work->NAVIO    := cNavioOld
         Work->DATABL   := dDataBl
         Work->PORT     := cPortOld
         Work->QTDMT    := nQtdMt
         If EG0->EG0_CLASSI == "1"
            Work->DEMURR  := nDemDes
            Work->TIMELS   := (If (EG0->EG0_DEM_TP == "2",EG0->EG0_TEMPO/24,EG0->EG0_TEMPO)* nQtdMt)/EG0->EG0_PARC_C
         ElseIf EG0->EG0_CLASSI == "2"
            Work->DESPATCH := nDemDes
            Work->TIMELS   := (If (EG0->EG0_DES_TP == "2",EG0->EG0_TEMPO/24,EG0->EG0_TEMPO)* nQtdMt)/EG0->EG0_PARC_C
         EndIf
         Work->(MsUnlock())
         nQtdMt :=0
         nDemDes:=0
         cEmbOLD := EG1->EG1_EMBARQ
         lCalc := .F.
      Endif
      
      If cEmbOLD == EG1->EG1_EMBARQ
         If nModulo == 17
            SW6->(DbSeek(cFilSW6+AvKey(EG1->EG1_EMBARQ,"W6_HAWB")))
            SW8->(DbSeek(cFilSW8+AvKey(EG1->EG1_EMBARQ,"W8_HAWB")))
            If (!Empty(dDt_Inicio) .OR. !Empty(dDt_FIM) ).And. (&(cDtBL) < dDt_Inicio .OR. &(cDtBL) > dDt_FIM )
               EG1->(DbSkip())
               cEmbOLD := EG1->EG1_EMBARQ
               Loop
            EndIf
            cEmbArq   := EG1->EG1_EMBARQ
            cNavioOld := EG1->EG1_NAVIO
            cPortOld   := SW6->W6_DEST
            dDataBl := &(cDtBL)
            If lExistDm
               nQTDE := EG1->EG1_QTDMT
            Else
               nQTDE:=0
               Do While SW8->(!EOF()) .AND. SW8->W8_FILIAL == cFilSW8 .AND. SW8->W8_HAWB == AvKey(EG1->EG1_EMBARQ,"W8_HAWB")
                  SAH->(DBSeek(cFilSAH+AVKey(SW8->W8_UNID,"AH_UNIMED")) )
                  If SAH->AH_COD_SIS = '21'     // Toneladas
                    nQTDE += SW8->W8_QTDE
                  ElseIf SAH->AH_COD_SIS = '10' // Kg
                    nQTDE += SW8->W8_QTDE/ 1000    
                  ElseIf SW7->(DbSeek(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM)) .And. SW7->W7_PESO # 0
                    nQTDE += (SW7->W7_PESO * SW8->W8_QTDE) / 1000
                  Else
                    nPesoL := B1Peso(SW8->W8_CC, SW8->W8_SI_NUM, SW8->W8_COD_I, SW8->W8_REG, SW8->W8_FABR, SW8->W8_FORN)
                    If nPesoL # 0
                       nQTDE += (nPesoL * SW8->W8_QTDE) / 1000
                    Else
                       nQTDE += AVTransUnid(SW8->W8_UNID, "MT", SW8->W8_COD_I,SW8->W8_QTDE)   
                    EndIf
                 EndIf
                 SW8->(DbSkip())
               EndDo  
            EndIF
         Else
            EEC->(DbSeek(cFilEEC+AvKey(EG1->EG1_EMBARQ,"EEC_PREEMB")))
            EE9->(DbSeek(cFilEE9+AvKey(EG1->EG1_EMBARQ,"EE9_PREEMB"))) 
            If (!Empty(dDt_Inicio) .OR. !Empty(dDt_FIM) ).And. (EEC->EEC_DTCONH < dDt_Inicio .OR.   EEC->EEC_DTCONH > dDt_FIM )
               EG1->(DbSkip())
               cEmbOLD := EG1->EG1_EMBARQ  
               Loop
            EndIf     
            cEmbArq   := EG1->EG1_EMBARQ  
            cNavioOld := EG1->EG1_NAVIO
            cPortOld   := EEC->EEC_DEST
            dDataBl := EEC->EEC_DTCONH
            If lExistDm 
              nQTDE := EG1->EG1_QTDMT
            Else
               nQTDE:=0
               Do While EE9->(!EOF()) .AND. EE9->EE9_FILIAL == cFilEE9 .AND. EE9->EE9_PREEMB == AvKey(EG1->EG1_EMBARQ,"EE9_PREEMB")
                  SB1->( DBSetOrder(1) )
                  SB1->( DBSeek( EE9->EE9_COD_I ) )
                 cUnidade:=EE9->EE9_UNIDAD
                 If(Empty(cUnidade),cUnidade:=EEC->EEC_UNIDAD,)
                 If(Empty(cUnidade),cUnidade:=EE9->EE9_UNPRC,)
                 If(Empty(cUnidade),cUnidade:=EE9->EE9_UNPES,)
                 If(Empty(cUnidade),cUnidade:=SB1->B1_UM,)
                 SAH->(DBSeek(cFilSAH+AVKey(cUnidade,"AH_UNIMED")) )                                    
                 If SAH->AH_COD_SIS = '21'     // Toneladas
                    nQTDE += EE9->EE9_SLDINI
                 ElseIf SAH->AH_COD_SIS = '10' // Kg
                    nQTDE +=EE9->EE9_SLDINI / 1000    
                 Elseif .not. Empty(EE9->EE9_PSBRTO)
                    nQTDE += EE9->EE9_PSBRTO / 1000
                 Else                  
                    If SB1->B1_PESO # 0
                       nQTDE += SB1->B1_PESO * EE9->EE9_SLDINI / 1000
                    Else
                       nQTDE += AVTransUnid(cUnidade, "MT", EE9->EE9_COD_I, EE9->EE9_SLDINI, .t.)   
                    EndIF
                 EndIf
                 EE9->(DbSkip())
              EndDo  
           EndIf
         EndIF 
         nQtdMt += nQtde
         nDemDes += nQtde * nDemuDespC
         lCalc := .T.        
      EndIF
   EG1->(DbSkip())
   EndDo
   If lCalc 
      RecLock("Work",.T.)
      If lExistDm
            Work->DEMURRAGE := EG0->EG0_DEMURR
      EndIF         
      Work->EMBARQUE := cEmbArq
      Work->NAVIO    := cNavioOld
      Work->DATABL   := dDataBl
      Work->PORT     := cPortOld
      Work->QTDMT    := nQtdMt
      If EG0->EG0_CLASSI == "1"
         Work->DEMURR  := nDemDes
         Work->TIMELS   := (If (EG0->EG0_DEM_TP == "2",EG0->EG0_TEMPO/24,EG0->EG0_TEMPO)* nQtdMt)/EG0->EG0_PARC_C
      ElseIf EG0->EG0_CLASSI == "2"
         Work->DESPATCH := nDemDes
         Work->TIMELS   := (If (EG0->EG0_DES_TP == "2",EG0->EG0_TEMPO/24,EG0->EG0_TEMPO)* nQtdMt)/EG0->EG0_PARC_C
      EndIf
      Work->(MsUnlock())                     
      nQtdMt :=0 
      nDemDes:=0
      lCalc := .F.
   EndIF   
EG0->(DbSkip())
EndDo

Return .T.


*--------------------------*                 
Static Function PulaLinha()           
*--------------------------*
IF Linha > 60                                                                  
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5])   
   Linha := 10
Else
   Linha++
Endif   

RETURN .T.                             

*-----------------------------*
Function GrvTotal()  
*-----------------------------*  
If  cPorto <> WORK->PORT
    If !lPVez                             
         PulaLinha()
         PulaLinha()                           
         @ Linha, 001 PSAY STR0015 //"Totais do porto :"
/*         PulaLinha()
         @ Linha, 000 PSAY "         10        20        30        40        50        60        70        80        90       100       110       120       130       140       150" 
         PulaLinha()
         @ Linha, 000 PSAY "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890" */
         PulaLinha()
         @ Linha, 001 PSAY STR0016 + TRANS(nQtD,cPicQTD ) //"Qtde (MT): "
         @ Linha, 031 PSAY STR0017 + TRANS(Abs(nDem -nDes), AVSX3("EG0_DEM_V" , 06)) //"Demurrage/Despatch : "
         @ Linha,074 PSAY STR0018+ TRANS(Abs(nDem -nDes)/nQtD, AVSX3("EG0_DEM_V" , 06)) //"Valor medio por tonelada : "
         @ Linha,124 PSAY STR0019+ TRANS(nDias, AVSX3("EG0_TEMPO",6,"EG0")) //"Dias : " //Alcir - 02-12-04
         @ Linha,144 PSAY STR0020 + ALLTRIM(STR(nNavio)) //"   Navios : "
         @ Linha,170 PSAY STR0021+ TRANS(Abs(nDem -nDes)/nNavio, AVSX3("EG0_DEM_V" , 06)) //"Average - Days "
         If WORK->(EOF())
            PulaLinha()    
            PulaLinha()
            @ Linha, 001 PSAY STR0022 //"Total Geral :"
            PulaLinha()
            @ Linha, 001 PSAY STR0016 + TRANS(nQtDTot,cPicQTD ) //"Qtde (MT): "
            @ Linha, 031 PSAY STR0017 + TRANS(Abs(nDemTot -nDesTot), AVSX3("EG0_DEM_V" , 06)) //"Demurrage/Despatch : "
            @ Linha,074 PSAY STR0018+ TRANS(Abs(nDemTot -nDesTot)/nQtDTot, AVSX3("EG0_DEM_V" , 06)) //"Valor medio por tonelada : "
         EndIF
    Endif   
    PulaLinha()                           
    PulaLinha()                           
    If WORK->(!EOF())
       @ Linha, 001 PSAY STR0023 //"Porto :"
       @ Linha, 010 PSAY WORK->PORT
    EndIF   
    cPorto := WORK->PORT
    lPVEz:= .F.
    nQTD := nDes := nDem := nDias:= 0
    nNavio :=  1
    aNavio:={}
    aADD(aNavio,WORK->NAVIO)
ElseIf aScan(aNavio,WORK->NAVIO) == 0
      nNavio++ 
      aADD(aNavio,WORK->NAVIO)
EndIF
nQTD += Work->QTDMT  
nDem += Work->DEMURR  
nDes += Work->DESPATCH
nDias+= Work->TIMELS  
nQtdTot +=Work->QTDMT  
nDesTot +=Work->DESPATCH 
nDemTot +=Work->DEMURR   
Return .T.


*-----------------------------*
Static Function Exporta(lExcel)       
*-----------------------------*
Local oExcelApp
cDirDocs := MsDocPath()
cPath	:= AllTrim(GetTempPath())
DbSelectArea("Work")
if lExcel
      Work->( dbCloseArea() )
      CpyS2T( cNomArq+".DBF" , cPath, .T. )

      //Envia ao Excel
      If ! ApOleClient( 'MsExcel' )
         MsgStop(STR0024)  //"MsExcel não instalado."
         RETURN .F.
      Else
         //Abre Dbf no Excel
         oExcelApp:= MsExcel():New()
         oExcelApp:WorkBooks:Open( cPath+cNomArq+".dbf" )
         oExcelApp:SetVisible(.T.)
      EndIf
   Else
      //Abre para criacao do arquivo TXT/DBF
      TR350ARQUIVO("WORK")   
      Work->( dbCloseArea() )
   EndIf
Return .T.                                 
