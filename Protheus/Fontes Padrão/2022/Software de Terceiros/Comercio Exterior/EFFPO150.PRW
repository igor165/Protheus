#INCLUDE "EFFPO150.ch"
#include "Average.ch"

//Revisão - 20-12-04 - Alcir Alves - tratamento de multifilial
//Revisão - 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EFFPOSCON³ Autor ³ EMERSON DIB SALVADOR  ³ Data ³28/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório DE POSIÇÃO CONTRATOS                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßlßß
*/
*-------------------------*
 Function EFFPO150()
*-------------------------*
Local cAliasOld := Alias()
Private cNomArq,cTPMODU
Private cFilEEC:=xFilial('EEC'),cFilEF3:=xFilial('EF3') //cFilEEQ := xFilial('EEQ'),
Private cFilSA1 := xFilial('SA1'),cFilSA6:=xFilial('SA6'),cFilEF1:=xFilial('EF1')
Private cContrato,cfilSel:={} 
Private cModo,WorkFile,Cabec1, cTpAtu:="-"
Private NomeProg := "EFFPO150" //BHF - 25/11/08
//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0
Private lExistBCO := EF1->(FieldPos("EF1_BAN_FI")) > 0 .and. EF1->(FieldPos("EF1_PRACA")) > 0 .and.;
                     EF2->(FieldPos("EF2_BAN_FI")) > 0 .and. EF2->(FieldPos("EF2_PRACA")) > 0 .and.;
                     EF3->(FieldPos("EF3_BAN_FI")) > 0 .and. EF3->(FieldPos("EF3_PRACA")) > 0 .and.;
                     EF4->(FieldPos("EF4_BAN_FI")) > 0 .and. EF4->(FieldPos("EF4_PRACA")) > 0
Private lCadFin := ChkFile("EF7") .AND. ChkFile("EF8") .AND. ChkFile("EF9") //HVR
	
Private lTemRof := EF3->(FieldPos("EF3_ROF")) > 0 //HVR

//** PLB 05/07/06 - Variaveis para o F3 de Tipos de Financiamento
If lCadFin
   Private cFiltroF3Fin := "I/E" ,;
           lEvCont      := .F.
EndIf
//**


cfilSel:=AvgSelectFil(.T.,"EF1") //Alcir Alves - 20-12-04  - tratamento de multifilial
if cfilSel[1]#"WND_CLOSE" //Alcir Alves - 15-03-05 - validação do retorno da função de seleção de multifilial
//ASK 13/02/07 15:16 - Incluso no AtuSx do P9R1
//   EFFPO150_ACERTADICIO()
   If !Pergunte("EFFPO1",.T.)
      EEC->(DBSETORDER(1))
//    EEQ->(DBSETORDER(1))
      EF3->(DBSETORDER(1))
      EF1->(DBSETORDER(1))
      DbSelectArea(cAliasOld)
      Return .F.
   EndIf
   IF EMPTY(mv_par02)
      mv_par02 :=CTOD("01/01/90")
   ENDIF
   IF EMPTY(mv_par03)
      mv_par03 :=CTOD("31/12/49")  
   ENDIF
   cBanco   := mv_par01
   dInicial := mv_par02
   dFinal   := mv_par03
   //cCodCli  := mv_par04
   cContrato:= mv_par04
   cModo    := mv_par08
//   cImport  :=mv_par10 // Filtro Importador SYT
   IF lEFFTpMod
      nTpModu  := mv_par12 //HVR Filtro Tipo de Modulo, Tipo de COntrato EF1_TPMODU
      cTPMODU  := IF(nTPMODU==1,"I",;
                     IF(nTPMODU==2,"E","A")) //LCS
      cSeqCNT  :=mv_par11 //HVR Filtro Sequencia do COntrato EF1_SEQCNT
   ENDIF
   IF mv_par09==1 //IMPRESSORA
      // Processamento
      MsAguarde({ || EFFPO150GERAREL()}, STR0001) //"Lendo Informações..."
   ELSE
      MsAguarde({ || EFFPO150IMPRIME()}, STR0001) //"Lendo Informações..."
      WORK_EXPORT(iif(mv_par09==2,.f.,.t.))
      Erase(WorkFile+TEOrdBagExt())
   ENDIF
                    
   //Retorno dos Indices a Ordem Natural
   EEC->(DBSETORDER(1))
//   EEQ->(DBSETORDER(1))
   EF3->(DBSETORDER(1))
   EF1->(DBSETORDER(1))
ENDIF
DbSelectArea(cAliasOld)

Return .T.

*---------------------------------*
Static Function EFFPO150GERAREL()
*---------------------------------*
Local cDesc1     := STR0002 //"Relatório de Posição de Contratos"
Local cDesc2     := ""
Local cDesc3     := ""
Local cString    := "EF1"
Local aOrd       := {}

Private nLin     := 80
Private nTipo    := 18
Private wnrel    := "EFFPO150"
Private Titulo   := STR0003 //"Posição de Contratos "
//Private nomeprog := "EFFPO150"
Private cbtxt    := Space(10)
Private cbcont   := 00
Private CONTFL   := 01
Private m_pag    := 01
PRIVATE nPagina  := 0
Private aReturn  := { "Zebrado", 1,"Financiamento", 1, 1, 1, "", 1}
Private nLastKey := 0
Private aDriver  := {}
Private tamanho:= "G"
Private limite := 220

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|lEnd| EFFPO150IMPRIME(wnRel,cString)})

Return .T.

*------------------------------*
Static Function EFFPO150IMPRIME()
*------------------------------*
//Para o Sintético

Local cPictVl:= AVSX3("EF1_SLD_PM",06), cPictBan:= AVSX3("A6_NOME",06)
Local cPictInv:=AVSX3("EF3_INVOIC",06) //cPictImp:= AVSX3("EEC_IMPODE",06)
Local cPictDt:= AVSX3("EF3_DT_EVE",06), cPictCon:= AVSX3("EF1_CONTRA",06)
Local cPictMoe:= AVSX3("EF3_MOE_IN",06), cPictProc:= AVSX3("EF3_PREEMB",06)
Local cPictTx:= AVSX3("EF3_TX_MOE",06), cCont:= ""
Local lImp:= .F., lPrim:= .T., nVlMoe:= 0, nVlRea:= 0,nfil:=0,filAtu:="-",filial_n:=""
Local i

Private cInvoice,Adata:={} //Alcir Alves - 21-02-05 - numero da invoice atual
Private cParc:="" //Alcir Alves - 21-02-05 - numero da invoice atual
Private EF3_Lrec:=0 //resgistro posicionado do EF3 - Alcir Alves - 19-02-05
Private nCol0:=0, nCol1:= nCol0+18, nCol2:= nCol1+05, nCol3:= nCol2+22, nCol4:= nCol3+21
Private nCol5:= nCol4+23, nCol6:= nCol5+27, nCol7:= nCol6+27, nCol8:= nCol7+25
Private nCol9:= nCol8+24, nCol10:=nCol1+39

nLin := 80
//Para o Analítico
Private nCol11:= nCol0, nCol12:= nCol11+26, nCol13:= nCol12+20
Private nCol14:=nCol13+20, nCol15:= nCol14+17, nCol16:= nCol15+23
Private nCol17:= nCol16+20, nCol18:=nCol17+27, nCol19:=nCol0+20
Private nCol20:= nCol19+31, nCol21:= nCol20+24, nCol22:= nCol21+33
Private nCol23:= nCol22+27
Private aWorkT1:=aWorkT2:=" "      //Alcir Alves - VARIAVEL DE TRABALHO
Private aMoedaMe := {}         //LRL - 13/01/04
Private aJurosMe := {}         //LRL - 13/01/04  
Private aTotalRea := {0,0,0,0,0,0} //LRL -13/01/04 
Private aFilToT  := {}         //AAF - 07/01/05
//** PLB 17/07/06
Private lQuebrou     := .F.
Private lMostraSALiq := .F.  // Controla a exibicao da coluna 'Saldo A Liquidar' na impressao do Totais
//**
//Alcir Alves - 22-02-05
if EasyEntryPoint("EFFPO150")  //inicia variaveis de trabalho
     ExecBlock("EFFPO150", .F., .F.,"VARIAVEIS_INICIO")
endif
//            


EF1->(dbsetorder(1))
EF3->(dbsetorder(1))
EEC->(dbsetorder(1))

