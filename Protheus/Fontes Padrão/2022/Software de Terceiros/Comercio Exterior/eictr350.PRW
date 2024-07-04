//Alcir Alves - 01-12-05 - Revisão - inclusão de subtotais por WB_TP_CON e inclusão de novos filtros por WB_TP_CON e WB_TIPOREG
//GCC - 28/08/2013 - Tratamento para trazer os valores de pagamento antecipado vinculado a PO quanto a Fornecedor

#INCLUDE "Eictr350.ch"
//#INCLUDE "FiveWin.ch"
#include "Average.ch"
#INCLUDE "TOPCONN.CH"
#include "avprint.ch"
#INCLUDE "Protheus.ch"

#DEFINE  OK           1
#DEFINE  CANCEL       0
#DEFINE  Sabado       STR0002 //"Saturday"
#DEFINE  Domingo      STR0003 //"Sunday"
#DEFINE  ENTER CHR(13)+CHR(10)         

#DEFINE TIMES_NEW_ROMAN_24        oFont1
#DEFINE COURIER_12                oFont2
#DEFINE COURIER_12_BOLD_UNDERLINE oFont3
#DEFINE COURIER_12_BOLD           oFont4

*---------------------*
FUNCTION EICTR350S()//Chamado do Schedule SXD
*---------------------*
E_Init()
EICTR350(.T.)
RETURN .T.
                  
*------------------------*
FUNCTION EICTR350(lSXD)
*------------------------*

LOCAL oDlg,cAliasAtual:=ALIAS(), aRegSXBFil:={}, nI, aF3_SX1:={}
LOCAL cAlias, cSX1_F3, cChSX1

PRIVATE nCod:=EasyCreateFile("cQuery.TXT")
PRIVATE MDt48H:=dDataBase+2,cMarca:=GetMark(),lInverte:=.F.
PRIVATE cWork,cWork1,cWork2,cIndex1,cIndex2,cIndex3,cIndex4,cIndex5,cIndex6,cIndex7,cIndex8,cIndex9,cIndex10
PRIVATE cFilSA2:=xFilial("SA2"),cFilSW2:=xFilial("SW2")
PRIVATE cFilSW6:=xFilial("SW6"),cFilSW9:=xFilial("SW9")
PRIVATE cFilSY6:=xFilial("SY6"),cFilSYT:=xFilial("SYT")
PRIVATE cFilSW7:=xFilial("SW7"),cFilSWB:=xFilial("SWB")
PRIVATE cFilSW8:=xFilial("SW8"),cFilSYW:=xFilial("SYW")

PRIVATE cPict:=AVSX3("WB_FOBMOE",6)
PRIVATE cHAWB:=SPACE(LEN(EEQ->EEQ_PREEMB)),cImport:=SPACE(LEN(SYT->YT_COD_IMP))
PRIVATE cForn:=SPACE(LEN(SA2->A2_COD)),cGrupo:=SPACE(15),dDtini:=dDtFim:=AVCTOD(''), cLoja:=SPACE(LEN(SA2->A2_LOJA))    
PRIVATE cTipoReg,TipoTit,aTitulo :={STR0004,STR0005,STR0006}//"C/Cambio","S/Cambio","Ambos"
PRIVATE cTipoOrd,aTipoOrd:={STR0010,STR0009,AVSX3("W2_FORNDES",5),AVSX3("A2_GRUPO",5)} //Processo,Vencto,Fornecedor,Grupo
PRIVATE aMoedaTotais:={},aTotaisMoedas:={}
//Outra Tela
PRIVATE nTipo:=1,aEscolha:={"Analitico","Sintetico"}//aEscolha:={STR0010,STR0019}//Processo,Moeda
PRIVATE cChave:=" ",lPrimeiro:=.T.,cTituloAtual:='',cChave2:=" ",lPrimeiro2:=.T., cChaveMoe:="",cChaveTp:=""
PRIVATE cMoedaDolar := BuscaDolar()//GETNEWPAR("MV_SIMB2","US$")
PRIVATE lEMail:=(!lSXD = NIL)
//Alcir Alves - 30-11-05
Private lTPCONExt :=  SWB->(FieldPos("WB_TP_CON"))  > 0 .and. SW9->(FieldPos("W9_FORNECC")) > 0 .and.;
                      SW9->(FieldPos("W9_LOJAC"))   > 0 .and. SW9->(FieldPos("W9_COMPV"))   > 0 .and.;
                      SW9->(FieldPos("W9_PERCOM"))  > 0 .and. SW9->(FieldPos("W9_VALCOM"))  > 0 .and.;
                      SWB->(FieldPos("WB_TIPOCOM")) > 0 .and. SW6->(FieldPos("W6_CONDP_F")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_F")) > 0 .and. SW6->(FieldPos("W6_CONDP_S")) > 0 .and.;
                      SW6->(FieldPos("W6_DIASP_S")) > 0 .and. SWB->(FieldPos("WB_TIPOCOM")) > 0 //GFC - 10/01/06 - Testar todos os campos

//HVR - Novos campos do FinImp
Private lEFFTpMod := EF1->( FieldPos("EF1_TPMODU") ) > 0 .AND. EF1->( FieldPos("EF1_SEQCNT") ) > 0 .AND.;
                     EF2->( FieldPos("EF2_TPMODU") ) > 0 .AND. EF2->( FieldPos("EF2_SEQCNT") ) > 0 .AND.;
                     EF3->( FieldPos("EF3_TPMODU") ) > 0 .AND. EF3->( FieldPos("EF3_SEQCNT") ) > 0 .AND.;
                     EF4->( FieldPos("EF4_TPMODU") ) > 0 .AND. EF4->( FieldPos("EF4_SEQCNT") ) > 0 .AND.;
                     EF6->( FieldPos("EF6_SEQCNT") ) > 0 .AND. EF3->( FieldPos("EF3_ORIGEM") ) > 0 .and.;
                     EF3->( FieldPos("EF3_ROF"   ) ) > 0

Private lEEQ_TP_CON := EEQ->(FIELDPOS("EEQ_TP_CON")) > 0

Private cTpContr:={"1-Câmbio de Importação","2-Remessa"}
Private aTotTpCamb:=aTCambG:={} //01-12-05 - Total por cambio 
//
PRIVATE aDados:={"WORK",;
                 STR0007,; //"Este relatorio ira o Follow-up de Pagamentos"
                 "",;
                 "",;
                 "G",;
                 231,;
                 "",;
                 "",;
                 STR0008,; //"Follow-up Cambio"
                 { "Zebrado", 1,"Importacao", 1, 2, 1, "",1 },;
                 "EICTR350",;
                {{|| .t. },{|| TR350Totais(aTotaisMoedas,.T.,cTituloAtual),;
                               TR350Totais(aMoedaTotais ,.F.,"Geral") }}}
                               
PRIVATE lCposAdto:=.T. /*EasyGParam("MV_PG_ANT",,.F.) */ // NCF - 15/05/2020 - Parametro descontinuado
PRIVATE lImpObs  := .F.
Private _FirstYear := Right(Padl(Set(_SET_EPOCH),4,"0"),2)

PRIVATE aFilSWB:={}, aFilSel:={}, aMarcados:={}, aSvFilSWB:={}

// ISS - 03/12/10 - Guarda a filial em que o cliente esta logado, sera nela em que as validações do filtro serão feitas.
Private cIniFilial := SM0->(M0_CODIGO+M0_CODFIL)

DO WHILE CDOW(MDt48H) = Sabado .OR. CDOW(MDt48H) = Domingo
   MDt48H++
ENDDO              

IF lEMail 
   TR350Works() 
ELSE
   PROCESSA({|| TR350Works() })
ENDIF

If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"INICIA_VAL"),)//JMS

DO WHILE .T.
   
   ASIZE(aMarcados,0)
   ASIZE(aFilSel,0)
   lBrowseFil:=.F.
   aFilSWB:=AvgSelectFil(.T.,"SWB")    //RS 23/01/06
   
   IF aFilSWB[1] == "WND_CLOSE"    	
      EXIT
   ENDIF
   
   aSvFilSWB:=ACLONE(aFilSWB)
   IF !Pergunte("EIC350",IF(lEmail,.F.,.T.),STR0001) .AND. !lEmail// AWR 
      EXIT
   ENDIF

   IF EMPTY(aMarcados) .AND. lBrowseFil 
      LOOP
   ENDIF   

   IF !TR350SX1Valid("DATA")   
      LOOP
   ENDIF

   IF lEMail      //AWR
      aReturn   := aDados[10]
      aDados[11]:= SetPrint(aDados[1],aDados[11],"EIC350",aDados[9],aDados[2],aDados[3],aDados[4],.F.,aEscolha,.T.,aDados[5])
      nTipo     := aReturn[8]
   ENDIF
   
   cHAWB    := MV_PAR01
   cImport  := MV_PAR02
   cForn    := MV_PAR03
   cLoja    := MV_PAR04 
   cGrupo   := MV_PAR05
   dDtini   := MV_PAR06
   dDtFim   := MV_PAR07
   cTipoReg := MV_PAR08
   
   //DFS - 19/01/11 - Inclusão de tratamento para verificar se é caracter ou numérico 
   If ValType(MV_PAR09) == "N"
      cTipoTit := STR(MV_PAR09,1,0)
   Else
      cTipoTit := MV_PAR09
   Endif                 
   
   If ValType(MV_PAR10) == "N"
      cTipoOrd := STR(MV_PAR10,1,0) 
   Else
      cTipoOrd := MV_PAR10   
   Endif
   
   //WFS
   If SX1->(DbSeek(IncSpace("EIC350", Len(X1_GRUPO),.F.)+"11"))
      cCorretor:=MV_PAR11
   Else
      cCorretor:= ""
   EndIf
  
   
   If lEEQ_TP_CON 
      cTpContra:=MV_PAR13
   EndIf

   IF !EMPTY(cHAWB) .AND. !EICLoja()
      cImport:=SPACE(LEN(SYT->YT_COD_IMP))         
      cForn  :=SPACE(LEN(SA2->A2_COD))
      IF EICLOJA()
         cLoja:= SPACE(LEN(SA2->A2_LOJA))
      ENDIF
      cGrupo :=SPACE(LEN(SA2->A2_GRUPO))
   ENDIF

   IF !EMPTY(cForn) .AND. (!EICLOJA() .OR. !EMPTY(cLoja))
      SA2->(DBSEEK(cFilSA2+cForn+IF(EICLOJA(),cLoja,"")))
      cGrupo:=SA2->A2_GRUPO
   ENDIF
   
   IF cTipoTit = "2"
      cTipoReg:= " "
   ENDIF   
      
   IF EMPTY(dDtini)
      dDtini:=AVCTOD("01/01/"+_FirstYear)
   ENDIF

   IF EMPTY(dDtFim)
      dDtFim:=AVCTOD("31/12/2999")      
   ENDIF
   
   If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"FINAL_VAL"),)//JMS
  
   IF !lBrowseFil
      aMarcados:=ACLONE(aFilSWB)
   ENDIF

   WORK->(avzap())
   cSvFilAnt:=cFilant   
   For nI:=1 to len(aMarcados)         
      cFilSel:=IF(lBrowseFil,aMarcados[nI][1],aMarcados[nI])
      IF(!EMPTY(aSvFilSWB[1]),cFilAnt:=cFilSel,)
   
      IF lBrowseFil .AND. ! EMPTY(aMarcados[nI][2])    // Processo
         cHAWB:=IF(LEFT(aMarcados[nI][2],1) == "*","",aMarcados[nI][2])
      ENDIF
      
      IF lBrowseFil .AND. ! EMPTY(aMarcados[nI][3])
         cImport:=IF(LEFT(aMarcados[nI][3],1) == "*","",aMarcados[nI][3])
      ENDIF
      
      IF lBrowseFil .AND. ! EMPTY(aMarcados[nI][4])
         cForn:=IF(LEFT(aMarcados[nI][4],1) == "*","",aMarcados[nI][4])
      ENDIF    
    
      IF lBrowseFil .AND. ! EMPTY(aMarcados[nI][5])
         cCorretor:=IF(LEFT(aMarcados[nI][5],1) == "*","",aMarcados[nI][5])
      ENDIF
         
      IF !EMPTY(cForn) .AND. lBrowseFil .AND. (!EICLOJA() .OR. !EMPTY(cLoja))
         SA2->(DBSEEK(xFilial("SA2")+cForn+IF(EICLOJA(),cLoja,"")))
         cGrupo:=SA2->A2_GRUPO
      ENDIF       
      
      IF !EMPTY(cHAWB) .AND. lBrowseFil
         cImport:=SPACE(LEN(SYT->YT_COD_IMP))         
         cForn  :=SPACE(LEN(SA2->A2_COD))
         cGrupo :=SPACE(LEN(SA2->A2_GRUPO))
         IF EICLOJA()
            cLoja := SPACE(LEN(SA2->A2_LOJA))
         ENDIF
      ENDIF
      
      IF lEMail      
         TR350Processa()
         IF lEEQ_TP_CON 
            TR350PrEEQ()
         ENDIF
         LOOP
      ENDIF

      PROCESSA( {|| TR350Processa()} )

      IF lEEQ_TP_CON 
         PROCESSA( {|| TR350PrEEQ()} )
      ENDIF
      
   Next
     
   TR350BROWSE()
   
   IF lEmail
      EXIT
   ENDIF 
   //ISS - 03/12/10 - Retorno da filial corrente para a filial inicial.
   cFilant:= cSvFilAnt
ENDDO

SW9->(DBSETORDER(1))

/* wfs 23/06/2017
a função e_erasearq está preparada para receber apenas 3 arquivos para exclusão
WORK->(E_EraseArq(cWork,cIndex1,cIndex2,cIndex3,cIndex4,cIndex5,cIndex6,cIndex7)) */
WORK->(E_EraseArq(cWork,cIndex1,cIndex2))
TR350Erase(cIndex3)
TR350Erase(cIndex4)
TR350Erase(cIndex5)
TR350Erase(cIndex6)
TR350Erase(cIndex7)

WORKA->(E_EraseArq(cWork1))
WORKB->(E_EraseArq(cWork2))
IF(nCod#-1,Fclose(nCod),)      
RETURN .T.        
/* 
Função: TR350Erase()
Objetivo: auxiliar a exclusão de arquivos temporários
*/
Static Function TR350Erase(cArq)
   If cArq <> Nil
      FErase(cArq + TEOrdBagExt())
   EndIf
Return

*--------------------------------*
FUNCTION TR350SX1Valid(cVar)
*--------------------------------*
DO CASE
   CASE cVar=="COMPRADOR"
        IF ExistCpo("SY1",cComprador)
           SY1->(DBSEEK(xFilial()+cComprador))
           TAutor:=SY1->Y1_NOME
           TAutor2 := SY1->Y1_NOME
        ENDIF

   CASE cVar=="HAWB"   //MV_PAR01
        SW2->(dbSetOrder(1))
        SW6->(dbSetOrder(1))         //SVG - 22/03/2011 -
        IF !Empty(MV_PAR01) .AND. ( !SW6->(dbSeek(xFilial("SW6")+MV_PAR01)) .And.  !SW2->(dbSeek(xFilial("SW2")+MV_PAR01)))//        !ExistCpo("SW6",MV_PAR01)
           MsgInfo(STR0130) //"Registro não encontrado."
           RETURN .F.
        ELSEIF !EMPTY(MV_PAR01)
           MV_PAR02:=SPACE(LEN(SYT->YT_COD_IMP))         
           MV_PAR03:=SPACE(LEN(SA2->A2_COD))
           MV_PAR04:=SPACE(LEN(SA2->A2_LOJA)) 
           MV_PAR05:=SPACE(LEN(SA2->A2_GRUPO))           
        ENDIF

   CASE cVar=="GRUPO" //MV_PAR05
        IF !Empty(MV_PAR05) .AND. !ExistCpo("SX5","Y7"+MV_PAR05)
           RETURN .F.
        ELSEIF !EMPTY(MV_PAR03)
           SA2->(DBSEEK(xFilial()+MV_PAR03))
           MV_PAR05:=SA2->A2_GRUPO
        ENDIF

   CASE cVar=="TITULO" //MV_PAR09
        IF STR(MV_PAR09,1) = "2"
           MV_PAR08:=" "
        ENDIF   

   CASE cVar=="DATA" //MV_PAR07
        IF !EMPTY(MV_PAR07)
           IF MV_PAR07 < MV_PAR06
              IF !lEMail
                 Help("",1,"AVG0001006")
                 RETURN .F.
              ELSE
                 ConOut("EICTR350: Datas Invalidas no Relatorio: "+STR0001)
              ENDIF
           ENDIF
        ENDIF
   CASE cVar=="REGISTRO"  // GFP - 25/08/2014
      IF !EMPTY(MV_PAR08)
         IF !ExistCpo("SX5", "Y6"+mv_par08)
            RETURN .F.
         ENDIF
      ENDIF
ENDCASE      

If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"SX1VALID"),)//JMS

RETURN .T.                

// EJA - 20/07/2017 - Converte o valor do menu Tipo Contrato da Pergunta, para o valor do banco de dados
Static Function askToTPCon(nAsk)

    DO CASE
    CASE nAsk == 2
        Return AvKey("2", "WB_TP_CON")
    CASE nAsk == 3
        Return AvKey("4", "WB_TP_CON")
    ENDCASE

*--------------------------------*

// EJA - 20/07/2017 - Converte o valor do banco de dados para o index do array ("1" - Cambio Imp(1), "4" - Remessa(2))
static function contrToArr(cTpContr)
    DO CASE
    CASE cTpContr == AvKey("2", "WB_TP_CON")
        Return 1
    CASE cTpContr == AvKey("4", "WB_TP_CON")
        Return 2
    ENDCASE

*--------------------------------*


*--------------------------------*
STATIC FUNCTION TR350Processa()
*--------------------------------*
LOCAL cCampos,cQuery:=cFrom:=" "
LOCAL nContador,lNaoVazio,nRecno:=0 
Local nPos:=0,nValor:=0
Private lLoja:= .T.
PRIVATE aImportador:={},aProcesso:={}  
aTotTpCamb:={}
aTCambG:={}
//WORK->(avzap())

cFilSA2:=xFilial("SA2"); cFilSW2:=xFilial("SW2")
cFilSW6:=xFilial("SW6"); cFilSW9:=xFilial("SW9")
cFilSY6:=xFilial("SY6"); cFilSYT:=xFilial("SYT")
cFilSW7:=xFilial("SW7"); cFilSWB:=xFilial("SWB")
cFilSW8:=xFilial("SW8"); cFilSYW:=xFilial("SYW")