// Alcir Alves - 20/12/04  - tratamento de multifilial
//begincomm
aFilEF3:=AvgSelectFil(.F.,"EF3")
aFilEEC:=AvgSelectFil(.F.,"EEC")
aFilSA6:=AvgSelectFil(.F.,"SA6")
//endcomm
//ALCIR ALVES - 22-02-05 - ESTRUTUTA DA WOR PARA EXPORTAÇÃO EXCEL E TEXTO
if mv_par09#1  //caso diferente de impressão
   Adata:= {}
   Aadd(Adata,{"FILIAL",AVSX3("EF3_FILIAL",2),AVSX3("EF3_FILIAL",3),AVSX3("EF3_FILIAL",4)}) //FILIAL
   Aadd(Adata,{"BANCO",AVSX3("EF1_BAN_FI",2),AVSX3("EF1_BAN_FI",3),AVSX3("EF1_BAN_FI",4)}) //BANCO
   Aadd(Adata,{"CONTRATO",AVSX3("EF1_CONTRA",2),AVSX3("EF1_CONTRA",3),AVSX3("EF1_CONTRA",4)}) //CONTRATO
   Aadd(Adata,{"DT_CONTRA",AVSX3("EF1_DT_CON",2),AVSX3("EF1_DT_CON",3),AVSX3("EF1_DT_CON",4)}) //CONTRATO       
   IF lExistBCO
      Aadd(Adata,{"PRACA",AVSX3("EF1_PRACA",2),AVSX3("EF1_PRACA",3),AVSX3("EF1_PRACA",4)}) //PRACA
   ENDIF
   Aadd(Adata,{"TPCONT",AVSX3("EF1_TP_FIN",2),AVSX3("EF1_TP_FIN",3),AVSX3("EF1_TP_FIN",4)}) //TIPO DE CONTRATO
   Aadd(Adata,{"VALOR_FIN",AVSX3("EF1_VL_MOE",2),AVSX3("EF1_VL_MOE",3),AVSX3("EF1_VL_MOE",4)}) //VALOR FINANCIADO
   Aadd(Adata,{"SACC_MOE ",AVSX3("EF1_SLD_PM",2),AVSX3("EF1_SLD_PM",3),AVSX3("EF1_SLD_PM",4)}) //SALDO ACC MOEDA
   Aadd(Adata,{"SACE_MOE ",AVSX3("EF1_SL2_PM",2),AVSX3("EF1_SL2_PM",3),AVSX3("EF1_SL2_PM",4)}) //SALDO ACE MOEDA
   Aadd(Adata,{"SACC_REA ",AVSX3("EF1_SLD_PR",2),AVSX3("EF1_SLD_PR",3),AVSX3("EF1_SLD_PR",4)}) //SALDO ACC REAL
   Aadd(Adata,{"SACE_REA ",AVSX3("EF1_SL2_PR",2),AVSX3("EF1_SL2_PR",3),AVSX3("EF1_SL2_PR",4)}) //SALDO ACE REAL

   Aadd(Adata,{"JACC_MOE ",AVSX3("EF1_SLD_JM",2),AVSX3("EF1_SLD_JM",3),AVSX3("EF1_SLD_JM",4)}) //JUROS ACC MOEDA
   Aadd(Adata,{"JACE_MOE ",AVSX3("EF1_SL2_JM",2),AVSX3("EF1_SL2_JM",3),AVSX3("EF1_SL2_JM",4)}) //JUROS ACE MOEDA
   Aadd(Adata,{"JACC_REA ",AVSX3("EF1_SLD_JR",2),AVSX3("EF1_SLD_JR",3),AVSX3("EF1_SLD_JR",4)}) //JUROS ACC REAL
   Aadd(Adata,{"JACE_REA ",AVSX3("EF1_SL2_JR",2),AVSX3("EF1_SL2_JR",3),AVSX3("EF1_SL2_JR",4)}) //JUROS ACE REAL
   IF cModo==1 //CASO SEJA ANALITICO
      Aadd(Adata,{"INVO_VINC",AVSX3("EF3_INVOIC",2),AVSX3("EF3_INVOIC",3),AVSX3("EF3_INVOIC",4)}) //INVOICE VINCULADA
      Aadd(Adata,{"INVO_MOE",AVSX3("EF3_MOE_IN",2),AVSX3("EF3_MOE_IN",3),AVSX3("EF3_MOE_IN",4)}) //MOEDA DA INVOICE
      Aadd(Adata,{"PROCESSO",AVSX3("EF3_PREEMB",2),AVSX3("EF3_PREEMB",3),AVSX3("EF3_PREEMB",4)}) //PROCESSO
      Aadd(Adata,{"DATA_VINC",AVSX3("EF3_DT_EVE",2),AVSX3("EF3_DT_EVE",3),AVSX3("EF3_DT_EVE",4)}) //DATA DA VINCULACAO
      Aadd(Adata,{"VAL_VINCME",AVSX3("EF3_VL_MOE",2),AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4)}) //VALOR DA VINCULAÇÃO NA MOEDA
      Aadd(Adata,{"VAL_VINCRE",AVSX3("EF3_VL_REA",2),AVSX3("EF3_VL_REA",3),AVSX3("EF3_VL_REA",4)}) //VALOR DA VINCULAÇÃO EM REAL
      Aadd(Adata,{"TAXA_MOE",AVSX3("EF3_TX_MOE",2),AVSX3("EF3_TX_MOE",3),AVSX3("EF3_TX_MOE",4)}) //TAXA DA MOEDA
      Aadd(Adata,{"CLIENTE",AVSX3("EEC_IMPORT",2),AVSX3("EEC_IMPORT",3),AVSX3("EEC_IMPORT",4)}) //CLIENTE
      Aadd(Adata,{"DATA_LIQ",AVSX3("EF3_DT_EVE",2),AVSX3("EF3_DT_EVE",3),AVSX3("EF3_DT_EVE",4)}) //DATA DA LIQUIDAÇÃO
      Aadd(Adata,{"VAL_LIQME",AVSX3("EF3_VL_MOE",2),AVSX3("EF3_VL_MOE",3),AVSX3("EF3_VL_MOE",4)}) //VALOR DA LIQUIDAÇÃO NA MOEDA
      Aadd(Adata,{"VAL_LIQRE",AVSX3("EF3_VL_REA",2),AVSX3("EF3_VL_REA",3),AVSX3("EF3_VL_REA",4)}) //VALOR DA LIQUIDACAO EM REAL
      Aadd(Adata,{"TAXA_LIQ",AVSX3("EF3_TX_MOE",2),AVSX3("EF3_TX_MOE",3),AVSX3("EF3_TX_MOE",4)}) //TAXA DA LIQUIDAÇÃO
   ENDIF
   //Alcir Alves - 22-02-05
   if EasyEntryPoint("EFFPO150")  //ESTRUTURA DA WORK
      ExecBlock("EFFPO150", .F., .F.,"WORK_ESTRU")
   endif
   //            
   If Select("Work") > 0
      Work->( DBCloseArea() )       
   EndIf

   WorkFile := E_CriaTrab(,Adata,"Work") //THTS - 25/09/2017 - TE-6431 - Temporario no Banco de Dados
endif
    //
for nfil=1 to len(cfilSel) //Alcir Alves - 20-12-04  - tratamento de multifilial
    //Alcir Alves - 20-12-04  - tratamento de multifilial
   cFilEF1:=cfilSel[nfil]
 IF lEFFTpMod  
   IF nTpModu = 1 //HVR     FILTRO 1-Importação/2-Exportação/3-Ambos
      EF1->(DbSeek(cFilEF1+IF(lEFFTpMod,"I","")+If(!Empty(cContrato),cContrato,"")))//+If(!Empty(cBanco),cBanco,"")))
   ELSEIF nTpModu = 2
      EF1->(DbSeek(cFilEF1+IF(lEFFTpMod,"E","")+If(!Empty(cContrato),cContrato,"")))//+If(!Empty(cBanco),cBanco,""))) 
   ELSEIF nTpModu = 3  
      IF !EF1->(DbSeek(cFilEF1+IF(lEFFTpMod,"E","")+If(!Empty(cContrato),cContrato,"")))//+If(!Empty(cBanco),cBanco,"")))
      	 EF1->(DbSeek(cFilEF1+IF(lEFFTpMod,"I","")+If(!Empty(cContrato),cContrato,"")))//+If(!Empty(cBanco),cBanco,"")))
      ENDIF
   ENDIF
 ELSE
    EF1->(DbSeek(cFilEF1+If(!Empty(cContrato),cContrato,"")))//+If(!Empty(cBanco),cBanco,"")))
 ENDIF

   Do While !EF1->(EOF()) .AND. IF(lEFFTpMod, IF(nTpModu = 3 .OR. !lEFFTpMod,.T.,IF(nTpModu = 1,EF1->EF1_TPMODU="I",EF1->EF1_TPMODU<>"I") ),.T. );
            .AND. EF1->EF1_FILIAL==cFilEF1 .And. If(!Empty(cContrato),cContrato = EF1->EF1_CONTRA, .T.)
      
      //ALCIR ALVES - NOVAS VALIDAÇÕES PERGUNTES - 21-02-05
      IF !EMPTY(mv_par05) .AND. EF1->EF1_TP_FIN#mv_par05  //TIPO DE CONTRATO
          EF1->(DBSKIP())                 
          LOOP
      ENDIF
      IF lEFFTPMod //HVR
         IF nTpModu = 3
            IF !EMPTY(mv_par06) .AND. EF1->EF1_EXPORT#mv_par06  //EXPORTADOR
                EF1->(DBSKIP())                 
                LOOP
            ENDIF
            IF !EMPTY(mv_par10) .AND. EF1->EF1_IMPORT#mv_par10  //IMPORTADOR
                EF1->(DBSKIP())                 
                LOOP
            ENDIF
         ELSEIF nTpModu = 1
            IF !EMPTY(mv_par10) .AND. EF1->EF1_IMPORT#mv_par10  //IMPORTADOR
                EF1->(DBSKIP())                 
                LOOP
            ENDIF
         ELSEIF nTpModu = 2
            IF !EMPTY(mv_par06) .AND. EF1->EF1_EXPORT#mv_par06  //EXPORTADOR
                EF1->(DBSKIP())                 
                LOOP
            ENDIF
         EndIF      
      EndIF
      
      IF !EMPTY(mv_par07) .AND. EF1->EF1_LOJA#mv_par07  //LOJA EXPORTADOR
          EF1->(DBSKIP())                 
          LOOP
      ENDIF
 
      // Verifica se esta dentro do periodo
      IF !EMPTY(dInicial)
         If EF1->EF1_DT_CON < dInicial
            EF1->(DbSkip())
            Loop
         Endif
      Endif

      IF !EMPTY(dFinal)
         If EF1->EF1_DT_CON >dFinal
            EF1->(DbSkip())
            Loop
         Endif
      Endif      

      // Verifica o Banco
      IF !EMPTY(cBanco)
         If EF1->EF1_BAN_FI # cBanco
            EF1->(DbSkip())
            Loop
         Endif
      Endif      
                      
      // Verifica o Contrato
      IF !EMPTY(cContrato)
         If EF1->EF1_CONTRA # cContrato
            EF1->(DbSkip())
            Loop
         Endif
      Endif

      IF lEFFTPMod //HVR
         IF !EMPTY(mv_par11) .AND. EF1->EF1_SEQCNT#mv_par11  //Seq. Contrato
             EF1->(DBSKIP())                 
             LOOP
         ENDIF
      EndIf

      If cModo = 2   // Sintético
         If nLin >= 55 .AND. mv_par09==1
	         EFFPO150CAB("S")
   	   EndIf
         //Alcir Alves - 20-12-04   - tratamento de multifilial
         //cria quebra por filial  //begincomm 05                                                                           IMPRESSORA   
         if filAtu<>cFilEF1 .and. !empty(alltrim(cFilEF1)) .and. len(cfilSel)>1 .AND. mv_par09==1
            IF filAtu#"-"
               EFFPO150CAB("S")
            ENDIF
            filAtu:=cFilEF1
            nLin +=1
            @ nLin,000 PSAY __PrtThinline()            
            nLin +=1
            filial_n:=AvgFilName({FilAtu})
            @ nLin,00 PSAY STR0034+FilAtu+" - "+filial_n[1] 
            nLin +=1
            @ nLin,000 PSAY __PrtThinline()                  
            nLin +=1
         endif
         //endcom

         //HVR Quebra por Modulo
         if lEFFTpMod  .And.  cTpAtu<>EF1->EF1_TPMODU .and. mv_par09==1
            IF cTpAtu="E" .And. EF1->EF1_TPMODU="I"
               ImpToTTp("S")
            ENDIF
            aMoedaMe  := {}         
            aJurosMe  := {}         
            aTotalRea := {0,0,0,0,0,0} 
            aFilTot   :={}
            IF cTpAtu#"-"
               EFFPO150CAB("S")
            ENDIF
            cTpAtu:=EF1->EF1_TPMODU
            @ nLin,00 PSAY STR0038+" "+IF(EF1->EF1_TPMODU="I",STR0040,STR0041)
            nLin +=1
            @ nLin,000 PSAY __PrtThinline()                  
            nLin +=1
         endif

	     IF mv_par09==1 //IMPRESSORA
           lImp:= .T.	  
           @ nLin,nCol0 PSAY Left(Transf(EF1->EF1_CONTRA, cPictCon),15)
           IF lEFFTpMod                            
              @ nLin,nCol1 PSAY Left(EF1->EF1_SEQCNT,2)
              EF7->(DBSETORDER(1))
              EF7->(DBSEEK(xFILIAL("EF7")+EF1->EF1_TP_FIN) )
              @ nLin,nCol1+4 PSAY Left(EF7->EF7_DESCRI,7)
           ELSE
              @ nLin,nCol1+4 PSAY If(EF1->EF1_TP_FIN == "01", STR0028, STR0029) //"ACC"###"ACE"
           ENDIF
           @ nLin,nCol2+6 PSAY Transf(EF1_SLD_PM, cPictVl)
           @ nLin,nCol3+6 PSAY Transf(EF1_SLD_PR, cPictVl)
           @ nLin,nCol4+6 PSAY Transf(EF1_SLD_JM, cPictVl)
           @ nLin,nCol5+6 PSAY Transf(EF1_SLD_JR, cPictVl)
           @ nLin,nCol6+6 PSAY Transf(EF1_SL2_PM, cPictVl)
           @ nLin,nCol7+6 PSAY Transf(EF1_SL2_PR, cPictVl)
           @ nLin,nCol8+6 PSAY Transf(EF1_SL2_JM, cPictVl)
           @ nLin,nCol9+6 PSAY Transf(EF1_SL2_JR, cPictVl)
           nLin:= nLin+1
        ELSE
            //SALVA DADOS NA WORK PARA GERAÇÃO DE ARQUIVOS
            WORK->(RECLOCK("WORK",.T.))
            WORK->FILIAL=cfilSel[nfil]
            WORK->BANCO=EF1->EF1_BAN_FIN
            WORK->CONTRATO=EF1->EF1_CONTRA
            WORK->DT_CONTRA=EF1->EF1_DT_CON
            IF lExistBCO         
                WORK->PRACA=EF1->EF1_PRACA
            ENDIF
            WORK->TPCONT=EF1->EF1_TP_FIN
            WORK->VALOR_FIN=EF1->EF1_VL_MOE
            WORK->SACC_MOE=EF1->EF1_SLD_PM 
            WORK->SACE_MOE=EF1->EF1_SL2_PM
            WORK->SACC_REA=EF1->EF1_SLD_PR
            WORK->SACE_REA=EF1->EF1_SL2_PR
            WORK->JACC_MOE=EF1->EF1_SLD_JM
            WORK->JACE_MOE=EF1->EF1_SL2_JM
            WORK->JACC_REA=EF1->EF1_SLD_JR
            WORK->JACE_REA=EF1->EF1_SL2_JR      	 
            //Alcir Alves - 22-02-05
            if EasyEntryPoint("EFFPO150")  //GRAVA WORK NO CASO DE RELATORIO SINTETICO
               ExecBlock("EFFPO150", .F., .F.,"GRAVA_WORK_SINTETICO")
            endif
            // 
            WORK->(MSUNLOCK())
      	ENDIF
      	AcumTotal("S") //LRL 15/01/2004 Acumula Total Sintatico
      Else						// Analitico LRL 14/01/04
         cFilEF3:=iif(len(aFilEF3)==1 .and. alltrim(aFilEF3[1])=="",aFilEF3[1],cfilSel[nfil]) //Alcir - 20-12-04  - tratamento de multifilial
         //Alcir Alves - 19-02-05 - nova chave considerando o banco_fin e praça
         If EF3->(DbSeek(cFilEF3+IF(lEFFTpMoD,EF1->EF1_TPMODU,"")+If(Empty(cContrato),EF1->EF1_CONTRA,cContrato)+iif(lExistBCO,EF1->EF1_BAN_FI+EF1->EF1_PRACA,"")+IF(lEFFTpMoD,EF1->EF1_SEQCNT,"")+"600" ))
            //Alcir Alves - 20-12-04  - tratamento de multifilial
            //cria quebra por filial //begincomm 05        
            if filAtu<>cFilEF1 .and. !empty(alltrim(cFilEF1)) .and. len(cfilSel)>1 .AND. mv_par09==1 //IMPRESSORA
                //** AAF 07/01/05 - Total Por Filial
                If filatu <> "-"
                   For i:= 1 To Len(aFilToT)
                      If i == 1
                         nLin++
                         @ nLin++, 000      PSAY __PrtThinLine()
                         @ nLin++, 000      PSAY STR0035+filatu+" - "+AvgFilName({filatu})[1]//"Total da Filial "
                         @ nLin++, 000      PSAY __PrtThinLine()
                         @ nlin++,nCol20+14 PSAY IIF(lMostraSALiq,STR0005,STR0043) //"Saldo Principal                       Saldo a Liquidar                         Saldo Liquidado"
                         //@ nlin++,nCol20+14 PSAY Repli("-", 16)+Space(23)+Repli("-", 16)
                         @ nlin++,nCol20+14 PSAY Repli("-", 15)+Space(22)+IIF(lMostraSALiq,Repli("-", 16)+Space(25)," ")+Repli("-",15)
                         nLin++
                         @ nlin,000 PSAY STR0031//"Sld. Principal "
                      Endif
                      @ nlin,nCol20    PSAY aFilToT[i][1]
                      @ nlin,nCol20+11 PSAY Transf(aFilToT[i][2], cPictVl)
                      If lMostraSALiq
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][3], cPictVl)
                         @ nlin,nCol20+89 PSAY Transf(aFilToT[i][6], cPictVl)  // PLB 17/07/06
                      Else
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][6], cPictVl)  // PLB 17/07/06
                      EndIf
                      nLin++
                   Next
                   For i:= 1 To Len(aFilToT)
                      If i == 1
                         nLin++
                         @ nlin++,000 PSAY STR0033//"Sld. Juros"                      
                      Endif
                      @ nlin,nCol20    PSAY aFilToT[i][1]
                      @ nlin,nCol20+11 PSAY Transf(aFilToT[i][4], cPictVl)
                      If lMostraSALiq
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][5], cPictVl)
                         @ nlin,nCol20+89 PSAY Transf(aFilToT[i][7], cPictVl)  // PLB 17/07/06
                      Else
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][7], cPictVl)  // PLB 17/07/06
                      EndIf
                      nLin++
                   Next
                   lQuebrou := .T.  // PLB 17/07/06
                Endif
                //**
                
                IF filAtu#"-" .OR. nLin > 55 .AND. mv_par09==1
                   EFFPO150CAB("A")
                ENDIF
                filAtu:=cFilEF1
                nLin +=1
                @ nLin,000 PSAY __PrtThinline()            
                nLin +=1
                filial_n:=AvgFilName({FilAtu})
                @ nLin,00 PSAY "Filial : "+FilAtu+" - "+filial_n[1] 
                nLin +=1
                @ nLin,000 PSAY __PrtThinline()                  
                nLin +=1
            endif
//endcom       	     	 	  
//HVR Quebra por Modulo
          IF lEFFTpMod
            if cTpAtu<>EF1->EF1_TPMODU .AND. mv_par09==1 //IMPRESSORA
               IF cTpAtu#"-"
                  For i:= 1 To Len(aFilToT)
                     If i == 1
                        nLin++
                        @ nLin++, 000      PSAY STR0042+IF(cTpAtu="I",STR0040,STR0041)//"Total do Modulo" "Importação" "Exportação"
                        nLin++
                        @ nlin++,nCol20+14 PSAY IIF(lMostraSALiq,STR0005,STR0043) //"Saldo Principal                       Saldo a Liquidar                         Saldo Liquidado"
                        //@ nlin++,nCol20+14 PSAY Repli("-", 16)+Space(23)+Repli("-", 16)
                        @ nlin++,nCol20+14 PSAY Repli("-", 15)+Space(22)+IIF(lMostraSALiq,Repli("-", 16)+Space(25)," ")+Repli("-",15)
                        nLin++
                        @ nlin,000 PSAY STR0031//"Sld. Principal "
                     Endif
                      @ nlin,nCol20    PSAY aFilToT[i][1]
                      @ nlin,nCol20+11 PSAY Transf(aFilToT[i][2], cPictVl)
                      If lMostraSALiq
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][3], cPictVl)
                         @ nlin,nCol20+89 PSAY Transf(aFilToT[i][6], cPictVl)  // PLB 17/07/06
                      Else
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][6], cPictVl)  // PLB 17/07/06
                      EndIf
                      nLin++
                   Next
                   For i:= 1 To Len(aFilToT)
                      If i == 1
                         nLin++
                         @ nlin++,000 PSAY STR0033//"Sld. Juros"                      
                      Endif
                      @ nlin,nCol20    PSAY aFilToT[i][1]
                      @ nlin,nCol20+11 PSAY Transf(aFilToT[i][4], cPictVl)
                      If lMostraSALiq
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][5], cPictVl)
                         @ nlin,nCol20+89 PSAY Transf(aFilToT[i][7], cPictVl)  // PLB 17/07/06
                      Else
                         @ nlin,nCol20+49 PSAY Transf(aFilToT[i][7], cPictVl)  // PLB 17/07/06
                      EndiF
                      nLin++
                    NEXT
                    aMoedaMe  := {}         
                    aJurosMe  := {}         
                    aTotalRea := {0,0,0,0,0,0} 
                    aFilTot   :={}
                    lMostraSALiq := .F.  // PLB 17/07/06
               EndIF

                
                IF cTpAtu#"-" .OR. nLin > 55 .AND. mv_par09==1
                   EFFPO150CAB("A")
                ENDIF
                cTpAtu:=EF1->EF1_TPMODU
                @ nLin,00 PSAY STR0038+IF(cTpAtu="I",STR0040,STR0041) 
                nLin +=1
                @ nLin,000 PSAY __PrtThinline()                  
                nLin +=1
            endif
         ElseIf lQuebrou  // PLB 17/07/06
            lMostraSALiq := .F.
         ENDIF
         lQuebrou := .F.