IF LEFT(cTipoTit,1) $ "13" //COM CAMBIO OU AMBOS
   SWB->(DBSETORDER(1))
   SW9->(DBSETORDER(1))     
      
   IF !lEMail      //AWR
      PROCREGUA(SWB->(LASTREC()))   
   ENDIF 
   
   IF (lNaoVazio:=!EMPTY(cHAWB))
      SWB->(DBSEEK(cFilSWB+AvKey(cHAWB,"WB_HAWB")))
   ELSE
      SWB->(DBSEEK(cFilSWB))
   ENDIF
      
   DO WHILE SWB->(!EOF()) .AND. SWB->WB_FILIAL==cFilSWB .AND.;
            IF(lNaoVazio,SWB->WB_HAWB==AvKey(cHAWB,"WB_HAWB"),.T.)
            
      TR350INCPROC("Lendo Hawb: "+SWB->WB_HAWB) 
      
      If LEFT(cTipoTit,1) $ "13" //COM CAMBIO
         IF !EMPTY(SWB->WB_CA_DT)
            SWB->(DBSKIP())
            LOOP
         ENDIF
      EndIf
      //Alcir Alves - 01-12-05
      IF lTPCONExt .and. !EMPTY(mv_par08) //TIPO DE REGISTRO
         if Left(SWB->WB_TIPOREG,1) # Alltrim(mv_par08)
            SWB->(DBSKIP())
            LOOP
         endif
      endif

      // EJA - 20/07/2017 -  
      if lTPCONExt //TIPO DE CONTRATO
         IF !EMPTY(mv_par12) .AND. mv_par12 != 1
            if SWB->WB_TP_CON # askToTPCon(mv_par12)
               SWB->(DBSKIP())
               LOOP
            endif
         endif
      endif

      IF !(SWB->WB_DT_VEN>=dDtini .AND. SWB->WB_DT_VEN<=dDtFim)
         SWB->(DBSKIP())
         LOOP
      ENDIF

      IF !Empty(cTipoReg) .AND. Left(SWB->WB_TIPOREG,1)<> LEFT(cTipoReg,1)
         SWB->(DBSKIP())
         LOOP
      ENDIF
      
      IF EICLOJA()
         IF !EMPTY(cForn) .AND. !EMPTY(cLoja) .AND. (SWB->WB_FORN<>cForn .OR. SWB->WB_LOJA<> cLoja)
            SWB->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         IF !EMPTY(cForn) .AND. SWB->WB_FORN <> cForn
            SWB->(DBSKIP())
            LOOP
         ENDIF
      ENDIF
      
      IF !EMPTY(cCorretor) .AND. SWB->WB_CORRETO <> cCorretor
         SWB->(DBSKIP())
         LOOP
      ENDIF
      
      IF lCposAdto .AND. SWB->WB_PO_DI == "A"					// GCC - 24/09/2013
         SW2->(DBSEEK(cFilSW2+Alltrim(SWB->WB_HAWB)))
         cValidImp:= SW2->W2_IMPORT
         cCondPag := SW2->W2_COND_PA
         nDiasPag := SW2->W2_DIAS_PA
         nValSWB  := SWB->WB_PGTANT
         cFOBMoeda:= SW2->W2_MOEDA
	  ElseIf SWB->WB_PO_DI == "C" .Or. SWB->WB_PO_DI == "F"		// GCC - 24/09/2013
	     cValidImp:= ""
         cCondPag := SWB->WB_FORMPAG
         nDiasPag := 0
         nValSWB  := SWB->WB_PGTANT
         cFOBMoeda:= SWB->WB_MOEDA
      ElseIf lTPCONExt .and. Left(SWB->WB_TIPOREG,1) == "A"
         SW6->(DBSEEK(cFilSW6+SWB->WB_HAWB))
         cValidImp:= SW6->W6_IMPORT
         cCondPag := SW6->W6_CONDP_F
         nDiasPag := SW6->W6_DIASP_F
         nValSWB  := SWB->WB_FOBMOE
         cFOBMoeda:= SW6->W6_FREMOED
      ElseIf lTPCONExt .and. Left(SWB->WB_TIPOREG,1) == "B"
         SW6->(DBSEEK(cFilSW6+SWB->WB_HAWB))
         cValidImp:= SW6->W6_IMPORT
         cCondPag := SW6->W6_CONDP_S
         nDiasPag := SW6->W6_DIASP_S
         nValSWB  := SWB->WB_FOBMOE
         cFOBMoeda:= SW6->W6_SEGMOED
      ELSE
         //TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
         SW9->(DBSEEK(cFilSW9+SWB->WB_INVOICE+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")+SWB->WB_HAWB))
         SW6->(DBSEEK(cFilSW6+SWB->WB_HAWB))
         cValidImp:=SW6->W6_IMPORT
         cCondPag :=SW9->W9_COND_PA
         nDiasPag :=SW9->W9_DIAS_PA
         nValSWB  :=SWB->WB_FOBMOE
         cFOBMoeda:=SW9->W9_MOE_FOB
      ENDIF
         
      If nValSWB=0  //Parcela de Andiantamento
         SWB->(DBSKIP())
         LOOP
      Endif
        
      SA2->(DBSEEK(cFilSA2+SWB->WB_FORN+EICRetLoja("SWB","WB_LOJA")))

      IF !EMPTY(cGrupo) .AND. SA2->A2_GRUPO<>cGrupo
         SWB->(DBSKIP())
         LOOP
      ENDIF
         
      If SWB->WB_PO_DI $ "AD"   
         If !Empty(cImport) .AND. cImport<>cValidImp
            SWB->(DbSkip())
            Loop
         EndIf
        
         SY6->(DbSeek(xFilial("SY6")+cCondPag+STR(nDiasPag,3,0)))
         If SY6->Y6_TIPOCOB =="4"
            SWB->(DbSkip())
            Loop
         EndIf         
         
         SW7->(DBSEEK(cFilSW7+SWB->WB_HAWB))
         
      EndIf
         
      SYW->(DBSEEK(cFilSYW+SWB->WB_CORRETO))
      
      
      If EICLoja()
         lLoja:= cLoja == SA2->A2_LOJA   .Or. Empty(cLoja)
      EndIf 
      
      If lLoja
      
         WORK->(DBAPPEND())
         WORK->WKFILIAL  :=SWB->WB_FILIAL
         WORK->WKFORN    :=SA2->A2_COD 
         If EICLoja()
            WORK->WKFORLOJ := SA2->A2_LOJA
         EndIf        
         WORK->WKNOM_FORN:=SA2->A2_NREDUZ
         WORK->WKGRUPO   :=SA2->A2_GRUPO
         WORK->WKHAWB    :=SWB->WB_HAWB
         WORK->WKIMPORT  :=cValidImp
         WORK->WB_BANCO  :=SWB->WB_BANCO
         WORK->WB_AGENCIA:=SWB->WB_AGENCIA         
         WORK->WB_NR_ROF :=SWB->WB_NR_ROF
         WORK->WKDT_VEN  :=SWB->WB_DT_VEN 
         WORK->WKINVOICE :=SWB->WB_INVOICE
         WORK->WKLINHA   :=SWB->WB_LINHA
         WORK->WKLIMBAC  :=SWB->WB_LIM_BAC
         WORK->WKAPE_NUM :=SWB->WB_NUM
         WORK->WKOBS     :=MSMM(SWB->WB_OBS,AVSX3("WB_VM_OBS",03))
         If !lTPCONExt
            WORK->WKTIPO    :=Left(SWB->WB_TIPOREG,1)
         EndIf
         WORK->WB_CORRETO:=SWB->WB_CORRETO+' '+ALLTRIM(SYW->YW_NOME)
         WORK->WKMOEDA   :=cFobMoeda
         WORK->WKCOND_PA :=cCondPag
         WORK->WKDIAS_PA :=nDiasPag
         WORK->WKVL_MOE  :=nValSWB               
         nValor:=IF(cMoedaDolar==cFobMoeda, nValSWB, nValSWB * BuscaTaxa(cFobMoeda,dDataBase,.T.,.F.,.T.) /BuscaTaxa(cMoedaDolar,dDataBase,.T.,.F.,.T.))
         WORK->WKVL_USD  :=nValor
         //Alcir Alves - 01-12-05
         If lTPCONExt
            WORK->WKTPREG:=Left(SWB->WB_TIPOREG,1)
            WORK->WKTPREGD:=Posicione("SX5",1,xFilial("SX5")+"Y6"+SWB->WB_TIPOREG, "X5_DESCRI") 
            //Totais por DI por tipo reg
            nPos:=ASCAN(aTotTpCamb,{|A| A[1] == (SWB->WB_HAWB+WORK->WKTPREG+WORK->WKMOEDA)})
            IF nPos == 0
               AADD(aTotTpCamb,{(SWB->WB_HAWB+Left(SWB->WB_TIPOREG,1)+WORK->WKMOEDA),SWB->WB_HAWB,WORK->WKTPREG,WORK->WKMOEDA,alltrim(WORK->WKTPREG)+"-"+alltrim(WORK->WKTPREGD),WORK->WKVL_MOE})
            ELSE
               aTotTpCamb[nPos,5]+=nValor
            ENDIF   
      
         //Totais Geral por tipo reg
         nPos:=ASCAN(aTCambG,{|A| A[1] == (WORK->WKTPREG+WORK->WKMOEDA)})
         IF nPos == 0
            AADD(aTCambG,{(WORK->WKTPREG+WORK->WKMOEDA),WORK->WKTPREG,WORK->WKMOEDA,alltrim(WORK->WKTPREG)+"-"+alltrim(WORK->WKTPREGD),WORK->WKVL_MOE})
         ELSE
            aTCambG[nPos,5]+=WORK->WKVL_MOE
         ENDIF   
      
            if !empty(SWB->WB_TP_CON)
               WORK->WK_TPCON:=cTpContr[contrToArr(SWB->WB_TP_CON)]
            endif
         endif
        
         IF lCposAdto .AND. (SWB->WB_PO_DI == "A" .Or. SWB->WB_PO_DI == "F" .Or. SWB->WB_PO_DI == "C" )	// GCC - 28/08/2013 
            WORK->WKHAWB    :=SWB->WB_HAWB         
            lImpObs:=.T.
         ELSE
            WORK->WKNR_DI   :=SW6->W6_DI_NUM
            WORK->WKDT_DI   :=SW6->W6_DT_DESE
            WORK->WKDT_EMB  :=SW6->W6_DT_EMB         
         ENDIF   
      
         IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GRV_WORK"),)
      EndIf
      SWB->(DBSKIP())
   ENDDO   
ENDIF                  
   
// EJA - Somente para quando Tipo de Contrato for "Todos" ou "Câmbio de Imp."
IF (cTipoTit$"23" .AND. (Empty(cTipoReg) .Or. Left(cTipoReg,1)== "1" ) ) .And. (mv_par12 == 1 .Or. mv_par12 == 2)
   // SEM CAMBIO SO TEM PRINCIPAL E TODOS 
             
   SW9->(DBSETORDER(3))
   SWB->(DBSETORDER(1))
   IF (lNaoVazio:=!EMPTY(cHAWB))
      SW9->(DBSEEK(cFilSW9+cHAWB))
   ELSE
      SW9->(DBSEEK(cFilSW9))
   ENDIF
      
   DO WHILE SW9->(!EOF()) .AND. SW9->W9_FILIAL==cFilSW9 .AND.IF(lNaoVazio,RTRIM(SW9->W9_HAWB)==RTRIM(cHAWB),.T.)
      
      TR350INCPROC(STR0038+":"+SW9->W9_HAWB)
         
      IF EICLOJA()
         IF !EMPTY(cForn) .AND. !EMPTY(cLoja) .AND. SW9->W9_FORN<>cForn .AND. SW9->W9_FORLOJ<> cLoja
            SW9->(DBSKIP())
            LOOP   
         ENDIF
      ELSE
         IF !EMPTY(cForn) .AND. SW9->W9_FORN<>cForn
            SW9->(DBSKIP())
            LOOP   
         ENDIF
      ENDIF
      
      IF SWB->(DBSEEK(cFilSWB+SW9->W9_HAWB+"D"+SW9->W9_INVOICE+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
         SW9->(DBSKIP())
         LOOP   
      ENDIF 
      
      IF !(SW9->W9_DT_EMIS>=dDtini .AND. SW9->W9_DT_EMIS<=dDtFim)
         SW9->(DBSKIP())
         LOOP
      ENDIF
      
      SY6->(DBSEEK(xFilial("SY6")+SW9->W9_COND_PA+STR(SW9->W9_DIAS_PA,3,0)))
      IF SY6->Y6_TIPOCOB =="4"
         SW9->(DBSKIP())
         LOOP
      ENDIF

      SA2->(DBSEEK(cFilSA2+SW9->W9_FORN+EICRetLoja("SW9","W9_FORLOJ")))
      IF !EMPTY(cGrupo) .AND. SA2->A2_GRUPO<>cGrupo
         SW9->(DBSKIP())
         LOOP
      ENDIF
         
      SW6->(DBSEEK(cFilSW9+SW9->W9_HAWB))
      IF !EMPTY(cImport) .AND. SW6->W6_IMPORT<>cImport
         SW9->(DBSKIP())
         LOOP
      ENDIF           
         
      SW7->(DBSEEK(cFilSW7+SW9->W9_HAWB))
      If EICLoja()
         lLoja:= cLoja == SA2->A2_LOJA  .Or. Empty(cLoja)
      EndIf
      
      If lLoja
      
         WORK->(DBAPPEND())      
         WORK->WKFILIAL  :=cFILSWB
         WORK->WKFORN    :=SA2->A2_COD 
         IF EICLoja()
            WORK->WKFORLOJ := SA2->A2_LOJA
         EndIf
         WORK->WKNOM_FORN:=SA2->A2_NREDUZ
         If !lTPCONExt
            WORK->WKTIPO    :="1"
         EndIf
         WORK->WKIMPORT  :=SW6->W6_IMPORT
         WORK->WKDT_EMB  :=SW6->W6_DT_EMB
         WORK->WKNR_DI   :=SW6->W6_DI_NUM
         WORK->WKDT_DI   :=SW6->W6_DT_DESE        
         WORK->WKGRUPO   :=SA2->A2_GRUPO
         WORK->WKINVOICE :=SW9->W9_INVOICE
         WORK->WKFLAGINV :="*" 
         WORK->WKLINHA   :=SWB->WB_LINHA
         WORK->WKCOND_PA :=SW9->W9_COND_PA
         WORK->WKDIAS_PA :=SW9->W9_DIAS_PA
         WORK->WKHAWB    :=SW9->W9_HAWB
         WORK->WKMOEDA   :=SW9->W9_MOE_FOB
         WORK->WKVL_MOE  :=DI500RetVal("TOT_INV", "TAB", .T.) // EOB - 11/06/08 - Chamada da função DI500RetVal
         WORK->WKVL_USD  :=IF(cMoedaDolar==SW9->W9_MOE_FOB,Work->WKVL_MOE, WORK->WKVL_MOE*BuscaTaxa(SW9->W9_MOE_FOB,dDataBase,.T.,.F.,.T.) /BuscaTaxa(cMoedaDolar,dDataBase,.T.,.F.,.T.))
         IF lTPCONExt
            WORK->WKTPREG:="1     "  //JWJ 06/11/06 - Corrigido para '1'
            WORK->WKTPREGD:=Posicione("SX5",1,xFilial("SX5")+"Y6"+WORK->WKTPREG, "X5_DESCRI") 
            WORK->WK_TPCON:=cTpContr[1] // EJA - 20/07/2017 - Index ajustado para Continuar como Câmbio de Importação
            nPos:=ASCAN(aTCambG,{|A| A[1] == (WORK->WKTPREG+WORK->WKMOEDA)})
            IF nPos == 0
               AADD(aTCambG,{(WORK->WKTPREG+WORK->WKMOEDA),WORK->WKTPREG,WORK->WKMOEDA,alltrim(WORK->WKTPREG)+"-"+alltrim(WORK->WKTPREGD),WORK->WKVL_MOE})
            ELSE
               aTCambG[nPos,5]+=WORK->WKVL_MOE
            ENDIF   
         EndIf
      EndIf
      SW9->(DBSKIP())
   ENDDO             
   IF lEMail 
      CALCULA_PARCELAS()
   ELSE
      PROCESSA({|| CALCULA_PARCELAS() })
   ENDIF
ENDIF    
WORK->(DBSETORDER(1))
WORK->(DBGOTOP())
aImportador:={}
aProcesso:={}  
aMoedaTotais:={}
aTotaisMoedas:={}

ProcRegua(WORK->(Lastrec()))
DO WHILE !WORK->(EOF())//Esse processamento deve ser na ordem "1" do Work por que eh a ordem que imprime
   IncProc(STR0048+WORK->WKHAWB) //"Processando Hawb No: "
   //WORK->WKFLAGWIN:=IF(EMPTY(WORK->WKDT_VEN) .OR. WORK->WKDT_VEN > MDt48H,'  ',cMarca) //comentado por wfs em 06/05/11

   //WFS 06/05/11
   If Empty(WORK->WKDT_VEN) .OR. WORK->WKDT_VEN > MDt48H //01 - A vencer
      WORK->WKFLAGWIN:= "01"
   ElseIf WORK->WKDT_VEN >= dDataBase //02 - Vence em até dois dias
      WORK->WKFLAGWIN:= "02"
   Else //Vencidas
      WORK->WKFLAGWIN:= "03"
   EndIf
   
   
   IF (ASCAN(aImportador,WORK->WKIMPORT))==0
      WORK->WKQUEBRA:=WORK->WKIMPORT            
      AADD(aImportador,WORK->WKIMPORT)
   ENDIF                           
   IF (ASCAN(aProcesso,WORK->WKHAWB))==0
      WORK->WKQUEBRA1:=WORK->WKHAWB            
      AADD(aProcesso,WORK->WKHAWB)
   ENDIF                                       
   IF !WORK->WKMOEDA $ cMoedaDolar
      IF (nPos:=ASCAN(aMoedaTotais,{|A| A[1] == WORK->WKMOEDA })) = 0
         AADD(aMoedaTotais,{WORK->WKMOEDA,WORK->WKVL_MOE})
      ELSE
         aMoedaTotais[nPos,2]+=WORK->WKVL_MOE
      ENDIF   
   ENDIF   
   IF (nPos:=ASCAN(aMoedaTotais,{|A| A[1] == cMoedaDolar })) = 0
      AADD(aMoedaTotais,{cMoedaDolar,WORK->WKVL_USD})
   ELSE
      aMoedaTotais[nPos,2]+=WORK->WKVL_USD
   ENDIF   
   WORK->(DBSKIP())
ENDDO

RETURN .T.


/*
// HVR 08/06/2006
Processa EEQ e grava na WORK, seguindo exemplo para SWB
*/

*--------------------------------*
STATIC FUNCTION TR350PrEEQ()
*--------------------------------*
LOCAL cCampos,cQuery:=cFrom:=" "
LOCAL nContador,lNaoVazio,nRecno:=0 
Local nPos:=0,nValor:=0
PRIVATE aImportador:={},aProcesso:={}  
aTotTpCamb:={}
aTCambG:={}


cFilSA2:=xFilial("SA2")
cFilSY6:=xFilial("SY6"); cFilSYT:=xFilial("SYT")
cFilEEQ:=xFilial("EEQ")
cFilSYW:=xFilial("SYW")

IF LEFT(cTipoTit,1) $ "13" //COM CAMBIO OU AMBOS
   EEQ->(DBSETORDER(1))
      
   IF !lEMail
      PROCREGUA(EEQ->(LASTREC()))   
   ENDIF 
   
   IF (lNaoVazio:=!EMPTY(cHAWB))
      EEQ->(DBSEEK(cFilEEQ+cHAWB))
   ELSE
      EEQ->(DBSEEK(cFilSWB))
   ENDIF
      
   DO WHILE EEQ->(!EOF()) .AND. EEQ->EEQ_FILIAL==cFilEEQ .AND.;
            IF(lNaoVazio,EEQ->EEQ_PREEMB==cHAWB,.T.)

      TR350INCPROC("Lendo Hawb: "+EEQ->EEQ_PREEMB) 
     
        // EJA - 21/07/2017 - Se diferente de 1-Todos e diferente de 2-Remessa, então pular o registro
        IF mv_par12 != 1 .And. mv_par12 != 3
            EEQ->(DBSKIP())
            LOOP
        END IF

        IF EEQ->EEQ_TP_CON <> "4"
            EEQ->(DBSKIP())
            LOOP
        ENDIF

        // EJA - 21/07/2017 - Para garantir que o EEQ_TIPO será somente pagamento (P).
        If EEQ->EEQ_TIPO # "P"
            EEQ->(DBSKIP())
            LOOP
        Endif

      //
      IF !(EEQ->EEQ_VCT>=dDtini .AND. EEQ->EEQ_VCT<=dDtFim)
         EEQ->(DBSKIP())
         LOOP
      ENDIF

      IF EICLOJA()
         IF !EMPTY(cForn) .AND. !EMPTY(cLoja) .AND. (EEQ->EEQ_FORN<>cForn .OR. EEQ->EEQ_FOLOJA<> cLoja)  // GFP - 26/08/2014
            EEQ->(DBSKIP())
            LOOP
         ENDIF
      ELSE
         IF !EMPTY(cForn) .AND. EEQ->EEQ_FORN<>cForn
            EEQ->(DBSKIP())
            LOOP   
         ENDIF
      ENDIF
      
      IF !EMPTY(cCorretor) .AND. EEQ->EEQ_CORR <> cCorretor
         EEQ->(DBSKIP())
         LOOP
      ENDIF

//         cValidImp:=EEQ->EEQ_IMPORT
         cCondPag :=""//SW2->W2_COND_PA
         nDiasPag :=0//SW2->W2_DIAS_PA
         nValSWB  :=EEQ->EEQ_VL//SWB->WB_PGTANT
         cFOBMoeda:=EEQ->EEQ_MOEDA
         
/*      If nValSWB=0  //Parcela de Andiantamento
         SWB->(DBSKIP())
         LOOP
      Endif
*/
        
      SA2->(DBSEEK(cFilSA2+EEQ->EEQ_FORN))

      IF !EMPTY(cGrupo) .AND. SA2->A2_GRUPO<>cGrupo
         EEQ->(DBSKIP())
         LOOP
      ENDIF

/*         
      IF !EMPTY(cImport) .AND. cImport<>cValidImp
         EEQ->(DBSKIP())
         LOOP
      ENDIF
  
*/
      SYW->(DBSEEK(cFilSYW+EEQ->EEQ_CORR))
      
      If EICLoja()
         lLoja:= cLoja == SA2->A2_LOJA  .Or. Empty(cLoja)
      EndIf
      
      If lLoja
         
         WORK->(DBAPPEND())
         WORK->WKFILIAL  :=EEQ->EEQ_FILIAL
         WORK->WKFORN    :=SA2->A2_COD
         If EICLoja()
            WORK->WKFORLOJ := SA2->A2_LOJA
         EndIf         
         WORK->WKNOM_FORN:=SA2->A2_NREDUZ
         WORK->WKGRUPO   :=SA2->A2_GRUPO
         WORK->WKHAWB    :=EEQ->EEQ_PREEMB
         WORK->WKIMPORT  :="" //cValidImp
         WORK->WB_BANCO  :=EEQ->EEQ_BANC
         WORK->WB_AGENCIA:=EEQ->EEQ_AGEN         
         WORK->WB_NR_ROF :=""
         WORK->WKDT_VEN  :=EEQ->EEQ_VCT
         WORK->WKINVOICE :=EEQ->EEQ_NRINVO
         WORK->WKLINHA   :=EEQ->EEQ_PARC

      WORK->WKTPREG   :=""
      WORK->WKAPE_NUM :=""//SWB->WB_NUM
      WORK->WKOBS     :="" //MSMM(EEQ->EEQ_OBS,AVSX3("EEQ_VM_OBS",03))
      If !lTPCONExt
         WORK->WKTIPO    :=""//SWB->WB_TIPOREG
      EndIf
      WORK->WB_CORRETO:=EEQ->EEQ_CORR+' '+ALLTRIM(SYW->YW_NOME)
      WORK->WKMOEDA   :=cFobMoeda
      WORK->WKCOND_PA :=cCondPag
      WORK->WKDIAS_PA :=nDiasPag
      WORK->WKVL_MOE  :=nValSWB               
      nValor:=IF(cMoedaDolar==cFobMoeda, nValSWB, nValSWB * BuscaTaxa(EEQ->EEQ_MOEDA,dDataBase,.T.,.F.,.T.) /BuscaTaxa(cMoedaDolar,dDataBase,.T.,.F.,.T.))
      WORK->WKVL_USD  :=nValor

      If lTPCONExt
         //Totais por DI por tipo reg
         nPos:=ASCAN(aTotTpCamb,{|A| A[1] == (EEQ->EEQ_PREEMB+WORK->WKTPREG+WORK->WKMOEDA)})
         IF nPos == 0
            AADD(aTotTpCamb,{(EEQ->EEQ_PREEMB+""+WORK->WKMOEDA),EEQ->EEQ_PREEMB,WORK->WKTPREG,WORK->WKMOEDA,alltrim(WORK->WKTPREG)+"-"+alltrim(WORK->WKTPREGD),WORK->WKVL_MOE})
         ELSE
            aTotTpCamb[nPos,5]+=nValor
         ENDIF   
      
         //Totais Geral por tipo reg
         nPos:=ASCAN(aTCambG,{|A| A[1] == (WORK->WKTPREG+WORK->WKMOEDA)})
         IF nPos == 0
            AADD(aTCambG,{(WORK->WKTPREG+WORK->WKMOEDA),WORK->WKTPREG,WORK->WKMOEDA,alltrim(WORK->WKTPREG)+"-"+alltrim(WORK->WKTPREGD),WORK->WKVL_MOE})
         ELSE
            aTCambG[nPos,5]+=WORK->WKVL_MOE
         ENDIF   
      
         if !empty(EEQ->EEQ_TP_CON)
            WORK->WK_TPCON:=cTpContr[contrToArr(EEQ->EEQ_TP_CON)]
         endif
      endif

         WORK->WKNR_DI   :=""//SW6->W6_DI_NUM
         WORK->WKDT_DI   :=CTOD("01/01/01")//SW6->W6_DT_DESE
         WORK->WKDT_EMB  :=CTOD("01/01/01")//SW6->W6_DT_EMB         
      
      IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GRV_WORK"),)
      EndIf
      EEQ->(DBSKIP())
   ENDDO   
ENDIF                  

         //Totais Geral por tipo reg
WORK->(DBSETORDER(1))
WORK->(DBGOTOP())
aImportador:={}
aProcesso:={}  
aMoedaTotais:={}
aTotaisMoedas:={}

ProcRegua(WORK->(Lastrec()))
DO WHILE !WORK->(EOF())//Esse processamento deve ser na ordem "1" do Work por que eh a ordem que imprime
   IncProc(STR0048+WORK->WKHAWB) //"Processando Hawb No: "
   //WORK->WKFLAGWIN:=IF(EMPTY(WORK->WKDT_VEN) .OR. WORK->WKDT_VEN > MDt48H,'  ',cMarca) //comentado por wfs em 06/05/11
   
   //WFS 06/05/11
   If Empty(WORK->WKDT_VEN) .OR. WORK->WKDT_VEN > MDt48H //01 - A vencer
      WORK->WKFLAGWIN:= "01"
   ElseIf WORK->WKDT_VEN >= dDataBase //02 - Vence em até dois dias
      WORK->WKFLAGWIN:= "02"
   Else //Vencidas
      WORK->WKFLAGWIN:= "03"
   EndIf

   IF (ASCAN(aImportador,WORK->WKIMPORT))==0
      WORK->WKQUEBRA:=WORK->WKIMPORT            
      AADD(aImportador,WORK->WKIMPORT)
   ENDIF                           
   IF (ASCAN(aProcesso,WORK->WKHAWB))==0
      WORK->WKQUEBRA1:=WORK->WKHAWB            
      AADD(aProcesso,WORK->WKHAWB)
   ENDIF                                       
   IF !WORK->WKMOEDA $ cMoedaDolar
      IF (nPos:=ASCAN(aMoedaTotais,{|A| A[1] == WORK->WKMOEDA })) = 0
         AADD(aMoedaTotais,{WORK->WKMOEDA,WORK->WKVL_MOE})
      ELSE
         aMoedaTotais[nPos,2]+=WORK->WKVL_MOE
      ENDIF   
   ENDIF   
   IF (nPos:=ASCAN(aMoedaTotais,{|A| A[1] == cMoedaDolar })) = 0
      AADD(aMoedaTotais,{cMoedaDolar,WORK->WKVL_USD})
   ELSE
      aMoedaTotais[nPos,2]+=WORK->WKVL_USD
   ENDIF   
   WORK->(DBSKIP())
ENDDO

RETURN .T.
/*
HVR***
*/

*----------------------------------------*
STATIC FUNCTION CALCULA_PARCELAS()
*----------------------------------------*      
LOCAL nColuna,nAscan,dDataEmb,aValores, nContador
LOCAL nRecno,lDeleta,dVencimento,dDataVenc
LOCAL cMoe := BuscaDolar()//GETNEWPAR("MV_SIMB2","US$")
LOCAL cData := ALLTRIM(GETNEWPAR("MV_DTB_APD","WORK->WKDT_EMB"))
PRIVATE dDtEmb
PRIVATE nVlrInvoice

cMoe := IF( EMPTY(cMoe),"US$" ,cMoe)
WORK->(DBSETORDER(3))
IF !lEMail      //AWR
   PROCREGUA(WORK->(LASTREC()))
ENDIF
nCont := 0      
WORK->(DBGOTOP())

DO WHILE WORK->(!EOF())
   nCont:=0
                                                                         
   IF Work->WKFLAGINV <> "*"
     Work->(DBSKIP())
     LOOP
   ENDIF  

   TR350INCPROC("Calculando Parcelas Invoice "+WORK->WKINVOICE)      
      
   SW6->(DBSEEK(cFilSW6+WORK->WKHAWB)) 

   dDataEmb := FI400DTRefTaxa(, , .F.) //LRS 

   //dDataEmb:= IF(!EMPTY(cData),&cData,Work->WKDT_EMB)
         
   IF EMPTY(dDataEmb)
      dDataEmb:=IF(!EMPTY(SW6->W6_DT_ETA),SW6->W6_DT_ETA,dDataBase)
   ENDIF
         
   dDataAVista:=IF(!EMPTY(SW6->W6_DT_DESE),SW6->W6_DT_DESE,dDataEmb)

   SY6->(DBSEEK(cFilSY6+WORK->WKCOND_PA+STR(WORK->WKDIAS_PA,3,0)))
         
         
   IF SY6->Y6_TIPOCOB=="4"  .OR. Work->WKDIAS_PA < -1 // SEM COBERTURA OU ANTECIPADO
      WORK->(DBDELETE())
      WORK->(DBSKIP())
      LOOP
   ENDIF

   dDtEmb:=dDataEmb      //FMB - 21/09/04
   
	IF EasyEntryPoint("EICTR350") 
   	ExecBlock("EICTR350",.F.,.F.,"DATA_EMBARQUE")
   ENDIF         
   
   dDataEmb:=dDtEmb
         
   IF WORK->WKDIAS_PA  == -1     
      IF dDataAVista < dDtini .OR. dDataAvista > dDtFim
       Work->(DBDELETE())                              
      ELSE      
        WORK->WKDT_VEN:=dDataAVista
        WORK->WKVL_USD  :=IF(Work->WKMOEDA == cMoe , Work->WKVL_MOE,WORK->WKVL_MOE*BuscaTaxa(WORK->WKMOEDA,dDataBase,.T.,.F.,.T.)/BuscaTaxa(cMoe,dDataBase,.T.,.F.,.T.))
      ENDIF  
      WORK->(DBSKIP())
      LOOP                            
   ELSEIF WORK->WKDIAS_PA>=0 .AND. WORK->WKDIAS_PA<900         
      dVencimento :=dDataEmb + SY6->Y6_DIAS_PA
      IF dVencimento>=dDtini .AND. dVencimento<=dDtFim
         WORK->WKDT_VEN:=dVencimento            
      ELSE
         WORK->(DBDELETE())
      ENDIF
       WORK->(DBSKIP())
      LOOP
   ELSEIF WORK->WKDIAS_PA>=900            
      lDeleta:=.F.
      nVlrInvoice:=WORK->WKVL_MOE
      nRecno:=WORK->(Recno())
      aValores:={}
      FOR nColuna:=1 TO WORK->(Fcount())
         AADD(aValores,{WORK->(FieldName(nColuna)),WORK->(FieldGet(nColuna))})
      NEXT
      FOR nContador:=1 TO 10      
         IF SY6->(&("Y6_DIAS_"+STRZERO(nContador,2)))=0
            EXIT 
         ELSEIF SY6->(&("Y6_DIAS_"+STRZERO(nContador,2))) < 0
           LOOP
         ENDIF              
         lDeleta:=.T.                    
         nVlrParcela:=nVlrInvoice*(SY6->&("Y6_PERC_"+STRZERO(nContador,2)))/100
         dDataVenc  :=dDataEmb+SY6->(&("Y6_DIAS_"+STRZERO(nContador,2)))
         IF nVlrParcela<>0 .AND. (dDataVenc>=dDtini .AND. dDataVenc<=dDtFim)             
            WORK->(DBAPPEND())
            nCont++
            FOR nColuna:=1 TO WORK->(Fcount())
               IF (nAscan:=Ascan(aValores,{|a|a[1]==WORK->(FieldName(nColuna))}))<>0
                  WORK->(FIELDPUT(nColuna,aValores[nAscan,2]))
               ENDIF
            NEXT
            WORK->WKVL_MOE  :=nVlrParcela
            WORK->WKVL_USD  :=IF(cMoe==Work->WKMOEDA,nVlrParcela,nVlrParcela*BuscaTaxa(WORK->WKMOEDA,dDataBase,.T.,.F.,.T.)/BuscaTaxa(cMoe,dDataBase,.T.,.F.,.T.))
            WORK->WKDT_VEN  :=dDataVenc
            If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.f.,.f.,"APOS_CALC_PARCELA"),) //JAP - 23/08/06
         ENDIF   
      NEXT 
         
      IF lDeleta
         WORK->(DBGOTO(nRecno))
         cChave:=WORK->WKIMPORT+WORK->WKHAWB+WORK->WKINVOICE+WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")
         WORK->(DBDELETE())
      ENDIF               
         
   ENDIF      
   WORK->(DBSKIP(nCont+1))
ENDDO      
RETURN .T.      
*-----------------------------*
STATIC FUNCTION TR350BROWSE()
*-----------------------------*
LOCAL oDlgBrow
Local aLeg:= {}
Local aButtons:= {}
Private nOrdem // usado no rdmake
DBSELECTAREA("Work")
WORK->(DBGOTOP())

IF WORK->(BOF()) .AND. WORK->(EOF())
   IF !lEMail
      Help(" ",1,"EICSEMREG")
   ELSE
      ConOut("EICTR350: Nao possui Itens Relatorio: "+STR0001)
   ENDIF
ELSEIF !lEMail
   Tb_Campos:={}      
   //AADD(TB_Campos,{"WKFLAGWIN"           ,,"  "      }) comentado por WFS em 06/05/11
   AADD(TB_Campos,{{||WORK->WKFILIAL+'-'+AvgFilName({WORK->WKFILIAL})[1]},,AVSX3("WB_FILIAL",5)})  // Filial
   AADD(TB_Campos,{{||WORK->WKIMPORT}            ,,"Imp."    })
   If lTPCONExt
      AADD(TB_Campos,{{||alltrim(WORK->WKTPREG)+"-"+alltrim(WORK->WKTPREGD)},,AVSX3("WB_TIPOREG",5)}) //Tipo de reg. - Alcir Alves - 01-12-05
   EndIf
   AADD(TB_Campos,{{||WORK->WKHAWB}              ,,STR0010   }) //"Processo"
   AADD(TB_Campos,{{||WORK->WKFORN+" - "+EICRetLoja("WORK","WKFORLOJ")+' '+WORK->WKNOM_FORN},, IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"
   AADD(TB_Campos,{{||WORK->WKGRUPO }            ,,STR0112 })
   AADD(TB_Campos,{{||WORK->WKINVOICE }          ,,AVSX3("EEQ_NRINVO",5)})
   AADD(TB_Campos,{{||WORK->WKLINHA }            ,,AVSX3("WB_LINHA",5)})
   AADD(TB_Campos,{{||TRAN(WORK->WKAPE_NUM,AVSX3("WB_NUM",6))}  ,,STR0017    }) //"Nro. APE"
   AADD(TB_Campos,{{||WORK->WKDT_EMB}            ,,STR0011 }) //"Embarque"
   AADD(TB_Campos,{{||WORK->WKMOEDA+' '+TRAN(WORK->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
   AADD(TB_Campos,{{||TRAN(WORK->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar }) //"Valor US$"
   AADD(TB_Campos,{{||WORK->WB_CORRETO}          ,,AVSX3("WB_CORRETO",5),AVSX3("WB_CORRETO",6) })
   AADD(TB_Campos,{{||WORK->WKCOND_PA}           ,,"Cond Pa"})
   AADD(TB_Campos,{{||TRANS(WORK->WKDIAS_PA, "999")},,"Dias"})
//   AADD(TB_Campos,{{||WORK->WKDT_VEN}            ,,STR0009 }) //"Vencto"
   AADD(TB_Campos,{{||WORK->WKDT_VEN}            ,,"Vencto" }) //"Vencto"
   AADD(TB_Campos,{{||TRANS(WORK->WKNR_DI,'@R 99/9999999-9')},,STR0021    }) //"No. D.I."
   AADD(TB_Campos,{{||WORK->WKDT_DI}             ,,STR0022    }) //"Dt. Desemb."
   AADD(TB_Campos,{{||WORK->WKLIMBAC}            ,,"Dt Bacen" })
   AADD(TB_Campos,{{||WORK->WKOBS}               ,,STR0018 }) //"Observacoes"
   If lTPCONExt
      AADD(TB_Campos,{{||WORK->WK_TPCON}               ,,AVSX3("WB_TP_CON",5)}) //Tipo de cambio - Alcir Alves - 01-12-05
   ENDIF
   oMainWnd:ReadClientCoors()             
   
   IF cTipoOrd=="1"    //Processo
      nOrdem := 1
   ELSEIF cTipoOrd=="2"//Vencimento
      nOrdem := 4
   ELSEIF cTipoOrd=="3"//Fornecedor
      nOrdem := 8
   ELSEIF cTipoOrd=="4"//Grupo
      nOrdem := 9
   ENDIF             
   If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.f.,.f.,"TELA_BROWSE"),)//AAF
   WORK->(DBSETORDER(nOrdem))

   //WFS 06/05/11 regra para legenda
   AAdd(aLeg,{"WORK->WKFLAGWIN == '01'" , "BR_VERDE"})
   AAdd(aLeg,{"WORK->WKFLAGWIN == '02'" , "BR_AMARELO"})
   AAdd(aLeg,{"WORK->WKFLAGWIN == '03'" , "BR_VERMELHO"})
   
   AAdd(aButtons, {"SVM",{|| TR350Legenda()}, "Legenda","Legenda"})
   WORK->(DBGOTOP())
   DEFINE MSDIALOG oDlgBrow TITLE STR0001;
          FROM oMainWnd:nTop+125,oMainWnd:nLeft+5 TO oMainWnd:nBottom-60,oMainWnd:nRight-10 ;
          OF oMainWnd PIXEL  
      
      
      Aadd( aButtons, {STR0041, {|| (TR350Busca(),oMark:oBrowse:Refresh())}, STR0041, STR0041 , {|| .T.}} ) //"Pesquisar"         
      Aadd( aButtons, {STR0042, {|| TR350Arq("WORK")}, STR0042, STR0042 , {|| .T.}} )                       //"Gerar Arquivo"
      Aadd( aButtons, {STR0043, {|| TR350Arq("RELATORIO")}, STR0043, STR0043 , {|| .T.}} )                  //"Relatorio"
              
      IF cTipoOrd=="1" .OR. cTipoOrd=="2" .OR. cTipoOrd=="3" .OR. cTipoOrd=="4"
         Aadd( aButtons, {STR0044, {|| TR350Pedido()}, STR0044, STR0044 , {|| .T.}} )                       //"Fechamento"         
      ENDIF      
      oMark:=MsSelect():New("WORK",,,TB_Campos,@lInverte,"",{38,3,(oDlgBrow:nHeight-30)/2,(oDlgBrow:nClientWidth-4)/2},,,,,aLeg)
      oMark:bAval:={||.T.}
      oMark:oBrowse:bWhen:={||DBSELECTAREA("WORK"),.T.}
      
	  oMark:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT	   //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   
   oDlgBrow:lMaximized:=.T.
   ACTIVATE MSDIALOG oDlgBrow ON INIT (EnchoiceBar(oDlgBrow,{||nOpca:=OK,oDlgBrow:End()},{||nOpca:=CANCEL,oDlgBrow:End()},,aButtons)) //LRL 13/04/04 - Alinhamento MDI. //BCO 13/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

ELSEIF lEMail
   TR350Arq("RELATORIO")
ENDIF

DBSELECTAREA("WORK")
     
RETURN .T.

*-------------------------------* 
STATIC FUNCTION TR350Arq(cTipo)
*-------------------------------*                                                   
LOCAL oDlgA,aCamposReport:={},nOpcao:=CANCEL
LOCAL aVencimento	:={},nInd
Local aDeletados	:= {}
PRIVATE nTPRegVal:=0,cChave:=" ",lPrimeiro:=.T., lE_Report := .T.,aCampos:={}
PRIVATE cTipo_RDM := cTipo //AAF - 09/06/04 - Possibilita cTipo ser usada em RDMAKE

PRIVATE cTitArqS := "Follow Up Câmbio - Sintético"

PRIVATE cTitArqA := "Follow Up Câmbio - Analítico"

PRIVATE aTitulosA:= {{"Filial"             ,"WKFILIAL"       ,"",,,"",,"C"},;
                     {"Flag"               ,"WKFLAGWIN"      ,"",,,"",,"C"},;
                     {"Tipo"               ,"WKTIPO"         ,"",,,"",,"C"},;
                     {"Observacão"         ,"WKOBS"          ,"",,,"",,"C"},;
                     {"Pedido"             ,"WKPO_NUM"       ,"",,,"",,"C"},;
                     {"Importador"         ,"WKIMPORT"       ,"",,,"",,"C"},;
                     {"Quebra"             ,"WKQUEBRA"       ,"",,,"",,"C"},;
                     {"Processo"           ,"WKHAWB"         ,"",,,"",,"C"},;          
                     {"Quebra 1"           ,"WKQUEBRA1"      ,"",,,"",,"C"},;
                     {"Fornecedor"         ,"WKFORN"         ,"",,,"",,"C"}}
//ISS - 27/09/10 - Adição do campo loja do fornecedor caso o EIC esteja tratando a loja
If EICLOJA()
      Aadd(aTitulosA,{"Loja Forn."         ,"WKFORLOJ"       ,"",,,"",,"C"})
EndIf
                     
      Aadd(aTitulosA,{"Nome Forn."         ,"WKNOM_FORN"     ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Grupo"              ,"WKGRUPO"        ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Invoice"            ,"WKINVOICE"      ,"",,,"",,"C"})      
      Aadd(aTitulosA,{"Linha"              ,"WKLINHA"        ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Aviso Banc."        ,"WKAPE_NUM"      ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Moeda"              ,"WKMOEDA"        ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Cond. Pagto"        ,"WKCOND_PA"      ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Nro DI"             ,"WKNR_DI"        ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Banco"              ,"WB_BANCO"       ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Agencia"            ,"WB_AGENCIA"     ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Nro ROF"            ,"WB_NR_ROF"      ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Corretor"           ,"WB_CORRETO"     ,"",,,"",,"C"})
      Aadd(aTitulosA,{"Data DI"            ,"WKDT_DI"        ,"",,,"",,"D"})
      Aadd(aTitulosA,{"Data Emb."          ,"WKDT_EMB"       ,"",,,"",,"D"})
      Aadd(aTitulosA,{"Data Venc."         ,"WKDT_VEN"       ,"",,,"",,"D"})
      Aadd(aTitulosA,{"Data NF"            ,"WKDT_NF"        ,"",,,"",,"D"})
      Aadd(aTitulosA,{"Data Bacen"         ,"WKLIMBAC"       ,"",,,"",,"D"})
      Aadd(aTitulosA,{"FOB Total"          ,"WKFOB_TOT"      ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Inland"             ,"WK_INLAND"      ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Frete"              ,"WK_FRETEIN"     ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Packing"            ,"WK_PACKING"     ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Outras Desp."       ,"WK_OUTDESP"     ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Desconto"           ,"WK_DESCONT"     ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Valor Moeda"        ,"WKVL_MOE"       ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Valor USD"          ,"WKVL_USD"       ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Dias Pagto"         ,"WKDIAS_PA"      ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Recno"              ,"WKRECNO"        ,"",,,"",,"N"})
      Aadd(aTitulosA,{"Condes"             ,"WKCONDES"       ,"",,,"",,"C"})

PRIVATE aTitulosS:= {{"Filial"             ,"WKFILIAL"       ,"",,,"",,"C"},;
                     {"Data NF"            ,"WKDT_NF"        ,"",,,"",,"D"},;
                     {"Data Venc."         ,"WKDT_VEN"       ,"",,,"",,"D"},;
                     {"Data Emb."          ,"WKDT_EMB"       ,"",,,"",,"D"},;
                     {"Importador"         ,"WKIMPORT"       ,"",,,"",,"C"},;
                     {"Quebra"             ,"WKQUEBRA"       ,"",,,"",,"C"},;
                     {"Processo"           ,"WKHAWB"         ,"",,,"",,"C"},;
                     {"Quebra 1"           ,"WKQUEBRA1"      ,"",,,"",,"C"},;
                     {"Moeda"              ,"WKMOEDA"        ,"",,,"",,"C"},;
                     {"Valor Moeda"        ,"WKVL_MOE"       ,"",,,"",,"N"},;
                     {"Valor USD"          ,"WKVL_USD"       ,"",,,"",,"N"}}
                     

lPrimeiro2:=.t.
cChave2:=""
cChaveMoe:=""
cChaveTp:=""

if lTPCONExt
   aadd(aTitulosA,{"Tip. Reg.","WKTPREG"  ,"",,,"",,"C"})
   aadd(aTitulosA,{"Tip. RegD","WKTPREGD" ,"",,,"",,"C"})
   aadd(aTitulosA,{"Tipo Contrato","WK_TPCON" ,"",,,"",,"C"})
endif

IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"ALT_TITULO"),)

IF !lEMail .AND. cTipoOrd $ "1/2"
   DEFINE MSDIALOG oDlgA TITLE "Selecione" From 9,0 To 21,55 OF oMainWnd  
      
      oPanel:= TPanel():New(0, 0, "", oDlgA,, .F., .F.,,, 90, 165) //MCF - 21/07/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      @ 16,35 TO 45,100 LABEL "" OF oPanel PIXEL
      @ 20,50 RADIO nTipo ITEMS aEscolha[1],aEscolha[2] 3D SIZE 45,10 OF oPanel

   ACTIVATE MSDIALOG oDlgA ON INIT (EnchoiceBar(oDlgA,{||nOpcao:=OK,oDlgA:End()},{||nOpcao:=CANCEL,oDlgA:End()})) CENTERED

   IF nOpcao==CANCEL
      RETURN .T.
   ENDIF   
ENDIF                 
WORK->(DBGOTOP())

IF dDtini==AVCTOD("01/01/"+_FirstYear) .AND. dDtFim==AVCTOD("31/12/2999")
   aDados[7]:="Periodo:Todos"
ELSE
   aDados[7]:="Periodo:"+DTOC(dDtini)+" a "+DTOC(dDtFim)
ENDIF   

SX5->(DBSEEK( xFilial("SX5")+"Y6"+ALLTRIM(cTipoReg) ))
aDados[7]+=SPACE(8)+STR0016+": "+aTitulo[MV_PAR09]
IF !EMPTY(cCorretor)
   SYW->(DBSEEK(cFilSYW+cCorretor))
   aDados[7]+=SPACE(8)+AVSX3("WB_CORRETO",5)+": "+cCorretor+' '+ALLTRIM(SYW->YW_NOME)
ENDIF                                                                                                                                                       

aDados[8]:=STR0024+":"+aTipoOrd[MV_PAR10]+"-"+IF(aEscolha[nTipo]==aEscolha[1],"Analitico","Sintetico")+SPACE(2)

If !Empty(cTipoReg)            
   SX5->(DBSEEK( xFilial("SX5")+"Y6"+ALLTRIM(cTipoReg) ))
   aDados[8]+=STR0034+": "+ALLTRIM(SX5->X5_DESCRI)//"Tipo"
Else
   aDados[8]+=STR0034+": "+SubStr(STR0025,3)
EndIf   
             
aAdd(aDeletados, "WKFLAGINV")

nQtdeCol:=if(nTipo==1,218,80)
nPosVlrMoe   :=3
lMaisdeUm    :=.F.

IF cTipoOrd=="1"//ORDEM  PROCESSO 

   IF nTipo==1 //PROCESSO - ANALITICO
    	IF cTipo=="WORK"   //ARQUIVO
        
		   TR350Arquivo("WORK",,aTitulosA,cTitArqA,aDeletados)		      
    	ELSE //RELATORIO 
         DBSELECTAREA("WORK")
         WORK->(DBGOTOP())
	      //Alcir Alves - 01-12-05
	      If !lTPCONExt
   	      AADD(aCamposReport,{{||WORK->WKQUEBRA } ,,"IM"          })
	         AADD(aCamposReport,{{||WORK->WKQUEBRA1 }  ,,STR0010 }) //"Processo"
         EndIf
         //
         AADD(aCamposReport,{{||WORK->WKINVOICE }  ,,AVSX3("EEQ_NRINVO",5)})
         AADD(aCamposReport,{{||WORK->WKLINHA }  ,,AVSX3("WB_LINHA",5)})
         AADD(aCamposReport,{{||WORK->WKGRUPO }    ,,STR0112}) //"GRUPO"         
         If EICLoja()   //Acb - 19/11/2010
            AADD(aCamposReport,{{||WORK->WKFORN+"\"+EICRetLoja("WORK","WKFORLOJ")+' '+WORK->WKNOM_FORN},,+IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"         
         Else
            AADD(aCamposReport,{{||WORK->WKFORN+' '+WORK->WKNOM_FORN},,+IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"         
         EndIF
         AADD(aCamposReport,{{||TRAN(WORK->WKAPE_NUM,AVSX3("WB_NUM",6))}  ,,STR0017    }) //"Nro. APE"
         AADD(aCamposReport,{{||WORK->WKDT_EMB } ,,STR0011 }) //"Embarque"
         AADD(aCamposReport,{{||WORK->WKMOEDA+' '+TRAN(WORK->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
         nPosVlrMoe:=LEN(aCamposReport)
         AADD(aCamposReport,{{||TRAN(WORK->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar   }) //"Valor US$"
         AADD(aCamposReport,{{||WORK->WKCOND_PA+'      '+TRANS(WORK->WKDIAS_PA, "999")},,"Cond Pa - Dias"})
//         AADD(aCamposReport,{{||WORK->WKDT_VEN }  ,,STR0009 }) //"Vencto"
         AADD(aCamposReport,{{||WORK->WKDT_VEN }  ,,"Vencto" }) //"Vencto" //ACB - 19/11/2010
         AADD(aCamposReport,{{||TRANS(WORK->WKNR_DI,'@R 99/9999999-9')},,STR0021  }) //"No. D.I."
         AADD(aCamposReport,{{||WORK->WKDT_DI }   ,,STR0022}) //"Dt. D.I."
         AADD(aCamposReport,{{||WORK->WKLIMBAC }  ,,"Lim. Bacen" })//"Dt Bacen"//ACB - 19/11/2010
//         AADD(aCamposReport,{{||WORK->WB_CORRETO },,AVSX3("WB_CORRETO",5) })
         AADD(aCamposReport,{{||WORK->WB_CORRETO },,"Corretor" })//ACB - 19/11/2010
         //Alcir Alves - 01-12-05
         if lTPCONExt         
            AADD(aCamposReport,{{||WORK->WK_TPCON }  ,,AVSX3("WB_TP_CON",5)})
            AADD(aCamposReport,{{||ALLTRIM(WORK->WKTPREG)+"-"+ALLTRIM(WORK->WKTPREGD) }  ,,AVSX3("WB_TIPOREG",5)})    
         endif
         //
         aDados[12][1]:={|| TR350Quebra("PROCESSO_PROCESSO")}
         aDados[5]:="G"
         aDados[6]:=231     
         aDados[1]:="WORK"
         WORK->(DBSETORDER(1))
         aCampos:=E_CriaRCampos(aCamposReport)
		ENDIF
   ELSE	//MOEDA - SINTETICO
      WORK->(DBSETORDER(5))
      WORK->(DBGOTOP())
      WORKB->(avzap())
      cChave   :=WORK->WKFILIAL+WORK->WKHAWB+WORK->WKIMPORT
      aVencimento:={}
      aImportador:={}
      DO WHILE WORK->(!EOF())      
         IF cChave==WORK->WKFILIAL+WORK->WKHAWB+WORK->WKIMPORT
            IF (nAscan1:=ASCAN(aVencimento,{|a|a[1]==WORK->WKMOEDA}))==0
               AADD(aVencimento,{WORK->WKMOEDA,WORK->WKVL_MOE,WORK->WKVL_USD,WORK->WKIMPORT,WORK->WKHAWB,WORK->WKDT_EMB,WORK->WKFILIAL})
            ELSE   
               aVencimento[nAscan1,2]+=WORK->WKVL_MOE
               aVencimento[nAscan1,3]+=WORK->WKVL_USD
            ENDIF
         ELSE
            FOR nInd:=1 TO LEN(aVencimento)
                WORKB->(DBAPPEND())
                WORKB->WKMOEDA :=aVencimento[nInd,1]
                WORKB->WKVL_MOE:=aVencimento[nInd,2]
                WORKB->WKVL_USD:=aVencimento[nInd,3]
                WORKB->WKIMPORT:=aVencimento[nInd,4]
                WORKB->WKHAWB  :=aVencimento[nInd,5]
                WORKB->WKDT_EMB:=aVencimento[nInd,6]
                WORKB->WKFILIAL:=aVencimento[nInd,7]
                IF (ASCAN(aImportador,WORKB->WKIMPORT))==0
                   WORKB->WKQUEBRA:=WORKB->WKIMPORT            
                   AADD(aImportador,WORKB->WKIMPORT)
                ENDIF                  
                IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GRV_WORKB"),)
            NEXT
            cChave   :=WORK->WKFILIAL+WORK->WKHAWB+WORK->WKIMPORT
            aVencimento:={}            
            AADD(aVencimento,{WORK->WKMOEDA,WORK->WKVL_MOE,WORK->WKVL_USD,WORK->WKIMPORT,WORK->WKHAWB,WORK->WKDT_EMB,WORK->WKFILIAL})            
         ENDIF   
         WORK->(DBSKIP())
      ENDDO      
      FOR nInd:=1 TO LEN(aVencimento)
          WORKB->(DBAPPEND())
          WORKB->WKMOEDA :=aVencimento[nInd,1]
          WORKB->WKVL_MOE:=aVencimento[nInd,2]
          WORKB->WKVL_USD:=aVencimento[nInd,3]
          WORKB->WKIMPORT:=aVencimento[nInd,4]
          WORKB->WKHAWB  :=aVencimento[nInd,5]
          WORKB->WKDT_EMB:=aVencimento[nInd,6]
          WORKB->WKFILIAL:=aVencimento[nInd,7]
          IF (ASCAN(aImportador,WORKB->WKIMPORT))==0
             WORKB->WKQUEBRA:=WORKB->WKIMPORT            
             AADD(aImportador,WORKB->WKIMPORT)
          ENDIF              
          IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GRV_WORKB"),)
      NEXT
      
   	  IF cTipo=="WORK" //ARQUIVO
      			TR350Arquivo("WORKB",,aTitulosS,cTitArqS)
     	ELSE         //RELATORIO
         AADD(aCamposReport,{{||WORKB->WKQUEBRA} ,,"IM"          })
        	AADD(aCamposReport,{{||WORKB->WKHAWB }   ,,STR0010 }) //"Processo"
         AADD(aCamposReport,{{||WORKB->WKDT_EMB}  ,,STR0011 }) //"Embarque"
         AADD(aCamposReport,{{||WORKB->WKMOEDA+' '+TRAN(WORKB->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
         nPosVlrMoe:=LEN(aCamposReport)
         AADD(aCamposReport,{{||TRAN(WORKB->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar   }) //"Valor US$"
         aDados[12][1]:={|| TR350QBFIL()}
         aDados[12][2]:={|| TR350Totais(aMoedaTotais ,.F.,"Geral") }
         aDados[1]:="WORKB"
         aDados[5]:="P"
         aDados[6]:=80      
         aCampos:=E_CriaRCampos(aCamposReport)      
      ENDIF   
   ENDIF	
    	
ELSEIF cTipoOrd=="2"  //ORDEM POR VENCIMENTO
   IF nTipo==1 //PROCESSO - ANALITICO
   	  IF cTipo=="WORK" //ARQUIVO
         // aAdd(aDeletados, "WKFLAGINV")
         TR350Arquivo("WORK",,aTitulosA,cTitArqA,aDeletados)
         // TR350Arquivo("WORK",,aTitulosA,cTitArqA)
         ELSE  //RELATORIO
         WORK->(DBGOTOP())
         AADD(aCamposReport,{{||WORK->WKIMPORT} ,,"IM"          })
         AADD(aCamposReport,{{||WORK->WKHAWB}    ,,STR0010 }) //"Processo"
         If EICLoja()    //Acb - 19/11/2010
            AADD(aCamposReport,{{||WORK->WKFORN+"\"+EICRetLoja("WORK","WKFORLOJ")+' '+WORK->WKNOM_FORN},,+IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"         
         Else
            AADD(aCamposReport,{{||WORK->WKFORN+' '+WORK->WKNOM_FORN},,+IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"         
         EndIF
         AADD(aCamposReport,{{||WORK->WKINVOICE }                 ,,AVSX3("EEQ_NRINVO",5)})         
         AADD(aCamposReport,{{||WORK->WKLINHA   }                 ,,AVSX3("WB_LINHA",5)})         
   	     AADD(aCamposReport,{{||WORK->WKGRUPO }                    ,,STR0112 })
         AADD(aCamposReport,{{||TRAN(WORK->WKAPE_NUM,AVSX3("WB_NUM",6))}  ,,STR0017    }) //"Nro. APE"
         AADD(aCamposReport,{{||WORK->WKDT_EMB}  ,,STR0011 }) //"Embarque"
         AADD(aCamposReport,{{||WORK->WKMOEDA+' '+TRAN(WORK->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
         nPosVlrMoe:=LEN(aCamposReport)
         AADD(aCamposReport,{{||TRAN(WORK->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar   }) //"Valor US$"
         AADD(aCamposReport,{{||WORK->WKCOND_PA},,"Cond Pa"})
         AADD(aCamposReport,{{||TRANS(WORK->WKDIAS_PA, "999")}     ,,"Dias"})
         AADD(aCamposReport,{{||TRANS(WORK->WKNR_DI,'@R 99/9999999-9')},,STR0021    }) //"No. D.I."
         AADD(aCamposReport,{{||WORK->WKDT_DI}   ,,STR0022    }) //"Dt. D.I."
//         AADD(aCamposReport,{{||WORK->WKLIMBAC}  ,,AVSX3("WB_LIM_BAC",5) })//"Dt Bacen"
         AADD(aCamposReport,{{||WORK->WKLIMBAC}  ,,"Lim. Bacen" })//"Dt Bacen"//ACB - 19/11/2010
//         AADD(aCamposReport,{{||WORK->WB_CORRETO},,AVSX3("WB_CORRETO",5) })
         AADD(aCamposReport,{{||WORK->WB_CORRETO},,"Corretor" })//ACB - 19/11/2010
         AADD(aCamposReport,{{||WORK->WKOBS}     ,,STR0018 }) //"Observacoes"
  	      //Alcir Alves - 01-12-05
         //if lTPCONExt         
         //   AADD(aCamposReport,{{||WORK->WK_TPCON }  ,,AVSX3("WB_TP_CON",5)})
         //endif
         //

         WORK->(DBSETORDER(2))
         aDados[1]:="WORK"
         aDados[12][1]:={|| TR350Quebra("VENCIMENTO_PROCESSO")}
         aDados[5]:="G"
         aDados[6]:=231      
         aCampos:=E_CriaRCampos(aCamposReport)
      ENDIF      
   ELSE  //MOEDA - SINTETICO
      WORK->(DBSETORDER(2))      
      WORK->(DBGOTOP())
      WORKA->(avzap())
      cChave   :=WORK->WKFILIAL+DTOS(WORK->WKDT_VEN)
      aVencimento:={}
      DO WHILE WORK->(!EOF())      
         IF cChave==WORK->WKFILIAL+DTOS(WORK->WKDT_VEN)             
            IF (nAscan:=ASCAN(aVencimento,{|a|a[1]==WORK->WKIMPORT}))==0
               AADD(aVencimento,{WORK->WKIMPORT,WORK->WKMOEDA,WORK->WKVL_MOE,WORK->WKVL_USD,WORK->WKDT_VEN,WORK->WKFILIAL})
            ELSE
               IF (nAscan1:=ASCAN(aVencimento,{|a|a[2]==WORK->WKMOEDA}))==0
                  AADD(aVencimento,{WORK->WKIMPORT,WORK->WKMOEDA,WORK->WKVL_MOE,WORK->WKVL_USD,WORK->WKDT_VEN,WORK->WKFILIAL})
               ELSE   
                  aVencimento[nAscan1,3]+=WORK->WKVL_MOE
                  aVencimento[nAscan1,4]+=WORK->WKVL_USD
               ENDIF   
            ENDIF             
         ELSE                 
            FOR nInd:=1 TO LEN(aVencimento)
               WORKA->(DBAPPEND())
               WORKA->WKIMPORT:=aVencimento[nInd,1]
               WORKA->WKMOEDA :=aVencimento[nInd,2]
               WORKA->WKVL_MOE:=aVencimento[nInd,3]
               WORKA->WKVL_USD:=aVencimento[nInd,4]
               WORKA->WKDT_VEN:=aVencimento[nInd,5]
               WORKA->WKFILIAL:=aVencimento[nInd,6]
               
               IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GRV_WORKA"),)
               
            NEXT
            cChave   :=WORK->WKFILIAL+DTOS(WORK->WKDT_VEN)
            aVencimento:={}            
            AADD(aVencimento,{WORK->WKIMPORT,WORK->WKMOEDA,WORK->WKVL_MOE,WORK->WKVL_USD,WORK->WKDT_VEN,WORK->WKFILIAL})                                     
         ENDIF      
         WORK->(DBSKIP())
      ENDDO
      
      FOR nInd:=1 TO LEN(aVencimento)
         WORKA->(DBAPPEND())
         WORKA->WKIMPORT:=aVencimento[nInd,1]
         WORKA->WKMOEDA :=aVencimento[nInd,2]
         WORKA->WKVL_MOE:=aVencimento[nInd,3]
         WORKA->WKVL_USD:=aVencimento[nInd,4]
         WORKA->WKDT_VEN:=aVencimento[nInd,5]
         WORKA->WKFILIAL:=aVencimento[nInd,6]         
         
         IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GRV_WORKA"),)

      NEXT
      
   	  IF cTipo=="WORK" //ARQUIVO
         TR350Arquivo("WORKA")
      ELSE         //RELATORIO      
//         AADD(aCamposReport,{{||WORKA->WKDT_VEN}  ,,STR0009 }) //"Vencto"            
         AADD(aCamposReport,{{||WORKA->WKDT_VEN}  ,,"Vencto" }) //"Vencto"             //ACB - 19/11/2010
         AADD(aCamposReport,{{||WORKA->WKMOEDA+' '+TRAN(WORKA->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
         nPosVlrMoe:=LEN(aCamposReport)
         AADD(aCamposReport,{{||TRAN(WORKA->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar   }) //"Valor US$"
         aDados[1]:="WORKA"
         aDados[5]:="P"
         aDados[6]:=80      
         aDados[12][1]:={|| TR350Quebra("VENCIMENTO_MOEDA")}
         aDados[12][2]:={|| TR350Totais(aMoedaTotais ,.F.,"") }
         cChave2:=" "		
         cChave:=" "		
         aCampos:=E_CriaRCampos(aCamposReport)
      ENDIF
   ENDIF   
ELSEIF cTipoOrd=="3"  //ORDEM POR FORNECEDOR
// ANALITICO
    IF cTipo=="WORK" //ARQUIVO
         TR350Arquivo("WORK",,aTitulosA,cTitArqA,aDeletados)
         //  TR350Arquivo("WORK",,aTitulosA,cTitArqA)
    ELSE  //RELATORIO
       WORK->(DBGOTOP())
//       AADD(aCamposReport,{{||WORK->WKDT_VEN}  ,,STR0009 }) //"Vencto"
       AADD(aCamposReport,{{||WORK->WKDT_VEN}  ,,"Vencto" }) //"Vencto"//ACB - 19/11/2010
       AADD(aCamposReport,{{||WORK->WKIMPORT}  ,,"IM"          })
       AADD(aCamposReport,{{||WORK->WKHAWB}    ,,STR0010 }) //"Processo"
       AADD(aCamposReport,{{||WORK->WKINVOICE} ,,AVSX3("EEQ_NRINVO",5)})         
       AADD(aCamposReport,{{||WORK->WKLINHA}   ,,AVSX3("WB_LINHA",5)})         
       AADD(aCamposReport,{{||WORK->WKGRUPO }                           ,,STR0112 })
       AADD(aCamposReport,{{||TRAN(WORK->WKAPE_NUM,AVSX3("WB_NUM",6))}  ,,STR0017    }) //"Nro. APE"
       AADD(aCamposReport,{{||WORK->WKDT_EMB}  ,,STR0011 }) //"Embarque"
       AADD(aCamposReport,{{||WORK->WKMOEDA+' '+TRAN(WORK->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
       nPosVlrMoe:=LEN(aCamposReport)
       AADD(aCamposReport,{{||TRAN(WORK->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar   }) //"Valor US$"
       AADD(aCamposReport,{{||WORK->WKCOND_PA},,"Cond Pa"})
       AADD(aCamposReport,{{||TRANS(WORK->WKDIAS_PA, "999")}     ,,"Dias"})
       AADD(aCamposReport,{{||TRANS(WORK->WKNR_DI,'@R 99/9999999-9')}     ,,STR0021    }) //"No. D.I."
       AADD(aCamposReport,{{||WORK->WKDT_DI}   ,,STR0022    }) //"Dt. D.I."
//       AADD(aCamposReport,{{||WORK->WKLIMBAC}  ,,AVSX3("WB_LIM_BAC",5) })//"Dt Bacen"
       AADD(aCamposReport,{{||WORK->WKLIMBAC}  ,,"Lim. Bacen" })//"Dt Bacen"           //ACB - 19/11/2010
//       AADD(aCamposReport,{{||WORK->WB_CORRETO},,AVSX3("WB_CORRETO",5) })
       AADD(aCamposReport,{{||WORK->WB_CORRETO},,"Corretor" })//ACB - 19/11/2010
       AADD(aCamposReport,{{||WORK->WKOBS}                              ,,STR0018 }) //"Observacoes"
       //Alcir Alves - 01-12-05
       if lTPCONExt         
          AADD(aCamposReport,{{||WORK->WK_TPCON }  ,,AVSX3("WB_TP_CON",5)})
          //AADD(aCamposReport,{{||ALLTRIM(WORK->WKTPREG)+"-"+ALLTRIM(WORK->WKTPREGD) }  ,,AVSX3("WB_TIPOREG",5)})
       endif
       
       WORK->(DBSETORDER(8))
       aDados[1]:="WORK"
       aDados[5]:="G"
       aDados[6]:=231     
       aDados[8]:=STR0024+":"+aTipoOrd[MV_PAR10]+"-"+aEscolha[1]
       aDados[12][1]:={|| TR350Quebra("FORNECEDOR") }
       cChave:=" "		
       aCampos:=E_CriaRCampos(aCamposReport)
    ENDIF      

ELSEIF cTipoOrd=="4"  //ORDEM POR FORNECEDOR
// ANALITICO
    IF cTipo=="WORK" //ARQUIVO
         TR350Arquivo("WORK",,aTitulosA,cTitArqA,aDeletados)
         // TR350Arquivo("WORK",,aTitulosA,cTitArqA)
    ELSE  //RELATORIO
       WORK->(DBGOTOP())
//       AADD(aCamposReport,{{||WORK->WKDT_VEN}  ,,STR0009 }) //"Vencto"
       AADD(aCamposReport,{{||WORK->WKDT_VEN}  ,,"Vencto" }) //"Vencto"//ACB - 19/11/2010
       AADD(aCamposReport,{{||WORK->WKIMPORT} ,,"IM"          })
       AADD(aCamposReport,{{||WORK->WKHAWB}   ,,STR0010 }) //"Processo"
       If EICLoja() //Acb - 19/11/2010
          AADD(aCamposReport,{{|| WORK->WKFORN+"\"+EICRetLoja("WORK","WKFORLOJ")+' '+WORK->WKNOM_FORN},, IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"	
       Else
          AADD(aCamposReport,{{|| WORK->WKFORN+' '+WORK->WKNOM_FORN},, IF(lEFFTpMod, STR0122,STR0015)}) //"Fornecedor"	
       endIf
       AADD(aCamposReport,{{||WORK->WKINVOICE } ,,AVSX3("EEQ_NRINVO",5)})         
       AADD(aCamposReport,{{||WORK->WKLINHA } ,,AVSX3("WB_LINHA",5)})         
       AADD(aCamposReport,{{||TRAN(WORK->WKAPE_NUM,AVSX3("WB_NUM",6))}  ,,STR0017    }) //"Nro. APE"
       AADD(aCamposReport,{{||WORK->WKDT_EMB}  ,,STR0011 }) //"Embarque"
       AADD(aCamposReport,{{||WORK->WKMOEDA+' '+TRAN(WORK->WKVL_MOE,AVSX3("WB_FOBMOE",6))},,STR0012 })//"Valor Moeda"
       nPosVlrMoe:=LEN(aCamposReport)
       AADD(aCamposReport,{{||TRAN(WORK->WKVL_USD,AVSX3("WB_FOBMOE",6))},,SUBSTR(STR0013,1,6)+cMoedaDolar   }) //"Valor US$"
       AADD(aCamposReport,{{||WORK->WKCOND_PA},,"Cond Pa"})
       AADD(aCamposReport,{{||TRANS(WORK->WKDIAS_PA, "999")}     ,,"Dias"})
       AADD(aCamposReport,{{||TRANS(WORK->WKNR_DI,'@R 99/9999999-9')}     ,,STR0021    }) //"No. D.I."
       AADD(aCamposReport,{{||WORK->WKDT_DI}   ,,STR0022    }) //"Dt. D.I."
//       AADD(aCamposReport,{{||WORK->WKLIMBAC}  ,,AVSX3("WB_LIM_BAC",5) })//"Dt Bacen"
       AADD(aCamposReport,{{||WORK->WKLIMBAC}  ,,"Lim. Bacen"})//"Dt Bacen"//ACB - 19/11/2010
//       AADD(aCamposReport,{{||WORK->WB_CORRETO},,AVSX3("WB_CORRETO",5) })
       AADD(aCamposReport,{{||WORK->WB_CORRETO},,"Corretor"})//ACB - 19/11/2010
       AADD(aCamposReport,{{||WORK->WKOBS}     ,,STR0018 }) //"Observacoes"
       WORK->(DBSETORDER(9))
       aDados[1]:="WORK"
       aDados[5]:="G"
       aDados[6]:=231     
       aDados[8]:=STR0024+":"+aTipoOrd[MV_PAR10]+"-"+aEscolha[1]
       aDados[12][1]:={|| TR350Quebra("GRUPO") }
       cChave:=" "		
       aCampos:=E_CriaRCampos(aCamposReport)
   ENDIF
ENDIF

                   
TotaisMoedas:={}

IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"GERA_REL"),)

IF cTipo # "WORK"
   dbSelectArea(aDados[1])
   
   lE_Report := .T.      
   Work->(dbGoTop())
   
   IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"IMPR_REL"),)
   
   FilAtu:="*"
   aTotalFil:={}
   if lE_Report 
      E_REPORT(aDados,aCampos,,!lEmail)
   endif   
ENDIF

Work->(dbGoTop())

RETURN .T.
*----------------------------------------*
STATIC FUNCTION TR350Quebra(cModoQuebra)
*----------------------------------------*
Local lImport := .F., I
PRIVATE cModoQbg := cModoQuebra // Para ser usado em rdmakes

IF FilAtu == "*" 
   Linha++
   @ Linha,01 PSAY AVSX3("WB_FILIAL",5)+".: "+WORK->WKFILIAL+'-'+AvgFilName({WORK->WKFILIAL})[1]
   Linha++
   FilAtu:=WORK->WKFILIAL
ENDIF   

DO CASE
   CASE cModoQuebra=="PROCESSO_PROCESSO"
      IF cChave <> WORK->WKHAWB
         IF lPrimeiro
            lPrimeiro:=.F.
         ELSE
            IF TR350Totais(aTotaisMoedas,.T.,cTituloAtual)
               Linha++
            ENDIF
            aTotaisMoedas:={}
         ENDIF   
         If lTPCONExt .and. !Empty(Work->WKQUEBRA)
            lImport := .T.
            Linha++
            @Linha,1 PSAY STR0031+":"+ALLTRIM(WORK->WKIMPORT)+"-"+ALLTRIM(Posicione("SYT",1,xFilial("SYT")+WORK->WKIMPORT,"YT_NOME"))
         EndIf
         cChave:=WORK->WKHAWB                                            
         cTituloAtual:=STR0010+": "+cChave// "Processo" 
         IF lTPCONExt
            Linha++
            @Linha,1 PSAY cTituloAtual //Alcir Alves - 30-11-05
         EndIf
      ENDIF
     
      IF lTPCONExt
         IF cChave2<>WORK->WKTPREG+WORK->WKMOEDA
            IF lPrimeiro2
               lPrimeiro2:=.f.
               cChave2:=WORK->WKTPREG+WORK->WKMOEDA
               cChaveMoe:=WORK->WKMOEDA         
               cChaveTp:=WORK->WKTPREG
               nTPRegVal:=WORK->WKVL_MOE
            else
               //@Linha,30 PSAY aTotTpCamb[nPos,5]
               Linha++
               Linha++
               @Linha,51 psay "Total por tipo de registro:"
               @Linha,84 PSAY cChaveMoe+space(1)+transform(nTPRegVal,AVSX3("WB_FOBREAL",6))
               Linha++
               nTPRegVal:=WORK->WKVL_MOE
               cChave2:=WORK->WKTPREG+WORK->WKMOEDA
               cChaveMoe:=WORK->WKMOEDA         
               cChaveTp:=WORK->WKTPREG
            endif
         else
            nTPRegVal+=WORK->WKVL_MOE
         endif
      EndIf
     
   CASE cModoQuebra=="VENCIMENTO_PROCESSO"

      IF cChave <> DTOS(WORK->WKDT_VEN)
         IF lPrimeiro
            lPrimeiro:=.F.
         ELSE
            TR350Totais(aTotaisMoedas,.T.,cTituloAtual)
            aTotaisMoedas:={}
         ENDIF   
         Linha++
         cTituloAtual:="Vencto"+": "+DTOC(WORK->WKDT_VEN)// "Vencimento"//ACB - 19/11/2010
         @Linha,T_Len[1,2] PSAY cTituloAtual
         cChave:=DTOS(WORK->WKDT_VEN)
       ENDIF

   CASE cModoQuebra == "GRUPO"

      IF cChave <> WORK->WKGRUPO
         IF lPrimeiro
            lPrimeiro:=.F.
         ELSE
            TR350Totais(aTotaisMoedas,.T.,cTituloAtual)
            aTotaisMoedas:={}
         ENDIF   
         Linha++
         SX5->(dbseek(xFilial()+"Y7"+WORK->WKGRUPO))
         cTituloAtual:=STR0112+': '+WORK->WKGRUPO+" - "+ALLTRIM(SUBSTR(SX5->X5_DESCRI,5))//'Grupo'
         @Linha,T_Len[1,2] PSAY cTituloAtual
         cChave:=WORK->WKGRUPO         
      ENDIF
                                        
   CASE cModoQuebra == "FORNECEDOR"

      IF cChave <> WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")
         IF lPrimeiro
            lPrimeiro:=.F.
         ELSE
            TR350Totais(aTotaisMoedas,.T.,cTituloAtual)
            aTotaisMoedas:={}
         ENDIF   
         Linha++
//         cTituloAtual:=IF(lEFFTpMod, STR0122,STR0015)+': '+WORK->WKFORN+" "+EICRetLoja("WORK","WKFORLOJ")+' - '+WORK->WKNOM_FORN//"Fornecedor"
         cTituloAtual:=IF(lEFFTpMod, STR0122,STR0015)+': '+WORK->WKFORN+" "+IIF(EICLoja(),WORK->WKFORLOJ,"")+' - '+WORK->WKNOM_FORN//"Fornecedor"//Acb 19/11/2010
         @Linha,T_Len[1,2] PSAY cTituloAtual
//         cChave:=WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")
         cChave:=WORK->WKFORN+IIF(EICLoja(),WORK->WKFORLOJ,"")//ACB - 19/11/2010
      ENDIF

   CASE cModoQuebra=="VENCIMENTO_MOEDA"
      IF cChave<>WORKA->WKIMPORT
         IF lPrimeiro
            Linha++
            lPrimeiro:=.F.
         ELSE
            Linha+=2
         ENDIF   
         @Linha,T_Len[1,2] PSAY STR0031+":"+WORKA->WKIMPORT
         cChave:=WORKA->WKIMPORT
      ENDIF   
      TR350QBFIL()
ENDCASE
IF cModoQuebra $ "PROCESSO_PROCESSO,VENCIMENTO_PROCESSO,GRUPO,FORNECEDOR"
   IF .NOT. (WORK->WKMOEDA $ cMoedaDolar)
      IF (nPos:=ASCAN(aTotaisMoedas,{|A| A[1] == WORK->WKMOEDA })) = 0
         AADD(aTotaisMoedas,{WORK->WKMOEDA,WORK->WKVL_MOE})
      ELSE
         aTotaisMoedas[nPos,2]+=WORK->WKVL_MOE
         lMaisdeUm:=.T.
      ENDIF     
   ENDIF   
   IF (nPos:=ASCAN(aTotaisMoedas,{|A| A[1] == cMoedaDolar})) = 0
      AADD(aTotaisMoedas,{cMoedaDolar,WORK->WKVL_USD})
   ELSE
      aTotaisMoedas[nPos,2]+=WORK->WKVL_USD
      lMaisdeUm:=.T.
   ENDIF    
ENDIF
If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"SOMA_TOTAIS"),)

IF cModoQuebra $ "PROCESSO_PROCESSO,VENCIMENTO_PROCESSO,GRUPO,FORNECEDOR"
   if FilAtu#WORK->WKFILIAL            
      Linha++   
      @Linha,T_Len[nPosVlrMoe,2] PSAY REPLICATE('-',T_Len[nPosVlrMoe,1])
      Linha+= 1

      @Linha,1 PSAY LEFT(STR0085,6)+AVSX3("WB_FILIAL",5)+".: " +FilAtu+'-'+AvgFilName({FilAtu})[1]
      ASORT(aTotalFil,,,{|x,y| x[1] < y[1]})
      FOR I := 1 TO LEN(aTotalFil)
          IF Linha > 55
             Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
             Linha++    
          ENDIF
          IF !lTPCONExt .or. (lTPCONExt .and. aTotalFil[I,2]>0)
             @Linha,T_Len[nPosVlrMoe,2] PSAY SUBST(aTotalFil[I,1],3)+" "+TRANS(aTotalFil[I,2],cPict)
          ENDIF
          Linha++                       
      Next
      @ Linha, 01 PSAY REPLICATE("=",218)   
      
      Linha++
      @ Linha,01 PSAY AVSX3("WB_FILIAL",5)+".: "+WORK->WKFILIAL+'-'+AvgFilName({WORK->WKFILIAL})[1]
      Linha++
   
      FilAtu:=WORK->WKFILIAL 
      ASIZE(aTotalFil,0)
   endif

   IF .NOT. (WORK->WKMOEDA $ cMoedaDolar)
      IF (nPos:=ASCAN(aTotalFil,{|A| A[1] ==WORK->WKFILIAL+WORK->WKMOEDA })) = 0
         AADD(aTotalFil,{WORK->WKFILIAL+WORK->WKMOEDA,WORK->WKVL_MOE})
      ELSE
         aTotalFil[nPos,2]+=WORK->WKVL_MOE
      ENDIF     
   ENDIF   
   IF (nPos:=ASCAN(aTotalFil,{|A| A[1] == WORK->WKFILIAL+cMoedaDolar})) = 0
      AADD(aTotalFil,{WORK->WKFILIAL+cMoedaDolar,WORK->WKVL_USD})
   ELSE
      aTotalFil[nPos,2]+=WORK->WKVL_USD
   ENDIF    
ENDIF

RETURN .T.

*------------------------------------------*
FUNCTION TR350Totais(aTotais,lTeste,cLChave)
*------------------------------------------*
LOCAL cFilName:=FilAtu+'-'+AvgFilName({FilAtu})[1]


Local ni:=0
LOCAL I:= 0
PRIVATE cChave:=cLChave// P/ o rdmake

IF lTeste .AND. !lMaisdeUm
   Linha++
   lMaisdeUm:=.F.
   RETURN .F.
ENDIF

ASORT(aTotais,,,{|x,y| x[1] < y[1]})

Linha++   
IF Linha > 56
   Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
   Linha++    
ENDIF

//Alcir Alves - 02-12-05
IF lTPCONExt .and. nTipo==1
   if nTPRegVal>0
   //Linha++
   Linha++
   @Linha,51 psay "Total por tipo de registro:"
   @Linha,84 PSAY cChaveMoe+space(1)+transform(nTPRegVal,AVSX3("WB_FOBREAL",6))
   Linha++
   Linha++
   nTPRegVal:=0
   cChave2:=WORK->WKTPREG+WORK->WKMOEDA
   cChaveMoe:=WORK->WKMOEDA         
   cChaveTp:=WORK->WKTPREG
   lPrimeiro2:=.f.
   endif
ENDIF


IF ! lTeste
   IF(aDados[1]=="WORKA",cFilName:="",)
   @Linha++,T_Len[nPosVlrMoe,2] PSAY REPLICATE('-',T_Len[nPosVlrMoe,1])

   @Linha,1 PSAY LEFT(STR0085,6)+IF(aDados[6]<>80,AVSX3("WB_FILIAL",5),"")+".: " +cFilName   // total filial
   ASORT(aTotalFil,,,{|x,y| x[1] < y[1]})
   FOR I := 1 TO LEN(aTotalFil)
       IF !lTPCONExt .or. (lTPCONExt .and. aTotalFil[I,2]>0)
          @Linha,T_Len[nPosVlrMoe,2] PSAY SUBST(aTotalFil[I,1],3)+" "+TRANS(aTotalFil[I,2],cPict)
       ENDIF
       Linha++
   Next

   @ Linha, 01 PSAY REPLICATE("=",nQtdeCol)   
   Linha++
ENDIF
If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"IMP_TRACO"),)

//Linha++
@Linha,iif(lTPCONExt .and. cChave<>"Geral",5,1) PSAY "Total "+ALLTRIM(cChave)
FOR I := 1 TO LEN(aTotais)
    IF Linha > 55
       Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
       Linha++    
    ENDIF
    IF !lTPCONExt .or. (lTPCONExt .and. aTotais[I,2]>0)
       @Linha,T_Len[nPosVlrMoe,2] PSAY aTotais[I,1]+" "+TRANS(aTotais[I,2],cPict)
    ENDIF
    If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"IMP_VALOR"),)

    Linha++
Next
IF LEN(aTotais) > 1
   Linha--
ENDIF
lMaisdeUm:=.F.
aTotaisMoedas:={}


//Alcir Alves - 01-12-05
If lTPCONExt
   Linha++
   @Linha,T_Len[nPosVlrMoe,2] PSAY REPLICATE('-',T_Len[nPosVlrMoe,1])
   Linha+= 1

   /*
   if cChave<>"Geral" .and. nTipo==1
      nPos:=ASCAN(aTotTpCamb,{|A| A[2] == substr(cChave,11,28)})
      if nPos>0
         Linha++
         @Linha,5 PSAY "Total por tipo registro:"//+ALLTRIM(substr(cChave,11,28))
         Linha++
         do while  nPos<=len(aTotTpCamb) .and. aTotTpCamb[nPos,2]==SWB->WB_HAWB 
            @Linha,30 PSAY aTotTpCamb[nPos,5]
            @Linha,73 PSAY aTotTpCamb[nPos,4]+space(1)+transform(aTotTpCamb[nPos,6],AVSX3("WB_FOBREAL",6))
            Linha++   
            nPos++
         enddo
      endif

   elseif cChave=="Geral"
   */
   if cChave=="Geral"
      if len(aTCambG)>0 .and. nTipo==1
         Linha++
         Linha++
         ASORT(aTCambG,,,{|x,y| x[4] < y[4]})
         @Linha,1 PSAY "Total geral "+If(lTPCONExt,"tipo registro:",":")//+ALLTRIM(substr(cChave,11,28))
         for ni=1 to len(aTCambG)
            If lTPCONExt
               @Linha,30 PSAY aTCambG[ni,4]
            EndIf
            @Linha,73 PSAY aTCambG[ni,3]+space(1)+transform(aTCambG[ni,5],AVSX3("WB_FOBREAL",6))
            Linha++   
         next ni
      endif
   endif
   Linha++
EndIf
//

If cChave=="Geral" .And. lImpObs //Imprimir no Rodapé legenda ref. a pgto antecipado
   Linha+=3
   IF Linha > 56
      Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
      Linha++    
   ENDIF         
   //@Linha,T_Len[1,2] PSAY STR0115  //"Os processos iniciados com * referem-se a Adiantamentos - Número do Pedido"
ENDIF

RETURN .T.

*-----------------------------*
STATIC FUNCTION TR350Works()
*-----------------------------*
Private aDBF:=;
            { {"WKFILIAL"  ,"C",FWSizeFilial(),0},;
              {"WKFLAGWIN" ,"C",02,0},;
              {"WKTIPO"    ,"C",01,0},;
              {"WKOBS"     ,"C",30,0},;
              {"WKPO_NUM"  ,"C",LEN(SW2->W2_PO_NUM), 0 } ,;
              {"WKIMPORT"  ,"C",LEN(SYT->YT_COD_IMP),0},;
              {"WKQUEBRA"  ,"C",LEN(SYT->YT_COD_IMP),0},;
              {"WKHAWB"    ,"C",AVSX3("W8_HAWB",3),AVSX3("W8_HAWB",4)},;
              {"WKQUEBRA1" ,"C",LEN(EEQ->EEQ_PREEMB),0},;
              {"WKFORN"    ,"C",LEN(SA2->A2_COD)    ,0},;
              {"WKNOM_FORN","C",LEN(SA2->A2_NREDUZ) ,0},;
              {"WKGRUPO"   ,"C",LEN(SA2->A2_GRUPO)  ,0},;
              {"WKINVOICE" ,"C",AVSX3("W8_INVOICE",3),AVSX3("W8_INVOICE",4)},;
              {"WKFLAGINV" ,"C",01,0},;
              {"WKLINHA"   ,"C",LEN(SWB->WB_LINHA)  ,0},;
              {"WKAPE_NUM" ,"C",LEN(SWB->WB_NUM)    ,0},;
              {"WKMOEDA"   ,"C",LEN(SW9->W9_MOE_FOB)  ,0},;
              {"WKCOND_PA" ,"C",LEN(SW9->W9_COND_PA),0},;
              {"WKNR_DI"   ,"C",LEN(SW6->W6_DI_NUM),0},;
              {"WB_BANCO"   ,"C",LEN(SWB->WB_BANCO),0},;
              {"WB_AGENCIA" ,"C",LEN(SWB->WB_AGENCIA),0},;
              {"WB_NR_ROF" ,"C",LEN(SWB->WB_AGENCIA),0},;
              {"WB_CORRETO","C",LEN(SWB->WB_CORRETO)+7,0},;//ACB - 19/11/2010
              {"WKDT_DI"   ,"D",08,0},;
              {"WKDT_EMB"  ,"D", 08,0},;
              {"WKDT_VEN"  ,"D", 08,0},;
              {"WKDT_NF"   ,"D", 08,0},;
              {"WKLIMBAC"  ,"D", 08,0},;
              {"WKFOB_TOT" ,"N",AVSX3("W6_FOB_TOT",3),AVSX3("W6_FOB_TOT",4)},;
              {"WK_INLAND"  ,"N",AVSX3("W9_INLAND",3),AVSX3("W9_INLAND",4)},;
              {"WK_FRETEIN" ,"N",AVSX3("W9_FRETEIN",3),AVSX3("W9_FRETEIN",4)},;
              {"WK_PACKING" ,"N",AVSX3("W9_PACKING",3),AVSX3("W9_PACKING",4)},;
              {"WK_OUTDESP" ,"N",AVSX3("W9_OUTDESP",3),AVSX3("W9_OUTDESP",4)},;
              {"WK_DESCONT" ,"N",AVSX3("W9_DESCONT",3),AVSX3("W9_DESCONT",4)},;
              {"WKVL_MOE"  ,"N",AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)},;
              {"WKVL_USD"  ,"N",AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)},;
              {"WKDIAS_PA" ,"N",AvSX3("Y6_DIAS_PA",3),0},;
              {"WKRECNO"   ,"N",10,0} ,;
              {"WKCONDES"  ,"C",50,0} }

              //ALCIR ALVES - 01-12-05
              if lTPCONExt
                 aadd(aDBF,{"WKTPREG"  ,"C",15,0})
                 aadd(aDBF,{"WKTPREGD"  ,"C",15,0})
                 aadd(aDBF,{"WK_TPCON" ,"C",15,0})
              endif
              //
              
PRIVATE nPontoEntrada := 1 //Para diferenciar o ponto de Entrada já que existe o mesmo Parametro em varios lugares diferentes  JMS
IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"ESTRU_WORK"),)
              
PRIVATE aHeader[0],aCampos:={}//E_CriaTrab utiliza   

If EICLOJA() .And. (nPos := aScan(aDBF, {|x| x[1] == "WKFORN" })) > 0
   aAdd(aDBF, Nil)
   aIns(aDBF, nPos + 1)
   aDBF[nPos+1] := {"WKFORLOJ", "C", AvSx3("A2_LOJA", AV_TAMANHO),0}
EndIf

cWork:=E_CriaTrab(,aDBF,"WORK")

IF !lEMail      //AWR
   PROCREGUA(11)
ENDIF
IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

cIndex1:=E_CREATE(,.F.)
cIndex2:=E_CREATE(,.F.)
cIndex3:=E_CREATE(,.F.)  
cIndex4:=E_CREATE(,.F.)  
cIndex5:=E_CREATE(,.F.)  
cIndex6:=E_CREATE(,.F.)  
cIndex7:=E_CREATE(,.F.)  
cIndex8:=E_CREATE(,.F.)  
cIndex9:=E_CREATE(,.F.)
cIndex10:=E_CREATE(,.F.)

IF !lEMail
   oDlgProc:=GetWndDefault()
   oDlgProc:SetText("Criando Arquivos Temporarios")
ENDIF

TR350INCPROC("Criando Indice 01","Aguarde")

IF EICLOJA()
   INDREGUA("WORK",cIndex1+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+"+If(lTPCONExt,"WKTPREG+","")+"WKFORN+WKFORLOJ+WKINVOICE+DTOS(WKDT_VEN)")
ELSE
   INDREGUA("WORK",cIndex1+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+"+If(lTPCONExt,"WKTPREG+","")+"WKFORN+WKINVOICE+DTOS(WKDT_VEN)")
ENDIF

TR350INCPROC("Criando Indice 02","Aguarde")
INDREGUA("WORK",cIndex2+TEOrdBagExt(),"WKFILIAL+DTOS(WKDT_VEN)+WKIMPORT+WKMOEDA")

TR350INCPROC("Criando Indice 03","Aguarde")

IF EICLOJA()
   INDREGUA("WORK",cIndex3+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+WKINVOICE+WKFORN+WKFORLOJ")
ELSE
   INDREGUA("WORK",cIndex3+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+WKINVOICE+WKFORN")
ENDIF

TR350INCPROC("Criando Indice 04","Aguarde")

IF EICLOJA()
   INDREGUA("WORK",cIndex4+TEOrdBagExt(),"WKFILIAL+DTOS(WKDT_VEN)+WKIMPORT+WKHAWB+WKINVOICE+WKFORN+WKFORLOJ")
ELSE
   INDREGUA("WORK",cIndex4+TEOrdBagExt(),"WKFILIAL+DTOS(WKDT_VEN)+WKIMPORT+WKHAWB+WKINVOICE+WKFORN") 
ENDIF


TR350INCPROC("Criando Indice 05","Aguarde")
INDREGUA("WORK",cIndex5+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+WKMOEDA")

TR350INCPROC("Criando Indice 06","Aguarde")
INDREGUA("WORK",cIndex6+TEOrdBagExt(),"WKFILIAL+WKHAWB")

TR350INCPROC("Criando Indice 07","Aguarde")

IF EICLOJA()
   INDREGUA("WORK",cIndex7+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+WKFORN+WKFORLOJ+WKMOEDA+DTOS(WKDT_VEN)")
ELSE
   INDREGUA("WORK",cIndex7+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB+WKFORN+WKMOEDA+DTOS(WKDT_VEN)")
ENDIF

TR350INCPROC("Criando Indice 08","Aguarde")

IF EICLOJA()
   INDREGUA("WORK",cIndex8+TEOrdBagExt(),"WKFILIAL+WKFORN+WKFORLOJ+DTOS(WKDT_VEN)")
ELSE
   INDREGUA("WORK",cIndex8+TEOrdBagExt(),"WKFILIAL+WKFORN+DTOS(WKDT_VEN)")
ENDIF

TR350INCPROC("Criando Indice 09","Aguarde")
INDREGUA("WORK",cIndex9+TEOrdBagExt(),"WKFILIAL+WKGRUPO+DTOS(WKDT_VEN)")

TR350INCPROC("Criando Indice 10","Aguarde")
INDREGUA("WORK",cIndex10+TEOrdBagExt(),"WKHAWB")

SET INDEX TO (cIndex1+TEOrdBagExt()),(cIndex2+TEOrdBagExt()),;
             (cIndex3+TEOrdBagExt()),(cIndex4+TEOrdBagExt()),;
             (cIndex5+TEOrdBagExt()),(cIndex6+TEOrdBagExt()),;             
             (cIndex7+TEOrdBagExt()),(cIndex8+TEOrdBagExt()),;
             (cIndex9+TEOrdBagExt()),(cIndex10+TEOrdBagExt())
                                                               
aDBF:={ {"WKFILIAL"  ,"C", FWSizeFilial(),0},;
        {"WKIMPORT"  ,"C",LEN(SYT->YT_COD_IMP),0},;
        {"WKHAWB"    ,"C",LEN(EEQ->EEQ_PREEMB),0},;
        {"WKFORN"    ,"C",LEN(SA2->A2_COD)    ,0},;
        {"WKNOM_FORN","C",LEN(SA2->A2_NREDUZ) ,0},;
        {"WKMOEDA"   ,"C",LEN(SW2->W2_MOEDA)  ,0},;
        {"WKVL_MOE"  ,"N",AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)},;
        {"WKVL_USD"  ,"N",AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)},;
        {"WKDT_VEN"  ,"D", 08,0},;        
        {"WKDT_NF"   ,"D", 08,0}}

If EICLOJA() .And. (nPos := aScan(aDBF, {|x| x[1] == "WKFORN" })) > 0
   aAdd(aDBF, Nil)
   aIns(aDBF, nPos + 1)
   aDBF[nPos+1] := {"WKFORLOJ", "C", AvSx3("A2_LOJA", AV_TAMANHO),0}
EndIf

nPontoEntrada := 2//Para diferenciar o ponto de Entrada já que existe o mesmo Parametro em varios lugares diferentes JMS
        
IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"ESTRU_WORK"),)
        
cWork1:=E_CriaTrab(,aDBF,"WORKA")
cWork2:=E_CREATE(,.F.)  
IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

TR350INCPROC("Criando Indice 10","Aguarde")
INDREGUA("WORKA",cWork1+TEOrdBagExt(),"WKFILIAL+WKIMPORT+DTOS(WKDT_VEN)+WKMOEDA")

aDBF:={ {"WKFILIAL"  ,"C", FWSizeFilial(),0},;
        {"WKDT_NF"   ,"D", 08,0},;      
        {"WKDT_VEN"  ,"D", 08,0},;
        {"WKDT_EMB"  ,"D", 08,0},;        
        {"WKIMPORT"  ,"C",LEN(SYT->YT_COD_IMP),0},;
        {"WKQUEBRA"  ,"C",LEN(SYT->YT_COD_IMP),0},;        
        {"WKHAWB"    ,"C",LEN(EEQ->EEQ_PREEMB),0},;
        {"WKQUEBRA1" ,"C",LEN(EEQ->EEQ_PREEMB),0},;
        {"WKMOEDA"   ,"C",LEN(SW2->W2_MOEDA)  ,0},;        
        {"WKVL_MOE"  ,"N",AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)},;
        {"WKVL_USD"  ,"N",AVSX3("WB_FOBMOE",3),AVSX3("WB_FOBMOE",4)}}

nPontoEntrada := 3//Para diferenciar o ponto de Entrada já que existe o mesmo Parametro em varios lugares diferentes JMS

IF(EasyEntryPoint("EICTR350"),Execblock("EICTR350",.F.,.F.,"ESTRU_WORK"),)
cWork2:=E_CriaTrab(,aDBF,"WORKB")

IF !USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF

TR350INCPROC("Criando Indice 11","Aguarde")
INDREGUA("WORKB",cWork2+TEOrdBagExt(),"WKFILIAL+WKIMPORT+WKHAWB")
RETURN .T.

*-----------------------------*
STATIC FUNCTION TR350Pedido()
*-----------------------------*
LOCAL nWorkKey:=WORK->(IndexOrd()),nAscan, lParcCamb := .F.
LOCAL cChave01:=WORK->WKFILIAL+WORK->WKIMPORT+WORK->WKHAWB+WORK->WKFORN+IIF(EICLoja(),WORK->WKFORLOJ,""),cChave02, cSvFilAnt:=cFilAnt
PRIVATE lFLCAMBIO:= EasyGParam("MV_AVG0191",,.T.)//TDF - Se(.T.),imprimi todas as Invoices relacionadas ao pedido.(Fatura nº)
PRIVATE nRecno1:=nBrowRecno:=WORK->(RECNO())
PRIVATE aTotal,nRateio:=1
PRIVATE nFob:= 0 // nInland:=nFrete:=nPack:=nOutDesp:=nDescont:=0


PRIVATE cFilSA2:=xFilial("SA2"),cFilSW2:=xFilial("SW2")
PRIVATE cFilSW6:=xFilial("SW6"),cFilSW9:=xFilial("SW9")
PRIVATE cFilSY6:=xFilial("SY6"),cFilSYT:=xFilial("SYT")
PRIVATE cFilSW7:=xFilial("SW7"),cFilSWB:=xFilial("SWB")
PRIVATE cFilSW8:=xFilial("SW8"),cFilSYW:=xFilial("SYW")


Work->(DbSetOrder(7))      
Work->(DbGoTo(nRecno1))
SW7->(DbSetOrder(4))
SW8->(DbSetOrder(1))
SW9->(DBSETORDER(1))

// AST 18/11/08
//WORK->(DBSEEK(cChave01))
//DO WHILE WORK->(!EOF()) .AND.WKFILIAL+WORK->WKIMPORT+WORK->WKHAWB+WORK->WKFORN==cChave01
   
   cFilAnt:=Work->WKFILIAL
   
   cFilSA2:=xFilial("SA2")
   cFilSW2:=xFilial("SW2")
   cFilSW6:=xFilial("SW6")
   cFilSW9:=xFilial("SW9")
   cFilSY6:=xFilial("SY6")
   cFilSYT:=xFilial("SYT")
   cFilSW7:=xFilial("SW7")
   cFilSWB:=xFilial("SWB")
   cFilSW8:=xFilial("SW8")
   cFilSYW:=xFilial("SYW")
   
   lParcCamb := .T.   
   aTotal:=ConvInvMoeda(WORK->WKHAWB,,)
   nRecno1:=WORK->(RECNO())
   cChave02:=WORK->(WKFILIAL+WKIMPORT+WKHAWB+WKFORN+IIF(EICLoja(),WKFORLOJ,"")+WKMOEDA/*+DTOS(WKDT_VEN)*/) //SVG - 05/11/08 -
   aPo:={};aLi:={};aNCM:={};aInvoice:={};aCond:={};aMaterial:={}
   nFob   := 0
   
   // TDF - 02/03/10
   If lFLCAMBIO == .T.     
      Work->(Dbseek(WORK->(WKFILIAL+WKIMPORT+WKHAWB+WKFORN+IIF(EICLoja(),WKFORLOJ,"")+WKMOEDA))) 
   EndIf
                                          
      DO WHILE WORK->(!EOF()) .AND. WORK->(WKFILIAL+WKIMPORT+WKHAWB+WKFORN+IIF(EICLoja(),WKFORLOJ,"")+WKMOEDA/*+DTOS(WKDT_VEN)*/) == cChave02 //SVG - 05/11/08 -
      
      nFob+= Work->WKVL_MOE
      IF SW8->(DBSEEK(cFilSW8+Work->WKHAWB+WORK->WKINVOICE+WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")))  
      
         DO WHILE SW8->(!EOF()) .AND. SW8->W8_FILIAL+SW8->W8_HAWB+SW8->W8_INVOICE+SW8->W8_FORN==cFilSW8+WORK->WKHAWB+WORK->WKINVOICE+WORK->WKFORN .AND. (!EICLOJA() .OR. SW8->W8_FORLOJ == Work->WKFORLOJ)  
         
            SW7->(DBSEEK(cFilSW7+SW8->W8_HAWB+SW8->W8_PO_NUM+SW8->W8_POSICAO+SW8->W8_PGI_NUM))
                        
            SW2->(DBSEEK(cFilSW2+SW7->W7_PO_NUM) ) 
            
           //IF (nAscan:=Ascan(aMaterial,SW2->W2_DES_IPI))==0                       // NCF 11/05/09 - Melhorada esta condição para evitar a repetição 
            IF (nAscan:=Ascan(aMaterial,SUBSTR(ALLTRIM(SW2->W2_DES_IPI),1,40)))==0  //                do mesmo Material na carta  
               AADD(aMaterial,SUBSTR(ALLTRIM(SW2->W2_DES_IPI),1,40))
            ENDIF            

            IF (nAscan:=Ascan(aNCM,SW7->W7_NCM))==0
               AADD(aNCM,SW7->W7_NCM)
            ENDIF
            
            IF (nAscan:=Ascan(aPo,SW8->W8_PO_NUM))==0
               AADD(aPo,SW8->W8_PO_NUM)
            ENDIF
                        
            IF (nAscan:=Ascan(aLi,SW8->W8_PGI_NUM))==0
               AADD(aLi,SW8->W8_PGI_NUM)
            ENDIF
            
            IF (nAscan:=Ascan(aCond,{|a|a[1]==WORK->WKCOND_PA .AND. a[2]==WORK->WKDIAS_PA}))==0
               AADD(aCond,{WORK->WKCOND_PA,WORK->WKDIAS_PA})               
            ENDIF
            
            IF (nAscan:=Ascan(aInvoice,SW8->W8_INVOICE))==0            
               AADD(aInvoice,SW8->W8_INVOICE)                                                          
            ENDIF
         SW8->(DBSKIP())                                     
       ENDDO   
     ENDIF
     WORK->(DBSKIP())   
   ENDDO
   cFilAnt:=cSvFilAnt
   Tr350Print()
//   IF !Tr350Print()
//      EXIT
//   ENDIF 
// WORK->(DBSKIP())
//ENDDO
IF !lParcCamb
   Help("",1,"AVG0001058")
ENDIF   
WORK->(DBSETORDER(nWorkKey))
WORK->(DBGOTO(nBrowRecno))
SW7->(DBSETORDER(1))
SW8->(DbSetOrder(1))
RETURN .T.
*----------------------------*
STATIC FUNCTION TR350Print()
*----------------------------*
LOCAL nRecno2:=Work->(Recno()), cSvFilAnt:=cFilAnt
LOCAL nOpcao:=OK
LOCAL nI:= 0
Local oPanel
PRIVATE nDiasPag,nVias:=1,lCabec:=.F.,odlgFec
Private nLinFec:= 18,nColFec:= 86
SW9->(DBSETORDER(1))
SA6->(dbSetOrder(1))
Work->(DbGoto(nRecno1))

If !Empty(Work->WKFILIAL)
    cFilAnt:=Work->WKFILIAL
EndIf

cFilSA2:=xFilial("SA2")
cFilSW2:=xFilial("SW2")
cFilSW6:=xFilial("SW6")
cFilSW9:=xFilial("SW9")
cFilSY6:=xFilial("SY6")
cFilSYT:=xFilial("SYT")
cFilSW7:=xFilial("SW7")
cFilSWB:=xFilial("SWB")
cFilSW8:=xFilial("SW8")
cFilSYW:=xFilial("SYW")

SW6->(DBSEEK(cFilSW6+WORK->WKHAWB))
//TDF 06/12/2010 - ACRESCENTA O HAWB NA CHAVE DE BUSCA
SW9->(DBSEEK(cFilSW9+AvKey(WORK->WKINVOICE,"WB_INVOICE")+WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")+AvKey(WORK->WKHAWB,"WB_HAWB")))
SW8->(DBSEEK(cFilSW8+AvKey(WORK->WKINVOICE,"WB_INVOICE")+WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")))
SB1->(DBSEEK(xFilial()+SW7->W7_COD_I))

_PictComp := ALLTRIM(X3Picture("Y1_COD"))
cOutr_1:=STR0050+DTOC(SW6->W6_DT_EMB)+STR0051+DTOC(SW6->W6_DT_DESEM)+SPACE(6) //"EMBARQUE - "###" / DESEMBARACO - "
cOutr_2:=ALLTRIM(TRANS(SW7->W7_COD_I,ALLTRIM(X3Picture("B1_COD"))))+" - "+MSMM(SB1->B1_DESC_P,AVSX3("B1_VM_P",03),1)+Space(15)
cLoc01:=cLoc02:=cLoc03:=TAutor:=TAutor2:=Space(40)
//cLoc03:=Space(25)
cComprador:=Space(LEN(SY1->Y1_COD)) //SY1->Y1_COD

//* SVG - 31/03/2010 - 
Private cBco_R  := Space(LEN(SA6->A6_COD)),;
        cBco_NR  := Space(LEN(SA6->A6_NREDUZ)),;
        cBco_N  := Space(LEN(SA6->A6_NOME)),;
        cBco_C  := Space(LEN(SA6->A6_CONTA)),;
        cBco_Ext:=SPACE(LEN(SA6->A6_NOME)),;
        cAge_R  :=  Space(LEN(SA6->A6_NUMCON)),;
        cEnd_R  := Space(LEN(SA6->A6_END))
If SA6->(DBSEEK(xFilial()+WORK->WB_BANCO+WORK->WB_AGENCIA))
   cBco_R :=SA6->A6_COD
   TR350BCO(SA6->A6_COD)
EndIf
//*   
dData:=DTOC(dDataBase)

IF !Empty(SW9->W9_COND_PA)
   nDiasPag:=SW9->W9_DIAS_PA
ELSE
   nDiasPag:=SW6->W6_DIAS_PA
ENDIF

If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"ALT_PRINT"),)//AOM - 18/03/2010

DO WHILE .T.
   nOpcao:=2
   cComprador:=SPACE(LEN(SY1->Y1_COD))
   DEFINE MSDIALOG odlgFec TITLE STR0052 FROM 9,0 TO 42,80 OF oMainWnd //"Fechamento Cambio"
   DEFINE SBUTTON oPrinter FROM 18,285 TYPE 6 ACTION (nOpcao:=OK,odlgFec:End()) ENABLE OF odlgFec
   
   oPanel:= TPanel():New(0, 0, "", odlgFec,, .F., .F.,,, 90, 165) //MCF - 17/07/2015
   oPanel:Align:= CONTROL_ALIGN_ALLCLIENT 
   
   @nLinFec,6      SAY STR0010 SIZE 40,8 PIXEL OF oPanel //"Processo"
   @nLinFec,nColFec  SAY WORK->WKHAWB SIZE 80,8 PIXEL OF oPanel
   
   @nLinFec+13,6   SAY STR0053 SIZE 40,8 PIXEL OF oPanel//"Vencimento"
   IF nDiasPag = -1
      @ nLinFec+13,nColFec SAY DTOC(WORK->WKDT_VEN)+' ( '+STR0054+' )' SIZE 90,8 PIXEL OF oPanel //"URGENTE"
   ELSE
      @ nLinFec+13,nColFec SAY WORK->WKDT_VEN SIZE 40,8 PIXEL OF oPanel
   ENDIF

   @nLinFec+26  ,6     SAY AVSX3("W9_INVOICE",5) SIZE 35,8 PIXEL OF oPanel
   @nLinFec+26  ,nColFec  SAY AvKey(WORK->WKINVOICE,"WB_INVOICE") SIZE 80,8 PIXEL OF oPanel
   
   @nLinFec+39  ,6     SAY STR0056 SIZE 40,8 PIXEL OF oPanel//"Outros" 
   @nLinFec+65  ,6     SAY STR0058 SIZE 80,8 PIXEL OF oPanel//"Bco. Recebedor Cobr / Conta"
   @nLinFec+65,nColFec+33 SAY STR0128 SIZE 50,8 PIXEL OF oPanel//Bco
   @nLinFec+65,nColFec+175 SAY "/" SIZE 10,8 PIXEL OF oPanel
   @nLinFec+65,nColFec+110 SAY STR0127 SIZE 50,8 PIXEL  OF oPanel//Ag / Conta
  // @nLinFec+78  ,6     SAY STR0058 SIZE 80,8 PIXEL //"Banqueiro no Exterior"   //SVG - 31/03/2010 -
   @nLinFec+91  ,6     SAY STR0059 SIZE 60,8 PIXEL OF oPanel//"Localidade"
   @nLinFec+130 ,6     SAY STR0060 SIZE 40,8 PIXEL OF oPanel//"Data"
   @nLinFec+143 ,6     SAY STR0061 SIZE 80,8 PIXEL OF oPanel//"Codigo do Comprador"
   @nLinFec+156 ,6     SAY STR0062 SIZE 80,8 PIXEL OF oPanel//"Autorizado por"
   @nLinFec+169 ,6     SAY STR0062 SIZE 60,8 PIXEL OF oPanel//"Autorizado por"
   @nLinFec+182 ,6     SAY STR0063 SIZE 60,8 PIXEL OF oPanel//"No. de Vias"
   
   nLinFec:=18                                 

   @nLinFec+39  ,nColFec  MSGET cOutr_1  SIZE 200,8  PICTURE "@!" PIXEL OF oPanel
   @nLinFec+52  ,nColFec  MSGET cOutr_2  SIZE 200,8  PICTURE "@!" PIXEL OF oPanel
   @nLinFec+65  ,nColFec  MSGET cBco_R  F3 "A61" SIZE 32,8  PICTURE "@!" Valid(Tr350BCO(cBco_R)) PIXEL OF oPanel HASBUTTON
   @nLinFec+65  ,nColFec+50  MSGET cBco_NR  SIZE 60,8  PICTURE "@!" PIXEL OF oPanel//Nome do Banco
   @nLinFec+65  ,nColFec+140 MSGET cAge_R SIZE 32,8  PICTURE "@!" PIXEL OF oPanel//Agencia
   @nLinFec+65  ,nColFec+180 MSGET cBco_C SIZE 32,8  PICTURE "@!" PIXEL OF oPanel//Conta

   //@nLinFec+78  ,nColFec MSGET cBco_Ext SIZE 140,8 PICTURE "@!" PIXEL
   @nLinFec+91  ,nColFec MSGET cLoc01   SIZE 160,8 PICTURE "@!" PIXEL OF oPanel
   @nLinFec+104 ,nColFec MSGET cLoc02   SIZE 160,8 PICTURE "@!" PIXEL OF oPanel
   @nLinFec+117 ,nColFec MSGET cLoc03   SIZE 160,8 PICTURE "@!" PIXEL OF oPanel
   @nLinFec+130 ,nColFec MSGET dData    SIZE 40,8  PIXEL OF oPanel
   
   @nLinFec+143 ,nColFec MSGET cComprador F3 "SY1" SIZE 10,8 VALID TR350SX1Valid("COMPRADOR") PICTURE _PictComp PIXEL OF oPanel HASBUTTON
   @nLinFec+156 ,nColFec MSGET oAutor VAR  TAutor  PICTURE "@!" SIZE 160,8 PIXEL OF oPanel
   @nLinFec+169 ,nColFec MSGET oAutor2 VAR TAutor2 PICTURE "@!" SIZE 160,8 PIXEL OF oPanel
   @nLinFec+182 ,nColFec MSGET nVias  SIZE 10,8  PICTURE "999" VALID IF(nVias==0,Help("",1,"AVG0001008"),Positivo(nVias)) PIXEL OF oPanel

   IF(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"TELA_FECHAMENTO"),)	// SVG - 22/10/2010 -

   ACTIVATE MSDIALOG odlgFec ON INIT ;
      EnchoiceBar(odlgFec,{||nOpcao:=OK,odlgFec:End()},{||nOpcao:=CANCEL,odlgFec:End()}) CENTERED
   
         
   IF nOpcao==CANCEL
      Work->(DbGoto(nRecno2))
      cFilAnt:=cSvFilAnt
      RETURN .T.
   ENDIF    
       
   IF nOpcao = 2//Se sair com botao X da DIALOG
      Work->(DbGoto(nRecno2))
      cFilAnt:=cSvFilAnt
      RETURN .F.
   ENDIF        
   
   EXIT
ENDDO

IF(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"ANTES_IMPRIMIR"),)	// SVG - 22/10/2010 -
    
AVPRINT oPrn NAME STR0065 //"Pedido para fechamento de câmbio"

   oPrn:SetPortrait()
   
   DEFINE FONT oFont1  NAME "Times New Roman"      SIZE 0,24                  OF oPrn
   DEFINE FONT oFont2  NAME "Courier New"          SIZE 0,12                  OF oPrn
   DEFINE FONT oFont3  NAME "Courier New"          SIZE 0,12 BOLD  UNDERLINE  OF oPrn
   DEFINE FONT oFont4  NAME "Courier New"          SIZE 0,12 BOLD             OF oPrn

   AVPAGE
   FOR nI:=1 To nVias
      Processa({||TR350FatPrint()})
   NEXT
   AVENDPAGE
AVENDPRINT

oFont1:End()
oFont2:End()
oFont3:End()
oFont4:End()     

IF(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"DEPOIS_IMPRIME_DOC"),)	// SVG - 22/10/2010 - 06/07/2005
 
Work->(DbGoto(nRecno2))
cFilAnt:=cSvFilAnt
RETURN .T.
*-------------------------------*
STATIC FUNCTION TR350FatPrint()
*-------------------------------*
LOCAL nLoop,cPictNcm:=AVSX3("W7_NCM",6),nContMat:=0,I:=0,Y:=0
LOCAL cChavImp := ""
PRIVATE nLine:=9999,nPagina:=1
ALTURA_LINHA:=50
COL_TITULOS :=200
COL_DADOS   :=850

cPictFob:=AVSX3("W9_FOB_TOT",6)
cPictInl:=AVSX3("W9_INLAND",6)
cPictFre:=AVSX3("W9_FRETEIN",6)
cPictPac:=AVSX3("W9_PACKING",6)
cPictOut:=AVSX3("W9_OUTDESP",6)
cPictDes:=AVSX3("W9_DESCONT",6)

//ER - 05/12/2006. Em caso de adiantamento o Importador usado será do P.O.
If Alltrim(WORK->WKTPREG) == "P" //Pagamento Antecipado
   SW2->(DbSetOrder(1))
   SW2->(DbSeek(cFilSW2 + WORK->WKHAWB))
   cChavImp := SW2->W2_IMPORT
Else
   SW6->(DbSetOrder(1))
   SW6->(DbSeek(cFilSW6+WORK->WKHAWB))   
   cChavImp := SW6->W6_IMPORT
EndIf

//SW6->(DbSeek(cFilSW6+WORK->WKHAWB))   
//SYT->(DBSEEK(cFilSYT+SW6->W6_IMPORT))
SYT->(DBSEEK(cFilSYT+cChavImp))

cMV_ID_EMPR :=If(EasyGParam('MV_ID_EMPR',,"S")$cSim,ALLTRIM(SM0->M0_NOMECOM),SYT->YT_NOME)

cPedidos := ''  
TR350Cab()
oPrn:Say(nLine,COL_TITULOS,STR0067+WORK->WKHAWB, COURIER_12_BOLD ) //"PROCESSO NUMERO........: "

nLine += (1.5*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0068+; //"Vencimento.............: "
If(nDiasPag=-1,STR0069,DTOC(WORK->WKDT_VEN) ), COURIER_12) //"A VISTA"
         
nLine += ALTURA_LINHA
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0070, COURIER_12) //"Condicao de Pagamento..: "
SY6->(DBSEEK(xFilial()+WORK->WKCOND_PA))
mDescri:=MSMM(SY6->Y6_DESC_P, 100)
                           
If ! EMPTY(ALLTRIM(mDescri))
   FOR nLoop := 1 TO 2
      TR350Cab()
      oPrn:Say( nLine,COL_DADOS ,AllTrim(memoline(mDescri,51,nLoop)))
      nLine+=ALTURA_LINHA
   NEXT
  // nLine-=ALTURA_LINHA CCH - 21/11/2008 - Removida pois a condição de pagto pode ter duas linhas
ELSE
   nLine+=ALTURA_LINHA   
EndIf

// AST - 18/11/08
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0123+WORK->WKMOEDA+' '+TRAN(WORK->WKVL_MOE,cPictFob), COURIER_12 ) //"Valor da Parcela.........: "

/* SVG - 31/03/2010 -
//nLine += 2*ALTURA_LINHA
//TR350Cab()
//oPrn:Say( nLine,COL_TITULOS,STR0071+cBco_R, COURIER_12) //"Bco Recebedor Cobrança.: "

//nLine += ALTURA_LINHA
//TR350Cab()
//oPrn:Say( nLine,COL_TITULOS,STR0072+cAge_R, COURIER_12) //"No. da Conta ..........: "
*/
SA2->(DBSEEK(xFilial()+WORK->WKFORN+EICRetLoja("WORK","WKFORLOJ")))
/* SVG - 31/03/2010 -
//nLine += ALTURA_LINHA
//TR350Cab()
//oPrn:Say( nLine,COL_TITULOS,STR0073+SA2->A2_SWIFT, COURIER_12) //"Swift .................: "

//nLine += ALTURA_LINHA
//TR350Cab()
//oPrn:Say( nLine,COL_TITULOS,STR0074+WORK->WB_NR_ROF, COURIER_12) //"ROF ...................: "
*/
nLine += ALTURA_LINHA
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0075+PADL(WORK->WKFORN,AVSX3("A2_COD",AV_TAMANHO),"0")+ IIF(EICLoja()," - "+WORK->WKFORLOJ+"/","") +" "+SA2->A2_NOME, COURIER_12 ) //"Exportador.............: "// TLM 04/04/2008 - Acerto do tamanho da WKFORN

nLine += ALTURA_LINHA
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0076+Left(AllTrim(SA2->A2_END),20)+" - "+Left(AllTrim(SA2->A2_MUN),20), COURIER_12 ) //"Endereço do exportador.: "
nLine += ALTURA_LINHA
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"                         "+Left(AllTrim(SA2->A2_BAIRRO),20)+" - "+Left(AllTrim(SA2->A2_ESTADO),20), COURIER_12 )
         
nLine += ALTURA_LINHA
TR350Cab()
cTexto:=STR0077+TRANS(SYT->YT_CGC,ALLTRIM(X3Picture("YT_CGC"))) //"C.N.P.J. Importador......: "

If(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"CGC_IMP"),)

oPrn:Say(nLine,COL_TITULOS, cTexto, COURIER_12)


nLine += ALTURA_LINHA
TR350Cab()
cAuxiliar:=cControle:=""          
nAjuste:=650
oPrn:Say(nLine,COL_TITULOS,STR0078,COURIER_12)

For nContMat:=1 To Len(aMaterial)

   If Empty(aMaterial[nContMat])
      Loop
   Endif   
   
   If Len(cAuxiliar+aMaterial[nContMat])>60
      oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
      nLine += ALTURA_LINHA
      TR350Cab()
      cAuxiliar:=cControle:=""
   EndIf
                 
   cAuxiliar+=cControle+(aMaterial[nContMat])     
   oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
      
   If Empty(cControle)
      cControle:=","   
   EndIf
   
Next                  


nLine += (2*ALTURA_LINHA)
TR350Cab()
nFechaTot := TRAN(nFob,cPictFob)
oPrn:Say( nLine,COL_TITULOS,STR0085+WORK->WKMOEDA+' '+nFechaTot, COURIER_12 ) //"Total a Fechar.........: "

nLine += (2*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0086, COURIER_12_BOLD_UNDERLINE ) //"DOCUMENTOS EM ANEXO"

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"Numero da D.I. ........: "+TRANS(SW6->W6_DI_NUM,AVSX3("W6_DI_NUM",6)), COURIER_12 ) //STR0087"4o. Via da D.I. No.....: " // NCF 27/04/09 - Alterado de "C.I" para "D.I"

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0089+ALLTRIM(WORK->WKHAWB)+STR0090+DTOC(SW6->W6_DT_HAWB), COURIER_12 ) //"Processo de Embarque...: "###"  de  "

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0091+SW6->W6_IDENTVE, COURIER_12 ) //"Navio..................: "

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0092+SW6->W6_HOUSE, COURIER_12 ) //"House/BL...............: "

nLine += (ALTURA_LINHA)
TR350Cab()
cAuxiliar:=cControle:=""
oPrn:Say( nLine,COL_TITULOS,STR0093,COURIER_12 )//"Fatura No..............: "      

For Y:=1 To LEN(aInvoice)
   If Empty(aInvoice[Y])
      Loop
   Endif
   
   If Len(cAuxiliar+aInvoice[Y])>60
      oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
      nLine += ALTURA_LINHA
      TR350Cab()
      cAuxiliar:=cControle:=""
   EndIf
                 
   cAuxiliar+=cControle+ALLTRIM(aInvoice[Y])     
   oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
   
   If Empty(cControle)
      cControle:=","   
   EndIf
Next                                                                                    

nLine += (ALTURA_LINHA)
TR350Cab()
cAuxiliar:=cControle:=""
oPrn:Say(nLine,COL_TITULOS,STR0094,COURIER_12 ) //"Numero de LI's.........: "

For I=1 To Len(aLi)
   If Empty(aLi[I]) .OR. LEFT(aLi[I],1)=="*"
      Loop
   Endif

   If Len(cAuxiliar+aLi[I])>60
      oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
      nLine += ALTURA_LINHA
      TR350Cab()
      cAuxiliar:=cControle:=""
   EndIf
                 
   cAuxiliar+=cControle+ALLTRIM(aLi[I])     
   oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)   
      
   If Empty(cControle)
      cControle:=","   
   EndIf
   
Next

nLine += (ALTURA_LINHA)
TR350Cab()
cAuxiliar:=cControle:=""
oPrn:Say( nLine,COL_TITULOS,STR0026,COURIER_12) //"P.O....................: "

FOR nLoop:=1 To LEN(aPo)

   IF EMPTY(aPo[nLoop])
      LOOP
   ENDIF
                                            
   If Len(cAuxiliar+aPo[nLoop])>60
      oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
      nLine += ALTURA_LINHA
      TR350Cab()
      cAuxiliar:=cControle:=""
   EndIf
                 
   cAuxiliar+=cControle+ALLTRIM(aPo[nLoop])     
   oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)   
      
   If Empty(cControle)
      cControle:=","   
   EndIf
NEXT

nLine += (ALTURA_LINHA)
TR350Cab()
cAuxiliar:=cControle:=""
oPrn:Say(nLine,COL_TITULOS,STR0095,COURIER_12) //"Tec / Ncm .............: "

For I:=1 To Len(aNCM)
   If Empty(aNcm[I])
      Loop
   Endif
   
   If Len(cAuxiliar+aNcm[I])>60
      oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)
      nLine += ALTURA_LINHA
      TR350Cab()
      cAuxiliar:=cControle:=""
   EndIf
                 
   cAuxiliar+=ALLTRIM(cControle+TRANS(aNcm[I],cPictNCM))
   oPrn:Say(nLine,COL_TITULOS+nAjuste,cAuxiliar,COURIER_12)   
      
   If Empty(cControle)
      cControle:=","   
   EndIf

Next

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0096+ALLTRIM(cOutr_1), COURIER_12 ) //"Outros.................: "

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"                         "+ALLTRIM(cOutr_2), COURIER_12 )

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0097+cBco_NR, COURIER_12 ) //"Banqueiro no Exterior..: "

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"                         "+cBco_N, COURIER_12 )
//** SVG - 31/03/2010 -
nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0124+cAge_R +" / "+cBco_C + "      "+ STR0125+ SA2->A2_SWIFT, COURIER_12 ) //"Agência/Conta..........: "  "Swift: " 

If SA2->(FIELDPOS("A2_IBAN")) > 0
   nLine += (ALTURA_LINHA)
   TR350Cab()
   oPrn:Say( nLine,COL_TITULOS,STR0126+SA2->A2_IBAN, COURIER_12 )// "Iban...................: "
EndIf
//**
nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0098+cLoc01, COURIER_12 ) //"Localidade.............: "

IF(EasyEntryPoint("EICTR350"),ExecBlock("EICTR350",.F.,.F.,"IMPRIMINDO"),)	// SVG - 22/10/2010 -

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"                         "+cLoc02, COURIER_12 )

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"                         "+cLoc03, COURIER_12 )

nLine += (1*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0099+DTOC(dDataBase), COURIER_12 ) //"Data..: "
oPrn:Say( nLine,COL_DADOS,REPL("_",45), COURIER_12 )

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_DADOS,STR0100+SUBSTR(TAutor,1,30), COURIER_12 ) //"AUTORIZADO POR "
//NCF 27/04/09 - Adicionada mais uma linha para assinatura da carta
nLine += (3*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,REPL(" ",16), COURIER_12 )
oPrn:Say( nLine,COL_DADOS,REPL("_",45), COURIER_12 )

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_DADOS,STR0100+SUBSTR(TAutor2,1,30), COURIER_12 ) //"AUTORIZADO POR "

nLine += (2*ALTURA_LINHA)
//lCabec:=.T.
TR350Cab()
oPrn:Say( nLine, 675, STR0101, TIMES_NEW_ROMAN_24 ) //"FECHAMENTO DE CAMBIO"

nLine += (2*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0102+REPL("_",44), COURIER_12 ) //"Banco..................: "

nLine += (2*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0103+REPL("_",44), COURIER_12 ) //"No. Contrato de Cambio.: "

nLine += (2*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0104+REPL("_",44), COURIER_12 ) //"Corretora..............: "

nLine += (2*ALTURA_LINHA)

If ((ALTURA_LINHA*3)+nLine) >= 3300 //3199
   nLine:=3601
   TR350Cab()
EndIf

oPrn:Say( nLine,COL_TITULOS,STR0105      , COURIER_12) //"DATA DE    TAXA DO    VALOR        DESPESAS    DATA DE     VALOR"

nLine += (ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,STR0106      , COURIER_12 ) //"FECHAMENTO FECHAMENTO FECHADO (R$) BANCARIAS   PAGAMENTO   TOTAL"

nLine += (2*ALTURA_LINHA)
TR350Cab()
oPrn:Say( nLine,COL_TITULOS,"___/___/__ __________ ____________ ___________ ___/___/__  ___________", COURIER_12)

RETURN .T.

*-------------------------*
STATIC FUNCTION TR350Cab()
*-------------------------*
If nLine >=If(lCabec,3000,3600)//2500 # 3000
   IF nPagina>1
      AVNEWPAGE  
   ENDIF

   oPrn:Box( 90, 155,  240, 2305 )
   
   //ER - 05/12/2006
   If !Empty(SYT->YT_LOGO) //--- LOGOTIPO do Importador
      oPrn:SayBitmap(100,190,AllTrim(SYT->YT_LOGO)+".BMP",300,135)
   EndIf
   
   oPrn:Say(125,1152, ALLTRIM(cMV_ID_EMPR), TIMES_NEW_ROMAN_24,,,,2)                            
   
   oPrn:Box(240, 155, 3150, 2305 )
   oPrn:Say(300, 400, STR0066, TIMES_NEW_ROMAN_24 ) //"PEDIDO PARA FECHAMENTO DE CAMBIO"
   nLine:=450;nPagina++ 

Endif

Return .T.

*------------------------------*
STATIC FUNCTION TR350Busca()
*------------------------------*
LOCAL OldRecno :=WORK->(RECNO()), nTipo:=1,nOpcA:=CANCEL
LOCAL cNumero:= SPACE(17), oDlg1, xDI_NUM,nOrdOld:=WORK->(INDEXORD())
Private cPict1 := AVSX3("W6_DI_NUM",6), cPict := AVSX3("W6_HAWB",6), oGetNum, oSayNum


DEFINE MSDIALOG oDlg1 TITLE STR0041 From 9,0 To 17,50 OF oMainWnd  //"Pesquisa"
   @ 7,4  TO 31,51 LABEL "" PIXEL
   @ 11,5  RADIO nTipo ITEMS STR0108,STR0109 3D SIZE 45,9 on change TR350GET(nTipo,oSayNum) PIXEL //"1-Processo   "###"2-Por D.I."
   @ 1.5,8 SAY oSayNum Var STR0108 SIZE 55,8 
   @ 1.5,12  MSGET oGetNum VAR cNumero PICTURE cPict SIZE 55,8 

   DEFINE SBUTTON FROM 11,160 TYPE 1 ACTION (nOpca:=1     ,oDlg1:End()) ENABLE OF oDlg1
   DEFINE SBUTTON FROM 27,160 TYPE 2 ACTION (nOpca:=CANCEL,oDlg1:End()) ENABLE OF oDlg1

ACTIVATE MSDIALOG oDlg1 CENTERED 

If nOpcA==1
   IF nTipo == 1
//      WORK->(DBSETORDER(6))
      WORK->(DBSETORDER(10))
      WORK->(DBSEEK(RTRIM(cNumero)))
      If WORK->(EOF())
         Help("",1,"AVG0001009") //"Número do processo não cadastrado."###"Informação"
         WORK->(DBGOTO(OldRecno))
      Else
         WORK->(DBSETORDER(2))
      EndIf
   ELSE
      WORK->(DBGOTOP())
      DO WHILE !WORK->(EOF()) .AND. cNumero <> WORK->WKNR_DI
         WORK->(DBSKIP())
         LOOP
      END
      IF WORK->(EOF())
         Help("",1,"AVG0001010") //'Número da D.I. não cadastrada.'###"Informação"
         WORK->(DBGOTO(OldRecno))
      ENDIF
   ENDIF
ENDIF                         

WORK->(DBSETORDER(nOrdOld))

RETURN .T. 

*-----------------------------------*
STATIC FUNCTION TR350GET(nTipo,oSayNum)
*-----------------------------------*
If nTipo==1
   oGetnum:Picture:=cPict
   oSayNum:cCaption:=STR0108   
else    
   oGetnum:Picture:=cPict1
   oSayNum:cCaption:=STR0109
endif 

RETURN .T.
/**-----------------------------------*
STATIC FUNCTION TR350Inv(PHawb,lRet)
*-----------------------------------*
LOCAL _Retorno:=''
nSomaValFob:=0
SW9->(DBSETORDER(3))
IF SW9->(DBSEEK(xFilial()+PHawb))
   WHILE ! SW9->(EOF()) .AND. PHawb == SW9->W9_HAWB .AND. SW9->W9_FILIAL=xFilial("SW9")
      _Retorno+= ALLTRIM(SW9->W9_INVOICE)+", "
      nSomaValFob+= SW9->W9_FOB_TOT
      SW9->(DBSKIP())
   END
ENDIF
_Retorno := IF(lRet,ALLTRIM(SUBSTR(_Retorno,1,(LEN(ALLTRIM(_Retorno))-1))),nSomaValFob)
RETURN _Retorno*/

//Alcir Alves 
*-----------------------------------*
STATIC FUNCTION TR350INCPROC(cSay)
*-----------------------------------*
IF !lEMail      //AWR
   INCPROC(cSay)
ENDIF

RETURN .T.

                 
*----------------------------------------*
FUNCTION EICTR350FIL
*----------------------------------------*
LOCAL cImportador, cTitulo:="TESTE DO TR350", aMarcaFil:={}, aTemp, cMensagem, i

LOCAL cCampoGET:=Readvar()
Local cBrwFil := "" //THTS - 28/07/2017 - Controle se vai chamar o SXB padrao ou multi filial

IF cCampoGET == "MV_PAR01"
   aFilSWB:=ACLONE(aSvFilSWB)
   ASIZE(aFilSEL,0)
   ccpo:="W6_HAWB"
   cTitulo:=AVSX3(ccpo,5)
   nColPos:=2
   cMensagem:=STR0118
   cBrwFil := If(Empty(xFilial("SW6")),"SW6","") //THTS - 28/07/2017 - Se exclusivo, chama consulta multi filial, senao chama consulta da tabela
ENDIF   

IF cCampoGET == "MV_PAR02"  
   cTitulo:=STR0031    // Importador
   ccpo:="YT_COD_IMP"   // Importador ??
   nColPos:=3
   cMensagem:=STR0119
   cBrwFil := If(Empty(xFilial("SYT")),"SYT","") //THTS - 28/07/2017 - Se exclusivo, chama consulta multi filial
ENDIF

IF cCampoGET == "MV_PAR03"
   cTitulo:=IF(lEFFTpMod, STR0122,STR0015)   // Fornecedor
   ccpo:="A2_COD"     // Fornecedor ??
   nColPos:=4
   cMensagem:=STR0120
   cBrwFil := If(Empty(xFilial("SA2")),"SA2A","") //THTS - 28/07/2017 - Se exclusivo, chama consulta multi filial
ENDIF

IF cCampoGET == "MV_PAR11"
   cTitulo:=STR0117  // Corretor
   ccpo:="YW_COD"  // Corretor ??
   nColPos:=5
   cMensagem:=STR0121
   cBrwFil := If(Empty(xFilial("SYW")),"SYW","") //THTS - 28/07/2017 - Se exclusivo, chama consulta multi filial
ENDIF

If Empty(cBrwFil) //THTS - 28/07/2017 - Se cBrwFil for vazio, chama a consulta multi filial, senao utiliza a consulta que esta na variavel
    //aFilSW6:={"02","11","13"}
    lBrowseFil:=.T.

    bCampo:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",STR0116,WorkFil->(FIELDGET(FIELDPOS(ccpo))))}

    aTB_Campos:={{bCampo,"",AVSX3(ccpo,5) } }

    aDBF:= { {ccpo,AVSX3(ccpo,2),AVSX3(ccpo,3),AVSX3(ccpo,4)} }
    bMarca:={||IF(LEFT(WorkFil->(FIELDGET(FIELDPOS(ccpo))),1)=="*",SPACE(AVSX3(ccpo,3)),WorkFil->(FIELDGET(FIELDPOS(ccpo)))),TR350GETCAMPO(cTitulo,ccpo,cMensagem)}

    aRetMarcados:={ccpo}

    aMarcaFil:=AvgMBrowseFil("","",aFilSWB,aTb_Campos,"",aDBF,bMarca,aRetMarcados)

    ASIZE(aFilSWB,0)

    For i:=1 to len(aMarcaFil)         
        aTemp:=aMarcaFil[i]
        cFilSel:=aTemp[1]
        cGET:=IF(LEFT(aTemp[2][1],1)=="*","",aTemp[2][1])
        
        nI:=ASCAN(aMarcados,{|fil|fil[1]==cFilSel})
        
        IF nI == 0   // SOMENTE PARA MV_PAR01 - PROCESSO , DEPOIS NAO ENTRARA MAIS - RS 22/01/06
	        AADD(aFilSel,cFilSel)
	        AADD(aMarcados,{cFilSel,cGET,"","",""})
	        LOOP
        ENDIF
        IF ASCAN(aFilSel,cFilSel) == 0
        	AADD(aFilSel,cFilSel)      
        ENDIF
        aMarcados[nI][nColPos]:=cGET
    Next             

    aFilSWB:=ACLONE(aFilSel)
    IF cCampoGET == "MV_PAR01"  .AND. LEN(aMarcaFil) > 0                                             
	    ASIZE(aFilSWB,0)
	    aFilSWB:=ACLONE(aFilSel)
    ENDIF   

    //NCF - 20/05/09 - Retorna o processo escolhido
    If cCampoGET == "MV_PAR01" .and. LEN(aMarcaFil) > 0
	    If Len(aTB_Campos) > 1
	        mv_par01 := cGet
	    EndIf
    EndIf
Else
    ConPad1(,,,cBrwFil,,)
EndIf
Return .T.

*----------------------------------------------------------------------------
Function TR350GETCAMPO(cTitulo,cCampoF3,cMensagem)
*----------------------------------------------------------------------------
LOCAL oDlg, nOpca:=0, lValid:=.F. ,oDlg1
LOCAL cArqF3:="S"+LEFT(cCampoF3,2)
LOCAL cCadastro:=STR0023+" "+cTitulo//"Selecione"
Local cTit:= STR0131 // "Selecione o filtro""Selecione o Filtro"
Local cTipoFiltro
LOCAL bValid:={||EMPTY(cCod) .OR. ExistCpo(cArqF3,cCod)}
LOCAL cSvFilAnt

nSize:=50

IF cArqF3 == "SYT"
   nSize:=20
ENDIF

IF cArqF3== "SW6" 
   nSize:=70

   //SVG - 22/03/2011 - Tela para seleção de filtros por processo ou PO.         
   DEFINE MSDIALOG oDlg1 TITLE cTit From 9,0 To 18,55 OF oMainWnd
    
   @ 3,10  COMBOBOX cTipoFiltro ITEMS {"1- PO", "2- Processo"} SIZE nSize,30 of odlg1        

   ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||oDlg1:End()},{||oDlg1:End()}) CENTERED
EndIf   
IF !EMPTY(WorkFil->WKMARCA)
   WorkFil->(FIELDPUT(FIELDPOS(cCampoF3),SPACE(AVSX3(cCampoF3,3))))
   WorkFil->WKMARCA:=SPACE(02)
   RETURN .T.
ENDIF
//SVG - 22/03/2011 - Tela para seleção de filtros por processo ou PO.         
If cTipoFiltro == "1- PO"
   cArqf3:="SW2"
EndIf
cSvFilAnt:=cFilAnt

IF FWModeAccess(cArqF3,3) =="E"    // TESTA TABELA EXCLUSIVA???  
   cFilAnt:=WorkFil->WKFILIAL
ENDIF

cCod:=WorkFil->(FIELDGET(FIELDPOS(cCampoF3)))

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 To 18,55 OF oMainWnd

@ 3,2  SAY  OemToAnsi(AVSX3(cCampoF3,5))//"C¢digo"
@ 3,10  MSGET cCod F3 cArqF3 SIZE nSize,10 VALID (lValid:=EVAL(bValid)) ;
           MESSAGE OemToAnsi(cMensagem)//"Informe o C¢digo do Processo/Importador/Fornecedor/Corretor ou tecle F3"

ACTIVATE MSDIALOG oDlg ON INIT ;
         EnchoiceBar(oDlg,{||nOpca:=1,If(lValid .OR. EVAL(bValid),;
                             oDlg:End(),)},;
                          {||nOpca:=0,oDlg:End()}) CENTERED

If nOpca = 0
   Return .F.
Endif

cCod:=IF(EMPTY(cCod),"*Todos",cCod)
WorkFil->WKMARCA:=cMarca
WorkFil->(FIELDPUT(FIELDPOS(cCampoF3),cCod))

cFilAnt:=cSvFilAnt

Return .T.

*-----------------------*
Function TR350QBFIL(cAlias)    
*----------------------*
LOCAL I

cAlias:=aDados[1]     // PEGA O ALIAS NA ADADOS[1] - > "WORKA" OU "WORKB"  - RS 25/01/06

IF FilAtu == "*" 
   Linha++
   @ Linha,01 PSAY AVSX3("WB_FILIAL",5)+".: "+(cAlias)->WKFILIAL+'-'+AvgFilName({(cAlias)->WKFILIAL})[1]
   Linha++
   FilAtu:=(cAlias)->WKFILIAL
ENDIF   

if FilAtu#(cAlias)->WKFILIAL
	Linha++
	@Linha,T_Len[nPosVlrMoe,2] PSAY REPLICATE('-',T_Len[nPosVlrMoe,1])
	Linha+= 1
	
	@Linha,1 PSAY LEFT(STR0085,6)+".: " +IF(cAlias=="WORKA","",FilAtu+'-'+AvgFilName({FilAtu})[1])
	ASORT(aTotalFil,,,{|x,y| x[1] < y[1]})
	FOR I := 1 TO LEN(aTotalFil)
		IF Linha > 55
			Linha := Cabec(aDados[9],aDados[7],aDados[8],aDados[11],aDados[5],EasyGParam("MV_COMP"))
			Linha++
		ENDIF
		IF !lTPCONExt .or. (lTPCONExt .and. aTotalFil[I,2]>0)
			@Linha,T_Len[nPosVlrMoe,2] PSAY SUBST(aTotalFil[I,1],3)+" "+TRANS(aTotalFil[I,2],cPict)
		ENDIF
		Linha++
	Next
	@ Linha, 01 PSAY REPLICATE("=",80)
	
	Linha++
	@ Linha,01 PSAY AVSX3("WB_FILIAL",5)+".: "+(cAlias)->WKFILIAL+'-'+AvgFilName({(cAlias)->WKFILIAL})[1]
	Linha++
	
	FilAtu:=(cAlias)->WKFILIAL
	ASIZE(aTotalFil,0)
endif

IF .NOT. ((cAlias)->WKMOEDA $ cMoedaDolar)
	IF (nPos:=ASCAN(aTotalFil,{|A| A[1] ==(cAlias)->WKFILIAL+(cAlias)->WKMOEDA })) = 0
		AADD(aTotalFil,{(cAlias)->WKFILIAL+(cAlias)->WKMOEDA,(cAlias)->WKVL_MOE})
	ELSE
		aTotalFil[nPos,2]+=(cAlias)->WKVL_MOE
	ENDIF
ENDIF
IF (nPos:=ASCAN(aTotalFil,{|A| A[1] == (cAlias)->WKFILIAL+cMoedaDolar})) = 0
	AADD(aTotalFil,{(cAlias)->WKFILIAL+cMoedaDolar,(cAlias)->WKVL_USD})
ELSE
	aTotalFil[nPos,2]+=(cAlias)->WKVL_USD
ENDIF

RETURN .T.

/*
Funcao      : TR350BCO
Parametros  : cBco_R - Código do Banco
Retorno     : lRet
Objetivos   : Validação e carregamento dos campos referentes ao banco no relatório de fechamento de câmbio.
Autor       : Saimon Vinicius Gava - SVG -
Data/Hora   : 31/03/2010
Revisao     : 
Obs.        : 
*/
*--------------------------*
Static Function TR350BCO(cBco_R)
*--------------------------*
Local cSigla :="" ,lRet:=.T. 
SYA->(dbSetOrder(1))
If !Empty(cBco_R)
   If SA6->(dbSeek(xFilial("SA6")+AllTrim(cBco_R)))
      cBco_NR := SA6->A6_NREDUZ
      cBco_N  := SA6->A6_NOME
      cBco_C := SA6->A6_NUMCON
      cAge_R := SA6->A6_AGENCIA
      cSigla := If(SYA->(dbSeek(xFilial("SYA")+SA6->A6_COD_P)), SYA->YA_SIGLA,"")
      cLoc01 := AllTrim(SA6->A6_END) +". "+ AllTrim(SA6->A6_BAIRRO)+" - "+ AllTrim(SA6->A6_MUN)+" - "+ AllTrim(SA6->A6_EST)+" - "+ AllTrim(SA6->A6_UNIDFED) +;
      " "+ cSigla
      If Len(cLoc01) > 40
         cLoc02 := SubStr(cLoc01,41)
         cLoc01 := SubStr(cLoc01,1,40)
         If Len(cLoc02) > 40
            cLoc03 := SubStr(cLoc02,41)
            cLoc02 := SubStr(cLoc02,1,40)
         EndIf
      EndIf   
   Else
      MsgAlert(STR0129)
      lRet:= .F.
   EndIf
EndIf

Return lRet


/*
Funcao     : TR350legenda()
Parametros : 
Retorno    : 
Objetivos  : 
Autor      : Wilsimar Fabricio da Silva
Data/Hora  : Mai/2011
*/

Function TR350legenda()
Local aLegenda:= {}

   AAdd(aLegenda, {"BR_VERDE"   , STR0132})
   AAdd(aLegenda, {"BR_AMARELO" , STR0133})
   AAdd(aLegenda, {"BR_VERMELHO", STR0134})

   BrwLegenda(STR0008, "Legenda", aLegenda) //Follow-up Cambio

Return

//-------------------------------------------------------------------------------------*
//                         FIM DO PROGRAMA EICTR350.PRW
//-------------------------------------------------------------------------------------*