//endcom       	     	 	  
            If nLin >= 55 .AND. mv_par09==1
         	   EFFPO150CAB("A")
            EndIf

            cFilSA6:=iif(len(aFilSA6)==1 .and. alltrim(aFilSA6[1])=="",aFilSA6[1],cfilSel[nfil])  //Alcir - 20-12-04 - tratamento de multifilial
            SA6->(DbSeek(cFilSA6+EF1->EF1_BAN_FI))
            IF mv_par09==1 //IMPRESSORA
                @ nLin,nCol0    PSAY Left(Transf(EF1->EF1_CONTRA, cPictCon),15)
               IF lEFFTpMod
                  @ nLin,nCol0+18 PSAY Left(EF1->EF1_SEQCNT,2)
                  EF7->(DBSETORDER(1))
                  EF7->(DBSEEK(xFILIAL("EF7")+EF1->EF1_TP_FIN) )
                  @ nLin,nCol0+22 PSAY Left(EF7->EF7_DESCRI,7)
               ELSE
                  @ nLin,nCol0+22 PSAY If(EF1->EF1_TP_FIN == "01", STR0028, STR0029) //"ACC"###"ACE"
               ENDIF
               @ nLin,nCol0+31 PSAY Left(EF1->EF1_MOEDA,3)+Transf(EF1->EF1_VL_MOE, "@E 999,999,999.99")
//               @ nLin,nCol0+57 PSAY Transf(EF1->EF1_VL_MOE, cPictVl)
               @ nLin,nCol10+6 PSAY Transf(SA6->A6_NOME, cPictBan)
               IF lExistBCO
                  @ nLin,nCol10+6+(len(SA6->A6_NOME)+2) PSAY Left(EF1->EF1_PRACA,5)
               ENDIF
               @ nLin,nCol10+6+(len(SA6->A6_NOME)+2+5+2)PSAY EF1->EF1_DT_CON
                
               if EasyEntryPoint("EFFPO150")  //NOVO CAMPO NO AGRUPAMENTO POR CONTRATO
                  ExecBlock("EFFPO150", .F., .F.,"CONTRATO_ANALIT")
               endif
            ENDIF
            
            nLin:= nLin+1
            If cCont <> EF1->EF1_CONTRA
               cCont:= EF1->EF1_CONTRA
               IF lEFFTpMod
                  cContSeqCNT := EF1->EF1_SEQCNT
               EndIF
               lPrim:= .T.
            Endif

            nVlMoe:= 0
            nVlRea:= 0
            nVlMoe2:=0
            nVlRea2:=0            
            NEF3R:=EF3->(recno())
            If lPrim .AND. mv_par09==1
               EFFPO150CAB("V")
               lPrim:= .F.
            Endif
            cFilEEC=iif(len(aFilEEC)==1 .and. alltrim(aFilEEC[1])=="",aFilEEC[1],cfilSel[nfil]) //Alcir 20-12-04 - tratamento de multifilial
            Do While !EF3->(EOF()) .AND. EF3->EF3_FILIAL==cFilEF3 .And. cCont == EF3->EF3_CONTRA .And. IF(lEFFTpMod,EF3->EF3_SEQCNT == cContSeqCNT,.T.) .And. EF3->EF3_CODEVE == "600" //Liquidação /*.AND. IF(lEFFTpMod, EF3->EF3_TPMODU==cTpAtu,.T.) - CCM - 05/03/09 - Revido Para acerto do filtro do relatorio Posição Contratos*/
               If nLin >= 55 .AND. mv_par09==1
                  EFFPO150CAB("A")
               Endif
               //Alcir Alves - 22-02-05
               if EasyEntryPoint("EFFPO150")  //VALIDAÇÃO DE INVOICE
                 ExecBlock("EFFPO150", .F., .F.,"VALIDA_INVOICE")
               endif
               //  
               IF mv_par09==1 //IMPRESSORA
                   nLin:= nLin+1
                   @ nLin,nCol11 PSAY IF(lEFFTpMod, IF(EF3->EF3_TPMODU= "I", Left(Transf(EF3->EF3_INVIMP, cPictInv),13)+"-"+Left(Transf(EF3->EF3_LINHA, cPictInv),3),Left(Transf(EF3->EF3_INVOIC, cPictInv),14)+"-"+Left(Transf(EF3->EF3_PARC, cPictInv),2) ),Left(Transf(EF3->EF3_INVOIC, cPictInv),14)+"-"+Left(Transf(EF3->EF3_PARC, cPictInv),2))
                   @ nLin,nCol12-6 PSAY Transf(EF3->EF3_MOE_IN, cPictMoe)
                   IF lEFFTpMod
                      IF EF3->EF3_ORIGEM ="SWB"
                         @ nLin,nCol13-6 PSAY Transf(EF3->EF3_HAWB, cPictProc)
                      Else
                         @ nLin,nCol13-6 PSAY Transf(EF3->EF3_PREEMB, cPictProc)
                      ENDIF
                   ELSE
                         @ nLin,nCol13-6 PSAY Transf(EF3->EF3_PREEMB, cPictProc)
                   Endif
                   @ nLin,nCol14-6 PSAY Transf(EF3->EF3_DT_EVE, cPictDt)
                   @ nLin,nCol15-6 PSAY Transf(EF3->EF3_VL_MOE, cPictVl)
                   @ nLin,nCol16-6 PSAY Transf(EF3->EF3_VL_REA, cPictVl)
                   @ nLin,nCol17-6 PSAY Transf(EF3->EF3_TX_MOE, cPictTx)
                   @ nLin,nCol18-6 PSAY IF( lEFFTpMod, IF(EF3->EF3_ORIGEM="SWB", EF3->EF3_FORN,EEC->EEC_IMPORT), EEC->EEC_IMPORT)        //POSICIONE("SA1",1,cFilSA1+EEC->EEC_IMPORT,"A1_NREDUZ")
               ELSE
                   //SALVA DADOS NA WORK PARA GERAÇÃO DE ARQUIVOS
                   WORK->(RECLOCK("WORK",.T.))
                   WORK->FILIAL=cfilSel[nfil]
                   WORK->BANCO=EF1->EF1_BAN_FIN
                   WORK->CONTRATO=EF1->EF1_CONTRA
                   WORK->DT_CONTRA=EF1->EF1_DT_CON
                   IF lExistBCO         
                       WORK->PRACA=EF1->EF1_PRACA
                   ENDIF
                   WORK->TPCONT=EF1->EF1_TP_FIN
                   WORK->VALOR_FIN=EF1->EF1_VL_MOE
                   WORK->SACC_MOE=EF1->EF1_SLD_PM 
                   WORK->SACE_MOE=EF1->EF1_SL2_PM
                   WORK->SACC_REA=EF1->EF1_SLD_PR
                   WORK->SACE_REA=EF1->EF1_SL2_PR
                   WORK->JACC_MOE=EF1->EF1_SLD_JM
                   WORK->JACE_MOE=EF1->EF1_SL2_JM
                   WORK->JACC_REA=EF1->EF1_SLD_JR
                   WORK->JACE_REA=EF1->EF1_SL2_JR      	 
                   WORK->INVO_VINC=EF3->EF3_INVOIC
                   WORK->INVO_MOE=EF3->EF3_MOE_IN
                   WORK->PROCESSO=EF3->EF3_PREEMB
                   WORK->DATA_VINC=EF3->EF3_DT_EVE
                   WORK->VAL_VINCME=EF3->EF3_VL_MOE
                   WORK->VAL_VINCRE=EF3->EF3_VL_REA
                   WORK->TAXA_MOE=EF3->EF3_TX_MOE
                   WORK->CLIENTE=EEC->EEC_IMPORT
                   if EasyEntryPoint("EFFPO150")  //GRAVA WORK COM A PARCELA VINCULADA NO CASO DE RELATORIO ANALITICO 
                      ExecBlock("EFFPO150", .F., .F.,"GRAVA_WORK_ANALIT_VINC")
                   endif
                   WORK->(MSUNLOCK())
               ENDIF
               nVlMoe+= EF3->EF3_VL_MOE
               nVlRea+= EF3->EF3_VL_REA
               lPrim:= .T.
               lImp:= .F.
               //LOCALIZA A RESPECTIVA INVOICE LIQUIDADA A RESPECTIVA INVOICE VINCULADA
               IF cTpAtu="I" // Alcir Alves - 21-02-05
                  cInvoice:=EF3->EF3_INVIMP
                  cParc:=Left(EF3->EF3_Linha,4)
                  nOrdEF3:=EF3->(IndexOrd())
                  nRecEF3:=EF3->(Recno())
                  EF3->(DBSETORDER(7))  
                  /// LCS EF3->(DbSeek(cFilEF3+IF(lEFFTpMod, cTpAtu,"")+EF3->EF3_HAWB+EF3->EF3_FORN+EF3->EF3_LOJAFO+AvKey(cInvoice,"EF3_INVIMP")+AvKey(cParc,"EF3_LINHA")+"630"))
                  EF3->(DbSeek(cFilEF3+"I"+EF3->EF3_HAWB+EF3->EF3_FORN+EF3->EF3_LOJAFO+AvKey(cInvoice,"EF3_INVIMP")+AvKey(cParc,"EF3_LINHA")+"630"))
               Else 
                  cInvoice:=EF3->EF3_INVOIC
                  cParc:=Left(EF3->EF3_PARC,2)
                  nOrdEF3:=EF3->(IndexOrd())
                  nRecEF3:=EF3->(Recno())
                  EF3->(DBSETORDER(2))  
                  /// LCS EF3->(DbSeek(cFilEF3+IF(lEFFTpMod, cTpAtu,"")+"630"+AvKey(cInvoice,"EF3_INVOIC")+Avkey(cParc,"EF3_PARC") ))
                  EF3->(DbSeek(cFilEF3+"E"+"630"+AvKey(cInvoice,"EF3_INVOIC")+Avkey(cParc,"EF3_PARC") ))
               EndIf
               /// LCS Do While !EF3->(EOF()) .AND. IF(lEFFTpMod, EF3->EF3_TPMODU==cTpAtu,.T.) .AND. EF3->EF3_FILIAL==cFilEF3 .And. IF(lEFFTpMod, IF(EF3->EF3_TPMODU="I",EF3->EF3_INVIMP == Left(cInvoice,15),EF3->EF3_INVOIC == cInvoice),.T.) .And. EF3->EF3_CODEVE == "630" .and. IF(lEFFTpMod, IF(EF3->EF3_TPMODU="I",EF3->EF3_LINHA==Left(cParc,4),EF3->EF3_PARC==Left(cParc,2)),.T.)  //Liquidação
               Do While !EF3->(EOF()) .AND.;
                  IF(cTPMODU=="A",.T.,EF3->EF3_TPMODU==cTPMODU) .AND.;
                  EF3->EF3_FILIAL==cFilEF3 .And.;
                  IF(lEFFTpMod, IF(EF3->EF3_TPMODU="I",EF3->EF3_INVIMP == Left(cInvoice,15),EF3->EF3_INVOIC == cInvoice),.T.) .And.;
                  EF3->EF3_CODEVE == "630" .and.;
                  IF(lEFFTpMod, IF(EF3->EF3_TPMODU="I",EF3->EF3_LINHA==Left(cParc,4),EF3->EF3_PARC==Left(cParc,2)),.T.)  //Liquidação
                  *
                    IF EMPTY(EF3->EF3_DT_EVE) //CASO DATA DO EVENTO ESTEJA VAZIA
                       EF3->(DBSKIP())
                       LOOP
                    ENDIF
                    IF mv_par09==1 //IMPRESSORA
                       @ nLin,nCol18+2 PSAY Transf(EF3->EF3_DT_EVE, cPictDt)
                       @ nLin,(nCol18+11) PSAY Transf(EF3->EF3_VL_MOE, cPictVl)
                       @ nLin,(nCol18+31) PSAY Transf(EF3->EF3_VL_REA, cPictVl)
                       @ nLin,(nCol18+51) PSAY Transf(EF3->EF3_TX_MOE, cPictTx)
                    ELSE
                       //SALVA DADOS NA WORK PARA GERAÇÃO DE ARQUIVOS
                       WORK->(RECLOCK("WORK",.T.))
                       WORK->FILIAL=cfilSel[nfil]
                       WORK->BANCO=EF1->EF1_BAN_FIN
                       WORK->CONTRATO=EF1->EF1_CONTRA
                       WORK->DT_CONTRA=EF1->EF1_DT_CON
                       IF lExistBCO         
                          WORK->PRACA=EF1->EF1_PRACA
                       ENDIF
                       WORK->TPCONT=EF1->EF1_TP_FIN
                       WORK->VALOR_FIN=EF1->EF1_VL_MOE
                       WORK->SACC_MOE=EF1->EF1_SLD_PM 
                       WORK->SACE_MOE=EF1->EF1_SL2_PM
                       WORK->SACC_REA=EF1->EF1_SLD_PR
                       WORK->SACE_REA=EF1->EF1_SL2_PR
                       WORK->JACC_MOE=EF1->EF1_SLD_JM
                       WORK->JACE_MOE=EF1->EF1_SL2_JM
                       WORK->JACC_REA=EF1->EF1_SLD_JR
                       WORK->JACE_REA=EF1->EF1_SL2_JR      	 
                       WORK->CLIENTE=EEC->EEC_IMPORT
                       WORK->INVO_VINC=EF3->EF3_INVOIC
                       WORK->DATA_LIQ=EF3->EF3_DT_EVE
                       WORK->VAL_LIQME=EF3->EF3_VL_MOE
                       WORK->VAL_LIQRE=EF3->EF3_VL_REA
                       WORK->TAXA_LIQ=EF3->EF3_TX_MOE
                       if EasyEntryPoint("EFFPO150")  //GRAVA WORK COM A PARCELA LIQUIDADA NO CASO DE RELATORIO ANALITICO 
                          ExecBlock("EFFPO150", .F., .F.,"GRAVA_WORK_ANALIT_LIQ")
                       endif
                       WORK->(MSUNLOCK())
                    ENDIF
                    nVlMoe2+= EF3->EF3_VL_MOE
                    nVlRea2+= EF3->EF3_VL_REA
                    lImp:= .T.
//                    nLin:= nLin+1             
                    EF3->(DBSKIP())
               EndDo                    
               lImp:= .T.
               EF3->(DBSETORDER(nOrdEF3))
               EF3->(DBGOTO(nRecEF3))
               EF3->(dbskip())
            EndDo
            //Alcir Alves - 22-02-05
            if EasyEntryPoint("EFFPO150")  //RODAPE TOTAIS POR CONTRATO
                 ExecBlock("EFFPO150", .F., .F.,"RODAPE_TOTAL_CONTRATO")
            endif
            If lImp .AND. mv_par09==1 //IMPRESSORA
               nLin:= nLin+1
               @ nLin,0 PSAY STR0004 //"Total - "
               //TOTAIS VINCULADOS
               @ nLin,nCol15-6 PSAY Transf(nVlMoe, cPictVl)
               @ nLin,nCol16-6 PSAY Transf(nVlRea, cPictVl)

               //TOTAIS LIQUIDADOS
               @ nLin,(nCol18+11) PSAY Transf(nVlMoe2, cPictVl)
               @ nLin,(nCol18+31) PSAY Transf(nVlRea2, cPictVl)
               nLin:= nLin+1
            Endif   
      	Else   
            EF1->(DBSKIP())
            Loop
         Endif
         IF mv_par09==1 //IMPRESSORA - ALCIR ALVES - 21-02-05
            If nLin >= 55
               EFFPO150CAB("A")
            Endif
            AcumTotal("A") //LRL 15/01/2004 Acumula Total Analitico 
//            nLin+= 1
            //** PLB 17/07/06
            If !lMostraSALiq  .And.  ( !lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1" )
               lMostraSALiq := .T.
            EndIf
            //**
            @ nlin,nCol20+14 PSAY IIF(!lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1",STR0005,STR0043) //"Saldo Principal                       Saldo a Liquidar                         Saldo Liquidado"
            nLin+= 1
            @ nlin,nCol20+14 PSAY Repli("-", 15)+Space(22)+IIF(!lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1",Repli("-", 16)+Space(25)," ")+Repli("-",15)
            nLin+= 1
            @ nlin,000 PSAY STR0006 //"Moeda(Me)"
            @ nlin,nCol20+11 PSAY Transf(EF1->EF1_SLD_PM, cPictVl)
            nOrdEF3:=EF3->(IndexOrd())
            nRecEF3:=EF3->(Recno())
            EF3->(DbSetOrder(1))
            /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
               nSld:=0
               EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
               Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
                  If EF3->EF3_TX_MOE == 0
                     nSld += EF3->EF3_VL_MOE
                  EndIf
                  EF3->( DBSkip() )
               EndDo
               @ nlin,nCol20+51 PSAY Transf(nSld, cPictVl)
				ELSE
               @ nlin,nCol20+51 PSAY Transf(EF1->EF1_SL2_PM, cPictVl)
            ENDIF*/
            If !lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1"
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_SL2_PM, cPictVl)
               @ nlin,nCol20+89 PSAY Transf(EF1->EF1_LIQPRM, cPictVl)
            Else
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_LIQPRM, cPictVl)
            EndIf
            nLin+= 1
            @ nlin,000 PSAY STR0007                            //"Reais(R$)"
            @ nlin,nCol20+11 PSAY Transf(EF1->EF1_SLD_PR, cPictVl)  

            /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
               nSld:=0
               EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
               Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
                  If EF3->EF3_TX_MOE == 0
                     nSld += EF3->EF3_VL_REA
                  EndIf
                  EF3->( DBSkip() )
               EndDo
               @ nlin,nCol20+51 PSAY Transf(nSld, cPictVl)
				ELSE
               @ nlin,nCol20+51 PSAY Transf(EF1->EF1_SL2_PR, cPictVl)
            ENDIF*/
            If !lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1"
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_SL2_PR, cPictVl)
               @ nlin,nCol20+89 PSAY Transf(EF1->EF1_LIQPRR, cPictVl)
            Else
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_LIQPRR, cPictVl)
            EndIf
            nLin+= 1
            @ nlin,000 PSAY STR0008 //"Juros(Me)"
            @ nlin,nCol20+11 PSAY Transf(EF1->EF1_SLD_JM, cPictVl)
            /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
               nSld:=0
               EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
               Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
                  If EF3->EF3_TX_MOE == 0
                     nSld += EF3->EF3_VL_MOE
                  EndIf
                  EF3->( DBSkip() )
               EndDo
               @ nlin,nCol20+51 PSAY Transf(nSld, cPictVl)
				ELSE
               @ nlin,nCol20+51 PSAY Transf(EF1->EF1_SL2_JM, cPictVl)
            ENDIF*/
            If !lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1"
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_SL2_JM, cPictVl)
               @ nlin,nCol20+89 PSAY Transf(EF1->EF1_LIQJRM, cPictVl)
            Else
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_LIQJRM, cPictVl)
            EndIf
            nlin +=1                   
            @ nlin,000 PSAY STR0009    //"Juros(R$)"
            @ nlin,nCol20+11 PSAY Transf(EF1->EF1_SLD_JR, cPictVl)
            /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
               nSld:=0
               EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
               Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
                  If EF3->EF3_TX_MOE == 0
                     nSld += EF3->EF3_VL_REA
                  EndIf
                  EF3->( DBSkip() )
               EndDo
               @ nlin,nCol20+51 PSAY Transf(nSld, cPictVl)
				ELSE
               @ nlin,nCol20+51 PSAY Transf(EF1->EF1_SL2_JR, cPictVl)
            ENDIF*/
            If !lEFFTpMod  .Or.  EF1->EF1_CAMTRA != "1"
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_SL2_JR, cPictVl)
               @ nlin,nCol20+89 PSAY Transf(EF1->EF1_LIQJRR, cPictVl)
            Else
               @ nlin,nCol20+49 PSAY Transf(EF1->EF1_LIQJRR, cPictVl)
            EndIf
            nlin +=1
            @ nlin,000 PSAY __PrtThinline()
            nlin +=1
            nOrdEF3:=EF3->(IndexOrd())
            nRecEF3:=EF3->(Recno())
            EF3->(DbSetOrder(nOrdEF3))
            EF3->(DBGOTO(nRecEF3))
         ENDIF
      Endif
      EF1->(DBSKIP())
   Enddo
next

IF mv_par09==1 //IMPRESSORA - ALCIR ALVES - 21-02-05

   //** AAF 07/01/05 - Total Por Filial
   if filAtu<>cFilEF1 .and. !empty(alltrim(cFilEF1)) .and. len(cfilSel)>1
      If filatu <> "-"
         For i:= 1 To Len(aFilToT)
            If i == 1
               nLin++
               @ nLin++, 000      PSAY __PrtThinLine()
               @ nLin++, 000      PSAY "Total da Filial "+filatu+" - "+AvgFilName({filatu})[1]
               @ nLin++, 000      PSAY __PrtThinLine()
               @ nlin++,nCol20+14 PSAY IIF(lMostraSALiq,STR0005,STR0043) //"Saldo Principal                       Saldo a Liquidar                         Saldo Liquidado"
               //@ nlin++,nCol20+14 PSAY Repli("-", 16)+Space(23)+Repli("-", 16)
               @ nlin++,nCol20+14 PSAY Repli("-", 15)+Space(22)+IIF(lMostraSALiq,Repli("-", 16)+Space(25)," ")+Repli("-",15)  // PLB 17/07/06
               nLin++
               @ nlin,000 PSAY STR0031//"Sld. Principal "
            Endif
            @ nlin,nCol20    PSAY aFilToT[i][1]
            @ nlin,nCol20+11 PSAY Transf(aFilToT[i][2], cPictVl)
            If lMostraSALiq
               @ nlin,nCol20+49 PSAY Transf(aFilToT[i][3], cPictVl)
               @ nlin,nCol20+89 PSAY Transf(aFilToT[i][6], cPictVl)  // PLB 17/07/06
            Else
               @ nlin,nCol20+49 PSAY Transf(aFilToT[i][6], cPictVl)  // PLB 17/07/06
            EndIf
            nLin++
         Next
         For i:= 1 To Len(aFilToT)
            If i == 1
               nLin++
               @ nlin++,000 PSAY STR0033//"Sld. Juros"                      
            Endif
            @ nlin,nCol20    PSAY aFilToT[i][1]
            @ nlin,nCol20+11 PSAY Transf(aFilToT[i][4], cPictVl)
            If lMostraSALiq
               @ nlin,nCol20+49 PSAY Transf(aFilToT[i][5], cPictVl)
               @ nlin,nCol20+89 PSAY Transf(aFilToT[i][7], cPictVl)  // PLB 17/07/06
            Else
               @ nlin,nCol20+49 PSAY Transf(aFilToT[i][7], cPictVl)  // PLB 17/07/06
            EndIf
            nLin++
         Next
      Endif
   Endif
   //**
   If cModo = 1
      ImpToTGeral("A") //LRL 13/01/04
   Else
      ImpToTTp("S") //HVR
      IF EF1->(EOF())    //HVR
         ImpToTGeral("S")
      ENDIF
   EndIf
   If lImp
      If aReturn[5] = 1
         Set Printer To
         Commit
         Ourspool(wnrel)
      Endif
   Else
      MsgInfo(STR0010, STR0011) //"Não existem dados para Impressao!"###"Mensagem"
   Endif
   MS_FLUSH()
ENDIF

Return .T.                       

*-----------------------------------*
Static Function EFFPO150CAB(cParam)
*-----------------------------------*
TituloRel := STR0003 + If(cParam =='A', STR0012, STR0013) + STR0014+DTOC(dInicial)+ STR0015 + DTOC(dFinal) //"Posição de Contratos "###"(Analitico)"###"(Sintético)"###" - Período: "###" Até "

If cParam  == "S"      //Sintético
   nLin := 08
   Cabec1 := STR0016 //"Contrato          Tipo     Sld. Princ. ME        Sld. Princ. R$        Sld. Juros ME          Sld. Juros R$         Sld. Princ. ME ACE         Sld. Princ. R$ ACE          Sld. Jr. ME ACE         Sld. Jr. R$ ACE"
   if EasyEntryPoint("EFFPO150")  //TITULOS DO AGRUPAMENTO POR CONTRATO SINTETICO
       ExecBlock("EFFPO150", .F., .F.,"CONTRATO_SINTETICO_CABEC")
   endif

ElseIf cParam  == "A"  //Analítico
   nLin := 08
   Cabec1 :=STR0017  //IIF(lExistBCO,STR0017,STR0017) //"Contrato          Seq.  Tipo     Valor Financiado              Banco                                  Praça      Data do Contrato"
   if EasyEntryPoint("EFFPO150")  //TITULOS DO AGRUPAMENTO POR CONTRATO ANALITICO
       ExecBlock("EFFPO150", .F., .F.,"CONTRATO_ANALIT_CABEC")
   endif
ElseIf cParam  == "V"  //Vinculação
   nLin:= nLin+1
   IF cTpAtu = "I"
      @ nLin,0 PSAY STR0037 //"Invoice Vinculada         Moeda Invoice       Processo            Dt.Vinc          Valor Vinculado ME     Valor Vinculado R$        Taxa Moeda      Fornec.     Dt.Liq.          Valor Liq. ME     Valor Liq. R$         Taxa Liq."
   Else
      @ nLin,0 PSAY STR0018 //"Invoice Vinculada         Moeda Invoice       Processo            Dt.Vinc          Valor Vinculado ME     Valor Vinculado R$        Taxa Moeda      Cliente     Dt.Liq.          Valor Liq. ME     Valor Liq. R$         Taxa Liq."
   EndIf
   nLin:= nLin+1
   //@ nLin,0 PSAY Repli("-", 17)+Space(09)+Repli("-", 13)+Space(07)+Repli("-", 08)+Space(16)+Repli("-", 18)+Space(04)+Repli("-", 18)+Space(14)+Repli("-", 18)+Space(15)+Repli("-", 10)+Space(11)+Repli("-", 07)
      @ nLin,0 PSAY STR0036
                // 01234567890123456789012345678901234567890123456789012345678901234567890123456789"
Else                   //Liquidação 
   nLin:= nLin+1
   @ nLin,20 PSAY STR0019 //"Invoice Liquidada         Data da Liquidação           Valor Liquidado ME               Valor Liquidado R$               Taxa Moeda"
   nLin:= nLin+1
   @ nLin,20 PSAY Repli("-", 17)+Space(09)+Repli("-", 18)+Space(11)+Repli("-", 18)+Space(15)+Repli("-", 18)+Space(15)+Repli("-", 10)
Endif

If cParam  $ "S/A"
   Cabec2:= ""   
   Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
Endif   

Return .T.


*-------------------------------------------*
Static Function AcumTotal(cTipo)   //LRL 13/01/04
*-------------------------------------------*  
Local nPos
If cTipo == "A"
      nOrdEF3:=EF3->(IndexOrd())
      nRecEF3:=EF3->(Recno())
      EF3->(DbSetOrder(1))
      //Acumula Total em ME
      nPos := ASCAN(aMoedaMe ,{ |x| x[1] = EF1->EF1_MOEDA })
      if nPos = 0
         AADD(aMoedaMe ,{EF1->EF1_MOEDA, EF1->EF1_SLD_PM, IIF(lEFFTpMod .And. EF1->EF1_CAMTRA=="1",0,EF1->EF1_SL2_PM),EF1_LIQPRM})
      else
         aMoedaMe[nPos,2] += EF1->EF1_SLD_PM
         If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
            aMoedaMe[nPos,3] += EF1->EF1_SL2_PM
         EndIf
         aMoedaMe[nPos,4] += EF1->EF1_LIQPRM
         /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
            EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
            Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
               If EF3->EF3_TX_MOE == 0
                  aMoedaMe[nPos,3]+= EF3->EF3_VL_MOE
               EndIf
               EF3->( DBSkip() )
            EndDo
			ELSE
            aMoedaMe[nPos,3] += EF1->EF1_SL2_PM 
         ENDIF*/
      endif 
      //Acumula Total de Juros em ME
      nPos := ASCAN(aJurosMe ,{ |x| x[1] = EF1->EF1_MOEDA })
      if nPos = 0
         AADD(aJurosMe ,{EF1->EF1_MOEDA,EF1->EF1_SLD_JM,IIF(lEFFTpMod .And. EF1->EF1_CAMTRA=="1",0,EF1->EF1_SL2_JM),EF1->EF1_LIQJRM})
      else
         aJurosMe[nPos,2] += EF1->EF1_SLD_JM
         If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
            aJurosMe[nPos,3] += EF1->EF1_SL2_JM
         EndIf
         aJurosMe[nPos,4] += EF1->EF1_LIQJRM
         /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
            EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
            Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
               If EF3->EF3_TX_MOE == 0
                  aJurosMe[nPos,3]+= EF3->EF3_VL_MOE
               EndIf
               EF3->( DBSkip() )
            EndDo
			ELSE
            aJurosMe[nPos,3] += EF1->EF1_SL2_JM 
         ENDIF*/
      endif 
      //Acumula Total em Reais
      aTotalRea[1] += EF1->EF1_SLD_PR
      If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
         aTotalRea[2] += EF1->EF1_SL2_PR
      EndIf
      aTotalRea[5] += EF1->EF1_LIQPRR
      /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod .And. EF1->EF1_TPMODU="I"
         EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
         Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
            If EF3->EF3_TX_MOE == 0
               aTotalRea[2]+= EF3->EF3_VL_REA
            EndIf
            EF3->( DBSkip() )
         EndDo
	   ELSE
         aTotalRea[2] += EF1->EF1_SL2_PR
      ENDIF*/
      //Acumula Total de Juros Em Reais
      aTotalRea[3] += EF1->EF1_SLD_JR  //EF1->EF1_SLD_JM   // PLB 05/07/06 - Saldo de Juros em Reais
      If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
         aTotalRea[4] += EF1->EF1_SL2_JR
      EndIf
      aTotalRea[6] += EF1->EF1_LIQJRR
      /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod .And. EF1->EF1_TPMODU="I"
         EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
         Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
            If EF3->EF3_TX_MOE == 0
               aTotalRea[4]+= EF3->EF3_VL_REA
            EndIf
            EF3->( DBSkip() )
         EndDo
	   ELSE
         aTotalRea[4] += EF1->EF1_SL2_JR
      ENDIF*/
      
      //** AAF 07/01/05 - Acumula total para a filial.
      nPos := aScan(aFilToT,{ |x| x[1] = "R$" })
      If nPos = 0
         aAdd(aFilToT,{"R$",EF1->EF1_SLD_PR,IIF(lEFFTpMod .And. EF1->EF1_CAMTRA=="1",0,EF1->EF1_SL2_PR),EF1->EF1_SLD_JR,IIF(lEFFTpMod .And. EF1->EF1_CAMTRA=="1",0,EF1->EF1_SL2_JR),EF1->EF1_LIQPRR,EF1->EF1_LIQJRR})
      Else
         aFilToT[nPos][2] += EF1->EF1_SLD_PR
         If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
            aFilToT[nPos][3] += EF1->EF1_SL2_PR
         EndIf
         aFilToT[nPos][6] += EF1->EF1_LIQPRR
         /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod .And. EF1->EF1_TPMODU="I"
            EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
            Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
               If EF3->EF3_TX_MOE == 0
                  aFilToT[nPos][3]+= EF3->EF3_VL_REA
               EndIf
               EF3->( DBSkip() )
            EndDo
   	   ELSE
            aFilToT[nPos][3] += EF1->EF1_SL2_PR
         ENDIF*/
         aFilToT[nPos][4] += EF1->EF1_SLD_JR
         If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
            aFilToT[nPos][5] += EF1->EF1_SL2_JR
         EndIf
         aFilToT[nPos][7] += EF1->EF1_LIQJRR
         /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
            EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
            Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
               If EF3->EF3_TX_MOE == 0
                  aFilToT[nPos][5]+= EF3->EF3_VL_REA
               EndIf
               EF3->( DBSkip() )
            EndDo
   	   ELSE
            aFilToT[nPos][5] += EF1->EF1_SL2_JR
         ENDIF*/
      Endif         
      nPos := aScan(aFilToT,{ |x| x[1] = EF1->EF1_MOEDA })
      If nPos = 0
         aAdd(aFilToT,{EF1->EF1_MOEDA,EF1->EF1_SLD_PM,IIF(lEFFTpMod .And. EF1->EF1_CAMTRA=="1",0,EF1->EF1_SL2_PM),EF1->EF1_SLD_JM,IIF(lEFFTpMod .And. EF1->EF1_CAMTRA=="1",0,EF1->EF1_SL2_JM),EF1->EF1_LIQPRM,EF1->EF1_LIQJRM})
      Else
         aFilToT[nPos][2] += EF1->EF1_SLD_PM
         If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
            aFilToT[nPos][3] += EF1->EF1_SL2_PM
         EndIf
         aFilToT[nPos][6] += EF1->EF1_LIQPRM
         /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
            EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
            Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"70") )
               If EF3->EF3_TX_MOE == 0
                  aFilToT[nPos][3]+= EF3->EF3_VL_MOE
               EndIf
               EF3->( DBSkip() )
            EndDo
   	   ELSE
            aFilToT[nPos][3] += EF1->EF1_SL2_PM
         ENDIF*/
         aFilToT[nPos][4] += EF1->EF1_SLD_JM
         If !(lEFFTpMod .And. EF1->EF1_CAMTRA=="1")
            aFilToT[nPos][5] += EF1->EF1_SL2_JM
         EndIf
         aFilToT[nPos][7] += EF1->EF1_LIQJRM
         /*IF EF1->EF1_CAMTRA= "1" .and. lEFFTpMod  .And.  EF1->EF1_TPMODU="I"
            EF3->( DBSeek(cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->EF1_CONTRA+EF1->EF1_BAN_FI+EF1->EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
            Do While EF3->( !EoF() .AND. EF3_FILIAL+IF(lEFFTpMod,EF3->EF3_TPMODU,"")+EF3_CONTRA+EF3_BAN_FI+EF3_PRACA+IF(lEFFTpMod,EF3->EF3_SEQCNT,"")+EF3_CODEVE == cFilEF3+IF(lEFFTpMod,EF1->EF1_TPMODU,"")+EF1->(EF1_CONTRA+EF1_BAN_FI+EF1_PRACA+IF(lEFFTpMod,EF1->EF1_SEQCNT,"")+"71") )
               If EF3->EF3_TX_MOE == 0
                  aFilToT[nPos][5]+= EF3->EF3_VL_MOE
               EndIf
               EF3->( DBSkip() )
            EndDo
   	   ELSE
            aFilToT[nPos][5] += EF1->EF1_SL2_JM        
         ENDIF*/
      Endif
      //**
Else                         
      nPos := ASCAN(aMoedaMe ,{ |x| X[1] = EF1->EF1_MOEDA })
      if nPos = 0
         AADD(aMoedaMe ,{EF1->EF1_MOEDA,EF1->EF1_SLD_PM,EF1->EF1_SLD_JM,EF1->EF1_SL2_PM,EF1->EF1_SL2_JM})
      else
         aMoedaMe[nPos,2] += EF1->EF1_SLD_PM
         aMoedaMe[nPos,3] += EF1->EF1_SLD_JM
         aMoedaMe[nPos,4] += EF1->EF1_SL2_PM
         aMoedaMe[nPos,5] += EF1->EF1_SL2_JM 
      endif 
      
   aTotalRea[1] += EF1->EF1_SLD_PR
   aTotalRea[2] += EF1->EF1_SLD_JR
   aTotalRea[3] += EF1->EF1_SL2_PR
   aTotalRea[4] += EF1->EF1_SL2_JR  
EndIf

Return .T. 
*-----------------------------------------------------*
Static Function QuebraTotal(cTipo)   //LRL 13/01/04
*-----------------------------------------------------*
IF nLin >= 55
      If cTipo == "A"
          nLin := 8
//          TituloRel := STR0003 + If(cTipo =='A', STR0012, STR0013) + STR0014+DTOC(dInicial)+ STR0015 + DTOC(dFinal) //"Posição de Contratos "###"(Analitico)"###"(Sintético)"###" - Período: "###" Até "
          TituloRel := STR0003 + STR0012 + STR0014+DTOC(dInicial)+ STR0015 + DTOC(dFinal) //"Posição de Contratos "###"(Analitico)"###" - Período: "###" Até "
/*          If cTipo  == "S"      //Sintético
             nLin := 08
             Cabec1 := STR0016 //"Contrato          Tipo     Sld. Princ. ME        Sld. Princ. R$        Sld. Juros ME          Sld. Juros R$         Sld. Princ. ME ACE         Sld. Princ. R$ ACE          Sld. Jr. ME ACE         Sld. Jr. R$ ACE"
             if EasyEntryPoint("EFFPO150")  //TITULOS DO AGRUPAMENTO POR CONTRATO ANALITICO
                 ExecBlock("EFFPO150", .F., .F.,"CONTRATO_SINTETICO_CABEC")
             endif
	         // 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
          ElseIf cTipo  == "A"  //Analítico
*/
          nLin := 08
          Cabec1 := IIF(lExistBCO,STR0017+space(len(SA6->A6_NOME)-3)+"Praça",STR0017) //"Contrato          Tipo     Valor Financiado              Banco"
          if EasyEntryPoint("EFFPO150")  //TITULOS DO AGRUPAMENTO POR CONTRATO ANALITICO
              ExecBlock("EFFPO150", .F., .F.,"CONTRATO_ANALIT_CABEC")
          endif
             // 012345678901234567890123456789012
//          Endif
          Cabec2 := ""   
          Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
                     
          nlin++
          @ nlin, 010 PSAY STR0042+IF(cTpAtu="I",STR0040,STR0041) //"Total do Modulo :"
          nLin++
          @ nlin,000 PSAY __PrtThinline()
          nLin++
        
          @ nlin,nCol20+14 PSAY IIF(lMostraSALiq,STR0005,STR0043) //"Saldo Principal                       Saldo a Liquidar                         Saldo Liquidado"
          nLin++
          //@ nlin,nCol20+14 PSAY Repli("-", 16)+Space(23)+Repli("-", 16)
          @ nlin,nCol20+14 PSAY Repli("-", 15)+Space(22)+IIF(lMostraSALiq,Repli("-", 16)+Space(25)," ")+Repli("-",15)  // PLB 17/07/06
          nLin++    
      Else
         EFFPO150CAB("S")
         nlin++
//          @ nlin, 010 PSAY STR0042+IF(cTpAtu="I",STR0040,STR0041)
          nLin++
      EndIf
Else
   nLin++
Endif
Return .T.    

*-------------------------------------------*
Static Function ImpToTGeral(cTipo)
*-------------------------------------------*
Local nInc
Local cPictVl:= AVSX3("EF1_SLD_PM",06)
nLin := 99

If cTipo == "A"
   QuebraTotal("A")
   nLin++//   QuebraTotal("A")
   nLin++//   QuebraTotal("A")
   @ nlin,000 PSAY STR0031//"Sld. Principal "
   For nInc:= 1 to len (aMoedaMe)
         @ nlin,nCol20  PSAY aMoedaMe[nInc,1]
         @ nlin,nCol20+11 PSAY Transf(aMoedaMe[nInc,2], cPictVl)
         If lMostraSALiq
            @ nlin,nCol20+49 PSAY Transf(aMoedaMe[nInc,3], cPictVl)
            @ nlin,nCol20+89 PSAY Transf(aMoedaMe[nInc,4], cPictVl)  // PLB 17/07/06
         Else
            @ nlin,nCol20+49 PSAY Transf(aMoedaMe[nInc,4], cPictVl)  // PLB 17/07/06
         EndIf
         nLin++//         QuebraTotal("A")
   Next
   nLin++//   QuebraTotal("A")
   @ nlin,nCol20  PSAY STR0032//"R$"
   @ nlin,nCol20+11 PSAY Transf(aTotalRea[1], cPictVl)
   If lMostraSALiq
      @ nlin,nCol20+49 PSAY Transf(aTotalRea[2], cPictVl)
      @ nlin,nCol20+89 PSAY Transf(aTotalRea[5], cPictVl)  // PLB 17/07/06
   Else
      @ nlin,nCol20+49 PSAY Transf(aTotalRea[5], cPictVl)  // PLB 17/07/06
   EndIf
   nLin++//  QuebraTotal("A")
   nLin++//  QuebraTotal("A")
  @ nlin,000 PSAY STR0033//"Sld. Juros"
  For nInc:= 1 to len (aJurosMe)
         @ nlin,nCol20  PSAY aJurosMe[nInc,1]
         @ nlin,nCol20+11 PSAY Transf(aJurosMe[nInc,2], cPictVl)
         If lMostraSALiq
            @ nlin,nCol20+49 PSAY Transf(aJurosMe[nInc,3], cPictVl)
            @ nlin,nCol20+89 PSAY Transf(aJurosMe[nInc,4], cPictVl)  // PLB 17/07/06
         Else
            @ nlin,nCol20+49 PSAY Transf(aJurosMe[nInc,4], cPictVl)  // PLB 17/07/06
         EndIf
         nLin++//         QuebraTotal("A")
   Next
   nLin++//  QuebraTotal("A")
  @ nlin,nCol20  PSAY STR0032//"R$"
  @ nlin,nCol20+11 PSAY Transf(aTotalRea[3], cPictVl)
  If lMostraSALiq
     @ nlin,nCol20+49 PSAY Transf(aTotalRea[4], cPictVl)
     @ nlin,nCol20+89 PSAY Transf(aTotalRea[6], cPictVl)  // PLB 17/07/06
  Else
     @ nlin,nCol20+49 PSAY Transf(aTotalRea[6], cPictVl)  // PLB 17/07/06
  EndIf
   nLin++//  QuebraTotal("A")
  @ nlin,000 PSAY __PrtThinline()
   nLin++//  QuebraTotal("A")
  lMostraSALiq := .F.  // PLB 17/07/06
Else
   QuebraTotal("S")
   If nLin < 53
      @ nlin, 010 PSAY STR0030//"TOTAL GERAL  :"
      QuebraTotal("S")
   EndIF   
   QuebraTotal("S")
   @ nlin,nCol1 PSAY  STR0032//"R$"
   @ nlin,nCol2 PSAY  "              0,00"
   @ nLin,nCol3 PSAY  Transf(aTotalRea[1], cPictVl)
   @ nlin,nCol4 PSAY  "              0,00"
   @ nLin,nCol5 PSAY  Transf(aTotalRea[2], cPictVl)
   @ nlin,nCol6 PSAY  "              0,00"
   @ nLin,nCol7 PSAY Transf(aTotalRea[3], cPictVl)
   @ nlin,nCol8 PSAY  "              0,00"
   @ nLin,nCol9 PSAY Transf(aTotalRea[4], cPictVl)
   QuebraTotal("S")
   For nInc:= 1 to len (aMoedaMe)
      @ nlin,nCol1 PSAY aMoedaMe[nInc,1]
      @ nlin,nCol2 PSAY Transf(aMoedaMe[nInc,2], cPictVl)
      @ nlin,nCol4 PSAY Transf(aMoedaMe[nInc,3], cPictVl)
      @ nlin,nCol6 PSAY Transf(aMoedaMe[nInc,4], cPictVl)
      @ nlin,nCol8 PSAY Transf(aMoedaMe[nInc,5], cPictVl)
      QuebraTotal("S")
   Next
EndIf
Return .t.


*-------------------------------------------*
Static Function ImpToTTp(cTipo)
*-------------------------------------------*
Local nInc
Local cPictVl:= AVSX3("EF1_SLD_PM",06)
//nLin := 99

If cTipo == "A"
   QuebraTotal("A")
   nLin++//   QuebraTotal("A")
   nLin++//   QuebraTotal("A")
   @ nlin,000 PSAY STR0031//"Sld. Principal "
   For nInc:= 1 to len (aMoedaMe)
         @ nlin,nCol20+6  PSAY aMoedaMe[nInc,1]
         @ nlin,nCol20+18 PSAY Transf(aMoedaMe[nInc,2], cPictVl)
         @ nlin,nCol20+56 PSAY Transf(aMoedaMe[nInc,3], cPictVl)
         @ nlin,nCol20+96 PSAY Transf(aMoedaMe[nInc,4], cPictVl)  // PLB 17/07/06
         nLin++//         QuebraTotal("A")
   Next
   nLin++//   QuebraTotal("A")
   @ nlin,nCol20+6  PSAY STR0032//"R$"
   @ nlin,nCol20+18 PSAY Transf(aTotalRea[1], cPictVl)  
   @ nlin,nCol20+56 PSAY Transf(aTotalRea[2], cPictVl)
   @ nlin,nCol20+96 PSAY Transf(aTotalRea[5], cPictVl)  // PLB 17/07/06
   nLin++//  QuebraTotal("A")
   nLin++//  QuebraTotal("A")
  @ nlin,000 PSAY STR0033//"Sld. Juros"
  For nInc:= 1 to len (aJurosMe)
         @ nlin,nCol20+6  PSAY aJurosMe[nInc,1]
         @ nlin,nCol20+18 PSAY Transf(aJurosMe[nInc,2], cPictVl)
         @ nlin,nCol20+56 PSAY Transf(aJurosMe[nInc,3], cPictVl)
         @ nlin,nCol20+96 PSAY Transf(aJurosMe[nInc,4], cPictVl)  // PLB 17/07/06
         nLin++//         QuebraTotal("A")
   Next
   nLin++//  QuebraTotal("A")
  @ nlin,nCol20+6  PSAY STR0032//"R$"
  @ nlin,nCol20+18 PSAY Transf(aTotalRea[3], cPictVl)
  @ nlin,nCol20+58 PSAY Transf(aTotalRea[4], cPictVl)
  @ nlin,nCol20+98 PSAY Transf(aTotalRea[6], cPictVl)  // PLB 17/07/06
   nLin++//  QuebraTotal("A")
  @ nlin,000 PSAY __PrtThinline()
   nLin++//  QuebraTotal("A")
Else
   IF cTpAtu <> "E" .And. lEFFTpMod  .And.  EF1->EF1_TPMODU <> "I"
      QuebraTotal("S")                        
   EndIF
   If nLin <= 52
      @ nlin, 010 PSAY STR0042+IF(cTpAtu="I",STR0040,STR0041)//"Total por Módulo :"
      QuebraTotal("S")
   EndIF   
//   QuebraTotal("S")
   @ nlin,nCol1+6 PSAY  STR0032//"R$"
   @ nlin,nCol2+6 PSAY  "              0,00"
   @ nLin,nCol3+6 PSAY  Transf(aTotalRea[1], cPictVl)
   @ nlin,nCol4+6 PSAY  "              0,00"
   @ nLin,nCol5+6 PSAY  Transf(aTotalRea[2], cPictVl)
   @ nlin,nCol6+6 PSAY  "              0,00"
   @ nLin,nCol7+6 PSAY Transf(aTotalRea[3], cPictVl)
   @ nlin,nCol8+6 PSAY  "              0,00"
   @ nLin,nCol9+6 PSAY Transf(aTotalRea[4], cPictVl)
   QuebraTotal("S")
   For nInc:= 1 to len (aMoedaMe)
      @ nlin,nCol1+6 PSAY aMoedaMe[nInc,1]
      @ nlin,nCol2+6 PSAY Transf(aMoedaMe[nInc,2], cPictVl)
      @ nlin,nCol4+6 PSAY Transf(aMoedaMe[nInc,3], cPictVl)
      @ nlin,nCol6+6 PSAY Transf(aMoedaMe[nInc,4], cPictVl)
      @ nlin,nCol8+6 PSAY Transf(aMoedaMe[nInc,5], cPictVl)
      QuebraTotal("S")
   Next
EndIf
Return .t.

// Função responsavel pela exportação de works para excel ou arquivo de texto
*---------------------------------------------------------------------------------------
STATIC FUNCTION WORK_EXPORT(lExcel) // 14-01-05 - Alcir Alves  - revisão
*---------------------------------------------------------------------------------------
//   Local oExcelApp                           // 27/02/09 - CCM
//   Local cDirDocs := MsDocPath()             // 27/02/09 - CCM
//   Local cPath	:= AllTrim(GetTempPath())  // 27/02/09 - CCM 
Local cWork := "Work"             // 27/02/09 - CCM

AvExcel(Workfile,cWork,.F.)       // 27/02/09 - CCM

/*
   DbSelectArea("Work")
   if lExcel
         //Work->(dbCloseArea())
         If ! ApOleClient( 'MsExcel' )
            MsgStop("Ms-Excel não instalado.")  
            RETURN .F.
         Else                        
            AvExcel(Workfile,cWork,.F.)       // 27/02/09 - CCM
         EndIf
   Else
         TR350ARQUIVO("work")   
         Work->(dbCloseArea())
   EndIf
*/
Return .T.

//** PLB 14/07/06 - Validacao dos Perguntes SX1
*---------------------------------------------------------------------------------------
Function PO150ValPerg(cField)
*---------------------------------------------------------------------------------------

 If cField=="Contra"
    If lEFFTpMod
       Return Posicione("EF1",1,xFilial("EF1")+"E"+mv_par04,"EF1_CONTRA")==mv_par04 .Or. AvgExistCpo("EF1","I"+mv_par04)
    Else
       Return AvgExistCpo("EF1",mv_par04)
    EndIf
 EndIf

Return .T.
